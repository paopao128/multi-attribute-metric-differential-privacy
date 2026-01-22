function [loss_benders] = cal_loss_benders(epsilon_value,distance_matrix_input,cost,threshould_adj)
    addpath('./benders/functions/');                                                     
    addpath('./benders/functions/myBDToolbox');                                         
    addpath('./benders/functions/myPlotToolbox');                                       
    addpath('./benders/functions/haversine'); 
    parameters;
    distance_matrix=distance_matrix_input;
    env_parameters.cost_matrix=cost;
    env_parameters.NR_NODE_IN_TARGET=length(distance_matrix);
    env_parameters.NR_OBFLOC=env_parameters.NR_NODE_IN_TARGET;
    env_parameters.NEIGHBOR_THRESHOLD=threshould_adj;
    
    loss_benders=zeros(1,length(epsilon_value));
    cluster_idx = kmeans(distance_matrix, env_parameters.NR_AGENT); 
    adjacence_matrix = heaviside(1 - distance_matrix/env_parameters.NEIGHBOR_THRESHOLD);
    obf_loc = 1:1:length(distance_matrix);
    env_parameters.obf_loc = obf_loc;
    for epsilon_id=1:1:length(epsilon_value)
        epsilon=epsilon_value(epsilon_id);
        env_parameters.EPSILON=epsilon;
        agent = agentCreation(cluster_idx, adjacence_matrix, distance_matrix, env_parameters.NR_AGENT, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.EPSILON); 
        masteragent  = masterAgentCreation(distance_matrix, agent, adjacence_matrix, cluster_idx, env_parameters.NR_NODE_IN_TARGET, env_parameters.NR_OBFLOC, env_parameters.NR_AGENT, env_parameters.EPSILON); 
        ITER = 1000;
        [~, ~, ~, ~, ~, ~, obf_matrix_LB] = bendersDecomposition(masteragent, agent, env_parameters, ITER); 
        loss_matrix_LB=env_parameters.cost_matrix.*obf_matrix_LB;
        loss_benders(1,epsilon_id)=sum(loss_matrix_LB(:));
    end
end