%% Data processing
% clc;

count=1;
data=load('data8.txt');
pair=zeros(size(data,1)*size(data,2),2);

for n=1:1 * size(data,1)
    seq=data(n,:);
    state=[0 0 0 0 0 0 0];
    for i=1:size(data,2)
        action = seq(i);
        %sprintf('( %d , %d )', bi2de(state) ,action )

        pair(count,1)=bi2de(state)+1 ;

        pair(count,2)=action ;

        count =count+1;
        state(1,action)=1; 
    end

end

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
            break;
        end
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
 
