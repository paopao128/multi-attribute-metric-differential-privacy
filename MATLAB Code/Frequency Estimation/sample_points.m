script_dir = fileparts(mfilename('fullpath'));
result_dir = fullfile(script_dir, 'result', 'result-1');
data_file = fullfile(result_dir, 'data.mat');

load(fullfile(result_dir, 'cost_attribute.mat'))
load(data_file)
load(fullfile(result_dir, 'ref.mat'))
load(fullfile(result_dir, 'u_clean.mat'))
load(fullfile(result_dir, 'attr_cols.mat'))
data=X;

attribute_set=cell(1,6);
attribute_set{1,1}=[1,4,9,11,13,15];  
attribute_set{1,2}=[2];                
attribute_set{1,3}=[3,8,10,12,14];   
attribute_set{1,4}=[5];               
attribute_set{1,5}=[6];                
attribute_set{1,6}=[7];

[uniqueVals1, ~, value_idx1] = unique(data(:,attribute_set{1,1}), 'rows');
[uniqueVals2, ~, value_idx2] = unique(data(:,attribute_set{1,2}), 'rows');
[uniqueVals3, ~, value_idx3] = unique(data(:,attribute_set{1,3}), 'rows');
[uniqueVals4, ~, value_idx4] = unique(data(:,attribute_set{1,4}), 'rows');
[uniqueVals5, ~, value_idx5] = unique(data(:,attribute_set{1,5}), 'rows');
[uniqueVals6, ~, value_idx6] = unique(data(:,attribute_set{1,6}), 'rows');


num_sample=1000;
loss_set1=zeros(num_sample,1);
loss_set2=zeros(num_sample,1);
loss_set3=zeros(num_sample,1);
loss_set4=zeros(num_sample,1);
loss_set5=zeros(num_sample,1);
loss_set6=zeros(num_sample,1);
loss_set_all=zeros(num_sample,1);

for sample_id=1:num_sample
    % set1
    load(data_file);
    data=X;
    obf_i_1=randi(length(uniqueVals1));
    obf_j_1=randi(length(uniqueVals1));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,1}), uniqueVals1(obf_i_1,:))
            data(i,attribute_set{1,1})=uniqueVals1(obf_j_1,:);
        end
    end


    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set1(sample_id,1)=(u_clean - u_obfuscated) * 100000;

    % set2
    load(data_file);
    data=X;
    obf_i_2=randi(length(uniqueVals2));
    obf_j_2=randi(length(uniqueVals2));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,2}), uniqueVals2(obf_i_2,:))
            data(i,attribute_set{1,2})=uniqueVals2(obf_j_2,:);
        end
    end

    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set2(sample_id,1)=(u_clean - u_obfuscated) * 100000;

    % set3
    load(data_file);
    data=X;
    obf_i_3=randi(length(uniqueVals3));
    obf_j_3=randi(length(uniqueVals3));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,3}), uniqueVals3(obf_i_3,:))
            data(i,attribute_set{1,3})=uniqueVals3(obf_j_3,:);
        end
    end

    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set3(sample_id,1)=(u_clean - u_obfuscated) * 100000;

    % set4
    load(data_file);
    data=X;
    obf_i_4=randi(length(uniqueVals4));
    obf_j_4=randi(length(uniqueVals4));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,4}), uniqueVals4(obf_i_4,:))
            data(i,attribute_set{1,4})=uniqueVals4(obf_j_4,:);
        end
    end
    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set4(sample_id,1)=(u_clean - u_obfuscated) * 100000;

    % set5
    load(data_file);
    data=X;
    obf_i_5=randi(length(uniqueVals5));
    obf_j_5=randi(length(uniqueVals5));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,5}), uniqueVals5(obf_i_5,:))
            data(i,attribute_set{1,5})=uniqueVals5(obf_j_5,:);
        end
    end
    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set5(sample_id,1)=(u_clean - u_obfuscated) * 100000;

    % set6
    load(data_file);
    data=X;
    obf_i_6=randi(length(uniqueVals6));
    obf_j_6=randi(length(uniqueVals6));
    for i=1:length(data)
        if isequal(data(i,attribute_set{1,6}), uniqueVals6(obf_i_6,:))
            data(i,attribute_set{1,6})=uniqueVals6(obf_j_6,:);
        end
    end
    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set6(sample_id,1)=(u_clean - u_obfuscated) * 100000;
    

    % all
    load(data_file);
    data=X;

    for i=1:length(data)
        if isequal(data(i,attribute_set{1,1}), uniqueVals1(obf_i_1,:))
            data(i,attribute_set{1,1})=uniqueVals1(obf_j_1,:);
        end
    end


    for i=1:length(data)
        if isequal(data(i,attribute_set{1,2}), uniqueVals2(obf_i_2,:))
            data(i,attribute_set{1,2})=uniqueVals2(obf_j_2,:);
        end
    end


    for i=1:length(data)
        if isequal(data(i,attribute_set{1,3}), uniqueVals3(obf_i_3,:))
            data(i,attribute_set{1,3})=uniqueVals3(obf_j_3,:);
        end
    end


    for i=1:length(data)
        if isequal(data(i,attribute_set{1,4}), uniqueVals4(obf_i_4,:))
            data(i,attribute_set{1,4})=uniqueVals4(obf_j_4,:);
        end
    end

    for i=1:length(data)
        if isequal(data(i,attribute_set{1,5}), uniqueVals5(obf_i_5,:))
            data(i,attribute_set{1,5})=uniqueVals5(obf_j_5,:);
        end
    end

    for i=1:length(data)
        if isequal(data(i,attribute_set{1,6}), uniqueVals6(obf_i_6,:))
            data(i,attribute_set{1,6})=uniqueVals6(obf_j_6,:);
        end
    end
    u_obfuscated = global_utility_marginal_numerical(data, attr_cols, ref);
    loss_set_all(sample_id,1)=(u_clean - u_obfuscated) * 100000;

end



%% ====== z ~ x1..x6：多自变量回归与相关性/诊断 一站式脚本 ======
% 需要你已在工作区提供以下向量（列/行均可，会自动转列）：
%   z, x1, x2, x3, x4, x5, x6  （全部长度相同，记为 N）

x1=loss_set1;
x2=loss_set2;
x3=loss_set3;
x4=loss_set4;
x5=loss_set5;
x6=loss_set6;

z=loss_set_all;
clc; close all;

% -------- 0) 将所有变量整理为列向量并做一致性检查 --------
vars = {'z','x1','x2','x3','x4','x5','x6'};
for k = 1:numel(vars)
    assert(exist(vars{k},'var')==1, sprintf('变量 "%s" 不存在，请先在工作区定义。', vars{k}));
    v = eval(vars{k});
    v = v(:);              % 强制列向量
    assignin('base', vars{k}, v);
end
N = numel(z);
for k = 2:numel(vars)
    if numel(eval(vars{k})) ~= N
        error('长度不一致：z 是 %d，%s 是 %d。请检查数据。', N, vars{k}, numel(eval(vars{k})));
    end
end

% -------- 1) 组装表格/设计矩阵 --------
X = [x1 x2 x3 x4 x5 x6];  % N x 6
varNames = compose('x%d',1:6);
T = array2table(X, 'VariableNames', varNames);
T.z = z;

% -------- 2) 简单相关性（皮尔逊） --------
C = corr(X, z, 'Rows','complete');  % 6x1，与 z 的相关
corr_tbl = table(varNames', C, 'VariableNames', {'Variable','CorrWithZ'});
disp('=== Pearson correlation with z ===');
disp(corr_tbl);

% 可选：自变量间相关性热图（查看共线性倾向）
% R = corr(X, 'Rows','pairwise');
% figure; heatmap(R, 'XDisplayLabels', varNames, 'YDisplayLabels', varNames);
% title('Predictor Correlation Heatmap');

% -------- 3) 线性模型（仅一次项） --------
mdl_lin = fitlm(T, 'z ~ x1 + x2 + x3 + x4 + x5 + x6');
disp('=== Linear Model (main effects) ===');
disp(mdl_lin);
fprintf('[Linear] R^2 = %.4f, Adjusted R^2 = %.4f, RMSE = %.4f\n', ...
    mdl_lin.Rsquared.Ordinary, mdl_lin.Rsquared.Adjusted, mdl_lin.RMSE);

% 打印显式方程（便于阅读/报告）
coefTable = mdl_lin.Coefficients;
intercept = coefTable.Estimate(1);
fprintf('z = %.6g', intercept);
for i = 1:6
    b = coefTable.Estimate(i+1);
    if b>=0, fprintf(' + %.6g*%s', b, varNames{i});
    else,    fprintf(' - %.6g*%s', -b, varNames{i});
    end
end
fprintf('\n\n');

% -------- 4) 纯二次模型（一次项 + 每个变量的平方，不含两两交互） --------
% mdl_pq = fitlm(T, 'purequadratic'); % 对 x1..x6 全部加入平方项
mdl_pq = fitlm(T, 'quadratic');
disp('=== Pure Quadratic Model ===');
fprintf('[PureQuadratic] R^2 = %.4f, Adjusted R^2 = %.4f, RMSE = %.4f\n', ...
    mdl_pq.Rsquared.Ordinary, mdl_pq.Rsquared.Adjusted, mdl_pq.RMSE);

% 若样本量允许并需要交互项，可改为：
% mdl_int = fitlm(T, 'interactions');   % 一次项 + 两两交互（无平方）
% mdl_qd  = fitlm(T, 'quadratic');      % 一次 + 平方 + 两两交互（项数更多）

% -------- 5) LASSO（带特征选择/正则化） --------
[B, FitInfo] = lasso(X, z, 'CV', 10, 'Standardize', true);
idxBest = FitInfo.IndexMinMSE;
B_best  = B(:, idxBest);
b0      = FitInfo.Intercept(idxBest);
fprintf('=== LASSO (10-fold CV, min MSE) ===\n');
fprintf('非零系数个数: %d / %d\n', nnz(B_best), numel(B_best));
sel = find(B_best~=0);
if ~isempty(sel)
    fprintf('选中变量: %s\n', strjoin(varNames(sel), ', '));
end
z_pred_lasso = X*B_best + b0;
SS_res = sum((z - z_pred_lasso).^2);
SS_tot = sum((z - mean(z)).^2);
R2_lasso = 1 - SS_res/SS_tot;
RMSE_lasso = sqrt(mean((z - z_pred_lasso).^2));
fprintf('[LASSO] R^2 = %.4f, RMSE = %.4f\n\n', R2_lasso, RMSE_lasso);

% % -------- 6) 树模型（非线性 & 交互，给出重要性 + PDP） --------
% mdl_tree = fitrensemble(X, z, 'Method','LSBoost', ...
%                         'NumLearningCycles',300, 'Learners','tree');
% z_pred_tree = predict(mdl_tree, X);
% R2_tree = 1 - sum((z - z_pred_tree).^2)/SS_tot;
% RMSE_tree = sqrt(mean((z - z_pred_tree).^2));
% fprintf('=== Ensemble Trees ===\n');
% fprintf('[Trees] R^2 = %.4f, RMSE = %.4f\n', R2_tree, RMSE_tree);
% 
% imp = predictorImportance(mdl_tree);
% [impSorted, ord] = sort(imp, 'descend');
% fprintf('[Trees] 重要性 Top-3: %s\n\n', strjoin(varNames(ord(1:min(3,6))), ', '));
% 
% % 部分依赖图（看一个或两个变量对 z 的边际影响）
% figure; plotPartialDependence(mdl_tree, ord(1), 1:size(X,2));
% title(sprintf('Partial Dependence of %s', varNames{ord(1)}));
% if numel(ord) >= 2
%     figure; plotPartialDependence(mdl_tree, [ord(1) ord(2)], 1:size(X,2));
%     title(sprintf('PDP of (%s, %s)', varNames{ord(1)}, varNames{ord(2)}));
% end
% 
% % -------- 7) 多重共线性：VIF（>10 常被视为严重） --------
% VIF = zeros(6,1);
% for j = 1:4
%     Xj   = X(:, j);
%     Xnot = X(:, setdiff(1:6, j));
%     mdlj = fitlm(Xnot, Xj); % 用其他变量去回归 Xj
%     R2j  = mdlj.Rsquared.Ordinary;
%     VIF(j) = 1 / max(1 - R2j, eps);
% end
% vif_tbl = table(varNames', VIF, 'VariableNames', {'Variable','VIF'});
% disp('=== VIF (Variance Inflation Factor) ===');
% disp(vif_tbl);
% 
% % -------- 8) 残差诊断（线性模型） --------
% figure; plotResiduals(mdl_lin, 'fitted'); title('Linear Model Residuals vs Fitted');
% figure; plotDiagnostics(mdl_lin, 'cookd'); title('Linear Model Cook''s Distance');
% 
% % -------- 9) 简单泛化验证：随机 80/20 切分 --------
% cv = cvpartition(N, 'HoldOut', 0.2);
% idxTr = training(cv); idxTe = test(cv);
% mdl_tr = fitlm(X(idxTr,:), z(idxTr));               % 线性模型做示例
% z_te   = z(idxTe);
% z_hat  = predict(mdl_tr, X(idxTe,:));
% RMSE_te = sqrt(mean((z_te - z_hat).^2));
% R2_te   = 1 - sum((z_te - z_hat).^2) / sum((z_te - mean(z_te)).^2);
% fprintf('=== 80/20 Hold-out (Linear) ===\n');
% fprintf('[Test] R^2 = %.4f, RMSE = %.4f\n', R2_te, RMSE_te);



% %% ===== 打印线性模型 z ~ x1..x6 =====
% coef = mdl_lin.Coefficients;
% b = coef.Estimate;              % [b0; b1..b6]
% names = coef.Properties.RowNames;
% 
% % 可读公式
% fprintf('--- Linear model: z = b0 + sum(bi*xi) ---\n');
% fprintf('z = %.6g', b(1));
% for i = 1:6
%     if b(i+1) >= 0
%         fprintf(' + %.6g*x%d', b(i+1), i);
%     else
%         fprintf(' - %.6g*x%d', -b(i+1), i);
%     end
% end
% fprintf('\n');
% 
% % LaTeX 版
% latex_str = sprintf('z = %.6g', b(1));
% for i = 1:6
%     if b(i+1) >= 0
%         latex_str = sprintf('%s + %.6g x_%d', latex_str, b(i+1), i);
%     else
%         latex_str = sprintf('%s - %.6g x_%d', latex_str, -b(i+1), i);
%     end
% end
% fprintf('LaTeX: %s\n\n', latex_str);

%% ===== 打印二次(含交互)模型 z ~ quadratic =====
% 需要你用过：mdl_qd = fitlm(T, 'quadratic');  % 或 'purequadratic' / 'interactions'
coef2 = mdl_pq.Coefficients;
b2 = coef2.Estimate;
rn = coef2.Properties.RowNames;

fprintf('--- Quadratic model terms ---\n');
% 逐项打印（常数/一次/平方/交互）
for k = 1:numel(rn)
    term = rn{k};
    c = b2(k);
    if strcmp(term,'(Intercept)')
        fprintf('%+ .6g  * 1\n', c);
    else
        % 把 term 中的 x1:x2 转成 x1*x2，^2 仍保留
        term_print = strrep(term, ':', '*');
        fprintf('%+ .6g  * %s\n', c, term_print);
    end
end

% 组合成一行可读公式
expr = sprintf('z = ');
for k = 1:numel(rn)
    c = b2(k);
    if strcmp(rn{k},'(Intercept)')
        piece = sprintf('%.6g', c);
    else
        piece = sprintf('%.6g*(%s)', c, strrep(rn{k},':','*'));
    end
    if k==1
        expr = [expr piece];
    else
        if c >= 0, expr = [expr ' + ' piece];
        else,      expr = [expr ' - ' strrep(piece,'-','')];
        end
    end
end
fprintf('\nQuadratic formula:\n%s\n', expr);
