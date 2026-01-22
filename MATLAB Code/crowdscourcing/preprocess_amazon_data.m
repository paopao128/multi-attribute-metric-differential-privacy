function [data, true_labels, attribute_names] = preprocess_amazon_data(amazon_file_path)
% PREPROCESS_AMAZON_DATA - 预处理Amazon评论数据用于众包多属性标注
%
% 输入: amazon_file_path - Amazon JSON数据文件路径  
% 输出: data - 特征矩阵 (n_samples x n_features)
%       true_labels - 真实标签矩阵 (n_samples x n_attributes) 
%       attribute_names - 属性名称

fprintf('正在预处理Amazon评论数据...\n');

% 属性定义 (基于Amazon评论常见维度)
attribute_names = {'Overall Quality', 'Value for Money', 'User Experience', 'Product Features', 'Reliability'};
n_attributes = length(attribute_names);

% 读取JSON数据 (简化示例，实际需要根据具体JSON格式调整)
try
    % 假设数据已转换为MATLAB结构体格式
    data_raw = load(amazon_file_path); % 或使用jsondecode()
    reviews = data_raw.reviews;
    
    n_samples = min(length(reviews), 1000); % 限制样本数量
    fprintf('处理 %d 个样本...\n', n_samples);
    
    % 初始化特征矩阵
    n_features = 15; % 扩展特征数量
    data = zeros(n_samples, n_features);
    true_labels = zeros(n_samples, n_attributes);
    
    for i = 1:n_samples
        review = reviews(i);
        
        % === 特征提取 ===
        
        % 特征1-3: 文本特征 (需要文本处理工具箱)
        review_text = review.reviewText;
        if ~isempty(review_text)
            % 文本长度特征
            data(i, 1) = length(review_text) / 1000; % 标准化
            
            % 情感词汇计数 (简化版本)
            positive_words = {'good', 'great', 'excellent', 'amazing', 'perfect', 'love', 'best'};
            negative_words = {'bad', 'terrible', 'awful', 'hate', 'worst', 'horrible', 'poor'};
            
            text_lower = lower(review_text);
            pos_count = 0; neg_count = 0;
            for j = 1:length(positive_words)
                pos_count = pos_count + length(strfind(text_lower, positive_words{j}));
            end
            for j = 1:length(negative_words)
                neg_count = neg_count + length(strfind(text_lower, negative_words{j}));
            end
            
            data(i, 2) = pos_count;
            data(i, 3) = neg_count;
        end
        
        % 特征4: 总体评分
        if isfield(review, 'overall')
            data(i, 4) = review.overall / 5; % 标准化到0-1
        end
        
        % 特征5: 验证购买
        if isfield(review, 'verified') && review.verified
            data(i, 5) = 1;
        end
        
        % 特征6: 有用性投票
        if isfield(review, 'helpful') && length(review.helpful) >= 2
            if review.helpful(2) > 0
                data(i, 6) = review.helpful(1) / review.helpful(2);
            end
        end
        
        % 特征7-10: 产品元数据特征
        if isfield(review, 'asin')
            % 这里可以根据ASIN获取产品信息
            % 简化处理：使用哈希值作为产品类别特征
            asin_hash = mod(sum(double(review.asin)), 100) / 100;
            data(i, 7) = asin_hash;
        end
        
        % 特征8-10: 价格相关特征 (如果有元数据)
        if isfield(review, 'price')
            data(i, 8) = log(review.price + 1) / 10; % 对数标准化
        end
        
        % 特征11-15: 时间特征
        if isfield(review, 'unixReviewTime')
            review_time = datetime(review.unixReviewTime, 'ConvertFrom', 'posixtime');
            data(i, 9) = month(review_time) / 12; % 月份
            data(i, 10) = hour(review_time) / 24;  % 小时
        end
        
        % 添加随机噪声特征 (模拟更复杂的特征工程)
        data(i, 11:15) = randn(1, 5) * 0.1;
        
        % === 标签生成 ===
        % 基于overall评分和文本特征生成多属性标签
        
        overall_rating = 3; % 默认值
        if isfield(review, 'overall')
            overall_rating = review.overall;
        end
        
        % 属性1: Overall Quality (主要基于overall rating)
        true_labels(i, 1) = min(5, max(1, round(overall_rating + randn()*0.3)));
        
        % 属性2: Value for Money (基于rating和价格感知)
        value_score = overall_rating;
        if data(i, 3) > data(i, 2) % 更多负面词汇
            value_score = value_score - 1;
        end
        true_labels(i, 2) = min(5, max(1, round(value_score + randn()*0.4)));
        
        % 属性3: User Experience (基于文本情感)
        ux_score = overall_rating;
        if data(i, 2) > 2 % 很多积极词汇
            ux_score = ux_score + 0.5;
        end
        true_labels(i, 3) = min(5, max(1, round(ux_score + randn()*0.4)));
        
        % 属性4: Product Features (基于文本长度和细节)
        feature_score = overall_rating;
        if data(i, 1) > 0.5 % 详细评论
            feature_score = feature_score + 0.3;
        end
        true_labels(i, 4) = min(5, max(1, round(feature_score + randn()*0.5)));
        
        % 属性5: Reliability (基于overall rating的变体)
        reliability_score = overall_rating * (0.8 + 0.4*rand()); 
        true_labels(i, 5) = min(5, max(1, round(reliability_score)));
    end
    
    % 数据清理和标准化
    data = fillmissing(data, 'constant', 0); % 填充缺失值
    
    % 特征标准化
    for j = 1:n_features
        if std(data(:, j)) > 0
            data(:, j) = (data(:, j) - mean(data(:, j))) / std(data(:, j));
        end
    end
    
    fprintf('数据预处理完成!\n');
    fprintf('生成了 %d 个样本，%d 个特征，%d 个属性\n', n_samples, n_features, n_attributes);
    
catch ME
    fprintf('数据读取错误: %s\n', ME.message);
    fprintf('请确保数据格式正确或使用模拟数据\n');
    
    % 如果读取失败，生成模拟的Amazon风格数据
    fprintf('使用模拟Amazon数据...\n');
    [data, true_labels] = generate_amazon_style_data(200);
end

end

function [data, true_labels] = generate_amazon_style_data(n_samples)
% 生成模拟的Amazon风格数据
n_features = 15;
n_attributes = 5;

% 生成基础特征
data = randn(n_samples, n_features);

% 模拟Amazon评论的一些特征分布
data(:, 1) = abs(data(:, 1)); % 文本长度（正值）
data(:, 4) = 0.2 + 0.6 * rand(n_samples, 1); % 标准化评分
data(:, 5) = rand(n_samples, 1) > 0.3; % 验证购买比例
data(:, 6) = rand(n_samples, 1) .^ 2; % 有用性投票（偏向低值）

% 生成相关的多属性标签
true_labels = zeros(n_samples, n_attributes);

for i = 1:n_samples
    base_quality = 1 + 4 * data(i, 4); % 基于标准化评分
    
    % 添加属性间的相关性和噪声
    true_labels(i, 1) = min(5, max(1, round(base_quality + 0.3*randn()))); % Overall Quality
    true_labels(i, 2) = min(5, max(1, round(base_quality - 0.5 + 0.4*randn()))); % Value
    true_labels(i, 3) = min(5, max(1, round(base_quality + 0.2*randn()))); % User Experience  
    true_labels(i, 4) = min(5, max(1, round(base_quality - 0.2 + 0.5*randn()))); % Features
    true_labels(i, 5) = min(5, max(1, round(base_quality + 0.1*randn()))); % Reliability
end

end