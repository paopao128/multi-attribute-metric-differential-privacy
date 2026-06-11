function val = piecewise_linear_eval(e, x, m, b)
% Evaluate a piecewise-linear function with linear endpoint extrapolation.
e = e(:);
nseg = numel(m);
xl = x(1:end-1);
xr = x(2:end);

val = zeros(size(e));

idx = e <= xl(1);
val(idx) = m(1).*e(idx) + b(1);

idx = e >= xr(end);
val(idx) = m(end).*e(idx) + b(end);

idx_mid = ~(e <= xl(1) | e >= xr(end));
if any(idx_mid)
    em = e(idx_mid);
    [~, bin] = histc(em, [-inf; xr]); %#ok<HISTC>
    bin(bin < 1) = 1;
    bin(bin > nseg) = nseg;
    val(idx_mid) = m(bin).*em + b(bin);
end
end
