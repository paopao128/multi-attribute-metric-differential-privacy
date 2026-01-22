%% 主分析函数 - 综合独立性分析
function NMI = independence_analysis(X, Y)
    % 确保是列向量
    X = X(:);
    Y = Y(:);
    
    fprintf('=====================================\n');
    fprintf('    变量独立性与相关性综合分析\n');
    fprintf('=====================================\n\n');
    
    %% 1. 皮尔逊相关系数（线性相关）
    [R, P] = corrcoef(X, Y);
    rho_pearson = R(1,2);
    p_pearson = P(1,2);
    
    fprintf('1. 皮尔逊相关系数:\n');
    fprintf('   相关系数 r = %.4f\n', rho_pearson);
    fprintf('   p值 = %.4f\n', p_pearson);
    fprintf('   解释: ');
    if abs(rho_pearson) < 0.3
        fprintf('弱线性相关\n');
    elseif abs(rho_pearson) < 0.7
        fprintf('中等线性相关\n');
    else
        fprintf('强线性相关\n');
    end
    fprintf('\n');
    
    %% 2. 斯皮尔曼秩相关系数（非线性单调相关）
    [rho_spearman, p_spearman] = corr(X, Y, 'Type', 'Spearman');
    
    fprintf('2. 斯皮尔曼秩相关系数:\n');
    fprintf('   相关系数 ρ = %.4f\n', rho_spearman);
    fprintf('   p值 = %.4f\n', p_spearman);
    fprintf('\n');
    
    %% 3. 肯德尔秩相关系数
    [rho_kendall, p_kendall] = corr(X, Y, 'Type', 'Kendall');
    
    fprintf('3. 肯德尔秩相关系数:\n');
    fprintf('   相关系数 τ = %.4f\n', rho_kendall);
    fprintf('   p值 = %.4f\n', p_kendall);
    fprintf('\n');
    
    %% 4. 互信息（非线性相关）
    nbins = min(20, round(sqrt(length(X))));  % 自适应分箱数
    X_discrete = discretize(X, nbins);
    Y_discrete = discretize(Y, nbins);
    
    MI = mutual_information(X_discrete, Y_discrete);
    H_X = entropy_calc(X_discrete);
    H_Y = entropy_calc(Y_discrete);
    NMI = 2 * MI / (H_X + H_Y);  % 归一化互信息 [0,1]
    
    fprintf('4. 互信息分析:\n');
    fprintf('   互信息 MI = %.4f\n', MI);
    fprintf('   归一化互信息 NMI = %.4f\n', NMI);
    fprintf('   解释: ');
    if NMI < 0.1
        fprintf('几乎独立\n');
    elseif NMI < 0.3
        fprintf('弱依赖关系\n');
    elseif NMI < 0.5
        fprintf('中等依赖关系\n');
    else
        fprintf('强依赖关系\n');
    end
    fprintf('\n');
    
    %% 5. 距离相关系数
    dcor = distance_correlation(X, Y);
    
    fprintf('5. 距离相关系数:\n');
    fprintf('   dCor = %.4f\n', dcor);
    fprintf('   解释: ');
    if dcor < 0.1
        fprintf('几乎独立\n');
    elseif dcor < 0.3
        fprintf('弱依赖关系\n');
    elseif dcor < 0.5
        fprintf('中等依赖关系\n');
    else
        fprintf('强依赖关系\n');
    end
    fprintf('\n');
    
    %% 6. 卡方独立性检验（针对离散化数据）
    [tbl, chi2, p_chi2] = crosstab(X_discrete, Y_discrete);
    
    fprintf('6. 卡方独立性检验:\n');
    fprintf('   χ²统计量 = %.4f\n', chi2);
    fprintf('   p值 = %.4f\n', p_chi2);
    fprintf('   解释: ');
    if p_chi2 > 0.05
        fprintf('在0.05显著性水平下，变量可能独立\n');
    else
        fprintf('在0.05显著性水平下，变量不独立\n');
    end
    fprintf('\n');
    
    %% 7. 综合判断
    fprintf('=====================================\n');
    fprintf('           综合结论\n');
    fprintf('=====================================\n');
    
    % 计算独立性得分（0-1，越接近1越独立）
    independence_score = 0;
    count = 0;
    
    if p_pearson > 0.05
        independence_score = independence_score + 1;
    end
    count = count + 1;
    
    if p_spearman > 0.05
        independence_score = independence_score + 1;
    end
    count = count + 1;
    
    if p_kendall > 0.05
        independence_score = independence_score + 1;
    end
    count = count + 1;
    
    if NMI < 0.1
        independence_score = independence_score + 1;
    elseif NMI < 0.3
        independence_score = independence_score + 0.5;
    end
    count = count + 1;
    
    if dcor < 0.1
        independence_score = independence_score + 1;
    elseif dcor < 0.3
        independence_score = independence_score + 0.5;
    end
    count = count + 1;
    
    if p_chi2 > 0.05
        independence_score = independence_score + 1;
    end
    count = count + 1;
    
    independence_score = independence_score / count;
    
    fprintf('独立性综合得分: %.2f/1.00\n', independence_score);
    fprintf('最终判断: ');
    if independence_score > 0.8
        fprintf('变量很可能是独立的\n');
    elseif independence_score > 0.6
        fprintf('变量可能是独立的（存在弱相关）\n');
    elseif independence_score > 0.4
        fprintf('变量存在中等程度的相关性\n');
    else
        fprintf('变量存在较强的相关性，不是独立的\n');
    end
    
    % %% 8. 可视化
    % figure('Name', '独立性分析可视化', 'Position', [100, 100, 1200, 800]);
    % 
    % % 散点图和回归线
    % subplot(2,3,1)
    % scatter(X, Y, 30, 'filled', 'MarkerFaceAlpha', 0.6);
    % hold on;
    % p = polyfit(X, Y, 1);
    % x_fit = linspace(min(X), max(X), 100);
    % plot(x_fit, polyval(p, x_fit), 'r-', 'LineWidth', 2);
    % xlabel('X'); ylabel('Y');
    % title(sprintf('散点图 (Pearson r=%.3f)', rho_pearson));
    % grid on;
    % 
    % % 联合分布热图
    % subplot(2,3,2)
    % histogram2(X, Y, nbins, 'DisplayStyle', 'tile', 'ShowEmptyBins', 'on');
    % colorbar;
    % xlabel('X'); ylabel('Y');
    % title('联合分布热图');
    % 
    % % 边缘分布
    % subplot(2,3,3)
    % yyaxis left
    % histogram(X, 20, 'FaceAlpha', 0.5);
    % ylabel('X的频数');
    % yyaxis right
    % histogram(Y, 20, 'FaceAlpha', 0.5);
    % ylabel('Y的频数');
    % xlabel('值');
    % title('边缘分布');
    % legend('X', 'Y');
    % 
    % % QQ图检查正态性
    % subplot(2,3,4)
    % qqplot(X);
    % title('X的QQ图');
    % 
    % subplot(2,3,5)
    % qqplot(Y);
    % title('Y的QQ图');
    % 
    % % 相关性度量条形图
    % subplot(2,3,6)
    % measures = [abs(rho_pearson), abs(rho_spearman), abs(rho_kendall), NMI, dcor];
    % names = {'Pearson', 'Spearman', 'Kendall', 'NMI', 'dCor'};
    % bar(measures);
    % set(gca, 'XTickLabel', names);
    % ylabel('相关性度量值');
    % title('各种相关性度量比较');
    % ylim([0, 1]);
    % grid on;
    % 
    % % 添加参考线
    % hold on;
    % plot(get(gca, 'XLim'), [0.3, 0.3], 'r--', 'LineWidth', 1);
    % text(5.5, 0.3, '弱相关阈值', 'Color', 'red');
end

%% 辅助函数1：计算互信息
function MI = mutual_information(X, Y)
    % 构建联合频率表
    unique_x = unique(X(~isnan(X)));
    unique_y = unique(Y(~isnan(Y)));
    
    joint_hist = zeros(length(unique_x), length(unique_y));
    for i = 1:length(unique_x)
        for j = 1:length(unique_y)
            joint_hist(i,j) = sum(X == unique_x(i) & Y == unique_y(j));
        end
    end
    
    % 转换为概率
    joint_prob = joint_hist / sum(joint_hist(:));
    
    % 边缘概率
    px = sum(joint_prob, 2);
    py = sum(joint_prob, 1);
    
    % 计算互信息
    MI = 0;
    for i = 1:length(px)
        for j = 1:length(py)
            if joint_prob(i,j) > 0 && px(i) > 0 && py(j) > 0
                MI = MI + joint_prob(i,j) * log2(joint_prob(i,j) / (px(i) * py(j)));
            end
        end
    end
end

%% 辅助函数2：计算熵
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

%% 辅助函数3：计算距离相关系数
function dcor = distance_correlation(X, Y)
    n = length(X);
    
    % 计算距离矩阵
    Dx = pdist2(X, X);
    Dy = pdist2(Y, Y);
    
    % 双中心化
    Dx_centered = double_center(Dx);
    Dy_centered = double_center(Dy);
    
    % 计算距离协方差和方差
    dCov_xy = sqrt(mean(Dx_centered(:) .* Dy_centered(:)));
    dVar_x = sqrt(mean(Dx_centered(:).^2));
    dVar_y = sqrt(mean(Dy_centered(:).^2));
    
    % 计算距离相关系数
    if dVar_x * dVar_y > 0
        dcor = dCov_xy / sqrt(dVar_x * dVar_y);
    else
        dcor = 0;
    end
end

%% 辅助函数4：双中心化
function A_centered = double_center(A)
    n = size(A, 1);
    
    % 计算行均值、列均值和总均值
    row_means = mean(A, 2);
    col_means = mean(A, 1);
    grand_mean = mean(A(:));
    
    % 双中心化
    A_centered = A - repmat(row_means, 1, n) - repmat(col_means, n, 1) + grand_mean;
end

%% 使用示例
% 生成测试数据
% n = 100;
% X = randn(n, 1);
% Y = randn(n, 1);  % 独立
% % Y = 2*X + 0.5*randn(n, 1);  % 线性相关
% % Y = X.^2 + 0.5*randn(n, 1);  % 非线性相关
% 
% % 运行分析
% independence_analysis(X, Y);
