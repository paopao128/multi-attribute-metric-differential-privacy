clear;
load("result/result-1/cost_attribute.mat")
load("result/result-1/distance_all_attributes.mat")
load("result/result-1/epsilon_value.mat")

attribute_set=cell(1,6);
attribute_set{1,1}=[1,4,9,11,13,15];  
attribute_set{1,2}=[2];                
attribute_set{1,3}=[3,8,10,12,14];   
attribute_set{1,4}=[5];               
attribute_set{1,5}=[6];                
attribute_set{1,6}=[7];
%%
epsilon_value=0.1:0.1:10; % 100
loss_table=cell(1,length(attribute_set));
for attribute_id=1:1:length(attribute_set)
    loss_table{1,attribute_id}=zeros(3,length(epsilon_value));
    cost=cost_attribute{1,attribute_id};
    distance_matrix_original=distance_all_attributes{1,attribute_id};
    for epsilon_id=1:1:length(epsilon_value)
        epsilon=epsilon_value(epsilon_id);
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
        loss_benchmarks = sum(sum(cost .* P_matrix));%/length(node_in_target);
        loss_table{1,attribute_id}(1,epsilon_id)=loss_benchmarks;
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
        loss_table{1,attribute_id}(2,epsilon_id)=BR_loss;
    end
end
%% OPT+PND
method_obfus=[2,2,2,2,2,2];
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
    %%
    
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

loss_OPT_RMP=zeros(length(epsilon_allocation_upper),1);
for epsilon_id=1:length(epsilon_allocation_upper)
    epsilon_allocat=epsilon_allocation_upper(epsilon_id,:);
    % method_obfus=[1,1,1,3]; 
    threshold_adj=[1, 0.125, 0.15, 0.15];
    %loss_set1_OPT_RMP=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},1);
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
    loss_set1_OPT_RMP=BR_loss;
    
   
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
    loss_set2_OPT_RMP=BR_loss;
    
   
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
    loss_set3_OPT_RMP=BR_loss;
    
    
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
    loss_set4_OPT_RMP=BR_loss;
    
    
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
    loss_set5_OPT_RMP=BR_loss;


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
    loss_set6_OPT_RMP=BR_loss;

    loss_OPT_RMP(epsilon_id,1)=loss_set1_OPT_RMP+loss_set2_OPT_RMP+loss_set3_OPT_RMP+loss_set4_OPT_RMP+loss_set5_OPT_RMP+loss_set6_OPT_RMP;
end

save('result/result-1/loss_OPT_RMP.mat','loss_OPT_RMP');
loss_OPT_RMP_lower=loss_lower;
save('result/result-1/loss_OPT_RMP_lower.mat','loss_OPT_RMP_lower');