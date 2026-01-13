load('X.mat');
data=X;
num_attributes=15;
num_group=[];
group_tau=cell(1,100);
for tau_id=1:1:100
    tau=tau_id/100;
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
    group_tau{1,tau_id}=groups;
end
save('figure 6/group_tau.mat','group_tau');
save('figure 6/num_group','num_group');