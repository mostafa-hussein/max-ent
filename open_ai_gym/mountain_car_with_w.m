%% Data processing
clear;
clc;
count=1;
data=load('data/mountain_car_expert_data9.txt');
index=load('data/mountain_car_index9.txt');
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

M=2;
adv=4;

no_dem=M + adv;
data=data(1:index(no_dem,3),:);

% backup_data=data;


for i=1:adv
%     num=round(index(M+i)* 1 );
    clear r;
    for j=0:index(M+i)-1
        if (data( index(M+i,2)+j,no_observation+1) == 1)
            r(j+1,1)=3;
        elseif (data( index(M+i,2)+j,no_observation+1) == 2)
            r(j+1,1)=2;
       elseif (data( index(M+i,2)+j,no_observation+1) == 3)
            r(j+1,1)=1;
        end
        
    end
%     r = randi([1 no_actions],num,1);

    data(index(M+i,2):index(M+i,3),no_observation+1)=r;
    
%     data(index(M+i,2):index(M+i,2)+num-1,no_observation+1)=r(1:num,1);
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
        elseif(data(i,no_observation+1)==3)
            ptsa(i,3)=1/index(j);
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
  elseif (data(j,no_observation+1)==2)
     f(3,j,2)=data(j,1); 
     f(4,j,2)=data(j,2);
  elseif (data(j,no_observation+1)==3)
     f(5,j,3)=data(j,1); 
     f(6,j,3)=data(j,2);
   
  end

end


%% optimization section 

lamda = optimvar ('lamda',no_features);%,'LowerBound', 0);
w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);

fu = @(lamda,w) opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
   
fun = fcn2optimexpr(fu,lamda,w);
   
prob = optimproblem('Objective',fun);

prob.Constraints.cons1= sum(w) ==M;
   
show(prob);
%%

x0.lamda = double (zeros(no_features,1));
x0.w = double (zeros(no_dem,1));

options = optimoptions (@fmincon,'Algorithm','sqp','Display','final');

[sol,fval] = solve(prob,x0, 'Options', options);

disp(fval);

disp(sol.lamda);
disp(sol.w);

w=sol.w;
lamda=sol.lamda;
fu=opt_mc(lamda,w,no_features,index,no_actions,no_dem,ptsa,f,pts,M,0);
%% calculate the Model

test_data=load('data/mountain_car_expert_data2.txt');
test_data=test_data(1:94,:);

cnt1=0;
cnt2=0;
cnt3=0;
result=0;
for i=1:size(test_data,1)
    fe=test_data(i,1:no_observation);
    action = get_action (lamda,fe,no_actions,no_observation);
%     disp("expert action "+(test_data(i,no_observation+1)+1) + "  Model action " + action);
    if(action==test_data(i,no_observation+1)+1)    
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
        
    elseif (action==3 || action==6)
        cnt3=cnt3+1;
        action3(cnt3,1)=test_data(i,1);
        action3(cnt3,2)=test_data(i,2);
        
    end
end

disp(result/size(test_data,1)*100);

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

for i=1:size(backup_data,1)
    if (backup_data(i,no_observation+1)==1)
        cnt1=cnt1+1;
        action1_exp(cnt1,1)=backup_data(i,1);
        action1_exp(cnt1,2)=backup_data(i,2);
        
    elseif (backup_data(i,no_observation+1)==2)
        cnt2=cnt2+1;
        action2_exp(cnt2,1)=backup_data(i,1);
        action2_exp(cnt2,2)=backup_data(i,2);
        
    elseif (backup_data(i,no_observation+1)==3)
        cnt3=cnt3+1;
        action3_exp(cnt3,1)=backup_data(i,1);
        action3_exp(cnt3,2)=backup_data(i,2);
        
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
%%

