%% Data processing
clear;
% clc;
count=1;
data=load('data/mountain_car_expert_data.txt');
index=load('data/mountain_car_index.txt');

index=index';
no_observation = size(data,2)-2;
data(:,no_observation+1)= data(:,no_observation+1)+1;

% nr_obs=normalize(data(:,1:no_observation),'range');

% data(:,1:no_observation)=nr_obs;


% data(:,5)=(data(:,3));
% data(:,6)=(data(:,4));
% 
% data(:,3)=data(:,1) .* data(:,1) .* data(:,1);
% data(:,4)=data(:,2) .* data(:,2) .* data(:,2);
% no_observation=4;


index(1,2)=1;
index(1,3)=index(1,1);
for i=2:size(index)
    index(i,2)=index(i-1,3)+1;
    index(i,3)=index(i,1)+index(i,2)-1;
end


 
 st=1;
%  endd=size(index,1);
  endd=1;
  
  
backup_data=data;
data=data(index(st,2):index(endd,3),:);

% data=repelem(data,100,1);


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

lamda = optimvar ('lamda',no_features);%,'LowerBound', 0);

fu = @(lamda) opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);
   
fun = fcn2optimexpr(fu,lamda);
   
prob = optimproblem('Objective',fun);
   
show(prob);

x0.lamda = double (zeros(no_features,1));

options = optimoptions (@fmincon,'Algorithm','sqp','Display','final');

[sol,fval] = solve(prob,x0, 'Options', options);

disp(fval);

disp(sol.lamda);

lamda=sol.lamda;

opt= opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);

% 
% lamda = double (zeros(no_features,1));
% opts = optimoptions(@fmincon,'Algorithm','sqp');
% 
% problem = createOptimProblem('fmincon','objective',fu,'x0',lamda,'options',opts);
% rng default % For reproducibility
% ms = MultiStart('FunctionTolerance',2e-4,'UseParallel',true);
% gs = GlobalSearch(ms);
% [lamda,fg,flg,og] = run(gs,problem);

% 
% lamda = double (zeros(no_features,1));
% 
% problem = createOptimProblem('fmincon','objective',fu,'x0',lamda);
% gs = GlobalSearch;
% [lamda,fg,flg,og] = run(gs,problem)
% 
% opt= opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts);


%% calculate the Model
clear result;
% no_features=9;
% test_data=load('data/mountain_car_expert_data6.txt');
test_data=backup_data(index(90,1):index(100,2) ,:);
test_data(:,3)=test_data(:,3)-1;

% test_data(:,1)=(test_data(:,1) .* test_data(:,1));
% test_data(:,2)=(test_data(:,2) .* test_data(:,2));
% 
% nr_obs=normalize(test_data(:,1:no_observation),'range');
% test_data(:,1:no_observation)=nr_obs;


clear result
cnt1=0;
cnt2=0;
cnt3=0;
result=0;

for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
%     disp("expert action "+(test_data(i,no_observation+1)+1) + "  Model action " + action);
    if(action==test_data(i,no_observation+1)+1  || action==test_data(i,no_observation+1)+4)
        result=result+1;
    end
  
    if (action==1 || action==4)
        cnt1=cnt1+1;
        action1(cnt1,1)=test_data(i,1);
        action1(cnt1,2)=test_data(i,2);
        
    elseif (action==2 || action==5)
        cnt2=cnt2+1;
        action2(cnt2,1)=test_data(i,1);
        action2(cnt2,2)=test_data(i,2);
        
    elseif (action==3|| action==6)
        cnt3=cnt3+1;
        action3(cnt3,1)=test_data(i,1);
        action3(cnt3,2)=test_data(i,2);
        
    end
end

% disp(result/size(test_data,1)*100);

figure;
hold on;
subplot(2,1,1);
if(cnt1>0)
    plot(action1(:,1),action1(:,2),'r.')
end
hold on
subplot(2,1,1);
if(cnt2>0)
    plot(action2(:,1),action2(:,2),'b.')
end
hold on
subplot(2,1,1);
if(cnt3>0)
    plot(action3(:,1),action3(:,2),'g.')
end

    
cnt1=0;
cnt2=0;
cnt3=0;

train_data=data;

for i=1:size(train_data,1)
    if (train_data(i,no_observation+1)==1)
        cnt1=cnt1+1;
        action1_exp(cnt1,1)=train_data(i,1);
        action1_exp(cnt1,2)=train_data(i,2);
        
    elseif (train_data(i,no_observation+1)==2)
        cnt2=cnt2+1;
        action2_exp(cnt2,1)=train_data(i,1);
        action2_exp(cnt2,2)=train_data(i,2);
        
    elseif (train_data(i,no_observation+1)==3)
        cnt3=cnt3+1;
        action3_exp(cnt3,1)=train_data(i,1);
        action3_exp(cnt3,2)=train_data(i,2);
        
    end
        
end


subplot(2,1,2)
if(cnt1>0)
    plot(action1_exp(:,1),action1_exp(:,2),'r+')
end
hold on
subplot(2,1,2)
if(cnt2>0)
    plot(action2_exp(:,1),action2_exp(:,2),'b+')
end
hold on
subplot(2,1,2)
if(cnt3>0)
    plot(action3_exp(:,1),action3_exp(:,2),'g+')
end
    
disp(lamda)
disp(result/size(test_data,1)*100);

