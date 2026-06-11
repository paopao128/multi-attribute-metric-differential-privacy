load("result/result-2/cost_attribute.mat")
load("result/result-2/X.mat")
data_ori=X;
attribute_set = cell(1,4);
attribute_set{1,1} = [1,3,4,7,8,9,10,11,12];
attribute_set{1,2} = [2];
attribute_set{1,3} = [5];
attribute_set{1,4} = [6];

data_norm = zscore(data_ori);

distance_all_attributes=cell(1,length(attribute_set));
for id_attribute=1:length(attribute_set)
    [uniqueVals, ~, value_idx] = unique(data_ori(:,attribute_set{1,id_attribute}), 'rows');
    first_uniqueval_idx=zeros(length(uniqueVals(:,1)),1);
    for ith_uni=1:length(uniqueVals)
        ith_value_idx=find(value_idx==ith_uni);
        first_uniqueval_idx(ith_uni,1)=ith_value_idx(1);
    end
    attribute_coordinates=data_norm(first_uniqueval_idx,attribute_set{1,id_attribute});
    coords = attribute_coordinates;
    N = size(coords,1);
    distance_all_attributes{1,id_attribute} = zeros(N,N);
    for i = 1:N
        diffs = coords - coords(i,:);   
        distance_all_attributes{1,id_attribute}(i,:) = sqrt(sum(diffs.^2, 2))'; 
    end
end
save('result/result-2/distance_all_attributes.mat','distance_all_attributes');






