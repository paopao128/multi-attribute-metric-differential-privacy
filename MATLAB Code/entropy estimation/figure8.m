load("result\result-1\cost_attribute.mat")
load("result\result-1\distance_all_attributes.mat")
num_groups = length(cost_attribute);

mean_ratio = nan(1, num_groups);
err_ratio  = nan(1, num_groups);

for g = 1:num_groups
    C = cost_attribute{g};
    D = distance_all_attributes{g};

    if isvector(C) && numel(C) == numel(D)
        C = reshape(C, size(D));
    end

    if ~isequal(size(C), size(D))
        warning('Group %d: cost and distance size not matched.', g);
        continue;
    end

    % 去掉距离为 0 或极小的项
    valid_idx = D > 1e-6;

    ratio_values = C(valid_idx) ./ D(valid_idx);
    ratio_values = ratio_values(isfinite(ratio_values));

    mean_ratio(g) = mean(ratio_values);

    % 用 standard error，而不是 std
    err_ratio(g) = std(ratio_values) / sqrt(length(ratio_values));
end

figure;

bar(1:num_groups, mean_ratio, ...
    'FaceColor', [0.65 0.82 0.92], ...
    'EdgeColor', 'k', ...
    'LineWidth', 0.8);

hold on;

errorbar(1:num_groups, mean_ratio, err_ratio, ...
    'r', ...
    'LineStyle', 'none', ...
    'LineWidth', 0.8, ...
    'CapSize', 6);

xlabel('Group index', 'FontSize', 30);
ylabel('Utility loss to distance ratio', 'FontSize', 30);
set(gca, 'FontSize', 30);

xlim([0, num_groups + 1]);

% 根据你的目标图手动限制 y 轴
ylim([0, max(mean_ratio + err_ratio) * 1.2]);

grid on;
box on;
