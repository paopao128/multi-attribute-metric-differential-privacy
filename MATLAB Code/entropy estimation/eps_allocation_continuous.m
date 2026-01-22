function R = eps_allocation_continuous(eps_budget, loss_eval, lb_eps, ub_eps, opts)
    if nargin < 5, opts = struct(); end
    if ~isfield(opts,'max_iter_bisect'), opts.max_iter_bisect = 60; end
    if ~isfield(opts,'tol_budget_sq'),  opts.tol_budget_sq  = max(1e-10,1e-10*eps_budget^2); end

    n = numel(loss_eval);

    if nargin < 3 || isempty(lb_eps), lb_eps = zeros(1,n); end
    if nargin < 4 || isempty(ub_eps), error('require upper bound of every variable ub_eps'); end
    lb = cellfun(@(x) x, num2cell(lb_eps(:) + zeros(n,1)), 'uni', 0);
    ub = cellfun(@(x) x, num2cell(ub_eps(:) + zeros(n,1)), 'uni', 0);

    target = eps_budget^2;


    lambda_lo = 0; lambda_hi = 1;
    for grow = 1:40
        sumsq_hi = sumsq_given_lambda(lambda_hi, loss_eval, lb, ub);
        if sumsq_hi <= max(1e-16, 1e-6*target), break; end
        lambda_hi = lambda_hi * 10;
    end

    best = struct('gap',inf,'lambda',NaN,'eps',[],'sumL',Inf,'sumsq',Inf);
    for it = 1:opts.max_iter_bisect
        lambda_mid = 0.5*(lambda_lo + lambda_hi);
        [eps_mid, sumL_mid, sumsq_mid] = pick_given_lambda(lambda_mid, loss_eval, lb, ub);
        gap = abs(sumsq_mid - target);
        if gap < best.gap
            best.gap   = gap;
            best.lambda= lambda_mid;
            best.eps   = eps_mid;
            best.sumL  = sumL_mid;
            best.sumsq = sumsq_mid;
        end
        if sumsq_mid > target + opts.tol_budget_sq
            lambda_lo = lambda_mid;  % Exceeds budget → increase lambda
        else
            lambda_hi = lambda_mid;  % Does not exceed budget → decrease lambda (use more budget)
        end
        if abs(lambda_hi - lambda_lo) <= max(1e-16, 1e-12*(1+best.lambda)), break; end
    end

    R.lambda_star   = best.lambda;
    R.eps_cont      = best.eps(:);
    R.loss_cont_sum = best.sumL;
    R.sum_eps_sq    = best.sumsq;
    R.status = sprintf('sum(eps^2)=%.6g (target=%.6g)', best.sumsq, target);
end


function [eps_pick, sumL, sumsq] = pick_given_lambda(lambda, loss_eval, lb, ub)
    n = numel(loss_eval);
    eps_pick = zeros(n,1); sumL = 0; sumsq = 0;
    opt = optimset('TolX',1e-9,'Display','off');
    for i = 1:n
        li = lb{i}; ui = ub{i};
        if ui <= li
            ei = li;
            Li = loss_eval{i}(ei);
        else
            obj = @(e) loss_eval{i}(e) + lambda*(e.^2);
            [ei, v] = fminbnd(obj, li, ui, opt);
            Li = v - lambda*(ei^2); 
        end
        eps_pick(i) = ei;
        sumL = sumL + Li;
        sumsq = sumsq + ei^2;
    end
end

function sumsq = sumsq_given_lambda(lambda, loss_eval, lb, ub)
    n = numel(loss_eval);
    sumsq = 0; opt = optimset('TolX',1e-6,'Display','off');
    for i = 1:n
        li = lb{i}; ui = ub{i};
        if ui <= li
            ei = li;
        else
            obj = @(e) loss_eval{i}(e) + lambda*(e.^2);
            ei = fminbnd(obj, li, ui, opt);
        end
        sumsq = sumsq + ei^2;
    end
end

