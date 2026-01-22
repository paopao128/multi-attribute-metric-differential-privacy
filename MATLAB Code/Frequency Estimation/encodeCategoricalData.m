function [X, T_encoded, encoding_info] = encodeCategoricalData(T, varargin)
% ENCODECATEGORICALDATA 将表格中的分类数据转换为数值
%
% 语法:
%   [X, T_encoded, encoding_info] = encodeCategoricalData(T)
%   [X, T_encoded, encoding_info] = encodeCategoricalData(T, 'categorical_cols', cols)
%   [X, T_encoded, encoding_info] = encodeCategoricalData(T, 'method', 'onehot')
%   [X, T_encoded, encoding_info] = encodeCategoricalData(T, 'normalize', true)
%
% 输入参数:
%   T - 输入表格，包含分类和数值列
%
% 可选参数（名称-值对）:
%   'categorical_cols' - 需要编码的分类列名（cell array）
%                        默认: 自动检测所有字符串/cell类型的列
%   'method' - 编码方法: 'label' (默认) 或 'onehot'
%   'normalize' - 是否对数值进行标准化，默认: false
%   'normalize_method' - 标准化方法: 'zscore' (默认) 或 'minmax'
%
% 输出参数:
%   X - 纯数值矩阵，所有列都是数值
%   T_encoded - 包含编码列的完整表格
%   encoding_info - 结构体，包含编码映射信息
%
% 示例:
%   % 基本用法
%   [X, T_encoded, info] = encodeCategoricalData(T);
%
%   % 指定要编码的列
%   cols = {'workclass', 'education', 'occupation'};
%   [X, T_encoded, info] = encodeCategoricalData(T, 'categorical_cols', cols);
%
%   % 使用独热编码
%   [X, T_encoded, info] = encodeCategoricalData(T, 'method', 'onehot');
%
%   % 编码后进行标准化
%   [X, T_encoded, info] = encodeCategoricalData(T, 'normalize', true);
%
% 作者: Claude
% 日期: 2025

    %% 解析输入参数
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
    
    %% 自动检测分类列（如果未指定）
    if isempty(categorical_cols)
        categorical_cols = {};
        for i = 1:width(T)
            col_data = T{:, i};
            % 检测字符串或cell类型的列
            if iscell(col_data) || isstring(col_data) || iscategorical(col_data)
                categorical_cols{end+1} = T.Properties.VariableNames{i};
            end
        end
        fprintf('自动检测到 %d 个分类列\n', length(categorical_cols));
    end
    
    %% 复制表格
    T_encoded = T;
    encoding_info = struct();
    
    %% 对每个分类列进行编码
    fprintf('开始编码分类变量...\n');
    
    for i = 1:length(categorical_cols)
        col_name = categorical_cols{i};
        
        if ~ismember(col_name, T.Properties.VariableNames)
            warning('列 "%s" 不存在，跳过', col_name);
            continue;
        end
        
        % 转换为categorical类型
        if ~iscategorical(T_encoded.(col_name))
            T_encoded.(col_name) = categorical(T_encoded.(col_name));
        end
        
        % 获取类别
        cats = categories(T_encoded.(col_name));
        
        % 保存映射信息
        encoding_info.(col_name).categories = cats;
        encoding_info.(col_name).method = method;
        
        if strcmp(method, 'label')
            % 标签编码
            encoded_col_name = [col_name '_encoded'];
            T_encoded.(encoded_col_name) = double(T_encoded.(col_name));
            encoding_info.(col_name).encoded_col = encoded_col_name;
            
            fprintf('  %s: %d个类别 -> %s\n', col_name, length(cats), encoded_col_name);
            
        elseif strcmp(method, 'onehot')
            % 独热编码
            encoded_vals = double(T_encoded.(col_name));
            onehot_matrix = dummyvar(encoded_vals);
            
            % 为每个类别创建新列
            onehot_col_names = cell(1, length(cats));
            for j = 1:length(cats)
                onehot_col_name = sprintf('%s_%s', col_name, matlab.lang.makeValidName(cats{j}));
                T_encoded.(onehot_col_name) = onehot_matrix(:, j);
                onehot_col_names{j} = onehot_col_name;
            end
            
            encoding_info.(col_name).encoded_cols = onehot_col_names;
            fprintf('  %s: %d个类别 -> %d个独热编码列\n', col_name, length(cats), length(cats));
        end
    end
    
    %% 提取数值列
    fprintf('提取数值列...\n');
    
    % 找出所有数值列（包括编码后的列）
    numeric_col_names = {};
    for i = 1:width(T_encoded)
        col_name = T_encoded.Properties.VariableNames{i};
        col_data = T_encoded.(col_name);
        
        if isnumeric(col_data)
            numeric_col_names{end+1} = col_name;
        end
    end
    
    % 创建数值矩阵
    X = table2array(T_encoded(:, numeric_col_names));
    encoding_info.numeric_columns = numeric_col_names;
    
    fprintf('数值矩阵维度: %d行 × %d列\n', size(X, 1), size(X, 2));
    
    %% 标准化（如果需要）
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


%% 辅助函数：显示编码映射
function displayEncodingInfo(encoding_info)
% DISPLAYENCODINGINFO 显示编码映射信息
%
% 输入:
%   encoding_info - encodeCategoricalData返回的编码信息结构体
%
% 示例:
%   displayEncodingInfo(info);

    fprintf('=== 编码映射信息 ===\n\n');
    
    field_names = fieldnames(encoding_info);
    
    for i = 1:length(field_names)
        field = field_names{i};
        
        % 跳过元信息字段
        if strcmp(field, 'numeric_columns') || strcmp(field, 'normalized') || strcmp(field, 'normalize_method')
            continue;
        end
        
        info = encoding_info.(field);
        
        fprintf('列名: %s\n', field);
        fprintf('编码方法: %s\n', info.method);
        fprintf('类别数: %d\n', length(info.categories));
        
        if strcmp(info.method, 'label')
            fprintf('编码后列名: %s\n', info.encoded_col);
            fprintf('类别映射:\n');
            for j = 1:length(info.categories)
                fprintf('  %s -> %d\n', info.categories{j}, j);
            end
        elseif strcmp(info.method, 'onehot')
            fprintf('独热编码列: %s\n', strjoin(info.encoded_cols, ', '));
        end
        
        fprintf('\n');
    end
    
    if isfield(encoding_info, 'normalized') && encoding_info.normalized
        fprintf('数据已标准化 (方法: %s)\n', encoding_info.normalize_method);
    end
    
    if isfield(encoding_info, 'numeric_columns')
        fprintf('数值列总数: %d\n', length(encoding_info.numeric_columns));
    end
end