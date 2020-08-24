%% Data processing
clear;
clc;
count=1;
data=load('data/cart_pole_expert_data.txt');
index=load('data/cart_pole_index.txt');

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
  endd=10;

backup_data=data;

data=data(index(st,2):index(endd,3),:);


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
   elseif(data(i,no_observation+1)==3)
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
  end
end


%%
cvx_begin
    variable lamda(no_features) 
    
    s1=0;   
    for i=1:no_features
        sum2=0;
        for x=1:no_states
           sum3=0;
           for y=1:no_actions
              sum3 = sum3 + ptsa(x,y)* f(i,x,y);
           end
           sum2=sum2+sum3;
        end
        s1=s1+lamda(i)*sum2;
    end
    
    
    sum1=0;
    for x=1:no_states
        sum2=0;
       for y=1:no_actions
           sum3=0;
          for i=1:no_features
            sum3=sum3 +  lamda(i)* f(i,x,y);
          end 
          sum2 = sum2 + exp( sum3) ;
       end
       sum1=sum1+pts(x)* log(sum2);
    end
   
    minimize( -s1+sum1 )
    
%     subject to
%         for i=1:no_features
%            lamda(i) > 0;
%         end
    
cvx_end

%% calculate the Model 

clear result;
test_data=backup_data(index(90,1):index(100,2) ,:);
test_data(:,3)=test_data(:,3)-1;


clear result
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
end


% %% mountain car 
% for i=1:size(test_data,1)
%     fe=test_data(i,1:no_observation);
%     action = get_action (lamda,fe,no_actions,no_observation);
%   
%     if (action==1 || action==4)
%         cnt1=cnt1+1;
%         action1(cnt1,1)=test_data(i,1);
%         action1(cnt1,2)=test_data(i,2);
%         
%     elseif (action==2 || action==5)
%         cnt2=cnt2+1;
%         action2(cnt2,1)=test_data(i,1);
%         action2(cnt2,2)=test_data(i,2);
%         
%     elseif (action==3|| action==6)
%         cnt3=cnt3+1;
%         action3(cnt3,1)=test_data(i,1);
%         action3(cnt3,2)=test_data(i,2);
%         
%     end
% end
% 
% 
% figure;
% hold on;
% subplot(2,1,1);
% if(cnt1>0)
%     plot(action1(:,1),action1(:,2),'r.')
% end
% hold on
% subplot(2,1,1);
% if(cnt2>0)
%     plot(action2(:,1),action2(:,2),'b.')
% end
% hold on
% subplot(2,1,1);
% if(cnt3>0)
%     plot(action3(:,1),action3(:,2),'g.')
% end
% 
%     
% cnt1=0;
% cnt2=0;
% cnt3=0;
% 
% train_data=data;
% 
% for i=1:size(train_data,1)
%     if (train_data(i,no_observation+1)==1)
%         cnt1=cnt1+1;
%         action1_exp(cnt1,1)=train_data(i,1);
%         action1_exp(cnt1,2)=train_data(i,2);
%         
%     elseif (train_data(i,no_observation+1)==2)
%         cnt2=cnt2+1;
%         action2_exp(cnt2,1)=train_data(i,1);
%         action2_exp(cnt2,2)=train_data(i,2);
%         
%     elseif (backup_data(i,no_observation+1)==3)
%         cnt3=cnt3+1;
%         action3_exp(cnt3,1)=train_data(i,1);
%         action3_exp(cnt3,2)=train_data(i,2);
%         
%     end
%         
% end
% 
% 
% subplot(2,1,2)
% if(cnt1>0)
%     plot(action1_exp(:,1),action1_exp(:,2),'r+')
% end
% hold on
% subplot(2,1,2)
% if(cnt2>0)
%     plot(action2_exp(:,1),action2_exp(:,2),'b+')
% end
% hold on
% subplot(2,1,2)
% if(cnt3>0)
%     plot(action3_exp(:,1),action3_exp(:,2),'g+')
% end

%% display result 


disp(lamda)
disp(result/size(test_data,1)*100);