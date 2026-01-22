function [data, true_labels, attribute_names, n_samples, n_attributes, n_features] = generate_synthetic_dataset()
    % Generate synthetic multi-attribute dataset (original implementation)
    
    fprintf('Generating synthetic multi-attribute dataset...\n');
    
    n_samples = 200;
    n_attributes = 5;
    n_features = 10;
    
    attribute_names = {'Quality Rating', 'Price Reasonableness', ...
        'User Friendliness', 'Innovation', 'Reliability'};
    
    data = randn(n_samples, n_features);
    
    weights = cell(n_attributes, 1);
    for i = 1:n_attributes
        weights{i} = randn(n_features, 1);
        weights{i} = weights{i} / norm(weights{i});
    end
    
    true_labels = zeros(n_samples, n_attributes);
    for i = 1:n_attributes
        scores = data * weights{i};
        true_labels(:, i) = min(5, max(1, round(3 + 2*tanh(scores))));
    end
end