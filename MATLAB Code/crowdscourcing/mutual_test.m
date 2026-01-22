% crowdsourcing
load('data.mat');
num_group=[];
for tau=0.01:0.01:1
    num_attributes=11;
    mutual_information_matrix=zeros(num_attributes,num_attributes);
    for i=1:num_attributes
        for j=1:num_attributes
            mutual_information_matrix(i,j)=independence_analysis(data(:,i), data(:,j));
        end
    end
    
    independent_matrix=mutual_information_matrix>tau;
    
    A = independent_matrix;
    n = size(A,1);
    G = A | A';                  
    bins = conncomp(graph(G));   
    num_groups = max(bins);
    
    groups = cell(num_groups,1);
    for i = 1:n
        groups{bins(i)} = [groups{bins(i)}, i];
    end
    num_group=[num_group,length(groups)];
end