% CROWDSOURCING_MULTI_ATTRIBUTE - Crowdsourcing Multi-Attribute Dataset Annotation System
% Enhanced version with real dataset loading capability

fprintf('=== Crowdsourcing Multi-Attribute Dataset Annotation System ===\n\n');

%% Configuration: Choose dataset source
% Options: 'synthetic', 'wine', 'student', 'car', 'csv'
DATASET_SOURCE = 'wine';  % Change this to switch datasets
% CSV_FILE_PATH = 'my_data.csv';  % If using 'csv' option

%% 1. Load Dataset
fprintf('Loading dataset...\n');
num_data=150;
[data, true_labels, attribute_names, n_samples, n_attributes, n_features, quality] = load_wine_quality_dataset(num_data);
        


fprintf('Dataset loaded: %d samples, %d attributes, %d features\n', n_samples, n_attributes, n_features);
fprintf('Dataset source: %s\n', DATASET_SOURCE);

%% 2. Simulate Crowdsourcing Annotation Process
fprintf('\nSimulating crowdsourcing annotation process...\n');

n_workers = 15;         % Number of workers
labels_per_sample = 5;  % Number of annotations per sample

% Generate worker reliability (between 0.3-0.95)
worker_reliability = 1 + 0.01 * rand(n_workers, n_attributes);

% Initialize crowdsourced labels storage
crowd_labels = cell(n_samples, n_attributes);

for sample = 1:n_samples
    for attr = 1:n_attributes
        % Randomly select workers for annotation
        selected_workers = randperm(n_workers, labels_per_sample);
        labels = zeros(labels_per_sample, 1);
        
        for w_idx = 1:labels_per_sample
            worker = selected_workers(w_idx);
            reliability = worker_reliability(worker, attr);
            
            % Determine annotation quality based on reliability
            if rand() < reliability
                % High quality annotation: correct label with small noise
                noise = randn() * 0.0;
                labels(w_idx) = min(5, max(1, round(true_labels(sample, attr) + noise)));
            else
                % Low quality annotation: random label
                labels(w_idx) = randi(5);
            end
        end
        
        crowd_labels{sample, attr} = labels;
    end
    
    % Display progress
    if mod(sample, 50) == 0
        fprintf('Completed %d/%d sample annotations\n', sample, n_samples);
    end
end

fprintf('Crowdsourcing annotation completed!\n');

%% 3. Annotation Quality Assessment
fprintf('\n=== Annotation Quality Assessment ===\n');

total_annotations = 0;
correct_annotations = 0;
non_correct=0;
total_num=0;
for sample = 1:n_samples
    for attr = 1:n_attributes
        labels = crowd_labels{sample, attr};
        true_label = true_labels(sample, attr);
        
        total_annotations = total_annotations + length(labels);
        correct_annotations = correct_annotations + sum(labels == true_label);
        non_correct=non_correct+sum(abs(labels - true_label));
        total_num=total_num+sum(labels);
    end
end

% overall_accuracy = correct_annotations / total_annotations;
overall_accuracy = 1-(non_correct / total_num);
fprintf('Overall annotation accuracy: %.2f%%\n', overall_accuracy * 100);

% Worker reliability statistics
fprintf('\nWorker reliability statistics:\n');
mean_reliability = mean(worker_reliability, 2);
fprintf('Average reliability: %.3f (std: %.3f)\n', mean(mean_reliability), std(mean_reliability));
fprintf('Highest reliability: %.3f\n', max(mean_reliability));
fprintf('Lowest reliability: %.3f\n', min(mean_reliability));

%% 4. Aggregate Annotation Results
fprintf('\nAggregating crowdsourced labels...\n');

aggregated_labels = zeros(n_samples, n_attributes);

for sample = 1:n_samples
    for attr = 1:n_attributes
        labels = crowd_labels{sample, attr};
        
        % Use weighted voting for aggregation
        if ~isempty(labels)
            % Simple majority voting
            vote_counts = zeros(5, 1);
            for label_idx = 1:length(labels)
                label = labels(label_idx);
                if label >= 1 && label <= 5
                    vote_counts(label) = vote_counts(label) + 1;
                end
            end
            [~, aggregated_labels(sample, attr)] = max(vote_counts);
            
            % If tied, use mean value
            if sum(vote_counts == max(vote_counts)) > 1
                aggregated_labels(sample, attr) = round(mean(labels));
            end
        else
            aggregated_labels(sample, attr) = 3; % Default middle value
        end
    end
end

fprintf('Label aggregation completed!\n');

%% 5. Final Result Evaluation
fprintf('\n=== Final Result Evaluation ===\n');

% Calculate accuracy for each attribute
attribute_accuracy = zeros(n_attributes, 1);
for attr = 1:n_attributes
    correct = sum(aggregated_labels(:, attr) == true_labels(:, attr));
    attribute_accuracy(attr) = correct / n_samples;
    fprintf('%s: Accuracy %.2f%%\n', attribute_names{attr}, ...
        attribute_accuracy(attr) * 100);
end

% Overall accuracy
overall_accuracy_final = mean(attribute_accuracy);
%fprintf('\nOverall accuracy: %.2f%%\n', overall_accuracy_final * 100);

% Calculate Mean Absolute Error (MAE)
mae = mean(abs(aggregated_labels - true_labels), 'all');
%fprintf('Mean Absolute Error (MAE): %.3f\n', mae);

% Calculate Root Mean Square Error (RMSE)
rmse = sqrt(mean((aggregated_labels - true_labels).^2, 'all'));
%fprintf('Root Mean Square Error (RMSE): %.3f\n', rmse);


overall_accuracy_final_ori=overall_accuracy_final;
overall_accuracy_ori=overall_accuracy;
%% cost
attribute_set=cell(1,4);
attribute_set{1,1}=[1,2,3,4,8,9,11];
attribute_set{1,2}=[5];
attribute_set{1,3}=[6,7];
attribute_set{1,4}=[10];

data_ori=data;
cost_attribute=cell(1,length(attribute_set));
for attribute_set_id=1:length(attribute_set)
    [uniqueVals, ~, value_idx] = unique(data(:,attribute_set{1,attribute_set_id}), 'rows');
    cost_matrix=zeros(length(uniqueVals(:,1)),length(uniqueVals(:,1)));
        for cost_row_id=1:1:length(uniqueVals(:,1))
            obfuscation_i=find(value_idx==cost_row_id);
            for cost_col_id=1:1:length(uniqueVals(:,1))
                obfuscation_value=uniqueVals(cost_col_id,:);
                if cost_row_id~=cost_col_id
                    for id_same_values=1:length(obfuscation_i)
                        data=data_ori;
                        data(obfuscation_i(id_same_values),attribute_set{1,attribute_set_id})=obfuscation_value;





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

    true_labels_change = [attr1, attr2, attr3, attr4, attr5];





                        training_cut;

                        cost_matrix(cost_row_id,cost_col_id)=cost_matrix(cost_row_id,cost_col_id)+(overall_accuracy_ori-overall_accuracy)/overall_accuracy_ori*10000;
                    end
                    cost_matrix(cost_row_id,cost_col_id)=cost_matrix(cost_row_id,cost_col_id)/length(obfuscation_i);
                end
                fprintf('attribute set id: %d       cost matrxi:      row = %d,      col = %d,      value = %.2f\n', attribute_set_id, cost_row_id, cost_col_id, cost_matrix(cost_row_id, cost_col_id));
            end
        end
        cost_attribute{1,attribute_set_id}=cost_matrix;
end
data=data_ori;
save('result/result-1/data.mat','data');
save('result/result-1/overall_accuracy_ori.mat','overall_accuracy_ori');
save('result/result-1/overall_accuracy_final_ori.mat','overall_accuracy_final_ori');
save('result/result-1/quality.mat','quality');

cost_attribute_ori=cost_attribute;
save('result/result-1/cost_attribute_ori.mat','cost_attribute_ori');
for attribute_id=1:length(cost_attribute)
    cost_attribute{1,attribute_id}=cost_attribute{1,attribute_id}/length(cost_attribute{1,attribute_id});
end
save('result/result-1/cost_attribute.mat','cost_attribute');
