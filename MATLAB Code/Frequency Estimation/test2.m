%% adult_global_utility_numerical.m
% Global utility u for frequency estimation on NUMERICAL matrix X
clear; clc;

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
fprintf('Loaded %d samples\n', height(T));

%% Convert categorical data to numerical matrix
% Specify which attributes to encode
attrs = {'education','occupation','race','sex','marital_status','workclass'};

% Encode all categorical columns and normalize
[X, T_encoded, info] = encodeCategoricalData(T, 'normalize', true);
fprintf('Encoded data shape: %d × %d\n', size(X,1), size(X,2));

%% Get column indices for the attributes we want to analyze
% Find the encoded column indices
attr_cols = zeros(length(attrs), 1);
for i = 1:length(attrs)
    encoded_col_name = [attrs{i} '_encoded'];
    idx = find(strcmp(info.numeric_columns, encoded_col_name));
    if ~isempty(idx)
        attr_cols(i) = idx;
    else
        error('Column %s not found', encoded_col_name);
    end
end

fprintf('Analyzing columns: %s\n', mat2str(attr_cols));

%% Define weights for global utility
d = numel(attrs);
w = ones(d,1);   % equal weights, can be changed

%% Build reference distributions from clean numerical data X
ref = build_reference_marginals_numerical(X, attr_cols, info, attrs);

%% Define obfuscation strength
pFlip = 0.10;     % obfuscation probability
% rng(0);         % for reproducibility

%% Compute u_clean (baseline with no obfuscation)
u_clean = global_utility_marginal_numerical(X, attr_cols, w, ref);
fprintf('u_clean = %.6f\n', u_clean);

%% Example 1: Obfuscate one attribute column
i = 1; % obfuscate first attribute
X_i = X;
X_i(:, attr_cols(i)) = obfuscate_numerical(X(:, attr_cols(i)), pFlip, info, attrs{i});
u_i = global_utility_marginal_numerical(X_i, attr_cols, w, ref);
fprintf('Obfuscate %s (col %d): u = %.6f, loss = %.6f\n', ...
    attrs{i}, attr_cols(i), u_i, (u_clean - u_i));

%% Example 2: Loop over all attributes, obfuscate each one individually
loss_each = zeros(d,1);
u_each = zeros(d,1);

for k = 1:d
    X_k = X;
    X_k(:, attr_cols(k)) = obfuscate_numerical(X(:, attr_cols(k)), pFlip, info, attrs{k});
    u_each(k) = global_utility_marginal_numerical(X_k, attr_cols, w, ref);
    loss_each(k) = u_clean - u_each(k);
end

disp(table(attrs(:), u_each, loss_each, ...
    'VariableNames', {'Attribute','u','UtilityLoss'}));

%% Example 3: Obfuscate a subset of attributes
S = [1 4]; % e.g., education and sex
X_S = X;
for idx = S
    X_S(:, attr_cols(idx)) = obfuscate_numerical(X(:, attr_cols(idx)), pFlip, info, attrs{idx});
end
u_S = global_utility_marginal_numerical(X_S, attr_cols, w, ref);
fprintf('Obfuscate set %s: u = %.6f, loss = %.6f\n', ...
    mat2str(S), u_S, (u_clean - u_S));

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
    ref.(attr_name).n_categories = info.(attr_name).categories;
end
end

function u = global_utility_marginal_numerical(X, attr_cols, w, ref)
% Compute global utility from numerical matrix
% u = -sum_j w_j ||p_hat_j - p_ref_j||_2^2
E = 0;

attrs = fieldnames(ref);
for i = 1:length(attrs)
    attr_name = attrs{i};
    col_idx = attr_cols(i);
    
    values_ref = ref.(attr_name).values;
    p_ref = ref.(attr_name).p;
    
    % Estimate current distribution
    x_vals = X(:, col_idx);
    p_hat = freq_estimate_aligned_numerical(x_vals, values_ref);
    
    E = E + w(i) * sum((p_hat - p_ref).^2);
end

u = -E;
end

function x_obs = obfuscate_numerical(x, p, info, attr_name)
% Randomly replace a fraction p of entries with random values
% x: column vector of numerical values (encoded categories)
% p: flip probability
% info: encoding information structure
% attr_name: name of the attribute

unique_vals = unique(x);
n_unique = length(unique_vals);

x_obs = x;
mask = rand(length(x), 1) < p;
n_flip = sum(mask);

if n_flip > 0
    % Randomly select from all possible encoded values
    random_vals = unique_vals(randi(n_unique, n_flip, 1));
    x_obs(mask) = random_vals;
end
end

function p = freq_estimate_aligned_numerical(x, values_ref)
% Estimate frequencies aligned to reference values
p = zeros(size(values_ref));
total = length(x);

for i = 1:length(values_ref)
    p(i) = sum(x == values_ref(i)) / total;
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% encodeCategoricalData Function (include here or keep in separate file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, T_encoded, encoding_info] = encodeCategoricalData(T, varargin)
% ENCODECATEGORICALDATA 将表格中的分类数据转换为数值
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
            encoded_col_name = [col_name '_encoded'];
            T_encoded.(encoded_col_name) = double(T_encoded.(col_name));
            encoding_info.(col_name).encoded_col = encoded_col_name;
            fprintf('  %s: %d个类别 -> %s\n', col_name, length(cats), encoded_col_name);
        end
    end
    
    % Extract numerical columns
    fprintf('提取数值列...\n');
    numeric_col_names = {};
    for i = 1:width(T_encoded)
        col_name = T_encoded.Properties.VariableNames{i};
        col_data = T_encoded.(col_name);
        
        if isnumeric(col_data)
            numeric_col_names{end+1} = col_name;
        end
    end
    
    X = table2array(T_encoded(:, numeric_col_names));
    encoding_info.numeric_columns = numeric_col_names;
    
    fprintf('数值矩阵维度: %d行 × %d列\n', size(X, 1), size(X, 2));
    
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