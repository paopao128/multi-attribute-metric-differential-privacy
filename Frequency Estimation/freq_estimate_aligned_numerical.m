function p = freq_estimate_aligned_numerical(x, values_ref)
% Estimate frequencies aligned to reference values
p = zeros(size(values_ref));
total = length(x);

for i = 1:length(values_ref)
    p(i) = sum(x == values_ref(i)) / total;
end
end