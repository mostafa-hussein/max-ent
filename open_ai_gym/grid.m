%% Data processing
clear;
clc;
count=1;
data=load('data/grid_expert_data1.txt');
index=load('grid_index1.txt');
index=index';
no_states=size(data,1);

index(1,2)=1;
index(1,3)=index(1,1);
for i=2:size(index)
    index(i,2)=index(i-1,3)+1;
    index(i,3)=index(i,1)+index(i,2)-1;
end

no_observation = size(data,2)-1;
% no_observation=1;

no_actions=5;
no_features=no_observation* no_actions; 

M=1;
no_dem=size(index,1);
backup_data=data;

% data=data(:,3:4);
% no_observation = size(data,2)-1;

% data(:,1:no_observation)=normalize(data(:,1:no_observation),'range');



%% Empirical model calculations
% clc;

pts=zeros(no_states,1);
pts(:,1)= 1/no_states;


ptsa=zeros(no_states,no_actions);

for i=1:no_states
    for j =1:no_actions
        
        if(data(i,no_observation+1)==j)
            ptsa(i,j)=1/no_states;
            continue
        end
    end
end

%%  feature calculations 
f=zeros(no_features,no_states,no_actions);

for i=1 : no_states
    for j = 1 : no_actions
        if (data(i,no_observation+1)==j)
            for k=1:no_observation
               f(k+(j-1)*no_observation,i,j)=data(i,k);
            end
            continue
        end
    end
  
end

%% optimization section 

lamda = optimvar ('lamda',no_features);
w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);

fu = @(lamda,w) opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
   
fun = fcn2optimexpr(fu,lamda,w);
   
prob = optimproblem('Objective',fun);

prob.Constraints.cons1= sum(w) == M;
   
show(prob);

x0.lamda = double (zeros(no_features,1));
x0.w = double (ones(no_dem,1));

options = optimoptions (@fmincon,'Algorithm','sqp','Display','final');

[sol,fval] = solve(prob,x0, 'Options', options);

disp(fval);

disp(sol.lamda);
disp(sol.w);

w_old=sol.w;
lamda_old=sol.lamda;

w=sol.w;
lamda=sol.lamda;
% fu=opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);


%%
% 
% u = optimvar ('u',no_features+no_dem);
% %w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);
% x0 = double (zeros(no_features+no_dem,1));
% 
% fu = @(u) opt_mc(u(1:no_features,1),u(no_features+1:end,1),no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
% 
% opts = optimoptions(@fmincon,'Algorithm','interior-point');
% 
% problem = createOptimProblem('fmincon','objective',fu,'x0',x0,'options',opts);
% 
% problem.Constraints.cons1= u(no_features+1)+u(no_features+2)+u(no_features+3) == M;
% 
% rng default % For reproducibility
% ms = MultiStart('FunctionTolerance',2e-4,'UseParallel',true);
% gs = GlobalSearch(ms);
% [x,fg,flg,og,sol] = run(gs,problem);



%% advanced optimization section  

% lamda_old = double (rand(no_features,1));
% w_old= double (rand(no_dem,1));
% 
% for i=1:2
%     
%     w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);
% 
%     fu = @(w) opt_mc(lamda_old,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
% 
%     fun = fcn2optimexpr(fu,w);
% 
%     prob = optimproblem('Objective',fun);
% 
%     prob.Constraints.cons1= sum(w) == M;
% 
%     x0.w = w_old;
% 
%     options = optimoptions (@fmincon,'Algorithm','sqp','Display','final');
% 
%     [sol,fval] = solve(prob,x0, 'Options', options);
%     
%     fprintf('weights = \n'); disp (sol.w)
% 
%     w_old=sol.w;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lamda = double (zeros(no_features,1));
% fu = @(lamda) opt_mc(lamda,w_old,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
% opts = optimoptions(@fmincon,'Algorithm','sqp');
% 
% problem = createOptimProblem('fmincon','objective',fu,'x0',lamda_old,'options',opts);
% rng default % For reproducibility
% ms = MultiStart('FunctionTolerance',2e-4,'UseParallel',true);
% gs = GlobalSearch(ms);
% [lamda,fg,flg,og] = run(gs,problem);
% disp(lamda)


%% check 
clear result;

test_data1=load('data/test_grid.txt');

test_data=test_data1;
% test_data(:,1:no_observation)=normalize(test_data1(:,1:no_observation),'range');

result=0;

for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
    act(test_data1(i,1)+1,test_data1(i,2)+1)=action;
    disp (fe) ; disp (action);
    
end


disp (w)
disp (lamda)


