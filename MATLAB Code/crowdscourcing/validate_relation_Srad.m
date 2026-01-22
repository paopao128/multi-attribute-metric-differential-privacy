num_sample=500;
for i_sample=1:num_sample
    %% Parameters 
    NR_RECORD = 15; 
    X_MAX = 10; 
    Y_MAX = 10; 
    EPSILON = 1; 
    DP_THRESHOLD = 2; 
    
    
    %% 
    loc_x = rand(1, NR_RECORD)*X_MAX;
    loc_y = rand(1, NR_RECORD)*Y_MAX;
    
    loc_x = loc_x(:);
    loc_y = loc_y(:);
    
    diff_x = loc_x - loc_x';
    diff_y = loc_y - loc_y';
    
    distance_matrix = hypot(diff_x, diff_y); 
    row_dis_matrix=distance_matrix(:);
    c = rand(NR_RECORD^2, 1);
    N=randi(225,1,1);
    %position_keep_d=randi(225,1,N);
    position_keep_d = randperm(225, N);
    for keep_id=1:N
        c(position_keep_d(keep_id),1)=row_dis_matrix(position_keep_d(keep_id),1);
    end
    %%
    Aeq = zeros(NR_RECORD, NR_RECORD^2);
    
    for i = 1:NR_RECORD
        Aeq(i, (i-1)*NR_RECORD+1:i*NR_RECORD) = 1;
    end
    
    A = [];
    b = [];
    
    for k = 1:1:NR_RECORD
        for i = 1:1:NR_RECORD
            for j = (i+1):1:NR_RECORD
                    distance = distance_matrix(i,j); 
                    a_value = exp(EPSILON * distance);
    
                    % for equation Xik >= Xjk/a
                    row1 = zeros(1, NR_RECORD^2);
                    row1((i-1)*NR_RECORD + k) = -1;  % the coefficient of Xik
                    row1((j-1)*NR_RECORD + k) = 1/a_value;  % the coefficient of -Xjk/a
                    A = [A; row1];
                    b = [b; 0];
                    
                    % for equation Xik <= a*Xjk
                    row2 = zeros(1, NR_RECORD^2);
                    row2((i-1)*NR_RECORD + k) = 1;  % the coefficient of Xik
                    row2((j-1)*NR_RECORD + k) = -a_value;  % the coefficient of -a*Xjk
                    A = [A; row2];
                    b = [b; 0];
            end
        end
    end
    
    
    beq = ones(NR_RECORD, 1);
    lb = zeros(NR_RECORD^2, 1);
    ub = ones(NR_RECORD^2, 1); 
    x = linprog(c, A, b, Aeq, beq, lb, ub);
    
    % A=[A;Aeq;-Aeq;eye(length(x));-eye(length(x))];
    % b=[b;beq;-beq;ones(length(x),1);-zeros(length(x),1)];
    % 
    % x = linprog(c, A, b, [], [], [], []);
    loss_LP(i_sample,1)=sum(c.*x);
    
    
    %%
    D=distance_matrix;
    C=reshape(c, NR_RECORD, NR_RECORD).';
    
    [Srad, nrmse, rmse] = radial_fit_score_from_matrices(C, D, ...
        'IgnoreDiagonal', true, ...
        'IgnoreZeroR', false, ...
        'Delta', 1e-8);
    loss_pre_EM(i_sample,1) = cal_loss_EM(1,D,C);  
    Srad_sample(i_sample,1)=Srad;
    loss_diff(i_sample,1)=loss_pre_EM(i_sample,1)-loss_LP(i_sample,1);
    loss_diff_ratio(i_sample,1)=(loss_pre_EM(i_sample,1)-loss_LP(i_sample,1))/loss_pre_EM(i_sample,1);
end
plot(Srad_sample, loss_diff_ratio, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
[R, P] = corr(Srad_sample(:), loss_diff_ratio(:), 'Type', 'Pearson');
save('figure 5/Srad_loss/Srad_sample.mat','Srad_sample');
save('figure 5/Srad_loss/loss_diff_ratio.mat','loss_diff_ratio');
save('figure 5/Srad_loss/R.mat','R');