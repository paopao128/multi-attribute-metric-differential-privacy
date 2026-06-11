load("result/result-1/epsilon_allocation_lower.mat")
load("result/result-1/epsilon_allocation_upper.mat")
load("result/result-1/distance_all_attributes.mat")
load("result/result-1/cost_attribute.mat")

%% BS(SPL)+PND,RMP
loss_BS_PND=zeros(length(epsilon_allocation_upper),1);
for epsilon_id=1:length(epsilon_allocation_upper)
    epsilon_allocat=epsilon_allocation_upper(epsilon_id,:);
    % method_obfus=[3,1,1,1]; threshold_adj=[1, 0.125, 0.15, 0.15];
    %loss_set1=cal_loss_benders(epsilon_allocat(1),distance_all_attributes{1,1},cost_attribute{1,1},1);
    % 1
    epsilon=sqrt(sum(epsilon_allocation_upper(epsilon_id,:).*epsilon_allocation_upper(epsilon_id,:))/length(cost_attribute));
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
    loss_set1=loss_EM;
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
    loss_set1_BR=BR_loss;
    % 2

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
    loss_set2=loss_EM;
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
    loss_set2_BR=BR_loss;
    % 3

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
    loss_set3=loss_EM;
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
    loss_set3_BR=BR_loss;
    % 4

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
    loss_set4=loss_EM;
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
    loss_set4_BR=BR_loss;

    % % 5
    % 
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
    % loss_set5=loss_EM;
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
    % loss_set5_BR=BR_loss;
    % 
    %  % 6
    % 
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
    % loss_set6=loss_EM;
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
    % loss_set6_BR=BR_loss;
    loss_BS_PND(epsilon_id,1)=loss_set1+loss_set2+loss_set3+loss_set4;
    loss_BS_RMP(epsilon_id,1)=loss_set1_BR+loss_set2_BR+loss_set3_BR+loss_set4_BR;
end


save('result/result-1/loss_BS_PND.mat','loss_BS_PND');
save('result/result-1/loss_BS_RMP.mat','loss_BS_RMP');