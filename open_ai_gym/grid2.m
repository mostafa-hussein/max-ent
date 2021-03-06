%% Data processing
clear;
clc;
M=4;
count=1;
data=load('tea_making_data_1.txt');
% w=data(:,1);
% data=data(:,2:end);

pair=zeros(size(data,2),2,size(data,1));
no_dem=size(data,1);


for d=1:size(data,1)
    count=1;
    seq=data(d,:);
    state=[0 0 0 0 0 0 0];
    
    for i=1:size(data,2)
        action = seq(i);
        pair(count,1,d)=bi2de(state)+1 ;
        pair(count,2,d)=action ;
        count =count+1;
        state(1,action)=1; 
    end
end

%disp(pair);

%% Empirical model calculations

no_states=128;
no_actions=7;
no_features=7;
l=size(pair,1);
cx=zeros(no_states,no_dem);
cxy=zeros(no_states,no_actions,no_dem);

for d=1:no_dem
    for i=1:l
       cx(pair(i,1,d),d) =cx(pair(i,1),d)+1;

       cxy(pair(i,1,d),pair(i,2,d),d)=cxy(pair(i,1),pair(i,2),d)+1;

    end
end

epst= cx./l;
epsat=cxy./l;


%% feature calcualtions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=zeros(no_features,no_states,no_actions);

for i=0:no_states-1
    tmp=de2bi(i,7);
    
    if ( tmp(2)==0 &&  tmp(3)==0 &&  tmp(4)==0 &&  tmp(5)==0 &&  tmp(6)==0 &&  tmp(7)==0 )
      f(1,i+1,1)=1;
    end
   
    if ( tmp(1)==1 &&  tmp(3)==1 &&  tmp(4)==0 &&  tmp(5)==0 &&  tmp(6)==0 &&  tmp(7)==0 )
      f(2,i+1,2)=1;
    end
    
    if ( tmp(1)==1 &&  tmp(2)==0 &&  tmp(4)==0 &&  tmp(5)==0 &&  tmp(6)==0 &&  tmp(7)==0 )
      f(3,i+1,3)=1;
    end
    
    if ( tmp(1)==1 &&  tmp(3)==1 &&  tmp(2)==1 &&  tmp(7)==1 &&  tmp(6)==0 &&  tmp(4)==0 )
      f(4,i+1,4)=1;
    end
    
    if ( tmp(1)==1 &&  tmp(3)==1 &&  tmp(2)==1 &&  tmp(7)==1 &&  tmp(6)==0 &&  tmp(5)==0 )
      f(5,i+1,5)=1;
    end

    if ( tmp(1)==1 &&  tmp(2)==1 &&  tmp(3)==1 &&  tmp(4)==1 &&  tmp(5)==1 &&  tmp(7)==1 )
      f(6,i+1,6)=1;
    end
   
    if ( tmp(1)==1 &&  tmp(2)==1 &&  tmp(3)==1 &&  tmp(5)==0 &&  tmp(6)==0 &&  tmp(4)==0 )
      f(7,i+1,7)=1;
    end    
end
%% optimization section 

lamda = optimvar ('lamda',no_features);
w = optimvar ('w',no_dem,'LowerBound', 0,'UpperBound',1);

fu = @(lamda,w) my_fun1(lamda,w,no_features,no_states,no_actions,no_dem,epsat,f,epst,M,0);
   
fun = fcn2optimexpr(fu,lamda,w);
   
prob = optimproblem('Objective',fun);

prob.Constraints.cons1= sum(w) ==M;
   
show(prob);

x0.lamda = double (zeros(no_features,1));
x0.w = double (zeros(no_dem,1));

options = optimoptions (@fmincon,'Algorithm','sqp-legacy','Display','final');

[sol,fval] = solve(prob,x0, 'Options', options);

disp(fval);

disp(sol.lamda);
disp(sol.w);

w=sol.w;
lamda=sol.lamda;
fu=my_fun1(lamda,w,no_features,no_states,no_actions,no_dem,epsat,f,epst,M,0);

%% calculate the Model 

for x=1:no_states
  
    for y=1:no_actions

        s=0;
       for i=1:no_features

           s=s + lamda(i) * f(i,x,y); 
       end
        pas(x,y)= exp(s);

    end

end

temp=sum(pas,2);

pas=pas./temp;

for x=1:no_states
    
    [v,pos(x,1)]=max(pas(x,:));
    
end

% disp (pos)

%% calculate the feature expected for empirical distribution 
% eps=zeros(no_states,1);
% 
% for i =1:no_states
%     for d=1:no_dem
%         eps(i,1)=eps(i,1) + epst(i,d)*w(d,1);
%     end
%     eps(i,1)=eps(i,1)/sum(w);
% end
% 
% for i=1:no_states
%     for j=1:no_actions
%         as=0;
%         ps=0;
%         for d=1:no_dem
%             as=as+epsat(i,j,d)*w(d,1);
%             ps=ps+epst(i,d)*w(d,1);
%         end
%         as=as/sum(w);
%         ps=ps/sum(w);
%         if(ps==0)
%             epas(i,j)=0;
%             continue;
%         end
%         epas(i,j)=as/ps;
%     end
% end
% 
% 
% for i=1:no_features
%     s2=0;
%     for x=1:no_states
%         s1=0;
%         for y=1:no_actions
%             s1 = s1 + epas(x,y)* f(i,x,y) ;
%         end
%         s2= s2+ eps(x,1)*s1;
%        
%     end
%     FE1(1,i)=s2;
% end
% 
% 
% 
% for i=1:no_features
%     s2=0;
%     for x=1:no_states
%         s1=0;
%         for y=1:no_actions
%             s1 = s1 + pas(x,y)* f(i,x,y) ;
%         end
%         s2= s2+ eps(x,1)*s1;
%        
%     end
%     FE2(1,i)=s2;
% end
% 
% disp (FE1);
% 
% disp (FE2);
% 
% %% entropy calculation 
% 
%  s1=0;   
%     for x=1:no_states
%         s2=0;
%        for y=1:no_actions
%            if(pas(x,y)==0)
%                continue;
%            end
%           s2 = s2 + pas(x,y) * log(pas(x,y));
%        end
%        s1=s1+eps(x,1)*s2;
%     end
% disp ("entropy = "+-s1);
% 
% %% 
% evaluate(data,data,pas,no_actions,pos);
% 
