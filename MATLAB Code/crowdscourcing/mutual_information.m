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