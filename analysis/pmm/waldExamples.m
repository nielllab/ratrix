function waldExamples()

alpha=0.05;
wald(60,100,65,100,alpha);  
wald(6000,10000,6500,10000,alpha);  

%TOY EXAMPLES
%                             % LB     MAP     UB
%      65/100 - 60/100		   -0.084 0.050 0.184       % not significant
%   6500/10000 - 6000/10000	    0.037 0.050 0.063       % more trials, now significant

%LOW N WEIRDNESS
%         0/2 - 2/2           -1.000 -1.000 -1.000      %infinite confidence
%         1/2 - 2/2           -1.193 -0.500  0.193      %nonsense bounds
%         2/3 - 3/3           -0.867 -0.333  0.200     
%         1/3 - 3/3		      -1.200 -0.667 -0.133      %how much do we trust it?

%BOUNDARY?
%       19/30 - 18/30		  -0.213  0.033  0.279      %limits of "acceptable" (n=30)
% 19000/30000 - 18000/30000	   0.026  0.033  0.041      %~the amount of data we have    
% 30000/30000 - 29995/30000	   0.000020 0.000167 0.000313 %limits of "acceptable" (n-x=5)

end

function CI=wald(x1,n1,x2,n2,alpha)  
    %wald interval
    if ~all(n1>30 & n2>30 & x1>5 & x2>5 & (n1-x1)>5 & (n2-x2)>5)
        error('wald interval is only good for large sample sizes, consider AgrestiCaffo')
    end
    
    %estimate p
    p1=x1./n1;
    p2=x2./n2;
    
    %estimate the variance
    var=(p1.*(1-p1)./n1) + (p2.*(1-p2)./n2);
    
    %the difference
    delta=p2-p1;
    
    %the confidence interval is simply
    er=norminv(1 - alpha/2, 0, 1).*sqrt(var);
    CI(1,:)=delta-er;
    CI(2,:)=delta+er;
    
    %display summary
    display(sprintf('%4.0d/%d - %d/%d\t\t%2.3f %2.3f %2.3f',x2,n2,x1,n1,CI(1),delta,CI(2)))
end