%% Data processing
clear;
% clc;
tic
count=1;
data=load('data/acrobot_expert_data.txt');
index=load('data/acrobot_index.txt');
index=index';
no_observation = size(data,2)-2;
data(:,no_observation+1)= data(:,no_observation+1)+1;


backup_data=data;
index(1,2)=1;
index(1,3)=index(1,1);
for i=2:size(index)
    index(i,2)=index(i-1,3)+1;
    index(i,3)=index(i,1)+index(i,2)-1;
end
 
st=1;
% endd=size(index,1);
endd=100;

data=data(index(st,2):index(endd,3),:);

% data=repelem(data,1,1);

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
   if(data(i,no_observation+1)==1)
       ptsa(i,1)=1/no_states;
   
   elseif (data(i,no_observation+1)==2)
       ptsa(i,2)=1/no_states;
       
   elseif (data(i,no_observation+1)==3)
       ptsa(i,3)=1/no_states;
  
   end
    
end

%%  feature calculations 
f=zeros(no_features,no_states,no_actions);

for j=1 : no_states
  if (data(j,no_observation+1)==1)
     f(1,j,1)=data(j,1); 
     f(2,j,1)=data(j,2);
     f(3,j,1)=data(j,3);
     f(4,j,1)=data(j,4);

  elseif (data(j,no_observation+1)==2)
     f(5,j,2)=data(j,1); 
     f(6,j,2)=data(j,2);
     f(7,j,2)=data(j,3); 
     f(8,j,2)=data(j,4);
  
  elseif (data(j,no_observation+1)==3)
     f(9,j,3)=data(j,1); 
     f(10,j,3)=data(j,2);
     f(11,j,3)=data(j,3); 
     f(12,j,3)=data(j,4);   
     
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
% 
% problem = createOptimProblem('fmincon','objective',fu,'x0',lamda);
% gs = GlobalSearch;
% [lamda,fg,flg,og] = run(gs,problem)
% 
% opt= opt_mountain_car(lamda,no_features,no_states,no_actions,ptsa,f,pts)
toc
%% calculate the Model
test_data=load('data/acrobot_expert_data.txt');
test_data=test_data(index(90,1):index(100,2),:);
cnt1=1;
cnt2=1;
clear result


for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
    
    if (action==test_data(i,no_observation+1)+1)
        result(i,1)=1;
    else
        result(i,1)=0;
    end
end

disp(lamda)
disp(sum(result)/size(test_data,1)*100)


%%

