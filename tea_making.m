%% Data processing
clear;
% clc;
count=1;
org_data=load('tea_making_data_1.txt');
actions=org_data(:,end);

no_observation = size(org_data,2)-1;
norm_data=org_data(:,1:no_observation);
norm_data(:,1:no_observation)=normalize(org_data(:,1:no_observation),'range');

obs=[norm_data(:,1:45) norm_data(:,51:56)];

train_data=[obs actions];


cnt=1;
for i=1:5:size(train_data,1)
    
    data(cnt,:)=train_data(i,:);
    cnt=cnt+1;
    
end


no_observation = size(data,2)-1;
no_states=size(data,1);
tmp=max(data);
no_actions=tmp(no_observation+1 );
no_features=no_observation* no_actions;




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

%% 
% matlab optimization 

% lamda = optimvar ('lamda',no_features);%,'LowerBound', 0);
% 
% fu = @(lamda) opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);
%    
% fun = fcn2optimexpr(fu,lamda);
%    
% prob = optimproblem('Objective',fun);
%    
% show(prob);
% 
% x0.lamda = double (zeros(no_features,1));
% 
% options = optimoptions (@fmincon,'Algorithm','sqp','Display','final');
% 
% [sol,fval] = solve(prob,x0, 'Options', options);
% 
% disp(fval);
% 
% % disp(sol.lamda);
% 
% lamda=sol.lamda;
% 
% opt= opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);


lamda = double (zeros(no_features,1));
fu = @(lamda) opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);
opts = optimoptions(@fmincon,'Algorithm','sqp');

problem = createOptimProblem('fmincon','objective',fu,'x0',lamda,'options',opts);
rng default % For reproducibility
ms = MultiStart('FunctionTolerance',2e-4,'UseParallel',true);
gs = GlobalSearch(ms);
[lamda,fg,flg,og] = run(gs,problem);

% lamda = double (zeros(no_features,1));
% fu = @(lamda) opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);
% problem = createOptimProblem('fmincon','objective',fu,'x0',lamda);
% gs = GlobalSearch;
% [lamda,fg,flg,og] = run(gs,problem)
% 
% opt= opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);


%% calculate the Model
clear result;

test_data=train_data(:,:);

% test_data=data(:,:);

result=0;

for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
%     disp("expert action "+(test_data(i,no_observation+1)) + "  Model action " + action);
    if(action==test_data(i,no_observation+1))
        result=result+1;
    end
end

disp(result/size(test_data,1)*100);
