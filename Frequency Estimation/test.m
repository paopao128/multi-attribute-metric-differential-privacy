%% adult_global_utility.m
% Global utility u for frequency estimation across multiple attributes
clear; clc;

%% Load Adult data (robust to .data extension)
colNames = { ...
    'age','workclass','fnlwgt','education','education_num', ...
    'marital_status','occupation','relationship','race','sex', ...
    'capital_gain','capital_loss','hours_per_week', ...
    'native_country','income'};

opts = detectImportOptions('adult.data','FileType','text','Delimiter',',');
opts.VariableNames = colNames;
opts = setvaropts(opts, colNames, 'TreatAsMissing', '?');
T = readtable('adult.data', opts);
T = rmmissing(T);
fprintf('Loaded %d samples\n', height(T));

%% Choose attributes for frequency estimation (categorical ones)
attrs = {'education','occupation','race','sex','marital_status','workclass'};
d = numel(attrs);

% weights (single global u uses these weights inside)
w = ones(d,1);   % you can change to your importance weights

%% Reference "true" distributions p_j
% In experiments, we typically treat clean empirical frequencies as reference.
ref = build_reference_marginals(T, attrs);

%% Define obfuscation strength
pFlip = 0.10;     % obfuscation probability
% rng(0);           % reproducibility

%% Compute u_clean (should be 0 error => u = 0 under this reference choice)
u_clean = global_utility_marginal(T, attrs, w, ref);
fprintf('u_clean = %.6f\n', u_clean);

%% Example 1: Obfuscate one attribute i and compute the SAME global u
i = 1; % obfuscate attrs{1}
T_i = T;
T_i.(attrs{i}) = obfuscate_categorical(categorical(T.(attrs{i})), pFlip);
u_i = global_utility_marginal(T_i, attrs, w, ref);
fprintf('Obfuscate %s: u = %.6f, loss = %.6f\n', attrs{i}, u_i, (u_clean - u_i));

%% Example 2: Loop over all attributes, each time obfuscate only that one
loss_each = zeros(d,1);
u_each = zeros(d,1);
for k = 1:d
    Tk = T;
    Tk.(attrs{k}) = obfuscate_categorical(categorical(T.(attrs{k})), pFlip);
    u_each(k) = global_utility_marginal(Tk, attrs, w, ref);
    loss_each(k) = u_clean - u_each(k);  % >= 0
end

disp(table(attrs(:), u_each, loss_each, 'VariableNames', {'Attribute','u','UtilityLoss'}));

%% Example 3 (optional): Obfuscate a set S of attributes and compute ONE u
S = [1 4]; % e.g., education and sex
T_S = T;
for idx = S
    T_S.(attrs{idx}) = obfuscate_categorical(categorical(T.(attrs{idx})), pFlip);
end
u_S = global_utility_marginal(T_S, attrs, w, ref);
fprintf('Obfuscate set %s: u = %.6f, loss = %.6f\n', mat2str(S), u_S, (u_clean - u_S));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions (keep in same file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ref = build_reference_marginals(T, attrs)
% Build reference marginal distributions p_j from clean data
ref = struct();
for i = 1:numel(attrs)
    a = attrs{i};
    x = categorical(T.(a));
    [cats, p] = freq_estimate(x);
    ref.(a).cats = cats;
    ref.(a).p = p;
end
end

function u = global_utility_marginal(T, attrs, w, ref)
% Single global utility u = - sum_j w_j ||p_hat_j - p_ref_j||_2^2
E = 0;
for i = 1:numel(attrs)
    a = attrs{i};
    cats_ref = ref.(a).cats;
    p_ref = ref.(a).p;

    x = categorical(T.(a));
    p_hat = freq_estimate_aligned(x, cats_ref);

    E = E + w(i) * sum((p_hat - p_ref).^2);
end
u = -E;
end

function x_obs = obfuscate_categorical(x, p)
% Randomly replace a fraction p of entries with random categories.
cats = categories(x);
x_obs = x;
mask = rand(length(x),1) < p;
x_obs(mask) = cats(randi(numel(cats), sum(mask), 1));
end

function [cats, p] = freq_estimate(x)
% Return categories and normalized frequencies aligned with cats.
[counts, cats] = groupcounts(x);
p = counts / sum(counts);
end

function p = freq_estimate_aligned(x, cats_ref)
% Estimate frequencies of x and align to cats_ref (missing => 0).
[counts, cats] = groupcounts(x);
p = zeros(size(cats_ref));
total = sum(counts);

for i = 1:numel(cats_ref)
    idx = find(cats == cats_ref(i));
    if ~isempty(idx)
        p(i) = counts(idx) / total;
    else
        p(i) = 0;
    end
end
end
