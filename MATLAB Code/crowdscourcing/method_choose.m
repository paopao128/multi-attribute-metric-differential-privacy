load("C:\Users\lry1t\Dropbox\Ruiyao Liu\multi_attribute_mDP\crowdsourcing\result\result-2\cost_attribute.mat")
load("C:\Users\lry1t\Dropbox\Ruiyao Liu\multi_attribute_mDP\crowdsourcing\result\result-2\distance_all_attributes.mat")
threshold_adj=[1, 0.125, 0.15, 0.15];

num_sample=100;
loss_pre_EM=zeros(num_sample,1);
loss_LP=zeros(num_sample,1);
loss_diff=zeros(num_sample,1);
Srad_sample=zeros(num_sample,1);
C_ori = cost_attribute{1,4};
D = distance_all_attributes{1,4};
for i_sample=1:num_sample
    C = C_ori+5*rand(length(C_ori),length(C_ori));


    [Srad, nrmse, rmse] = radial_fit_score_from_matrices(C, D, ...
        'IgnoreDiagonal', true, ...
        'IgnoreZeroR', false, ...
        'Delta', 1e-8);
    loss_pre_EM(i_sample,1) = cal_loss_EM(5,D,C); 
    loss_LP(i_sample,1) = cal_loss_benders(5,D,C,threshold_adj(4));    
    %loss_LP(i_sample,1) = cal_loss_LP(5,D,C); 
    Srad_sample(i_sample,1)=Srad;
    loss_diff(i_sample,1)=(loss_pre_EM(i_sample,1)-loss_LP(i_sample,1))/loss_pre_EM(i_sample,1);
end
plot(Srad_sample, loss_diff, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'b');





for i=1:length(cost_attribute)
    C = cost_attribute{1,i};
    D = distance_all_attributes{1,i};

    [Srad, nrmse, rmse] = radial_fit_score_from_matrices(C, D, ...
        'IgnoreDiagonal', true, ...
        'IgnoreZeroR', false, ...
        'Delta', 1e-8);

    %disp(Srad)
    [Srad,(loss_table{1,i}(1,250)-loss_table{1,i}(3,250))/loss_table{1,i}(1,250)]
end



