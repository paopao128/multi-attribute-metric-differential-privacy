load("result/result-2/epsilon_allocation_upper.mat")
load("result/result-2/distance_all_attributes.mat")
load("result/result-2/cost_attribute.mat")
load("result/result-2/Srad_val.mat")
%% use epsilon_allocation upper
loss_real_r_1=zeros(length(epsilon_allocation_upper),1);
for epsilon_id=1:length(epsilon_allocation_upper)
    epsilon_allocat=epsilon_allocation_upper(epsilon_id,:);
    % method_obfus=[1,1,1,3]; 
    threshold_adj=[1.2, 0.125, 0.02, 0.15];
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
    if Srad_val(1,1)<0.2
        if length(cost)>100
            loss_set1=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},threshold_adj(1));
        else
            loss_set1= cal_loss_LP(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1});
        end
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
    if Srad_val(1,2)<0.2
        if length(cost)>100
            loss_set2=cal_loss_benders(epsilon_allocat(2),distance_all_attributes{1,2},cost_attribute{1,2},threshold_adj(2));
        else
            loss_set2= cal_loss_LP(epsilon_allocat(2),distance_all_attributes{1,2},cost_attribute{1,2});
        end
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
    if Srad_val(1,3)<0.2
        if length(cost)>100
            loss_set3=cal_loss_benders(epsilon_allocat(3),distance_all_attributes{1,3},cost_attribute{1,3},threshold_adj(3));
        else
            loss_set3= cal_loss_LP(epsilon_allocat(3),distance_all_attributes{1,3},cost_attribute{1,3});
        end
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
    if Srad_val(1,4)<0.2
        if length(cost)>100
            loss_set4=cal_loss_benders(epsilon_allocat(4),distance_all_attributes{1,4},cost_attribute{1,4},threshold_adj(4));
        else
            loss_set4= cal_loss_LP(epsilon_allocat(4),distance_all_attributes{1,4},cost_attribute{1,4});
        end
    end

    % % 5
    % epsilon=epsilon_allocat(5);
    % distance_matrix_original=distance_all_attributes{1,5};
    % cost=cost_attribute{1,5};
    % P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    % sum_i=zeros(length(distance_matrix_original),1);
    % for i=1:length(distance_matrix_original)
    %     for j=1:length(distance_matrix_original)
    %         sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
    %     end
    %     for j=1:length(distance_matrix_original)
    %         P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
    %     end
    % end
    % loss_EM = sum(sum(cost .* P_matrix));
    % obf_loc=1:1:length(distance_matrix_original);
    % P_2=zeros(length(obf_loc),length(distance_matrix_original));
    % for i=1:length(obf_loc)
    %     for j=1:length(distance_matrix_original)
    %         P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
    %     end
    % end
    % y_k=sparse(length(distance_matrix_original),0);
    % for i=1:length(obf_loc)
    %     sum_pc=[];
    %     for j=1:length(obf_loc)
    %         sum_pc_j=P_2(i,:)*cost(:,j);
    %         sum_pc=[sum_pc,sum_pc_j];
    %     end
    %     [min_sum, y_k(i)] = min(sum_pc);
    % end
    % BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    % loss_set5=loss_EM;
    % loss_set5=BR_loss;
    % if Srad_val(1,5)<0.2
    %     if length(cost)>100
    %         loss_set5=cal_loss_benders(epsilon_allocat(5),distance_all_attributes{1,5},cost_attribute{1,5},threshold_adj(5));
    %     else
    %         loss_set5= cal_loss_LP(epsilon_allocat(5),distance_all_attributes{1,5},cost_attribute{1,5});
    %     end
    % end
    % 
    % % 6
    % epsilon=epsilon_allocat(6);
    % distance_matrix_original=distance_all_attributes{1,6};
    % cost=cost_attribute{1,6};
    % P_matrix=zeros(length(distance_matrix_original),length(distance_matrix_original));
    % sum_i=zeros(length(distance_matrix_original),1);
    % for i=1:length(distance_matrix_original)
    %     for j=1:length(distance_matrix_original)
    %         sum_i(i,1)=sum_i(i,1)+exp(-epsilon*distance_matrix_original(i,j)/2.0);
    %     end
    %     for j=1:length(distance_matrix_original)
    %         P_matrix(i,j)=exp(-epsilon*distance_matrix_original(i,j)/2.0)/sum_i(i,1);
    %     end
    % end
    % loss_EM = sum(sum(cost .* P_matrix));
    % obf_loc=1:1:length(distance_matrix_original);
    % P_2=zeros(length(obf_loc),length(distance_matrix_original));
    % for i=1:length(obf_loc)
    %     for j=1:length(distance_matrix_original)
    %         P_2(i,j)=P_matrix(j,i)/sum(P_matrix(:,i));
    %     end
    % end
    % y_k=sparse(length(distance_matrix_original),0);
    % for i=1:length(obf_loc)
    %     sum_pc=[];
    %     for j=1:length(obf_loc)
    %         sum_pc_j=P_2(i,:)*cost(:,j);
    %         sum_pc=[sum_pc,sum_pc_j];
    %     end
    %     [min_sum, y_k(i)] = min(sum_pc);
    % end
    % BR_loss=sum(sum(cost(:,y_k) .* P_matrix));
    % loss_set6=loss_EM;
    % loss_set6=BR_loss;
    % if Srad_val(1,6)<0.2
    %     if length(cost)>100
    %         loss_set6=cal_loss_benders(epsilon_allocat(6),distance_all_attributes{1,6},cost_attribute{1,6},threshold_adj(6));
    %     else
    %         loss_set6= cal_loss_LP(epsilon_allocat(6),distance_all_attributes{1,6},cost_attribute{1,6});
    %     end
    % end
    loss_real_r_1(epsilon_id,1)=loss_set1+loss_set2+loss_set3+loss_set4;
end


% %% benchmark
% 
% loss_benchmark_r=zeros(length(epsilon_allocation_upper),1);
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
%     if Srad_val(1,1)<0.3
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
%     if Srad_val(1,2)<0.3
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
%     if Srad_val(1,3)<0.3
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
%     if Srad_val(1,4)<0.3
%         loss_set4=cal_loss_benders(epsilon,distance_all_attributes{1,4},cost_attribute{1,4},threshold_adj(4));
%     end
%     loss_benchmark_r(epsilon_id,1)=1.00859*loss_set1+0.991475*loss_set2+0.736224*loss_set3+1.00261*loss_set4+11.9124;
% end
% %save('result/result-2/loss_benchmark_r.mat','loss_benchmark_r');
save('result/result-2/loss_real_r_1.mat','loss_real_r_1');