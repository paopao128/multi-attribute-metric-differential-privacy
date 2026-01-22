%%
get_cost_matrix2;
%%
distance_all_attribute_sets;

%%
% sample_points;
%% 
loss_calculation2;

%% 
epsilon_allocation;

%%
real_loss_r;

%%
real_loss_m;

%%
BS_SPL;

%%
OPT_PND;

%%
OPT_RMP;

%%
src = 'result/result-t';

dst = sprintf('result/result-%d', 10);

copyfile(src, dst);
