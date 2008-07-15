function pass=checkReinforcementManager(tm,rmStructure)
%this function just checks the structure to see if it has the right
%parameters... will probably be better to move this and call
%errorCheck(reinforcementManager,rm) 

f=fields(rmStructure);

allowedFields = {'type',...
    %'fractionOpenTimeSoundIsOn',...
    %'fractionPenaltySoundIsOn',... %moved to super class -pmm 
    'rewardNthCorrect',...
    'msPenalty',...
    'scalar');
%     'scalarStartsCached'};

pass=0;
if hasAllFieldsAndNoMore(f,allowedFields)
    pass=1;
end