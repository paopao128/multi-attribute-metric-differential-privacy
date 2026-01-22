function [loss_EM] = cal_loss_EM(epsilon,distance_matrix_original,cost)
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
    loss_EM=loss_benchmarks;
end

