%% adult_global_utility_numerical.m
% Global utility u for frequency estimation on NUMERICAL matrix X
% Enhanced with cost matrix calculation for each attribute set
clear; clc;

%% ========== CONFIGURATION ==========
% Set the number of samples to use (for faster computation)
%n_samples = 300;  % Change this value as needed
n_samples = 1500;
% ====================================

%% Load Adult data
colNames = { ...
    'age','workclass','fnlwgt','education','education_num', ...
    'marital_status','occupation','relationship','race','sex', ...
    'capital_gain','capital_loss','hours_per_week', ...
    'native_country','income'};

opts = detectImportOptions('adult.data','FileType','text','Delimiter',',');
opts.VariableNames = colNames;
opts = setvaropts(opts, colNames, 'TreatAsMissing', '?');
T = readtable('adult.data', opts);
T = rmmissing(T);
fprintf('Loaded %d samples from full dataset\n', height(T));

%% Randomly sample n_samples rows
total_rows = height(T);
if n_samples < total_rows
    rng('shuffle');  % Use current time as seed for randomness
    sample_indices = randperm(total_rows, n_samples);
    T = T(sample_indices, :);
    fprintf('Randomly selected %d samples for analysis\n', n_samples);
else
    fprintf('Using all %d samples (n_samples >= total rows)\n', total_rows);
end

%% Define attribute sets
attribute_set=cell(1,6);
attribute_set{1,1}=[1,4,9,11,13,15];  % age, education, race, capital_gain, hours_per_week, income
attribute_set{1,2}=[2];                % workclass
attribute_set{1,3}=[3,8,10,12,14];    % fnlwgt, relationship, sex, capital_loss, native_country
attribute_set{1,4}=[5];                % education_num
attribute_set{1,5}=[6];                % marital_status
attribute_set{1,6}=[7];                % occupation

%% Convert categorical data to numerical matrix
% Encode all categorical columns and normalize
[X, T_encoded, info] = encodeCategoricalData(T, 'normalize', true);
fprintf('Encoded data shape: %d × %d\n', size(X,1), size(X,2));

%% Use ALL columns for analysis
attr_cols = 1:size(X, 2);  % All columns
attrs = info.numeric_columns;  % All column names

fprintf('Analyzing ALL columns: %d columns total\n', length(attr_cols));
fprintf('Column names: %s\n', strjoin(attrs, ', '));

%% Define weights for global utility
d = numel(attr_cols);


%% Build reference distributions from clean numerical data X
ref = build_reference_marginals_numerical(X, attr_cols, info, attrs);

%% Compute u_clean (baseline with no obfuscation)
u_clean = global_utility_marginal_numerical(X, attr_cols, ref);
fprintf('u_clean (baseline) = %.6f\n\n', u_clean);

%% ============= COST MATRIX CALCULATION FOR EACH ATTRIBUTE SET =============
fprintf('=== Starting Cost Matrix Calculation ===\n\n');

X_ori = X;  % Save original data
cost_attribute = cell(1, length(attribute_set));

for attribute_set_id = 1:length(attribute_set)
    fprintf('Processing attribute set %d/%d...\n', attribute_set_id, length(attribute_set));
    
    % Get unique value combinations for this attribute set
    current_attr_cols = attribute_set{1, attribute_set_id};
    [uniqueVals, ~, value_idx] = unique(X(:, current_attr_cols), 'rows');
    
    n_unique = size(uniqueVals, 1);
    fprintf('  Found %d unique value combinations\n', n_unique);
    
    % Initialize cost matrix
    cost_matrix = zeros(n_unique, n_unique);
    
    % Calculate cost for each pair of values
    for cost_row_id = 1:n_unique
        % Find all samples with this original value
        obfuscation_i = find(value_idx == cost_row_id);
        
        for cost_col_id = 1:n_unique
            if cost_row_id ~= cost_col_id
                % Get the obfuscation value
                obfuscation_value = uniqueVals(cost_col_id, :);
                
                % Calculate cost for all samples with this original value
                total_cost = 0;
                for id_same_values = 1:length(obfuscation_i)
                    % Restore original data
                    X = X_ori;
                    
                    % Apply obfuscation: replace the attribute set values
                    X(obfuscation_i(id_same_values), current_attr_cols) = obfuscation_value;
                    
                    % Recalculate utility with obfuscated data
                    u_obfuscated = global_utility_marginal_numerical(X, attr_cols, ref);
                    
                    % Calculate cost (relative utility loss)
                    cost = (u_clean - u_obfuscated) * 100000;
                    total_cost = total_cost + cost;
                end
                
                % Average cost over all samples with the same original value
                cost_matrix(cost_row_id, cost_col_id) = total_cost / length(obfuscation_i);
            end
            
            % Progress indicator
            if mod(cost_col_id, 10) == 0 || cost_col_id == n_unique
                fprintf('    Attribute set %d: row %d/%d, col %d/%d, value = %.2f\n', ...
                    attribute_set_id, cost_row_id, n_unique, cost_col_id, n_unique, ...
                    cost_matrix(cost_row_id, cost_col_id));
            end
        end
    end
    
    % Store cost matrix for this attribute set
    cost_attribute{1, attribute_set_id} = cost_matrix;
    
    fprintf('Completed attribute set %d\n', attribute_set_id);
    fprintf('  Cost matrix size: %d × %d\n', size(cost_matrix, 1), size(cost_matrix, 2));
    fprintf('  Max cost: %.2f, Min non-zero cost: %.2f\n\n', ...
        max(cost_matrix(:)), min(cost_matrix(cost_matrix > 0)));
end

%% Restore original data
X = X_ori;

%% Save results
fprintf('Saving results...\n');
save('result/result-2/data.mat', 'X');
save('result/result-2/cost_attribute.mat', 'cost_attribute');
save('result/result-2/u_clean.mat', 'u_clean');
save('result/result-2/attribute_set.mat', 'attribute_set');
save('result/result-2/ref.mat', 'ref');
save('result/result-2/attr_cols.mat', 'attr_cols');

fprintf('\n=== Cost Matrix Calculation Complete ===\n');
fprintf('Results saved to:\n');
fprintf('  - data.mat\n');
fprintf('  - cost_attribute.mat\n');
fprintf('  - u_clean.mat\n');
fprintf('  - attribute_set.mat\n');

%% Display summary statistics
fprintf('\n=== Summary Statistics ===\n');
for i = 1:length(cost_attribute)
    cm = cost_attribute{1, i};
    fprintf('Attribute Set %d:\n', i);
    fprintf('  Matrix size: %d × %d\n', size(cm, 1), size(cm, 2));
    fprintf('  Max cost: %.2f\n', max(cm(:)));
    fprintf('  Mean non-zero cost: %.2f\n', mean(cm(cm > 0)));
    fprintf('  Non-zero entries: %d / %d\n', sum(cm(:) > 0), numel(cm));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Helper Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ref = build_reference_marginals_numerical(X, attr_cols, info, attrs)
% Build reference marginal distributions from numerical matrix X
ref = struct();
for i = 1:length(attr_cols)
    col_idx = attr_cols(i);
    attr_name = attrs{i};
    
    x_vals = X(:, col_idx);
    unique_vals = unique(x_vals);
    
    % Compute frequency for each unique value
    p = zeros(size(unique_vals));
    for j = 1:length(unique_vals)
        p(j) = sum(x_vals == unique_vals(j)) / length(x_vals);
    end
    
    ref.(attr_name).values = unique_vals;
    ref.(attr_name).p = p;
    
    % Only add n_categories if this attribute exists in info (i.e., it's categorical)
    if isfield(info, attr_name) && isfield(info.(attr_name), 'categories')
        ref.(attr_name).n_categories = info.(attr_name).categories;
    else
        % For numerical columns, n_categories is just the number of unique values
        ref.(attr_name).n_categories = length(unique_vals);
    end
end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% encodeCategoricalData Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, T_encoded, encoding_info] = encodeCategoricalData(T, varargin)
% ENCODECATEGORICALDATA 将表格中的分类数据转换为数值
% 保持X的列顺序与T一致
    p = inputParser;
    addRequired(p, 'T', @istable);
    addParameter(p, 'categorical_cols', {}, @iscell);
    addParameter(p, 'method', 'label', @(x) any(validatestring(x, {'label', 'onehot'})));
    addParameter(p, 'normalize', false, @islogical);
    addParameter(p, 'normalize_method', 'zscore', @(x) any(validatestring(x, {'zscore', 'minmax'})));
    
    parse(p, T, varargin{:});
    
    categorical_cols = p.Results.categorical_cols;
    method = p.Results.method;
    do_normalize = p.Results.normalize;
    normalize_method = p.Results.normalize_method;
    
    % Auto-detect categorical columns
    if isempty(categorical_cols)
        categorical_cols = {};
        for i = 1:width(T)
            col_data = T{:, i};
            if iscell(col_data) || isstring(col_data) || iscategorical(col_data)
                categorical_cols{end+1} = T.Properties.VariableNames{i};
            end
        end
        fprintf('自动检测到 %d 个分类列\n', length(categorical_cols));
    end
    
    T_encoded = T;
    encoding_info = struct();
    
    % Encode each categorical column
    fprintf('开始编码分类变量...\n');
    
    for i = 1:length(categorical_cols)
        col_name = categorical_cols{i};
        
        if ~ismember(col_name, T.Properties.VariableNames)
            warning('列 "%s" 不存在，跳过', col_name);
            continue;
        end
        
        if ~iscategorical(T_encoded.(col_name))
            T_encoded.(col_name) = categorical(T_encoded.(col_name));
        end
        
        cats = categories(T_encoded.(col_name));
        encoding_info.(col_name).categories = cats;
        encoding_info.(col_name).method = method;
        
        if strcmp(method, 'label')
            % Replace the original column with encoded values (in-place)
            T_encoded.(col_name) = double(T_encoded.(col_name));
            encoding_info.(col_name).encoded_col = col_name;
            fprintf('  %s: %d个类别 -> 编码为数值\n', col_name, length(cats));
        end
    end
    
    % Extract numerical columns in the SAME ORDER as original T
    fprintf('提取数值列（保持原始顺序）...\n');
    numeric_col_names = {};
    original_col_names = T.Properties.VariableNames;
    
    for i = 1:length(original_col_names)
        col_name = original_col_names{i};
        col_data = T_encoded.(col_name);
        
        if isnumeric(col_data)
            numeric_col_names{end+1} = col_name;
        end
    end
    
    X = table2array(T_encoded(:, numeric_col_names));
    encoding_info.numeric_columns = numeric_col_names;
    
    fprintf('数值矩阵维度: %d行 × %d列\n', size(X, 1), size(X, 2));
    fprintf('列顺序: %s\n', strjoin(numeric_col_names, ', '));
    
    % Normalize if requested
    if do_normalize
        fprintf('进行数据标准化 (%s)...\n', normalize_method);
        X = normalize(X, normalize_method);
        encoding_info.normalized = true;
        encoding_info.normalize_method = normalize_method;
    else
        encoding_info.normalized = false;
    end
    
    fprintf('编码完成！\n\n');
end