function [data, true_labels, attribute_names, n_samples, n_attributes, n_features, quality] = load_wine_quality_dataset(num_data)

    wine_data = readtable('winequality-red.csv');
    
    % Random selection
    data_row = randi(height(wine_data), num_data, 1);
    data = table2array(wine_data(data_row, 1:end-1));
    quality = table2array(wine_data(data_row, end)); % original label 0–10

    % ===== Attribute 1: Overall Quality =====
    combined_score1 = normalize(sum(data(:, 1:11), 2));
    attr1 = min(5, max(1, round(combined_score1 * 4 + 1)));

    % ===== Attribute 2: Acidity Balance =====
    acidity_components = data(:, [1,2,3]);   % fixed acidity, volatile acidity, citric acid
    acidity_score = normalize(mean(acidity_components, 2));
    attr2 = min(5, max(1, round(acidity_score * 4 + 1)));

    % ===== Attribute 3: Sweetness + Alcohol =====
    sweet_alcohol = data(:, [4, 11]);        % residual sugar + alcohol
    sweet_alcohol_score = normalize(mean(sweet_alcohol, 2));
    attr3 = min(5, max(1, round(sweet_alcohol_score * 4 + 1)));

    % ===== Attribute 4: Sulfur content =====
    sulfur = data(:, [6,7]);                 % free + total sulfur dioxide
    sulfur_score = normalize(max(sulfur, [], 2));
    attr4 = min(5, max(1, round((1 - sulfur_score) * 4 + 1)));

    % ===== Attribute 5: Body & Texture =====
    body_texture = data(:, [5, 8, 10]);      % chlorides, density, sulphates
    body_score = normalize(mean(body_texture, 2));
    attr5 = min(5, max(1, round(body_score * 4 + 1)));

    true_labels = [attr1, attr2, attr3, attr4, attr5];

    attribute_names = {'Overall Quality', 'Acidity Balance', ...
                       'Sweetness & Alcohol', 'Preservation', 'Body & Texture'};

    [n_samples, n_features] = size(data);
    n_attributes = size(true_labels, 2);
end
