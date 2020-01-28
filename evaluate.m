%% Data processing
% clc;
function []= evaluate(data1,data2,pas,no_actions)

count=1;
% data1=load('data7.txt');
% data2=load('data7.txt');
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
pair=pair1;
%disp(pair);


%%  system evaluation 

pas =round(pas,4);
c=0;
for i=1:size(pair,1)
    
    index=pair(i,1);
    
    [v,po]=max(pas(index,:));
    
    I=find (pas(index,:) == v);
    
    if (size(I,2)==no_actions)
        continue;
    end
    
    for j=1:size(I,2)
        
        if (I(j)  == pair(i,2))
            c=c+1;
%             disp (i);
            break;
            
        end
%         disp (i);
    end
    
end
disp('............................')
disp(c);
disp(c*100/size(pair,1));


c1=0;
for i=1:size(pair,1)
    
    index=pair(i,1);
        if (pos(index)  == pair(i,2))
            c1=c1+1;
        end
end
% disp('............................')
% disp(c1);
% disp(c1*100/size(pair,1));
 
