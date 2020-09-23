function fu = opt_mc(lamda,w,no_features,index,no_actions,no_dem,epsat,f,epst,M,show)
    c=0;
    for d=1:no_dem
        a=0;
        b=0;
        st=index(d,2);
        endd=index(d,3);
            
        for i=1:no_features
            sum2=0;
            
            for x=st:endd
               sum3=0;
               for y=1:no_actions
                  sum3 = sum3 + epsat(x,y)* f(i,x,y);
               end
               sum2=sum2+sum3;
            end
            b=b+lamda(i)*sum2;
        end
        
        for x=st:endd
            sum2=0;
           for y=1:no_actions
               sum3=0;
              for i=1:no_features
                sum3=sum3 +  lamda(i)* f(i,x,y);
              end 
              sum2 = sum2 + exp( sum3) ;
           end
           a=a+epst(x)* log(sum2);
        end
        
        if show
            disp (-(b-a));
        end
        
        c=c+(b-a)*w(d);
        
    end
    fu=-c/M;
end