script_dir = fileparts(mfilename('fullpath'));
result_dir = fullfile(script_dir, 'result', 'result-1');

addpath(fullfile(script_dir, 'benders', 'functions'));
addpath(fullfile(script_dir, 'benders', 'Dataset'));
addpath(fullfile(script_dir, 'benders', 'functions', 'myBDToolbox'));
addpath(fullfile(script_dir, 'benders', 'functions', 'myPlotToolbox'));
addpath(fullfile(script_dir, 'benders', 'functions', 'haversine'));
load(fullfile(result_dir, 'cost_attribute.mat'))
load(fullfile(result_dir, 'distance_all_attributes.mat'))
parameters;
distance_matrix=distance_all_attributes{1,1};
env_parameters.cost_matrix=cost_attribute{1,1};
env_parameters.NR_NODE_IN_TARGET=length(distance_matrix);
env_parameters.NR_OBFLOC=env_parameters.NR_NODE_IN_TARGET;

cluster_idx = kmeans(distance_matrix, env_parameters.NR_AGENT); 
adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);
obf_loc = randperm(length(distance_matrix), env_parameters.NR_OBFLOC);
env_parameters.obf_loc = obf_loc;

env_parameters.EPSILON=5;
agent = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters.NR_AGENT, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.EPSILON); 
masteragent  = masterAgentCreation(distance_matrix, agent, adjacence_matrix, cluster_idx, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.NR_AGENT, env_parameters.EPSILON); 
tic;
ITER = 100;
[~, ~, lowerbound_LB, upperbound_LB, upperbound__LB, loss_LB, obf_matrix_LB] = bendersDecomposition(masteragent, agent, env_parameters, ITER); 
time_LB=toc;
loss_matrix_LB=env_parameters.cost_matrix.*obf_matrix_LB;
loss_LB=sum(loss_matrix_LB(:));
