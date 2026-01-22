load("result/result-t/cost_attribute.mat")
load("result/result-t/distance_all_attributes.mat")



% Srad
Srad_val=zeros(1,length(cost_attribute));
for i=1:length(cost_attribute)
    C = cost_attribute{1,i};
    D = distance_all_attributes{1,i};

    [Srad, nrmse, rmse] = radial_fit_score_from_matrices(C, D, ...
        'IgnoreDiagonal', true, ...
        'IgnoreZeroR', false, ...
        'Delta', 1e-8);

    %disp(Srad)
    Srad_val(1,i)=Srad;
end
 Srad_val
save('result/result-t/Srad_val.mat','Srad_val');

%%
Smse_val=zeros(1,length(cost_attribute));
for i=1:length(cost_attribute)
    C = cost_attribute{1,i};
    D = distance_all_attributes{1,i};

    [Smse] = mse_likeness_score_from_matrices(C, D, ...
        'IgnoreDiagonal', true, ...
        'IgnoreZeroR', false, ...
        'Delta', 1e-8);
    if length(C)<=2
        Smse=0.05;
    end
    %disp(Srad)
    Smse_val(1,i)=Smse;
end
Smse_val
save('result/result-t/Smse_val.mat','Smse_val');
%%
attribute_set = cell(1,6);
attribute_set{1,1} = [2,13];
attribute_set{1,2} = [6];
attribute_set{1,3} = [7];
attribute_set{1,4} = [3,9];
attribute_set{1,5} = [1,4,5,8,10,11];
attribute_set{1,6} = [12];

%% EM,EMBR
%epsilon_value=[0.02:0.02:1,1.02:0.02:2,2.04:0.04:3,3.05:0.05:4,4.1:0.1:10];
% epsilon_value=0.04:0.04:10; % 250
epsilon_value=0.1:0.1:10; % 100
save('result/result-t/epsilon_value.mat','epsilon_value');
loss_table=cell(1,length(attribute_set));
threshold_adj=[0.2, 0.125, 0.02, 0.15, 0.6, 0.25];
for attribute_id=1:1:length(attribute_set)
    loss_table{1,attribute_id}=zeros(3,length(epsilon_value));
    cost=cost_attribute{1,attribute_id};
    distance_matrix_original=distance_all_attributes{1,attribute_id};
    % EM, EMBR
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
    % benders
    if Srad_val(1,attribute_id)<0.2||Smse_val(1,attribute_id)<0.2
        if length(cost)>100
            loss_table{1,attribute_id}(3,:)=cal_loss_benders(epsilon_value,distance_matrix_original,cost,threshold_adj(attribute_id));
        else
            loss_table{1,attribute_id}(3,:) = cal_loss_LP(epsilon_value, distance_matrix_original, cost);
        end
        
    end
    save('result/result-t/loss_table.mat','loss_table');
end


%%


attribute_set = cell(1,6);
attribute_set{1,1} = [2,13];
attribute_set{1,2} = [6];
attribute_set{1,3} = [7];
attribute_set{1,4} = [3,9];
attribute_set{1,5} = [1,4,5,8,10,11];
attribute_set{1,6} = [12];

load("result/result-t/Srad_val.mat")
load("result/result-t/cost_attribute.mat")
load("result/result-t/distance_all_attributes.mat")
load("result/result-t/loss_table.mat")
method_obfus=[2,2,2,2,2,2];
%method_obfus=[1,1,1,1,1,1];
for i=1:length(cost_attribute)
    if Srad_val(1,i)<0.2
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


save('result/result-t/loss_eval_upper.mat','loss_eval_upper');
save('result/result-t/loss_eval_lower.mat','loss_eval_lower');