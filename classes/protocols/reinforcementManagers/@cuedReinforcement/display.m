function d=display(r)
    d=[sprintf('\n\t\t\trewardSizeULorMS:\t\t%3.3g',r.rewardSizeULorMS) ...
       ];
   
   %add on the superclass 
    d=[d sprintf('\n\t\treinforcementManager:\t') display(r.reinforcementManager)];