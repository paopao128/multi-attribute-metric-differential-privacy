load_data;

%% entropy_cost_matrix.m
% Calculate cost matrices based on entropy estimation
% For multi-attribute dataset obfuscation analysis


%% ========== CONFIGURATION ==========
% Load your preprocessed data
% Assuming X is already loaded as a 308x13 matrix
% If X is in a .mat file, uncomment the next line:
% load('your_data.mat', 'X');

% For demonstration, generate sample data (replace with your actual data)
% rng(42);

fprintf('Data shape: %d × %d\n', size(X,1), size(X,2));

%% Define attribute sets
attribute_set = cell(1,6);
attribute_set{1,1} = [2,13];
attribute_set{1,2} = [6];
attribute_set{1,3} = [7];
attribute_set{1,4} = [3,9];
attribute_set{1,5} = [1,4,5,8,10,11];
attribute_set{1,6} = [12];

fprintf('\nAttribute set configuration:\n');
for i = 1:length(attribute_set)
    fprintf('  Set %d: [%s] (%d attributes)\n', i, ...
        num2str(attribute_set{1,i}), length(attribute_set{1,i}));
end

%% Discretize continuous data for entropy calculation
% Convert continuous values to discrete bins
n_bins = 10;  % Number of bins for discretization
X_discrete = discretize_data(X, n_bins);
fprintf('\nData discretized into %d bins per attribute\n', n_bins);

%% Calculate baseline entropy (clean data)
all_attrs = 1:size(X, 2);
H_clean = calculate_entropy_metrics(X_discrete, all_attrs);

fprintf('\n=== Baseline Entropy Metrics (Clean Data) ===\n');
fprintf('Total marginal entropy: %.4f\n', H_clean.total_marginal);
fprintf('Average marginal entropy: %.4f\n', H_clean.avg_marginal);
fprintf('Joint entropy (all attributes): %.4f\n', H_clean.joint_entropy);

%% ============= COST MATRIX CALCULATION =============
fprintf('\n=== Starting Cost Matrix Calculation ===\n\n');

X_ori = X_discrete;  % Save original discretized data
cost_attribute = cell(1, length(attribute_set));

for attr_set_id = 1:length(attribute_set)
    fprintf('Processing attribute set %d/%d...\n', attr_set_id, length(attribute_set));
    
    % Get current attribute columns
    current_attr_cols = attribute_set{1, attr_set_id};
    fprintf('  Attributes: [%s]\n', num2str(current_attr_cols));
    
    % Get unique value combinations for this attribute set
    [uniqueVals, ~, value_idx] = unique(X_discrete(:, current_attr_cols), 'rows');
    n_unique = size(uniqueVals, 1);
    fprintf('  Found %d unique value combinations\n', n_unique);
    
    % Initialize cost matrix
    cost_matrix = zeros(n_unique, n_unique);
    
    % Calculate cost for each pair of values
    for cost_row_id = 1:n_unique
        % Find all samples with this original value
        obfuscation_indices = find(value_idx == cost_row_id);
        n_samples_with_value = length(obfuscation_indices);
        
        if mod(cost_row_id, 10) == 0 || cost_row_id == 1
            fprintf('  Processing row %d/%d (%d samples)...\n', ...
                cost_row_id, n_unique, n_samples_with_value);
        end
        
        for cost_col_id = 1:n_unique
            if cost_row_id ~= cost_col_id
                % Get the obfuscation value
                obfuscation_value = uniqueVals(cost_col_id, :);
                
                % Calculate cost for all samples with this original value
                total_cost = 0;
                
                for sample_id = 1:n_samples_with_value
                    % Restore original data
                    X_temp = X_ori;
                    
                    % Apply obfuscation: replace the attribute values
                    sample_idx = obfuscation_indices(sample_id);
                    X_temp(sample_idx, current_attr_cols) = obfuscation_value;
                    
                    % Calculate entropy metrics with obfuscated data
                    H_obfuscated = calculate_entropy_metrics(X_temp, all_attrs);
                    
                    % Calculate comprehensive cost
                    cost = calculate_entropy_cost(H_clean, H_obfuscated, ...
                        current_attr_cols, all_attrs);
                    
                    total_cost = total_cost + cost;
                end
                
                % Average cost over all samples with the same original value
                cost_matrix(cost_row_id, cost_col_id) = total_cost / n_samples_with_value;
            end
        end
        
        % Progress update
        if mod(cost_row_id, 10) == 0 || cost_row_id == n_unique
            fprintf('    Completed row %d/%d\n', cost_row_id, n_unique);
        end
    end
    
    % Store cost matrix for this attribute set
    cost_attribute{1, attr_set_id} = cost_matrix;
    
    fprintf('✓ Completed attribute set %d\n', attr_set_id);
    fprintf('  Cost matrix size: %d × %d\n', size(cost_matrix, 1), size(cost_matrix, 2));
    fprintf('  Max cost: %.4f\n', max(cost_matrix(:)));
    fprintf('  Mean non-zero cost: %.4f\n', mean(cost_matrix(cost_matrix > 0)));
    fprintf('  Min non-zero cost: %.4f\n\n', min(cost_matrix(cost_matrix > 0)));
end

%% Save results
fprintf('Saving results...\n');
if ~exist('result', 'dir')
    mkdir('result');
end
if ~exist('result/entropy-based', 'dir')
    mkdir('result/entropy-based');
end

save('result/result-1/X.mat', 'X');
save('result/result-1/cost_attribute.mat', 'cost_attribute');
save('result/result-1/H_clean.mat', 'H_clean');
save('result/result-1/attribute_set.mat', 'attribute_set');

fprintf('\n=== Cost Matrix Calculation Complete ===\n');
fprintf('Results saved to result/entropy-based/\n');

%% Display summary statistics
fprintf('\n=== Summary Statistics ===\n');
for i = 1:length(cost_attribute)
    cm = cost_attribute{1, i};
    fprintf('Attribute Set %d:\n', i);
    fprintf('  Matrix size: %d × %d\n', size(cm, 1), size(cm, 2));
    fprintf('  Max cost: %.4f\n', max(cm(:)));
    fprintf('  Mean cost: %.4f\n', mean(cm(cm > 0)));
    fprintf('  Std cost: %.4f\n', std(cm(cm > 0)));
    fprintf('  Non-zero entries: %d (%.1f%%)\n\n', ...
        sum(cm(:) > 0), 100*sum(cm(:) > 0)/numel(cm));
end

%% Visualize cost matrices (optional)
% fprintf('Generating visualizations...\n');
% figure('Position', [100, 100, 1200, 800]);
% for i = 1:length(cost_attribute)
%     subplot(2, 3, i);
%     imagesc(cost_attribute{1,i});
%     colorbar;
%     title(sprintf('Attribute Set %d', i));
%     xlabel('Target Value');
%     ylabel('Original Value');
%     axis square;
% end
% saveas(gcf, 'result/entropy-based/cost_matrices_heatmap.png');
% fprintf('Visualization saved.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HELPER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X_discrete = discretize_data(X, n_bins)
    % Discretize continuous data into bins for entropy calculation
    [n_samples, n_attrs] = size(X);
    X_discrete = zeros(n_samples, n_attrs);
    
    for i = 1:n_attrs
        col_data = X(:, i);
        % Use equal-width binning
        edges = linspace(min(col_data), max(col_data), n_bins + 1);
        edges(end) = edges(end) + eps;  % Include max value
        X_discrete(:, i) = discretize(col_data, edges);
    end
end

function H_metrics = calculate_entropy_metrics(X, attr_cols)
    % Calculate comprehensive entropy metrics
    % Returns a structure with multiple entropy measures
    
    H_metrics = struct();
    n_attrs = length(attr_cols);
    
    % 1. Marginal entropies for each attribute
    marginal_entropies = zeros(1, n_attrs);
    for i = 1:n_attrs
        col_idx = attr_cols(i);
        marginal_entropies(i) = calculate_shannon_entropy(X(:, col_idx));
    end
    
    H_metrics.marginal_entropies = marginal_entropies;
    H_metrics.total_marginal = sum(marginal_entropies);
    H_metrics.avg_marginal = mean(marginal_entropies);
    
    % 2. Joint entropy of all attributes
    H_metrics.joint_entropy = calculate_joint_entropy(X(:, attr_cols));
    
    % 3. Total correlation (multi-information)
    % TC = sum(H(X_i)) - H(X_1, ..., X_n)
    H_metrics.total_correlation = H_metrics.total_marginal - H_metrics.joint_entropy;
    
    % 4. Normalized metrics
    H_metrics.normalized_joint = H_metrics.joint_entropy / n_attrs;
end

function H = calculate_shannon_entropy(x)
    % Calculate Shannon entropy: H(X) = -sum(p(x) * log2(p(x)))
    
    % Get probability distribution
    [~, ~, idx] = unique(x);
    counts = histcounts(idx, 1:max(idx)+1);
    probs = counts / sum(counts);
    
    % Remove zero probabilities
    probs = probs(probs > 0);
    
    % Calculate entropy
    H = -sum(probs .* log2(probs));
end

function H_joint = calculate_joint_entropy(X)
    % Calculate joint entropy: H(X1, X2, ..., Xn)
    
    % Treat each row as a unique combination
    [~, ~, idx] = unique(X, 'rows');
    counts = histcounts(idx, 1:max(idx)+1);
    probs = counts / sum(counts);
    
    % Remove zero probabilities
    probs = probs(probs > 0);
    
    % Calculate entropy
    H_joint = -sum(probs .* log2(probs));
end

function cost = calculate_entropy_cost(H_clean, H_obfuscated, ...
                                       changed_attrs, all_attrs)
    % Calculate cost based on multiple entropy-based metrics
    % Uses weighted combination of different entropy changes
    
    % Weight parameters (can be tuned)
    w_marginal = 0.3;      % Weight for marginal entropy change
    w_joint = 0.4;         % Weight for joint entropy change
    w_correlation = 0.3;   % Weight for total correlation change
    
    % 1. Marginal entropy loss (for changed attributes)
    marginal_loss = 0;
    for attr = changed_attrs
        attr_idx = find(all_attrs == attr);
        if ~isempty(attr_idx)
            delta_H = abs(H_clean.marginal_entropies(attr_idx) - ...
                         H_obfuscated.marginal_entropies(attr_idx));
            marginal_loss = marginal_loss + delta_H;
        end
    end
    marginal_loss = marginal_loss / length(changed_attrs);  % Average
    
    % 2. Joint entropy change
    joint_loss = abs(H_clean.joint_entropy - H_obfuscated.joint_entropy);
    
    % 3. Total correlation change
    correlation_loss = abs(H_clean.total_correlation - H_obfuscated.total_correlation);
    
    % 4. Combined cost with normalization
    cost = w_marginal * marginal_loss + ...
           w_joint * joint_loss + ...
           w_correlation * correlation_loss;
    
    % Scale to reasonable range (0-100)
    cost = cost * 100;
end