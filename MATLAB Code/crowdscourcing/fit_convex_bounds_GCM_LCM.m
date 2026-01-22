function [eps_sorted, y_sorted, u_lower, u_upper] = fit_convex_bounds_GCM_LCM(eps_vec, y_vec)
% 输入:  eps_vec, y_vec  (可乱序、可不等距)
% 输出:  u_lower = 最大凸下界 (greatest convex minorant)
%        u_upper = 最小凸上界 (least convex majorant)

    % 0) 预处理：排序、去重、去 NaN/Inf
    x = eps_vec(:); y = y_vec(:);
    good = isfinite(x) & isfinite(y);
    x = x(good); y = y(good);

    [x, idx] = sort(x); y = y(idx);
    % 合并重复 x（取均值；也可取中位数/最小值按需调整）
    [eps_sorted, ~, g] = unique(x);
    y_sorted = accumarray(g, y, [], @mean);

    n = numel(eps_sorted);
    if n <= 2
        % 0/1 段天然凸：GCM/LCM 都等于 y 本身
        u_lower = y_sorted;
        u_upper = y_sorted;
        return;
    end

    % 1) 凸性约束：相邻离散斜率非减 => Aconv * u <= 0
    dx = diff(eps_sorted);
    if any(dx <= 0), error('x 必须严格递增'); end
    Aconv = zeros(n-2, n);
    for i = 1:n-2
        Aconv(i, i)   = -1/dx(i);
        Aconv(i, i+1) =  1/dx(i) + 1/dx(i+1);
        Aconv(i, i+2) = -1/dx(i+1);
    end
    bconv = zeros(max(n-2,0),1);

    % 2) 最大凸下界：max sum(u) s.t. convex & u <= y
    %    => min -1'*u  s.t. [Aconv;  I] u <= [0; y]
    f_lower = -ones(n,1);
    A_lower = [Aconv; eye(n)];
    b_lower = [bconv; y_sorted];

    optsLP = optimoptions('linprog','Display','off','Algorithm','dual-simplex');
    u_lower = linprog(f_lower, A_lower, b_lower, [], [], [], [], optsLP);

    % 3) 最小凸上界：min sum(u) s.t. convex & u >= y
    %    => min 1'*u   s.t. [Aconv; -I] u <= [0; -y]
    f_upper =  ones(n,1);
    A_upper = [Aconv; -eye(n)];
    b_upper = [bconv; -y_sorted];

    u_upper = linprog(f_upper, A_upper, b_upper, [], [], [], [], optsLP);
end
