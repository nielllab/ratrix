function d=display(r)
    d=[sprintf('\n\t\t\trewardNthCorrect:\t\t\t%s',num2str(r.rewardNthCorrect)) ...
       ];
   
   %add on the superclass 
    d=[d sprintf('\n\t\treinforcementManager:\t') display(r.reinforcementManager)];