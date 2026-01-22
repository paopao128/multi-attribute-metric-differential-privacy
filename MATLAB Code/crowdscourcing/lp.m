%% Parameters 
NR_RECORD = 51; 

EPSILON = 10; 
DP_THRESHOLD = 2; 


%% 

distance_matrix=distance_all_attributes{1,4};
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
                %distance = sqrt((loc_x(1, i) - loc_x(1, j))^2 + (loc_y(1, i) - loc_y(1, j))^2); 
                a_value = exp(EPSILON * distance_matrix(i,j));

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

%c = rand(NR_RECORD^2, 1);
c = cost_attribute{1,4};
beq = ones(NR_RECORD, 1);
lb = zeros(NR_RECORD^2, 1);
ub = ones(NR_RECORD^2, 1); 
x = linprog(c, A, b, Aeq, beq, lb, ub);

A=[A;Aeq;-Aeq;eye(length(x));-eye(length(x))];
b=[b;beq;-beq;ones(length(x),1);-zeros(length(x),1)];
save('matrices.mat', 'A', 'b', 'c');
x = linprog(c, A, b, [], [], [], []);