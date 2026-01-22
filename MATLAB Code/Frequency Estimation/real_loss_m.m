clear;
clc;
load("result/result-10/epsilon_allocation_lower.mat")
load("result/result-10/epsilon_allocation_upper.mat")
load("result/result-10/distance_all_attributes.mat")
load("result/result-10/cost_attribute.mat")
load("result/result-10/Smse_val.mat")
load("result/result-10/loss_table.mat")

%%
load("result/result-10/epsilon_value.mat")
attribute_set=cell(1,6);
attribute_set{1,1}=[1,4,9,11,13,15];  
attribute_set{1,2}=[2];                
attribute_set{1,3}=[3,8,10,12,14];   
attribute_set{1,4}=[5];               
attribute_set{1,5}=[6];                
attribute_set{1,6}=[7];

method_obfus=[2,2,2,2,2,2];
for i=1:length(cost_attribute)
    if Smse_val(1,i)<0.3
        method_obfus(1,i)=3;
    end
end
for i = 1:length(attribute_set)
    %% method1
    eps_samples=epsilon_value;
    loss_samples=loss_table{1,i}(method_obfus(i),:);
    eps_samples=eps_samples';
    loss_samples=loss_samples';
    %[eps_s, y_s, y_lower, y_upper] = fit_convex_bounds(eps_samples, loss_samples);
    [eps_s, y_s, y_lower, y_upper] = fit_convex_bounds_GCM_LCM(eps_samples, loss_samples);
    
    %% move
    y_upper_firstvalue=2*y_upper(1,1)-y_upper(2,1);
    y_upper=[y_upper_firstvalue;y_upper(1:length(y_upper)-1,1)];
    
    y_lower_lastvalue=y_lower(length(y_lower),1);
    y_lower=[y_lower(2:length(y_lower),1);y_lower_lastvalue];
    % 生成连续函数
    [lower_fun, upper_fun, intervals, params] = convex_bounds_fun(eps_s, y_lower, y_upper, true, 1e-8);
    loss_eval_upper{i}=upper_fun;
    loss_eval_lower{i}=lower_fun;
end

%%
attribute_set=cell(1,6);
attribute_set{1,1}=[1,4,9,11,13,15];  
attribute_set{1,2}=[2];                
attribute_set{1,3}=[3,8,10,12,14];   
attribute_set{1,4}=[5];               
attribute_set{1,5}=[6];                
attribute_set{1,6}=[7];


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
    
    lb = zeros(1,n);
    ub = 10*ones(1,n);   
    
    R = eps_allocation_continuous(eps_budget, loss_eval_upper, lb, ub);
    R.loss_cont_sum=R.loss_cont_sum;
    loss_upper(epsilon_id)=R.loss_cont_sum;
    epsilon_allocation_upper(epsilon_id,:)=R.eps_cont';
    disp(R.status)

    
    R = eps_allocation_continuous(eps_budget, loss_eval_lower, lb, ub);
    R.loss_cont_sum=R.loss_cont_sum;
    loss_lower(epsilon_id)=R.loss_cont_sum;
    epsilon_allocation_lower(epsilon_id,:)=R.eps_cont';
    
    computation_time(epsilon_id)=toc;
end
loss_lower_m=loss_lower;
save('result/result-10/loss_lower_m.mat','loss_lower_m');

%% use epsilon_allocation upper
threshold_adj=[0.2, 0.125, 0.02, 0.15];
loss_real_m=zeros(length(epsilon_allocation_upper),1);
for epsilon_id=1:length(epsilon_allocation_upper)
    epsilon_allocat=epsilon_allocation_upper(epsilon_id,:);
    % method_obfus=[1,1,1,3]; 
    %loss_set1=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},1);
    % 1
    epsilon=epsilon_allocat(1);
    distance_matrix_original=distance_all_attributes{1,1};
    cost=cost_attribute{1,1};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set1=loss_EM;
    loss_set1=BR_loss;
    if Smse_val(1,1)<0.3
        loss_set1=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},threshold_adj(1));
    end
    % 2
    epsilon=epsilon_allocat(2);
    distance_matrix_original=distance_all_attributes{1,2};
    cost=cost_attribute{1,2};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set2=loss_EM;
    loss_set2=BR_loss;
    if Smse_val(1,2)<0.3
        loss_set2=cal_loss_benders(epsilon_allocat(2),distance_all_attributes{1,2},cost_attribute{1,2},threshold_adj(2));
    end
    % 3
    epsilon=epsilon_allocat(3);
    distance_matrix_original=distance_all_attributes{1,3};
    cost=cost_attribute{1,3};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set3=loss_EM;
    loss_set3=BR_loss;
    if Smse_val(1,3)<0.3
        loss_set3=cal_loss_benders(epsilon_allocat(3),distance_all_attributes{1,3},cost_attribute{1,3},threshold_adj(3));
    end
    % 4
    epsilon=epsilon_allocat(4);
    distance_matrix_original=distance_all_attributes{1,4};
    cost=cost_attribute{1,4};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set4=loss_EM;
    loss_set4=BR_loss;
    if Smse_val(1,4)<0.3
        loss_set4=cal_loss_benders(epsilon_allocat(4),distance_all_attributes{1,4},cost_attribute{1,4},threshold_adj(4));
    end

    % 5
    epsilon=epsilon_allocat(5);
    distance_matrix_original=distance_all_attributes{1,5};
    cost=cost_attribute{1,5};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set5=loss_EM;
    loss_set5=BR_loss;
    if Smse_val(1,5)<0.3
        loss_set5=cal_loss_benders(epsilon_allocat(5),distance_all_attributes{1,5},cost_attribute{1,5},threshold_adj(5));
    end

    % 6
    epsilon=epsilon_allocat(6);
    distance_matrix_original=distance_all_attributes{1,6};
    cost=cost_attribute{1,6};
    P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    sum_i=zeros(length(distance_matrix_original),1);
    for i=1:length(distance_matrix_original)
        for j=1:length(distance_matrix_original)
            sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
        end
        for j=1:length(distance_matrix_original)
            P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
        end
    end
    loss_EM = sum(sum(cost .* P_matrix));
    obf_loc=1:1:length(distance_matrix_original);
    P_2=zeros(length(obf_loc),length(distance_matrix_original));
    for i=1:length(obf_loc)
        for j=1:length(distance_matrix_original)
            P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
        end
    end
    y_k=sparse(length(distance_matrix_original),0);
    for i=1:length(obf_loc)
        sum_pc=[];
        for j=1:length(obf_loc)
            sum_pc_j=P_2(i,:)*cost(:,j);
            sum_pc=[sum_pc,sum_pc_j];
        end
        [min_sum, y_k(i)] = min(sum_pc);
    end
    BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    loss_set6=loss_EM;
    loss_set6=BR_loss;
    if Smse_val(1,6)<0.3
        loss_set6=cal_loss_benders(epsilon_allocat(6),distance_all_attributes{1,6},cost_attribute{1,6},threshold_adj(6));
    end
    loss_real_m(epsilon_id,1)=loss_set1+loss_set2+loss_set3+loss_set4+loss_set5+loss_set6;
end


% %% benchmark
% 
% loss_benchmark_m=zeros(length(epsilon_allocation_upper),1);
% for epsilon_id=1:length(epsilon_allocation_upper)
%     epsilon_allocat=epsilon_allocation_upper(epsilon_id,:);
%     % method_obfus=[3,1,1,1]; 
%     %loss_set1=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},1);
%     % 1
%     epsilon=sqrt(sum(epsilon_allocation_upper(epsilon_id,:).*epsilon_allocation_upper(epsilon_id,:))/length(cost_attribute));
%     distance_matrix_original=distance_all_attributes{1,1};
%     cost=cost_attribute{1,1};
%     P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
%     sum_i=zeros(length(distance_matrix_original),1);
%     for i=1:length(distance_matrix_original)
%         for j=1:length(distance_matrix_original)
%             sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
%         end
%         for j=1:length(distance_matrix_original)
%             P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
%         end
%     end
%     loss_EM = sum(sum(cost .* P_matrix));
%     loss_set1=loss_EM;
%     if Smse_val(1,1)<0.1
%         loss_set1=cal_loss_benders(epsilon,distance_all_attributes{1,1},cost_attribute{1,1},threshold_adj(1));
%     end
%     % 2
% 
%     distance_matrix_original=distance_all_attributes{1,2};
%     cost=cost_attribute{1,2};
%     P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
%     sum_i=zeros(length(distance_matrix_original),1);
%     for i=1:length(distance_matrix_original)
%         for j=1:length(distance_matrix_original)
%             sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
%         end
%         for j=1:length(distance_matrix_original)
%             P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
%         end
%     end
%     loss_EM = sum(sum(cost .* P_matrix));
%     loss_set2=loss_EM;
%     if Smse_val(1,2)<0.1
%         loss_set2=cal_loss_benders(epsilon,distance_all_attributes{1,2},cost_attribute{1,2},threshold_adj(2));
%     end
%     % 3
% 
%     distance_matrix_original=distance_all_attributes{1,3};
%     cost=cost_attribute{1,3};
%     P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
%     sum_i=zeros(length(distance_matrix_original),1);
%     for i=1:length(distance_matrix_original)
%         for j=1:length(distance_matrix_original)
%             sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
%         end
%         for j=1:length(distance_matrix_original)
%             P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
%         end
%     end
%     loss_EM = sum(sum(cost .* P_matrix));
%     loss_set3=loss_EM;
%     if Smse_val(1,3)<0.1
%         loss_set3=cal_loss_benders(epsilon,distance_all_attributes{1,3},cost_attribute{1,3},threshold_adj(3));
%     end
%     % 4
% 
%     distance_matrix_original=distance_all_attributes{1,4};
%     cost=cost_attribute{1,4};
%     P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
%     sum_i=zeros(length(distance_matrix_original),1);
%     for i=1:length(distance_matrix_original)
%         for j=1:length(distance_matrix_original)
%             sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
%         end
%         for j=1:length(distance_matrix_original)
%             P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
%         end
%     end
%     loss_EM = sum(sum(cost .* P_matrix));
%     loss_set4=loss_EM;
%     if Smse_val(1,4)<0.1
%         loss_set4=cal_loss_benders(epsilon,distance_all_attributes{1,4},cost_attribute{1,4},threshold_adj(4));
%     end
%     loss_benchmark_m(epsilon_id,1)=1.00859*loss_set1+0.991475*loss_set2+0.736224*loss_set3+1.00261*loss_set4+11.9124;
% end
% save('result/result-10/loss_benchmark_m.mat','loss_benchmark_m');
save('result/result-10/loss_real_m.mat','loss_real_m');