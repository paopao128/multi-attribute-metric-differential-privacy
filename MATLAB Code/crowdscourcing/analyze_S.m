script_dir = fileparts(mfilename('fullpath'));
base_dir = fullfile(script_dir, 'result');
loss_real_all=zeros(10,10);
Srad_in=[];
Smse_in=[];
domain_size=[];
for i = 1:10
    folder_name = sprintf('result-%d', i);
    file_name   = 'Srad_val.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    Srad_in=[Srad_in,Srad_val];
end

for i = 1:10
    folder_name = sprintf('result-%d', i);
    file_name   = 'Smse_val.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    Smse_in=[Smse_in,Smse_val];  
end

for i = 1:10
    folder_name = sprintf('result-%d', i);
    file_name   = 'distance_all_attributes.mat';
    full_path = fullfile(base_dir, folder_name, file_name);
    load(full_path);
    for j=1:length(distance_all_attributes)
        domain_size=[domain_size,length(distance_all_attributes{1,j})];
    end
end


% for epsilon_id=1:10
%     loss_epsilon_i=loss_real_all(:,epsilon_id);
%     mean_loss=mean(loss_epsilon_i);
%     std_loss=std(loss_epsilon_i);
%     fprintf('%.2f ± %.2f & ',mean_loss,std_loss);
% end
save(fullfile(base_dir, 'domain_size.mat'), 'domain_size');
save(fullfile(base_dir, 'Srad_in.mat'), 'Srad_in');
save(fullfile(base_dir, 'Smse_in.mat'), 'Smse_in');
