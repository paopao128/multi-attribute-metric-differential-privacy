function [Smse, nrmse, rmse, u_hat, r_sorted, u_sorted, a_hat, b_hat] = mse_likeness_score_from_matrices(costMat, distMat, varargin)
%MSE_LIKENESS_SCORE_FROM_MATRICES Compute S^mse via quadratic fit u ≈ a*r^2 + b.
%
% Inputs:
%   costMat:  n×n matrix, u_{x,y}
%   distMat:  n×n matrix, r_{x,y}
%
% Optional name-value:
%   'IgnoreDiagonal' (default true) : remove i==j entries
%   'IgnoreZeroR'    (default false): remove entries with r==0
%   'Delta'          (default 1e-8) : small constant in denominator
%   'EnforcePositiveA' (default true): project a to be > 0
%   'MinA'             (default 1e-12): minimum a if enforcing positivity
%
% Outputs:
%   Smse = 1 - NRMSE^mse
%   nrmse, rmse: as defined
%   u_hat: fitted values aligned with (r_sorted,u_sorted)
%   r_sorted, u_sorted: sorted samples used for fitting
%   a_hat, b_hat: fitted parameters in u ≈ a*r^2 + b

p = inputParser;
p.addParameter('IgnoreDiagonal', true, @(x)islogical(x)&&isscalar(x));
p.addParameter('IgnoreZeroR', false, @(x)islogical(x)&&isscalar(x));
p.addParameter('Delta', 1e-8, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.addParameter('EnforcePositiveA', true, @(x)islogical(x)&&isscalar(x));
p.addParameter('MinA', 1e-12, @(x)isnumeric(x)&&isscalar(x)&&x>0);
p.parse(varargin{:});
ignoreDiag = p.Results.IgnoreDiagonal;
ignoreZeroR = p.Results.IgnoreZeroR;
delta = p.Results.Delta;
enforcePosA = p.Results.EnforcePositiveA;
minA = p.Results.MinA;

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

% Sort by r (for consistent outputs/plotting; not required for LS)
[r_sorted, idx] = sort(r, 'ascend');
u_sorted = u(idx);

% --- Quadratic fit u ≈ a*r^2 + b ---
x = r_sorted.^2;
X = [x, ones(size(x))];   % [r^2, 1]

% Unconstrained least squares
theta = X \ u_sorted;     % [a; b]
a_hat = theta(1);
b_hat = theta(2);

% Enforce a > 0 if requested (projection)
if enforcePosA
    if a_hat < minA
        a_hat = minA;
        % Re-fit b with fixed a (optimal b is mean(u - a*x))
        b_hat = mean(u_sorted - a_hat * x);
    end
end

u_hat = a_hat * x + b_hat;

% Metrics
rmse  = sqrt(mean((u_sorted - u_hat).^2));
nrmse = rmse / (std(u_sorted) + delta);
Smse  = 1 - nrmse;

end
