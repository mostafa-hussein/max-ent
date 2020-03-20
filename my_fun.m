function fu = my_fun(lamda,no_features,no_states,no_actions,ptsa,f,pts)

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
          sum2 = sum2 + exp(sum3) ;
       end
       sum1=sum1+pts(x)* log(sum2);
    end
    fu = sum1-s1;
    
end