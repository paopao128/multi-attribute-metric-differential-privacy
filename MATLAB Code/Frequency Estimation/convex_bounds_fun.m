function [lower_fun, upper_fun, intervals, params] = convex_bounds_fun(eps_s, y_lower, y_upper, do_merge, slope_tol)
% 给定按升序排列的 eps_s 以及对应的凸下界/上界离散点 y_lower / y_upper，
% 返回两个连续的分段线性函数句柄 lower_fun(e)、upper_fun(e)，
% 并可选对相邻“斜率近似相等”的线段进行合并以简化分段数。
%
% 参数
%   eps_s   : n×1 升序向量
%   y_lower : n×1 下界取值
%   y_upper : n×1 上界取值
%   do_merge: 是否合并相邻近似同斜率的段（true/false）
%   slope_tol : 斜率合并容差（如 1e-8 或 1e-6）
%
% 输出
%   lower_fun(e) / upper_fun(e) : 分段线性、在区间外线性外推的函数句柄
%   intervals : 每段区间 [x_i, x_{i+1}]（合并后）
%   params    : 结构体，包含两套分段的斜率/截距等信息
%
% 注：分段线性插值保持凸性；外推使用端段斜率，仍保持凸与上下界方向。

    if nargin < 4 || isempty(do_merge),   do_merge  = true;   end
    if nargin < 5 || isempty(slope_tol),  slope_tol = 1e-8;   end

    x  = eps_s(:);
    yl = y_lower(:);
    yu = y_upper(:);

    % 基础斜率与截距
    mL = diff(yl)./diff(x);
    bL = yl(1:end-1) - mL.*x(1:end-1);

    mU = diff(yu)./diff(x);
    bU = yu(1:end-1) - mU.*x(1:end-1);

    % 可选：合并相邻“近似同斜率”的线段，减少分段数（不影响凸性）
    if do_merge && numel(mL) >= 2
        [xL, mL, bL] = merge_segments(x, mL, bL, slope_tol);
        [xU, mU, bU] = merge_segments(x, mU, bU, slope_tol);
    else
        xL = x; xU = x;
    end

    % 返回区间与参数
    intervals.lower = [xL(1:end-1) xL(2:end)];
    intervals.upper = [xU(1:end-1) xU(2:end)];

    params.lower.m = mL; params.lower.b = bL; params.lower.x = xL;
    params.upper.m = mU; params.upper.b = bU; params.upper.x = xU;

    % 构造函数句柄：区间内分段线性，区间外按端段线性外推
    lower_fun = @(e) piecewise_linear_eval(e, xL, mL, bL);
    upper_fun = @(e) piecewise_linear_eval(e, xU, mU, bU);
end

% ========= 工具：评估分段线性（支持向量 e），区间外线性外推 =========
function val = piecewise_linear_eval(e, x, m, b)
    e = e(:);
    nseg = numel(m);
    xl = x(1:end-1); xr = x(2:end);

    val = zeros(size(e));
    % 左外推
    idx = e <= xl(1);
    val(idx) = m(1).*e(idx) + (b(1));
    % 右外推
    idx = e >= xr(end);
    val(idx) = m(end).*e(idx) + (b(end));

    % 区间内
    idx_mid = ~(e <= xl(1) | e >= xr(end));
    if any(idx_mid)
        em = e(idx_mid);
        % 为每个 em 找到所在分段 i，使得 xl(i) <= em <= xr(i)
        % 使用histcounts快速定位
        [~, bin] = histc(em, [-inf; xr]); %#ok<HISTC>
        bin(bin<1) = 1;
        bin(bin>nseg) = nseg;
        val(idx_mid) = m(bin).*em + b(bin);
    end
end

% ========= 工具：合并相邻近似同斜率的线段 =========
function [x_new, m_new, b_new] = merge_segments(x, m, b, tol)
    xl = x(1:end-1); xr = x(2:end);
    % 初始分段
    xL = xl; xR = xr; M = m; B = b;

    i = 1;
    while i < numel(M)
        if abs(M(i+1) - M(i)) <= tol
            % 合并 i 与 i+1 段：新段起点 xL(i)，终点 xR(i+1)
            xL(i+1) = []; %#ok<AGROW>
            xR(i)   = xR(i+1); xR(i+1) = []; %#ok<AGROW>
            % 以两端点拟合一条线（保证连续）
            xi1 = xL(i); xi2 = xR(i);
            % 用原函数在端点的值：y = m*x + b
            yi1 = M(i)*xi1 + B(i);          % 左段左端值
            yi2 = M(i+1)*xi2 + B(i+1);      % 右段右端值
            M(i) = (yi2 - yi1)/(xi2 - xi1);
            B(i) = yi1 - M(i)*xi1;
            % 删除 i+1
            M(i+1) = []; B(i+1) = [];
        else
            i = i + 1;
        end
    end

    % 输出
    x_new = [xL; xR(end)];
    m_new = M;
    b_new = B;
end

