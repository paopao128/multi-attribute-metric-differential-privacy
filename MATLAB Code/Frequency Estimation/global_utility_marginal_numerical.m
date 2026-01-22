function u = global_utility_marginal_numerical(X, attr_cols, ref)
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
    
    E = E + sum((p_hat - p_ref).^2);
end

u = -E;
end