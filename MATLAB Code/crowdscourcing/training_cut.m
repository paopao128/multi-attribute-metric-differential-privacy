% %% data processing
% attr1 = min(5, max(1, round((quality - 3) / 1.6 * 2 + 3)));
% 
% % Attribute 2: Acidity Balance (based on pH and fixed acidity)
% acidity_score = (data(:,1) - min(data(:,1))) / (max(data(:,1)) - min(data(:,1)));
% attr2 = min(5, max(1, round(acidity_score * 4 + 1)));
% 
% % Attribute 3: Alcohol Content Rating
% alcohol_score = (data(:,11) - min(data(:,11))) / (max(data(:,11)) - min(data(:,11)));
% attr3 = min(5, max(1, round(alcohol_score * 4 + 1)));
% 
% % Attribute 4: Sulfur Content (preservation quality)
% sulfur_score = 1 - (data(:,6) - min(data(:,6))) / (max(data(:,6)) - min(data(:,6)));
% attr4 = min(5, max(1, round(sulfur_score * 4 + 1)));
% 
% % Attribute 5: Overall Chemical Balance
% attr5 = min(5, max(1, round(quality / 2)));
% 
% true_labels = [attr1, attr2, attr3, attr4, attr5];


 % ===== Attribute 1: Overall Quality =====
    % combined_score1 = normalize(sum(data(:, 1:11), 2));
    % attr1 = min(5, max(1, round(combined_score1 * 4 + 1)));
    % 
    % % ===== Attribute 2: Acidity Balance =====
    % acidity_components = data(:, [1,2,3]);   % fixed acidity, volatile acidity, citric acid
    % acidity_score = normalize(mean(acidity_components, 2));
    % attr2 = min(5, max(1, round(acidity_score * 4 + 1)));
    % 
    % % ===== Attribute 3: Sweetness + Alcohol =====
    % sweet_alcohol = data(:, [4, 11]);        % residual sugar + alcohol
    % sweet_alcohol_score = normalize(mean(sweet_alcohol, 2));
    % attr3 = min(5, max(1, round(sweet_alcohol_score * 4 + 1)));
    % 
    % % ===== Attribute 4: Sulfur content =====
    % sulfur = data(:, [6,7]);                 % free + total sulfur dioxide
    % sulfur_score = normalize(max(sulfur, [], 2));
    % attr4 = min(5, max(1, round((1 - sulfur_score) * 4 + 1)));
    % 
    % % ===== Attribute 5: Body & Texture =====
    % body_texture = data(:, [5, 8, 10]);      % chlorides, density, sulphates
    % body_score = normalize(mean(body_texture, 2));
    % attr5 = min(5, max(1, round(body_score * 4 + 1)));
    % 
    % true_labels_change = [attr1, attr2, attr3, attr4, attr5];







%%
n_workers = 15;         % Number of workers
labels_per_sample = 5;  % Number of annotations per sample
n_attributes=5;
% Generate worker reliability (between 0.3-0.95)
%worker_reliability = 0.4 + 0.55 * rand(n_workers, n_attributes);
worker_reliability = 1 + 0.01 * rand(n_workers, n_attributes);
n_samples=150;
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
                labels(w_idx) = min(5, max(1, round(true_labels_change(sample, attr) + noise)));
            else
                % Low quality annotation: random label
                labels(w_idx) = randi(5);
            end
        end
        
        crowd_labels{sample, attr} = labels;
    end
    
    % Display progress
    % if mod(sample, 50) == 0
    %     fprintf('Completed %d/%d sample annotations\n', sample, n_samples);
    % end
end

%fprintf('Crowdsourcing annotation completed!\n');

%% 3. Annotation Quality Assessment
%fprintf('\n=== Annotation Quality Assessment ===\n');
%true_labels=true_labels_change;
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

%fprintf('Overall annotation accuracy: %.2f%%\n', overall_accuracy * 100);

% Worker reliability statistics
%fprintf('\nWorker reliability statistics:\n');
mean_reliability = mean(worker_reliability, 2);
%fprintf('Average reliability: %.3f (std: %.3f)\n', mean(mean_reliability), std(mean_reliability));
%fprintf('Highest reliability: %.3f\n', max(mean_reliability));
%fprintf('Lowest reliability: %.3f\n', min(mean_reliability));

%% 4. Aggregate Annotation Results
%fprintf('\nAggregating crowdsourced labels...\n');

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

%fprintf('Label aggregation completed!\n');

%% 5. Final Result Evaluation
%fprintf('\n=== Final Result Evaluation ===\n');

% Calculate accuracy for each attribute
attribute_accuracy = zeros(n_attributes, 1);
for attr = 1:n_attributes
    correct = sum(aggregated_labels(:, attr) == true_labels(:, attr));
    attribute_accuracy(attr) = correct / n_samples;
    %fprintf('%s: Accuracy %.2f%%\n', attribute_names{attr}, attribute_accuracy(attr) * 100);
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