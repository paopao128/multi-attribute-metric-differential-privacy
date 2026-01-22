%% === 可视化与拟合 z = f(x, y) ===
% 假设以下变量已经存在：
% attribute_x_value (49x1 向量)
% attribute_y_value (4x1 向量)
% change_matrix1_2 (49x4 矩阵)


% ========== 1. 构造网格 ==========
[X, Y] = meshgrid(attribute_y_value, attribute_x_value);
Z = change_matrix1_2;

% ========== 2. 原始数据三维曲面 ==========
figure;
surf(X, Y, Z);
title('Original Surface of change\_matrix1\_2');
xlabel('Y value');
ylabel('X value');
zlabel('Z value');
shading interp; colorbar; colormap jet;
view(45,30);

% ========== 3. 拟合准备 ==========
x_data = X(:);
y_data = Y(:);
z_data = Z(:);

% ========== 4. 二元多项式拟合 ==========
% poly23 表示二次多项式（含交叉项），可改为 'poly22', 'poly33' 等
fit_model = fit([x_data, y_data], z_data, 'poly23');
disp(fit_model);

% ========== 5. 拟合结果可视化 ==========
figure;
plot(fit_model, [x_data, y_data], z_data);
title('Fitted Surface (z ~ f(x, y))');
xlabel('Y value');
ylabel('X value');
zlabel('Z value');
grid on; view(45,30);

% ========== 6. 计算相关性 ==========
corr_xz = corr(x_data, z_data);
corr_yz = corr(y_data, z_data);
fprintf('Correlation(x, z) = %.4f\n', corr_xz);
fprintf('Correlation(y, z) = %.4f\n', corr_yz);

% ========== 7. 计算拟合优度 R² ==========
z_pred = feval(fit_model, [x_data, y_data]);
SS_res = sum((z_data - z_pred).^2);
SS_tot = sum((z_data - mean(z_data)).^2);
R2 = 1 - SS_res / SS_tot;
fprintf('R^2 (Goodness of Fit) = %.4f\n', R2);

% ========== 8. 在图上标注 R² ==========
text(min(y_data), max(x_data), max(z_data), ...
     sprintf('R^2 = %.4f', R2), 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');
