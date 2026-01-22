base_dir = 'result';   % 例如 './results'
loss_real_all=zeros(3,10);
sample_start=1;
sample_end=10;
%% SPL_DPN
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_BS_PND.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_BS_PND';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% SPL_RMP
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_BS_RMP.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_BS_RMP';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% ALL_DPN
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_OPT_PND.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_OPT_PND';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% ALL_RMP
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_OPT_RMP.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_OPT_RMP';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% m
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_real_m.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_real_m';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% r
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_real_r.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_real_r';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% bound-m
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_lower_m.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_lower_m';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');
%% bound-r
for i = sample_start:sample_end
    folder_name = sprintf('result-%d', i);
    file_name   = 'loss_lower.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    loss_real_all(i,:) = loss_lower';
end

for epsilon_id=1:10
    loss_epsilon_i=loss_real_all(:,epsilon_id);
    mean_loss=mean(loss_epsilon_i);
    std_loss=std(loss_epsilon_i);
    fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
end
fprintf('\n');