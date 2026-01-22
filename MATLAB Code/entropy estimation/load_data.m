%% Step 1: Load Real Heart Disease Dataset
%fprintf('Loading heart_disease_uci.csv dataset...\n');

% Load the CSV file
try
    data = readtable('heart_disease_uci.csv');
    %fprintf('Successfully loaded dataset with %d rows and %d columns\n', height(data), width(data));
catch ME
    error('Could not load heart_disease_uci.csv. Please make sure the file is in the current directory. Error: %s', ME.message);
end
%data=data(:,[1,2,6,7,10,12,16]);
% Display column names to understand the structure
%fprintf('Column names in the dataset:\n');
col_names = data.Properties.VariableNames;
for i = 1:length(col_names)
    %fprintf('  %d: %s\n', i, col_names{i});
end

%% Step 1.1: Data Preprocessing and Encoding
%fprintf('\nProcessing mixed data types...\n');

% Extract and process each feature
processed_data = [];
feature_names = {};

% Age (numeric)
if any(strcmp(col_names, 'age'))
    processed_data = [processed_data, data.age];
    feature_names{end+1} = 'age';
end

% Sex (Male=1, Female=0)
if any(strcmp(col_names, 'sex'))
    sex_numeric = double(strcmp(data.sex, 'Male'));
    processed_data = [processed_data, sex_numeric];
    feature_names{end+1} = 'sex';
end

% CP - Chest Pain Type (encode categorically)
if any(strcmp(col_names, 'cp'))
    cp_categories = unique(data.cp);
    cp_numeric = zeros(height(data), 1);
    for i = 1:length(cp_categories)
        cp_numeric(strcmp(data.cp, cp_categories{i})) = i-1;
    end
    processed_data = [processed_data, cp_numeric];
    feature_names{end+1} = 'cp';
    %fprintf('  CP categories: %s\n', strjoin(cp_categories, ', '));
end

% Trestbps (numeric)
if any(strcmp(col_names, 'trestbps'))
    processed_data = [processed_data, data.trestbps];
    feature_names{end+1} = 'trestbps';
end

% Chol (numeric)
if any(strcmp(col_names, 'chol'))
    processed_data = [processed_data, data.chol];
    feature_names{end+1} = 'chol';
end

% FBS (TRUE=1, FALSE=0)
if any(strcmp(col_names, 'fbs'))
    if iscell(data.fbs)
        % Handle text 'TRUE'/'FALSE'
        fbs_numeric = double(strcmp(data.fbs, 'TRUE'));
    elseif islogical(data.fbs)
        % Handle logical true/false
        fbs_numeric = double(data.fbs);
    else
        % Handle numeric
        fbs_numeric = data.fbs;
    end
    processed_data = [processed_data, fbs_numeric];
    feature_names{end+1} = 'fbs';
end

% RestECG (encode categorically)
if any(strcmp(col_names, 'restecg'))
    restecg_categories = unique(data.restecg);
    restecg_numeric = zeros(height(data), 1);
    for i = 1:length(restecg_categories)
        restecg_numeric(strcmp(data.restecg, restecg_categories{i})) = i-1;
    end
    processed_data = [processed_data, restecg_numeric];
    feature_names{end+1} = 'restecg';
    %fprintf('  RestECG categories: %s\n', strjoin(restecg_categories, ', '));
end

% Thalch (numeric) - note it's 'thalch' not 'thalach'
if any(strcmp(col_names, 'thalch'))
    processed_data = [processed_data, data.thalch];
    feature_names{end+1} = 'thalch';
end

% Exang (TRUE=1, FALSE=0)
if any(strcmp(col_names, 'exang'))
    if iscell(data.exang)
        % Handle text 'TRUE'/'FALSE'
        exang_numeric = double(strcmp(data.exang, 'TRUE'));
    elseif islogical(data.exang)
        % Handle logical true/false
        exang_numeric = double(data.exang);
    else
        % Handle numeric
        exang_numeric = data.exang;
    end
    processed_data = [processed_data, exang_numeric];
    feature_names{end+1} = 'exang';
end

% Oldpeak (numeric)
if any(strcmp(col_names, 'oldpeak'))
    processed_data = [processed_data, data.oldpeak];
    feature_names{end+1} = 'oldpeak';
end

% Slope (encode categorically)
if any(strcmp(col_names, 'slope'))
    slope_categories = unique(data.slope);
    slope_numeric = zeros(height(data), 1);
    for i = 1:length(slope_categories)
        slope_numeric(strcmp(data.slope, slope_categories{i})) = i-1;
    end
    processed_data = [processed_data, slope_numeric];
    feature_names{end+1} = 'slope';
    %fprintf('  Slope categories: %s\n', strjoin(slope_categories, ', '));
end

% CA (numeric)
if any(strcmp(col_names, 'ca'))
    processed_data = [processed_data, data.ca];
    feature_names{end+1} = 'ca';
end

% Thal (encode categorically)
if any(strcmp(col_names, 'thal'))
    thal_categories = unique(data.thal);
    thal_numeric = zeros(height(data), 1);
    for i = 1:length(thal_categories)
        thal_numeric(strcmp(data.thal, thal_categories{i})) = i-1;
    end
    processed_data = [processed_data, thal_numeric];
    feature_names{end+1} = 'thal';
    %fprintf('  Thal categories: %s\n', strjoin(thal_categories, ', '));
end

% Features matrix
X = processed_data;
if any(strcmp(col_names, 'num'))
    y = double(data.num > 0);
else
    error('Target column "num" not found in the dataset');
end

% Remove rows with missing values (NaN)
valid_rows = ~any(isnan(X), 2) & ~isnan(y);
X = X(valid_rows, :);
valid_rows2=randperm(length(X),200);
X = X(valid_rows2', :);
X=zscore(X);