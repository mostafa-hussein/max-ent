%% Data processing
clear;
clc;
count=1;
data=load('data/cart_pole_expert_data1.txt');
index=load('data/cart_pole_index1.txt');
index=index';
no_states=max(index);

index(1,2)=1;
index(1,3)=index(1,1);
for i=2:size(index)
    index(i,2)=index(i-1,3)+1;
    index(i,3)=index(i,1)+index(i,2)-1;
end

no_observation = size(data,2)-2;
data(:,no_observation+1)= data(:,no_observation+1)+1;


tmp=max(data);
no_actions=tmp(no_observation+1 );
no_features=no_observation* no_actions;

M=5;
adv=0;

no_dem=M + adv;
data=data(1:index(no_dem,3),:);

backup_data=data;


for i=1:adv
    clear r;
    for j=0:index(M+i)-1
        if (data( index(M+i,2)+j,no_observation+1) == 1)
            r(j+1,1)=2;
        elseif (data( index(M+i,2)+j,no_observation+1) == 2)
            r(j+1,1)=1
        end
    end
    data(index(M+i,2):index(M+i,3),no_observation+1)=r;
end


new_data=data;
new_data(:,no_observation+1)=new_data(:,no_observation+1)-1;

backup_data=data;

%% Empirical model calculations

pts=zeros(no_states,1);
ptsa=zeros(no_states,no_actions);

for i=1 :no_dem
    st=index(i,2);
    endd=index(i,3);
    for j=st : endd 
        pts(j,1)= 1.0/index(i);
    end
end

for j=1:no_dem
    st=index(j,2);
    endd=index(j,3);
    
    for i=st:endd
        if(data(i,no_observation+1)==1)
            ptsa(i,1)=1/index(j);
        elseif (data(i,no_observation+1)==2)
            ptsa(i,2)=1/index(j);
        end
    end
end
%% feature calcualtions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=zeros(no_features,index(no_dem,3),no_actions);

for j=1 : index(no_dem,3)
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

  end

end

%% optimization section 

lamda = optimvar ('lamda',no_features);%,'LowerBound', 0);
w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);

fu = @(lamda,w) opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
   
fun = fcn2optimexpr(fu,lamda,w);
   
prob = optimproblem('Objective',fun);

prob.Constraints.cons1= sum(w) >=M;
   
show(prob);
%%

x0.lamda = double (zeros(no_features,1));
x0.w = double (zeros(no_dem,1));

options = optimoptions (@fmincon,'Algorithm','sqp-legacy','Display','final');

[sol,fval] = solve(prob,x0, 'Options', options);

disp(fval);

disp(sol.lamda);
disp(sol.w);

w=sol.w;
lamda=sol.lamda;
fu=opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
%% calculate the Model

test_data=load('data/cart_pole_expert_data2.txt');


cnt1=0;
cnt2=0;
result=0;

for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
    if(action==test_data(i,no_observation+1)+1)
        result=result+1;
    end
end

disp(result/size(test_data,1)*100);

%%

