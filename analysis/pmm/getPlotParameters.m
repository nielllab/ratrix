function params=getPlotParameters(conditionType,conditionNames)


switch conditionType
    case 'everything'
        %ploting params
        someConditions=[1:7];
        nm=length(someConditions);
        blacken=[1:nm];

        %choose colors
        colors=hsv(nm);
        colors(blacken,:)=0;  % set all to black
        colors(2,:)=[1 0 0];  % VV is red
        colors(6,:)=[0 1 0];  % V-target is green
        colors(7,:)=[0 0 1];  % H-target is blue
        
       conditionNames =  {'all','VV', 'VH', 'HV', 'HH','V','H'};

    case 'fourFlankers'
        
        someConditions=[1:4];
        nm=length(someConditions);
        
        %choose colors
        colors=hsv(nm);
        blacken=[1:nm];
        colors(blacken,:)=0;  % set all to black
        colors(1,:)=[1 0 0];  % VV is red
        colors(2,:)=[0 1 1];  % VH is cyan
        
        conditionNames = {'VV', 'VH', 'HV', 'HH'};
        
    case 'twoFlankers'

        someConditions=[1:2];
        nm=length(someConditions);

        %choose colors
        colors=hsv(nm);
        blacken=[1:nm];
        colors(blacken,:)=0;  % set all to black
        colors(1,:)=[1 0 0];  % VV is red
        colors(2,:)=[0 1 1];  % VH is cyan

        conditionNames = {'VV', 'VH'};
        
    case 'onlyTarget'
        %ploting params
        someConditions=[1:2];
        nm=length(someConditions);
        blacken=[1:nm];

        %choose colors
        colors(1,:)=[0 1 0];  % V-target is green
        colors(2,:)=[0 0 1];  % H-target is blue
        conditionNames ={'V', 'H'};
        
        
     case 'allOrientations'
         
        someConditions=[1:length(conditionNames)];
        nm=length(someConditions);
        %choose colors
        colors=hsv(nm);
        
        
      case 'allPixPerCycs'

        someConditions=[1:length(conditionNames)];
        nm=length(someConditions);
        %choose colors
        colors=hsv(nm);
    case 'colin-other'
        someConditions=[1:3];
        nm=length(someConditions);
        
        %choose colors
        colors=hsv(nm);
        blacken=[1:nm];
        colors(blacken,:)=0;  % set all to black
        colors(1,:)=[1 0 0];  % colin is red
        colors(2,:)=[0 1 0];  % phaseRev is green
        colors(3,:)=[0 1 1];  % popOut is Cyan 
        conditionNames = {'colinear', 'phaseRev','popOut'};
    otherwise
        conditionType
        error ('Bad conditionType');
        
end
smallDisplacement=([1:nm]-ceil(nm/2))/(nm*250);
alpha=0.05;

%set params into structure
params.someConditions=someConditions;
params.conditionNames=conditionNames;
params.colors=colors;
params.smallDisplacement=smallDisplacement;
params.alpha=alpha;

