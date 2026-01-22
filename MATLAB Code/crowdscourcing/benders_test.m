addpath('./benders/functions/');                                                    
addpath('./benders/Dataset/'); 
addpath('./benders/functions/myBDToolbox');                                         
addpath('./benders/functions/myPlotToolbox');                                       
addpath('./benders/functions/haversine'); 
load("C:\Users\lry1t\Dropbox\Ruiyao Liu\multi_attribute_mDP\crowdsourcing\result-1\cost_attribute.mat")
load("C:\Users\lry1t\Dropbox\Ruiyao Liu\multi_attribute_mDP\crowdsourcing\result-1\distance_all_attributes.mat")
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