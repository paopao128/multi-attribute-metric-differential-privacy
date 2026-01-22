function H = entropy_calc(X)
    % 计算离散变量的熵
    unique_vals = unique(X(~isnan(X)));
    p = zeros(size(unique_vals));
    
    for i = 1:length(unique_vals)
        p(i) = sum(X == unique_vals(i)) / length(X);
    end
    
    % 移除零概率
    p(p == 0) = [];
    
    % 计算熵
    H = -sum(p .* log2(p));
end