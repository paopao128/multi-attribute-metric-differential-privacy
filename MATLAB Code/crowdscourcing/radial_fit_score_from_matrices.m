function [Srad, nrmse, rmse, u_hat, r_sorted, u_sorted] = radial_fit_score_from_matrices(costMat, distMat, varargin)
%RADIAL_FIT_SCORE_FROM_MATRICES Compute S^rad using isotonic regression.
%
% Inputs:
%   costMat:  n×n matrix, u_{x,y}
%   distMat:  n×n matrix, r_{x,y}
%
% Optional name-value:
%   'IgnoreDiagonal' (default true) : remove i==j entries
%   'IgnoreZeroR'    (default false): remove entries with r==0
%   'Delta'          (default 1e-8) : small constant in denominator
%
% Outputs:
%   Srad = 1 - NRMSE^rad
%   nrmse, rmse: as defined
%   u_hat: fitted values aligned with (r_sorted,u_sorted)

p = inputParser;
p.addParameter('IgnoreDiagonal', true, @(x)islogical(x)&&isscalar(x));
p.addParameter('IgnoreZeroR', false, @(x)islogical(x)&&isscalar(x));
p.addParameter('Delta', 1e-8, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.parse(varargin{:});
ignoreDiag = p.Results.IgnoreDiagonal;
ignoreZeroR = p.Results.IgnoreZeroR;
delta = p.Results.Delta;

% Basic checks
assert(isequal(size(costMat), size(distMat)), 'costMat and distMat must have the same size.');

n = size(costMat,1);

% Vectorize
u = costMat(:);
r = distMat(:);

% Build mask for valid entries
mask = isfinite(u) & isfinite(r);

% Optionally remove diagonal entries (i==j)
if ignoreDiag
    diagMask = true(numel(u),1);
    I = reshape(1:n*n, n, n);
    diagMask(I(1:n+1:end)) = false;
    mask = mask & diagMask;
end

% Optionally remove r==0 entries
if ignoreZeroR
    mask = mask & (r ~= 0);
end

u = u(mask);
r = r(mask);

% Sort by r
[r_sorted, idx] = sort(r, 'ascend');
u_sorted = u(idx);

% --- Isotonic regression (nondecreasing) ---
% Preferred: lsqisotonic if available; otherwise use local PAV.
if exist('lsqisotonic', 'file') == 2
    u_hat = lsqisotonic(r_sorted, u_sorted);   % nondecreasing fit
else
    u_hat = pav_isotonic(u_sorted);            % assumes sorted by r already
end

% Metrics
rmse  = sqrt(mean((u_sorted - u_hat).^2));
nrmse = rmse / (std(u_sorted) + delta);
Srad  = 1 - nrmse;

end

function yhat = pav_isotonic(y)
%PAV_ISOTONIC Nondecreasing isotonic regression with squared loss.
% Input y is assumed ordered by increasing x (here: r_sorted).
n = numel(y);
yhat = y(:);
w = ones(n,1);

i = 1;
while i < n
    if yhat(i) <= yhat(i+1)
        i = i + 1;
    else
        % pool blocks i and i+1
        newy = (w(i)*yhat(i) + w(i+1)*yhat(i+1)) / (w(i)+w(i+1));
        yhat(i) = newy;
        w(i) = w(i) + w(i+1);
        % delete i+1
        yhat(i+1) = [];
        w(i+1) = [];
        n = n - 1;
        if i > 1
            i = i - 1;
        end
    end
end


yhat_full = [];
for k = 1:numel(yhat)
    yhat_full = [yhat_full; repmat(yhat(k), w(k), 1)]; 
end
yhat = yhat_full;
end