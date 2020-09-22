function action = get_action (lamda,f,no_actions,no_observation)
    
    pas=zeros(1,no_actions);
    for i=0:no_actions-1
        s=0;
        for j=1:no_observation
            s=s + lamda(j+i*(no_observation)) * f(j); 
        end
        pas(i+1)=exp(s);
    end
     disp(pas)
    [~,action]=max(pas);
end