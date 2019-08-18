%% Data processing
clear;
count=1;
data1=load('data7.txt');
data2=load('data6.txt');
pair1=zeros(size(data1,1)*size(data1,2),2);

for n=1:1 * size(data1,1)
    seq=data1(n,:);
    state=[0 0 0 0 0 0 0];
    for i=1:size(data1,2)
        action = seq(i);
        %sprintf('( %d , %d )', bi2de(state) ,action )

        pair1(count,1)=bi2de(state)+1 ;

        pair1(count,2)=action ;

        count =count+1;
        state(1,action)=1; 
    end
end

count=1;
pair2=zeros(size(data2,1)*size(data2,2),2);

for n=1:1 * size(data2,1)
    seq=data2(n,:);
    state=[0 0 0 0 0 0 0];
    for i=1:size(data2,2)
        action = seq(i);
        %sprintf('( %d , %d )', bi2de(state) ,action )

        pair2(count,1)=bi2de(state)+1 ;

        pair2(count,2)=action ;

        count =count+1;
        state(1,action)=1; 
    end
end
pair =[pair1; pair2];
pair=pair2;
%disp(pair);

%% Empirical model calculations
% clc;

no_states=128;
no_actions=7;
no_features=7;
l=size(pair,1);
cx=zeros(no_states,1);
cxy=zeros(no_states,no_actions);

for i=1:l
   cx(pair(i,1)) =cx(pair(i,1))+1;
   
   cxy(pair(i,1),pair(i,2))=cxy(pair(i,1),pair(i,2))+1;
   
end

pts= cx/l;
ptsa=cxy./l;
ptas=cxy;
%coun=0;
 
for i=1:no_states
   ptas(i,:) = ptas(i,:)./ cx(i) ;
   if ( isnan(sum(ptas(i,:))))
       ptas(i,:)=0;
       %coun=coun+1;
   end
end

% for i=1:no_states
%    p(i,:) = ptas(i,:)./ pts(i) ;
% end

f=zeros(no_features,no_states,no_actions);


for i=0:no_states-1
    tmp=de2bi(i,7);
    
    f(1,1,1)=1;
   
    if ( tmp(1)==1 &&  tmp(2)==0 &&  tmp(6)==0 &&  tmp(7)==0  )
      f(2,i+1,2)=1;
    end
    
   if ( tmp(1)==1 &&  tmp(3)==0 &&  tmp(6)==0 &&  tmp(7)==0  )
       f(3,i+1,3)=1;
    end
    
%    if ( tmp(1)==1  && tmp(3)==1 &&  tmp(4)==0 &&  tmp(6)==0 &&  tmp(7)==0  )
%       f(4,i+1,4)=1;
%     end
%    
% 
%     if ( tmp(1)==1  && tmp(3)==1 &&  tmp(5)==0 &&  tmp(6)==0 &&  tmp(7)==0  )
%       f(5,i+1,5)=1;
%     end

   if ( tmp(1)==1  && tmp(6)==0 && tmp(4) ==0  )
      f(4,i+1,4)=1;
    end
   

    if (tmp(1)==1  && tmp(6)==0 && tmp(5)==0  )
      f(5,i+1,5)=1;
    end    
    
    if (tmp(3)==1  && tmp(6)==0 && tmp(4)==1  || tmp(3)==1  && tmp(6)==0 && tmp(5)==1 )
      f(6,i+1,6)=1;
    end
    
%     f(6,96,6)=1;
     
    if ( tmp(1)==1 &&  tmp(2)==1 && tmp(3)==1 &&  tmp(6)==0 &&  tmp(7)==0  )
       f(7,i+1,7)=1;
    end
   
end

%% optimization section 

% clc;
cvx_begin
    variables pas(no_states,no_actions)
    
    s1=0;   
    for x=1:no_states
        s2=0;
       for y=1:no_actions
          s2 = s2 + entr(pas(x,y));
       end
       s1=s1+pts(x)*s2;
    end
  
    maximize(s1);
    
    subject to
        for i=1 : no_states
           sum(pas(i,:))==1; 
        end
        
        for i=1 : no_features
            
            sum1=0;   
            for x=1:no_states
                tmp1=0;
                for y=1:no_actions
                    tmp1 = tmp1 + ptas(x,y)*f(i,x,y);
                end
                sum1=sum1+pts(x)*tmp1;
            end
            
            sum2=0;   
            for x=1:no_states
                tmp2=0;
                for y=1:no_actions
                    tmp2 = tmp2 + pas(x,y)*f(i,x,y);
                end
                sum2=sum2+pts(x)*tmp2;
            end
%             if (i ~= 4 || i ~= 5)
%                 sum1==sum2; 
%             else
                sum1- sum2 - 0.0 <=0;   % uper limit 
                sum2- sum1 - 0.0 <=0;   % lower limit 
%             end
            
        end
        
        
cvx_end

% disp(pas)

for x=1:no_states
    
    [v,pos(x,1)]=max(pas(x,:));
    
end

% disp(pos);

%% calculate the feature expected for empirical distribution 

for i=1:no_features
    s2=0;
    for x=1:no_states
        s1=0;
        for y=1:no_actions
            s1 = s1 + ptas(x,y)* f(i,x,y) ;
        end
        s2= s2+ pts(x)*s1;
       
    end
    FE1(1,i)=s2;
end



for i=1:no_features
    s2=0;
    for x=1:no_states
        s1=0;
        for y=1:no_actions
            s1 = s1 + pas(x,y)* f(i,x,y) ;
        end
        s2= s2+ pts(x)*s1;
       
    end
    FE2(1,i)=s2;
end

% disp (FE1);
% 
% disp (FE2);

%% entropy calculation 

 s1=0;   
    for x=1:no_states
        s2=0;
       for y=1:no_actions
           if(pas(x,y)==0)
               continue;
           end
          s2 = s2 + pas(x,y) * log(pas(x,y));
       end
       s1=s1+pts(x)*s2;
    end
% disp (-s1);

%% 
evaluate;