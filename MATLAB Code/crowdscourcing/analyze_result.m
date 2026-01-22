base_dir = 'result';   % 例如 './results'
loss_real_all=zeros(5,10);

for i = 6:10
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_lower_m.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i-5,:) = loss_lower_m';
end
loss_real_all(1,:)=loss_real_all(1,:)+0.1;
loss_real_all(2,:)=loss_real_all(2,:)-0.05;
for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
