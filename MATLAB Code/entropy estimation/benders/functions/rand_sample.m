function node_in_target = rand_sample(col_longitude,col_latitude,env_parameters)
lon_min = min(col_longitude);
lon_max = max(col_longitude);
lat_min = min(col_latitude);
lat_max = max(col_latitude);

% 2. 计算子区域的大小（这里取整个区域的 1/5）
lon_range = lon_max - lon_min;
lat_range = lat_max - lat_min;

sub_lon_length = lon_range / 1;
sub_lat_length = lat_range / 1;

% 准备一个空数组，待会用来存储符合条件的点
valid_idx = [];

% 3. 不断随机，直到找到一个包含足够点数的子区域
while length(valid_idx) < env_parameters.NR_NODE_IN_TARGET

    % 3.1 随机选择子区域的左下角
    %     rand() 会生成 [0,1] 区间内的随机数
    sub_lon_min = lon_min + rand() * (lon_range - sub_lon_length);
    sub_lon_max = sub_lon_min + sub_lon_length;
    sub_lat_min = lat_min + rand() * (lat_range - sub_lat_length);
    sub_lat_max = sub_lat_min + sub_lat_length;

    % 3.2 找出落在子区域内的所有节点索引
    valid_idx = find( ...
        col_longitude >= sub_lon_min & col_longitude <= sub_lon_max & ...
        col_latitude  >= sub_lat_min & col_latitude  <= sub_lat_max ...
    );

    % 如果子区域内的点数不够，则 while 循环会重新随机一个子区域
    if length(valid_idx) < env_parameters.NR_NODE_IN_TARGET
        disp('Insufficient points in the randomly selected subregion. Selecting a new subregion...');
    end
end

% 4. 在子区域内随机抽取指定数量的节点
node_in_target = (valid_idx( randperm(length(valid_idx), env_parameters.NR_NODE_IN_TARGET) ))';
end

