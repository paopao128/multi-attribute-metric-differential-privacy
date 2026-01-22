load("result/result-t/cost_attribute.mat")
load("result/result-t/distance_all_attributes.mat")
load("result/result-t/loss_eval_lower.mat")
load("result/result-t/loss_eval_upper.mat")
load("result/result-t/loss_table.mat")

attribute_set = cell(1,6);
attribute_set{1,1} = [2,13];
attribute_set{1,2} = [6];
attribute_set{1,3} = [7];
attribute_set{1,4} = [3,9];
attribute_set{1,5} = [1,4,5,8,10,11];
attribute_set{1,6} = [12];


n = length(attribute_set);
computation_time=zeros(length(1:1:10),1);
epsilon_i=1:1:10;
loss_lower=zeros(length(1:1:10),1);
loss_upper=zeros(length(1:1:10),1);

epsilon_allocation_lower=zeros(length(1:1:10),n);
epsilon_allocation_upper=zeros(length(1:1:10),n);
for epsilon_id=1:length(epsilon_i)
    tic;
    eps_budget = epsilon_i(epsilon_id);
    
    % for i=1:n
    %     costi_min=min(cost_attribute{i}(:));
    %     cost_attribute{i}=cost_attribute{i}+(abs(costi_min)+50)*(~eye(size(cost_attribute{i})));
    % end
    
    
    
    % cost_attribute{1}=1.00859*cost_attribute{1};
    % cost_attribute{2}=0.991475*cost_attribute{2};
    % cost_attribute{3}=0.736224*cost_attribute{3};
    % cost_attribute{4}=1.00261*cost_attribute{4};
    
    %% real
    % for i = 1:1
    %     Di = distance_all_attributes{i};
    %     Ci = cost_attribute{i};
    %     loss_eval{i} = @(e) cal_loss_benders(e, Di, Ci, 1); 
    % end
    % 
    % for i = 2:2
    %     Di = distance_all_attributes{i};
    %     Ci = cost_attribute{i};
    %     loss_eval{i} = @(e) cal_loss_EM(e, Di, Ci); 
    % end
    % 
    % for i = 3:3
    %     Di = distance_all_attributes{i};
    %     Ci = cost_attribute{i};
    %     loss_eval{i} = @(e) cal_loss_EM(e, Di, Ci); 
    % end
    % 
    % for i = 4:4
    %     Di = distance_all_attributes{i};
    %     Ci = cost_attribute{i};
    %     loss_eval{i} = @(e) cal_loss_EM(e, Di, Ci); 
    % end
    %%
    
    lb = zeros(1,n);
    ub = 10*ones(1,n);   
    
    R = eps_allocation_continuous(eps_budget, loss_eval_upper, lb, ub);
    R.loss_cont_sum=R.loss_cont_sum;
    loss_upper(epsilon_id)=R.loss_cont_sum;
    epsilon_allocation_upper(epsilon_id,:)=R.eps_cont';
    disp(R.status)
    % fprintf('\nepsilon allocation:\n   ε1     ε2     ε3     ε4\n');
    % fprintf('%.4f %.4f %.4f %.4f \n\n',R.eps_cont');
    % fprintf('lambda* = %.6g\n\n', R.lambda_star);
    % fprintf('sum of utility loss(upper bound) = %.6f\n', R.loss_cont_sum);
    
    R = eps_allocation_continuous(eps_budget, loss_eval_lower, lb, ub);
    R.loss_cont_sum=R.loss_cont_sum;
    loss_lower(epsilon_id)=R.loss_cont_sum;
    epsilon_allocation_lower(epsilon_id,:)=R.eps_cont';
    
    computation_time(epsilon_id)=toc;
end
% disp(R.status)
% fprintf('\nepsilon allocation:\n   ε1     ε2     ε3     ε4\n');
% fprintf('%.4f %.4f %.4f %.4f \n\n',R.eps_cont');
% fprintf('lambda* = %.6g\n\n', R.lambda_star);
% fprintf('sum of utility loss(lower bound) = %.6f\n', R.loss_cont_sum);
save('result/result-t/computation_time.mat','computation_time');
save('result/result-t/loss_lower.mat','loss_lower');
save('result/result-t/loss_upper.mat','loss_upper');
save('result/result-t/epsilon_allocation_lower.mat','epsilon_allocation_lower');
save('result/result-t/epsilon_allocation_upper.mat','epsilon_allocation_upper');



