function x = normalize(v)
    x = (v - min(v)) ./ (max(v) - min(v) + 1e-8);
end