%% Header
addpath('./functions/');                                                    % Functions
addpath('./Dataset/'); 
addpath('./functions/myBDToolbox');                                         % My Benders decomposition toolbox
addpath('./functions/myPlotToolbox');                                       % My plot toolbox
addpath('./functions/haversine');                                          % Read the Haversine distance package. This package is created by Created by Josiah Renfree, May 27, 2010
parameters;                                                                 % Read the parameters of the simulation
env_parameters.NR_NODE_IN_TARGET=num_rec(id_num_rec);
fprintf('number of nodes is %d, id_repeat_times: %d \n', env_parameters.NR_NODE_IN_TARGET, id_repeat_times);
%fprintf('------------------- Environment settings --------------------- \n \n'); 

%% Read the map information
%fprintf("Loading the map information ... \n")
load('rome_df_nodes.mat');
load('rome_df_edges.mat');

col_longitude = table2array(df_nodes(:, 'x'));                              % Actual x (longitude) coordinate from the nodes data
col_latitude = table2array(df_nodes(:, 'y'));                               % Actual y (latitude) coordinate from the nodes data
freq=table2array(df_nodes(:, 'street_count'));                          
env_parameters.NR_LOC = size(col_longitude, 1); 

%fprintf("The map information has been loaded. \n")
[G, u, v] = graph_preparation(df_nodes, df_edges);               % Given the map information, create the mobility graph
load('u.mat');
load('v.mat');
load('G.mat'); %fast





%% Find the set of nodes in the target region

NR_LOC=length(col_latitude);
node_in_target = randperm(NR_LOC, env_parameters.NR_NODE_IN_TARGET);
freq=freq(node_in_target);
node_in_target_ori=node_in_target;


loc_x_in_target = col_longitude(node_in_target);                           
loc_y_in_target = col_latitude(node_in_target);
%fprintf('The number of nodes is %d  \n', env_parameters.NR_NODE_IN_TARGET);

%% Perturbed locations are randomly distributed over the target region
obf_loc = randperm(size(node_in_target, 2), env_parameters.NR_OBFLOC);

env_parameters.obf_loc = obf_loc;
%fprintf('The number of perturbed locations is %d  \n \n', env_parameters.NR_OBFLOC);


%% Distance matrix calculation                                                           
distance_matrix = distanceMatrix(col_longitude(node_in_target), col_latitude(node_in_target));
distance_matrix_original=distance_matrix;
adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);       % Create the adjacency matrix. 
adjacence_matrix_original=adjacence_matrix;
mDPMatrix = adjacence_matrix.*distance_matrix;                              % Create the mDP matrix. 
mDPGraph = graph(mDPMatrix);                                                % Create the mDP graph using the mDP matrix
% path_distance_matrix = distances(mDPGraph);                                 % Calculate the path distance using the mDP graph






%%
%num_user=5+floor(i_positionnn/10);
num_user=env_parameters.NR_AGENT;
user=randperm(env_parameters.NR_NODE_IN_TARGET, num_user);






%%
[adjacence_matrix, distance_matrix, epsilon_nmw] = reget(adjacence_matrix, distance_matrix, all_target, epsilon_nmw);
env_parameters.NR_NODE_IN_TARGET=length(distance_matrix);
task_loc = 2;

freq=freq(1:length(all_target))/sum(freq(1:length(all_target)));
env_parameters.cost_matrix = costMatrix(node_in_target, task_loc, obf_loc, G, all_target, freq, real);             % Calculate the cost matrix
node_in_target_ori=node_in_target;
[loss_benchmarks,loss_Bayesian_Remapping,time_BR]=loss_for_benchmark(env_parameters, obf_loc, distance_matrix_original, node_in_target_ori, G, task_loc);
node_in_target = node_in_target(1,all_target);


%% 2PPO
% Cluster the nodes
env_parameters.NR_AGENT=20;
cluster_idx = kmeans(distance_matrix, env_parameters.NR_AGENT); 
% Create the agents
%env_parameters.NEIGHBOR_THRESHOLD=1;
%fprintf('------------------- Create the agents ----------------------- \n'); 
tic;
agent_2PPO = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters.NR_AGENT, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.EPSILON); 
%fprintf('%d agents have been created. \n', env_parameters.NR_AGENT); 

% Create the master agent
%fprintf('------------------- Create the agents ----------------------- \n'); 
masteragent  = masterAgentCreation(distance_matrix, agent_2PPO, adjacence_matrix, cluster_idx, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.NR_AGENT, env_parameters.EPSILON); 
time2=toc;

% The algorithm starts here!!
tic;
ITER = 100; 
[~, ~, lowerbound, upperbound, upperbound_, loss1, obf_matrix] = bendersDecomposition(masteragent, agent_2PPO, env_parameters, ITER); 
time_2PPO=toc;
loss_matrix=env_parameters.cost_matrix.*obf_matrix;
loss=sum(loss_matrix(:));



%% LB
parameters;
distance_matrix=distance_all_attributes{1,4};
env_parameters.cost_matrix=cost_attribute{1,4};
env_parameters.NR_NODE_IN_TARGET=length(distance_matrix);
env_parameters.NR_OBFLOC=round(env_parameters.NR_NODE_IN_TARGET/3);

cluster_idx = kmeans(distance_matrix, env_parameters.NR_AGENT); 
adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);
obf_loc = randperm(size(node_in_target, 2), env_parameters.NR_OBFLOC);
env_parameters.obf_loc = obf_loc;


agent = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters.NR_AGENT, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.EPSILON); 
masteragent  = masterAgentCreation(distance_matrix, agent, adjacence_matrix, cluster_idx, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.NR_AGENT, env_parameters.EPSILON); 
tic;
ITER = 100;
[~, ~, lowerbound_LB, upperbound_LB, upperbound__LB, loss_LB, obf_matrix_LB] = bendersDecomposition(masteragent, agent, env_parameters, ITER); 
time_LB=toc;
loss_matrix_LB=env_parameters.cost_matrix.*obf_matrix_LB;
loss_LB=sum(loss_matrix_LB(:));


%time_2PPO
ep=min(env_parameters.EPSILON,epsilon_nmw);

time_2PPO;
phase1_budget=mean(ep(:));
safety_margin=mean(privacy_budget(:));

