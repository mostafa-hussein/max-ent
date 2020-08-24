function fu = my_fun2(var,no_features,no_states,no_actions,no_dem,epsat,f,epst,M,show)
    
    c=0;
    for d=1:no_dem
        a=0;
        b=0;
        for i=1:no_features
            sum2=0;
            for x=1:no_states
               sum3=0;
               for y=1:no_actions
                  sum3 = sum3 + epsat(x,y,d)* f(i,x,y);
               end
               sum2=sum2+sum3;
            end
            b=b+var(i)*sum2;
        end
        
        for x=1:no_states
            sum2=0;
           for y=1:no_actions
               sum3=0;
              for i=1:no_features
                sum3=sum3 +  var(i)* f(i,x,y);
              end 
              sum2 = sum2 + exp( sum3) ;
           end
           a=a+epst(x,d)* log(sum2);
        end
        
        if show
            disp (-(b-a));
        end
        
        c=c+(b-a)*var(d+no_features);
        
    end
    fu=-c/M;
end