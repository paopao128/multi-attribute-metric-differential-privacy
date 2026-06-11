%% sample_points_entropy.m
% Random sampling for entropy-based cost analysis
% Similar structure to original sample_points.m but using entropy metrics

%% Load data and baseline metrics
load("result/result-1/X.mat");
load("result/result-1/H_clean.mat");
load("result/result-1/attribute_set.mat");

% Define attribute sets (same as in get_cost_matrix2.m)
attribute_set = cell(1,4);
attribute_set{1,1} = [1,3,4,7,8,9,10,11,12];
attribute_set{1,2} = [2];
attribute_set{1,3} = [5];
attribute_set{1,4} = [6];

fprintf('Loaded data: %d × %d\n', size(X,1), size(X,2));
fprintf('Baseline entropy metrics loaded.\n\n');

%% Get unique value combinations for each attribute set
fprintf('Extracting unique value combinations...\n');
[uniqueVals1, ~, value_idx1] = unique(X(:,attribute_set{1,1}), 'rows');
[uniqueVals2, ~, value_idx2] = unique(X(:,attribute_set{1,2}), 'rows');
[uniqueVals3, ~, value_idx3] = unique(X(:,attribute_set{1,3}), 'rows');
[uniqueVals4, ~, value_idx4] = unique(X(:,attribute_set{1,4}), 'rows');
% [uniqueVals5, ~, value_idx5] = unique(X(:,attribute_set{1,5}), 'rows');
% [uniqueVals6, ~, value_idx6] = unique(X(:,attribute_set{1,6}), 'rows');

fprintf('  Set 1: %d unique combinations\n', size(uniqueVals1,1));
fprintf('  Set 2: %d unique combinations\n', size(uniqueVals2,1));
fprintf('  Set 3: %d unique combinations\n', size(uniqueVals3,1));
fprintf('  Set 4: %d unique combinations\n', size(uniqueVals4,1));
% fprintf('  Set 5: %d unique combinations\n', size(uniqueVals5,1));
% fprintf('  Set 6: %d unique combinations\n\n', size(uniqueVals6,1));

%% Configuration
num_sample = 1000;
all_attrs = 1:size(X, 2);  % All column indices

% Initialize loss vectors
loss_set1 = zeros(num_sample,1);
loss_set2 = zeros(num_sample,1);
loss_set3 = zeros(num_sample,1);
loss_set4 = zeros(num_sample,1);
% loss_set5 = zeros(num_sample,1);
% loss_set6 = zeros(num_sample,1);
loss_set_all = zeros(num_sample,1);

fprintf('Starting random sampling (%d samples)...\n\n', num_sample);

%% Random sampling loop
for sample_id = 1:num_sample
    if mod(sample_id, 100) == 0 || sample_id == 1
        fprintf('Processing sample %d/%d...\n', sample_id, num_sample);
    end
    
    % === SET 1 ===
    X_temp = X;  % Restore original data
    obf_i_1 = randi(length(uniqueVals1));
    obf_j_1 = randi(length(uniqueVals1));
    count_obf=0;
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,1}), uniqueVals1(obf_i_1,:))
            X_temp(i,attribute_set{1,1}) = uniqueVals1(obf_j_1,:);
            count_obf=count_obf+1;
        end
    end
    
    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    loss_set1(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
        attribute_set{1,1}, all_attrs);
    loss_set1(sample_id,1)=loss_set1(sample_id,1)/count_obf;

    % === SET 2 ===
    X_temp = X;
    obf_i_2 = randi(length(uniqueVals2));
    obf_j_2 = randi(length(uniqueVals2));
    count_obf=0;
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,2}), uniqueVals2(obf_i_2,:))
            X_temp(i,attribute_set{1,2}) = uniqueVals2(obf_j_2,:);
            count_obf=count_obf+1;
        end
    end
    
    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    loss_set2(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
        attribute_set{1,2}, all_attrs);
    loss_set2(sample_id,1)=loss_set2(sample_id,1)/count_obf;

    % === SET 3 ===
    X_temp = X;
    obf_i_3 = randi(length(uniqueVals3));
    obf_j_3 = randi(length(uniqueVals3));
    count_obf=0;
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,3}), uniqueVals3(obf_i_3,:))
            X_temp(i,attribute_set{1,3}) = uniqueVals3(obf_j_3,:);
            count_obf=count_obf+1;
        end
    end
    
    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    loss_set3(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
        attribute_set{1,3}, all_attrs);
    loss_set3(sample_id,1)=loss_set3(sample_id,1)/count_obf;

    % === SET 4 ===
    X_temp = X;
    obf_i_4 = randi(length(uniqueVals4));
    obf_j_4 = randi(length(uniqueVals4));
    count_obf=0;
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,4}), uniqueVals4(obf_i_4,:))
            X_temp(i,attribute_set{1,4}) = uniqueVals4(obf_j_4,:);
            count_obf=count_obf+1;
        end
    end
    
    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    loss_set4(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
        attribute_set{1,4}, all_attrs);
    loss_set4(sample_id,1)=loss_set4(sample_id,1)/count_obf;

    % % === SET 5 ===
    % X_temp = X;
    % obf_i_5 = randi(length(uniqueVals5));
    % obf_j_5 = randi(length(uniqueVals5));
    % count_obf=0;
    % for i = 1:size(X_temp,1)
    %     if isequal(X_temp(i,attribute_set{1,5}), uniqueVals5(obf_i_5,:))
    %         X_temp(i,attribute_set{1,5}) = uniqueVals5(obf_j_5,:);
    %         count_obf=count_obf+1;
    %     end
    % end
    % 
    % H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    % loss_set5(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
    %     attribute_set{1,5}, all_attrs);
    % loss_set5(sample_id,1)=loss_set5(sample_id,1)/count_obf;
    % 
    % % === SET 6 ===
    % X_temp = X;
    % obf_i_6 = randi(length(uniqueVals6));
    % obf_j_6 = randi(length(uniqueVals6));
    % count_obf=0;
    % for i = 1:size(X_temp,1)
    %     if isequal(X_temp(i,attribute_set{1,6}), uniqueVals6(obf_i_6,:))
    %         X_temp(i,attribute_set{1,6}) = uniqueVals6(obf_j_6,:);
    %         count_obf=count_obf+1;
    %     end
    % end
    % 
    % H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    % loss_set6(sample_id,1) = calculate_entropy_cost(H_clean, H_obfuscated, ...
    %     attribute_set{1,6}, all_attrs);
    % loss_set6(sample_id,1)=loss_set6(sample_id,1)/count_obf;

    % === ALL SETS COMBINED ===
    % Track each set's count separately so normalization matches individual xi's
    X_temp = X;
    count1_comb = 0; count2_comb = 0; count3_comb = 0; count4_comb = 0;
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,1}), uniqueVals1(obf_i_1,:))
            X_temp(i,attribute_set{1,1}) = uniqueVals1(obf_j_1,:);
            count1_comb = count1_comb + 1;
        end
    end
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,2}), uniqueVals2(obf_i_2,:))
            X_temp(i,attribute_set{1,2}) = uniqueVals2(obf_j_2,:);
            count2_comb = count2_comb + 1;
        end
    end
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,3}), uniqueVals3(obf_i_3,:))
            X_temp(i,attribute_set{1,3}) = uniqueVals3(obf_j_3,:);
            count3_comb = count3_comb + 1;
        end
    end
    for i = 1:size(X_temp,1)
        if isequal(X_temp(i,attribute_set{1,4}), uniqueVals4(obf_i_4,:))
            X_temp(i,attribute_set{1,4}) = uniqueVals4(obf_j_4,:);
            count4_comb = count4_comb + 1;
        end
    end

    % z = sum of per-set per-record costs evaluated on combined obfuscated data.
    % Each term uses the same changed_attrs and count denominator as the
    % corresponding individual xi, so the scales are directly comparable.
    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
    loss_set_all(sample_id,1) = ...
        calculate_entropy_cost(H_clean, H_obfuscated, attribute_set{1,1}, all_attrs) / count1_comb + ...
        calculate_entropy_cost(H_clean, H_obfuscated, attribute_set{1,2}, all_attrs) / count2_comb + ...
        calculate_entropy_cost(H_clean, H_obfuscated, attribute_set{1,3}, all_attrs) / count3_comb + ...
        calculate_entropy_cost(H_clean, H_obfuscated, attribute_set{1,4}, all_attrs) / count4_comb;
end

fprintf('\n✓ Sampling complete!\n\n');

%% Display basic statistics
fprintf('=== Loss Statistics ===\n');
fprintf('Set 1: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
    mean(loss_set1), std(loss_set1), min(loss_set1), max(loss_set1));
fprintf('Set 2: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
    mean(loss_set2), std(loss_set2), min(loss_set2), max(loss_set2));
fprintf('Set 3: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
    mean(loss_set3), std(loss_set3), min(loss_set3), max(loss_set3));
fprintf('Set 4: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
    mean(loss_set4), std(loss_set4), min(loss_set4), max(loss_set4));
% fprintf('Set 5: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
%     mean(loss_set5), std(loss_set5), min(loss_set5), max(loss_set5));
% fprintf('Set 6: Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n', ...
%     mean(loss_set6), std(loss_set6), min(loss_set6), max(loss_set6));
fprintf('All:   Mean=%.4f, Std=%.4f, Range=[%.4f, %.4f]\n\n', ...
    mean(loss_set_all), std(loss_set_all), min(loss_set_all), max(loss_set_all));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REGRESSION ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x1 = loss_set1;
x2 = loss_set2;
x3 = loss_set3;
x4 = loss_set4;
% x5 = loss_set5;
% x6 = loss_set6;
z = loss_set_all;

clc; close all;

% -------- 0) Validate and prepare variables --------
% vars = {'z','x1','x2','x3','x4','x5','x6'};
vars = {'z','x1','x2','x3','x4'};
for k = 1:numel(vars)
    assert(exist(vars{k},'var')==1, sprintf('Variable "%s" does not exist', vars{k}));
    v = eval(vars{k});
    v = v(:);  % Force column vector
    assignin('base', vars{k}, v);
end

N = numel(z);
for k = 2:numel(vars)
    if numel(eval(vars{k})) ~= N
        error('Length mismatch: z has %d, %s has %d', N, vars{k}, numel(eval(vars{k})));
    end
end

% -------- 1) Build design matrix --------
% X_reg = [x1 x2 x3 x4 x5 x6];  % N x 6
X_reg = [x1 x2 x3 x4];
varNames = compose('x%d',1:4);
T = array2table(X_reg, 'VariableNames', varNames);
T.z = z;

% -------- 2) Pearson correlation --------
C = corr(X_reg, z, 'Rows','complete');
corr_tbl = table(varNames', C, 'VariableNames', {'Variable','CorrWithZ'});
disp('=== Pearson correlation with z ===');
disp(corr_tbl);

% -------- 3) Linear model --------
% mdl_lin = fitlm(T, 'z ~ x1 + x2 + x3 + x4 + x5 + x6');
mdl_lin = fitlm(T, 'z ~ x1 + x2 + x3 + x4');
disp('=== Linear Model (main effects) ===');
disp(mdl_lin);
fprintf('[Linear] R^2 = %.4f, Adjusted R^2 = %.4f, RMSE = %.4f\n', ...
    mdl_lin.Rsquared.Ordinary, mdl_lin.Rsquared.Adjusted, mdl_lin.RMSE);

% Print readable equation
coefTable = mdl_lin.Coefficients;
intercept = coefTable.Estimate(1);
fprintf('z = %.6g', intercept);
for i = 1:4
    b = coefTable.Estimate(i+1);
    if b>=0, fprintf(' + %.6g*%s', b, varNames{i});
    else,    fprintf(' - %.6g*%s', -b, varNames{i});
    end
end
fprintf('\n\n');

% -------- 4) Pure quadratic model --------
mdl_pq = fitlm(T, 'purequadratic');
disp('=== Pure Quadratic Model ===');
fprintf('[PureQuadratic] R^2 = %.4f, Adjusted R^2 = %.4f, RMSE = %.4f\n', ...
    mdl_pq.Rsquared.Ordinary, mdl_pq.Rsquared.Adjusted, mdl_pq.RMSE);

% Full quadratic with interactions
mdl_qd = fitlm(T, 'quadratic');

% -------- 5) LASSO --------
[B, FitInfo] = lasso(X_reg, z, 'CV', 10, 'Standardize', true);
idxBest = FitInfo.IndexMinMSE;
B_best = B(:, idxBest);
b0 = FitInfo.Intercept(idxBest);

fprintf('=== LASSO (10-fold CV, min MSE) ===\n');
fprintf('Non-zero coefficients: %d / %d\n', nnz(B_best), numel(B_best));
sel = find(B_best~=0);
if ~isempty(sel)
    fprintf('Selected variables: %s\n', strjoin(varNames(sel), ', '));
end

z_pred_lasso = X_reg*B_best + b0;
SS_res = sum((z - z_pred_lasso).^2);
SS_tot = sum((z - mean(z)).^2);
R2_lasso = 1 - SS_res/SS_tot;
RMSE_lasso = sqrt(mean((z - z_pred_lasso).^2));
fprintf('[LASSO] R^2 = %.4f, RMSE = %.4f\n\n', R2_lasso, RMSE_lasso);

% -------- 6) Ensemble trees --------
mdl_tree = fitrensemble(X_reg, z, 'Method','LSBoost', ...
    'NumLearningCycles',300, 'Learners','tree');
z_pred_tree = predict(mdl_tree, X_reg);
R2_tree = 1 - sum((z - z_pred_tree).^2)/SS_tot;
RMSE_tree = sqrt(mean((z - z_pred_tree).^2));

fprintf('=== Ensemble Trees ===\n');
fprintf('[Trees] R^2 = %.4f, RMSE = %.4f\n', R2_tree, RMSE_tree);

imp = predictorImportance(mdl_tree);
[impSorted, ord] = sort(imp, 'descend');
fprintf('[Trees] Importance Top-3: %s\n\n', strjoin(varNames(ord(1:min(3,6))), ', '));

% Partial dependence plots
figure; plotPartialDependence(mdl_tree, ord(1), 1:size(X_reg,2));
title(sprintf('Partial Dependence of %s', varNames{ord(1)}));

if numel(ord) >= 2
    figure; plotPartialDependence(mdl_tree, [ord(1) ord(2)], 1:size(X_reg,2));
    title(sprintf('PDP of (%s, %s)', varNames{ord(1)}, varNames{ord(2)}));
end

% -------- 7) VIF (multicollinearity) --------
VIF = zeros(4,1);
for j = 1:4
    Xj = X_reg(:, j);
    Xnot = X_reg(:, setdiff(1:4, j));
    mdlj = fitlm(Xnot, Xj);
    R2j = mdlj.Rsquared.Ordinary;
    VIF(j) = 1 / max(1 - R2j, eps);
end
vif_tbl = table(varNames', VIF, 'VariableNames', {'Variable','VIF'});
disp('=== VIF (Variance Inflation Factor) ===');
disp(vif_tbl);

% -------- 8) Residual diagnostics --------
figure; plotResiduals(mdl_lin, 'fitted'); 
title('Linear Model Residuals vs Fitted');

figure; plotDiagnostics(mdl_lin, 'cookd'); 
title('Linear Model Cook''s Distance');

% -------- 9) 80/20 holdout validation --------
cv = cvpartition(N, 'HoldOut', 0.2);
idxTr = training(cv); 
idxTe = test(cv);
mdl_tr = fitlm(X_reg(idxTr,:), z(idxTr));
z_te = z(idxTe);
z_hat = predict(mdl_tr, X_reg(idxTe,:));
RMSE_te = sqrt(mean((z_te - z_hat).^2));
R2_te = 1 - sum((z_te - z_hat).^2) / sum((z_te - mean(z_te)).^2);

fprintf('=== 80/20 Hold-out (Linear) ===\n');
fprintf('[Test] R^2 = %.4f, RMSE = %.4f\n\n', R2_te, RMSE_te);

%% ===== Print linear model equation =====
coef = mdl_lin.Coefficients;
b = coef.Estimate;

fprintf('--- Linear model: z = b0 + sum(bi*xi) ---\n');
fprintf('z = %.6g', b(1));
for i = 1:4
    if b(i+1) >= 0
        fprintf(' + %.6g*x%d', b(i+1), i);
    else
        fprintf(' - %.6g*x%d', -b(i+1), i);
    end
end
fprintf('\n');

% LaTeX version
latex_str = sprintf('z = %.6g', b(1));
for i = 1:4
    if b(i+1) >= 0
        latex_str = sprintf('%s + %.6g x_%d', latex_str, b(i+1), i);
    else
        latex_str = sprintf('%s - %.6g x_%d', latex_str, -b(i+1), i);
    end
end
fprintf('LaTeX: %s\n\n', latex_str);

%% ===== Print quadratic model =====
coef2 = mdl_qd.Coefficients;
b2 = coef2.Estimate;
rn = coef2.Properties.RowNames;

fprintf('--- Quadratic model terms ---\n');
for k = 1:numel(rn)
    term = rn{k};
    c = b2(k);
    if strcmp(term,'(Intercept)')
        fprintf('%+ .6g  * 1\n', c);
    else
        term_print = strrep(term, ':', '*');
        fprintf('%+ .6g  * %s\n', c, term_print);
    end
end

% Combined readable formula
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HELPER FUNCTIONS (copied from get_cost_matrix2.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H_metrics = calculate_entropy_metrics(X, attr_cols)
    % Calculate comprehensive entropy metrics
    H_metrics = struct();
    n_attrs = length(attr_cols);
    
    % 1. Marginal entropies
    marginal_entropies = zeros(1, n_attrs);
    for i = 1:n_attrs
        col_idx = attr_cols(i);
        marginal_entropies(i) = calculate_shannon_entropy(X(:, col_idx));
    end
    
    H_metrics.marginal_entropies = marginal_entropies;
    H_metrics.total_marginal = sum(marginal_entropies);
    H_metrics.avg_marginal = mean(marginal_entropies);
    
    % 2. Joint entropy
    H_metrics.joint_entropy = calculate_joint_entropy(X(:, attr_cols));
    
    % 3. Total correlation
    H_metrics.total_correlation = H_metrics.total_marginal - H_metrics.joint_entropy;
    
    % 4. Normalized metrics
    H_metrics.normalized_joint = H_metrics.joint_entropy / n_attrs;
end

function H = calculate_shannon_entropy(x)
    % Calculate Shannon entropy: H(X) = -sum(p(x) * log2(p(x)))
    [~, ~, idx] = unique(x);
    n_unique = max(idx);
    
    probs = zeros(1, n_unique);
    for i = 1:n_unique
        probs(i) = sum(idx == i) / length(x);
    end
    
    probs = probs(probs > 0);
    H = -sum(probs .* log2(probs));
end

function H_joint = calculate_joint_entropy(X)
    % Calculate joint entropy: H(X1, X2, ..., Xn)
    [~, ~, idx] = unique(X, 'rows');
    n_unique = max(idx);
    
    probs = zeros(1, n_unique);
    for i = 1:n_unique
        probs(i) = sum(idx == i) / length(idx);
    end
    
    probs = probs(probs > 0);
    H_joint = -sum(probs .* log2(probs));
end

function cost = calculate_entropy_cost(H_clean, H_obfuscated, changed_attrs, all_attrs)
    % Calculate cost based on entropy changes
    
    % Weight parameters
    % w_marginal = 0.3;
    % w_joint = 0.4;
    % w_correlation = 0.3;
    w_marginal = 0.6;
    w_joint = 0.4;
    w_correlation = 0;
    % 1. Marginal entropy loss
    marginal_loss = 0;
    for attr = changed_attrs
        attr_idx = find(all_attrs == attr);
        if ~isempty(attr_idx)
            delta_H = abs(H_clean.marginal_entropies(attr_idx) - ...
                         H_obfuscated.marginal_entropies(attr_idx));
            marginal_loss = marginal_loss + delta_H;
        end
    end
    marginal_loss = marginal_loss / length(changed_attrs);
    
    % 2. Joint entropy change
    joint_loss = abs(H_clean.joint_entropy - H_obfuscated.joint_entropy);
    
    % 3. Total correlation change
    correlation_loss = abs(H_clean.total_correlation - H_obfuscated.total_correlation);
    
    % 4. Combined cost
    cost = w_marginal * marginal_loss + ...
           w_joint * joint_loss + ...
           w_correlation * correlation_loss;
    
    % Scale to reasonable range
    cost = cost * 1000;
end