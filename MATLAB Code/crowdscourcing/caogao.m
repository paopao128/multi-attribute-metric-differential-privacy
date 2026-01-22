combined_score1 = normalize(sum(data_ori(:, 1:11), 2));
attr1_ori = min(5, max(1, round(combined_score1 * 4 + 1)));
attr1_ori(1:10)
% ===== Attribute 2: Acidity Balance =====
acidity_components = data_ori(:, [1,2,3]);   % fixed acidity, volatile acidity, citric acid
acidity_score = normalize(mean(acidity_components, 2));
attr2_ori = min(5, max(1, round(acidity_score * 4 + 1)));

% ===== Attribute 3: Sweetness + Alcohol =====
sweet_alcohol = data_ori(:, [4, 11]);        % residual sugar + alcohol
sweet_alcohol_score = normalize(mean(sweet_alcohol, 2));
attr3_ori = min(5, max(1, round(sweet_alcohol_score * 4 + 1)));

% ===== Attribute 4: Sulfur content =====
sulfur = data_ori(:, [6,7]);                 % free + total sulfur dioxide
sulfur_score = normalize(max(sulfur, [], 2));
attr4_ori = min(5, max(1, round((1 - sulfur_score) * 4 + 1)));

% ===== Attribute 5: Body & Texture =====
body_texture = data_ori(:, [5, 8, 10]);      % chlorides, density, sulphates
body_score = normalize(mean(body_texture, 2));
attr5_ori = min(5, max(1, round(body_score * 4 + 1)));

true_labels_change = [attr1, attr2, attr3, attr4, attr5];

%%
combined_score1 = normalize(sum(data(:, 1:11), 2));
attr1 = min(5, max(1, round(combined_score1 * 4 + 1)));
attr1(1:10)
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

true_labels_change = [attr1, attr2, attr3, attr4, attr5];