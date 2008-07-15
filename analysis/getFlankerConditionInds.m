

function [conditionInds names haveData colors]=getFlankerConditionInds(d,restrictedSubset,types);

if ~exist('restrictedSubset','var'); restrictedSubset=[]; end
if isempty(restrictedSubset)
    restrictedSubset=ones(size(d.date));
end

if ~exist('types','var')
    types='colin-other';
end

%set defaults
addFlank=0;

%Initialize
i=0; %the condition number
names= {};
conditionInds=[];


if ~isempty(strfind(types,'colin'))
    %setup colinear preprocessing
        d.flankerPosAngle(isnan(d.flankerPosAngle))=99;
        fpas=unique(d.flankerPosAngle);
        fpas(find(fpas==0 | fpas==99))=[]; %allowed to remove these
        if ~(length(fpas)==2 && diff(sign(fpas))==2)
            fpas
            d.info.subject{1}
            error('violates conditions for analysis: must have two positions, one CW and one CCW')
        end
        TFangleDiff=abs(d.targetOrientation-d.flankerOrientation); %target-flanker angle
        TFPhaseDiff=abs(d.targetPhase-d.flankerPhase);             %target-flanker phase
        PFangleDiff=abs(d.flankerPosAngle-d.flankerOrientation);  %global (P)osition angle consistent with (F)lanker angle
        PTangleDiff=abs(d.flankerPosAngle-d.flankerOrientation);  %global (P)osition angle consistent with (T)arget angle
        delta=10*eps;
end


%add specifics
switch types
    case 'everything'
        error('unused')
        %recursively calls all types and add them on
    case 'fourFlankers'
        warning('only good for VH, not diagonal')
        VV=  d.targetOrientation==0 & d.flankerOrientation==0;
        VH=  d.targetOrientation==0 & d.flankerOrientation~=0;
        HV=  d.targetOrientation~=0 & d.flankerOrientation==0;
        HH=  d.targetOrientation~=0 & d.flankerOrientation~=0;


        conditionInds(i+1,:)=VV;
        conditionInds(i+2,:)=VH;
        conditionInds(i+3,:)=HV;
        conditionInds(i+4,:)=HH;
        i=i+4;
        names = [names, {'VV', 'VH', 'HV', 'HH'}];

    case 'twoFlankers'
        warning('only good for VH, not diagonal')
        VV=  d.targetOrientation==0 & d.flankerOrientation==0;
        VH=  d.targetOrientation==0 & d.flankerOrientation~=0;

        conditionInds(i+1,:)=VV;
        conditionInds(i+2,:)=VH;

        i=i+2;
        names = [names, {'VV', 'VH'}];
    case 'onlyTarget'
        error('probably just use allOrientations')
        V=  d.targetOrientation==0;
        H=  d.targetOrientation~=0;
        conditionInds(i+1,:)=V;
        conditionInds(i+2,:)=H;
        i=i+2;
        names = [names, {'V', 'H'}];
    case 'allOrientations'
        orients=unique(d.targetOrientation(~isnan(d.targetOrientation)));
        numOrientations=length(orients);
        for i=1:numOrientations
            conditionInds(i,:)= d.targetOrientation==orients(i);
            names = [names, {num2str(orients(i)*180/pi,'%2.0f')}];
        end
    case 'allPixPerCycs'
        PPC=unique(d.pixPerCycs(~isnan(d.pixPerCycs)));
        numPPC=length(PPC);
        for i=1:numPPC
            conditionInds(i,:)= d.pixPerCycs==PPC(i);
            names = [names, {num2str(PPC(i),'%2.0f')}];
            %get cycles per degree from spatial setup
        end
    case 'allDevs'
        devs=unique(d.deviation(~isnan(d.deviation)));
        numDevs=length(devs);
        for i=1:numDevs
            conditionInds(i,:)= d.deviation==devs(i);
            names = [names, {['dev-' num2str(devs(i)*16,'%2.1f')]}];
        end
    case 'colin-other'
        colinear=TFangleDiff<delta & PFangleDiff<delta & TFPhaseDiff<delta;
        phaseRev=TFangleDiff<delta & PFangleDiff<delta & abs(TFPhaseDiff-pi)<delta;  
        pop= TFangleDiff>delta;

        conditionInds(i+1,:)=colinear;
        conditionInds(i+2,:)=phaseRev;
        conditionInds(i+3,:)=pop;
        
        colors=[1 ,0 ,0;%colinear=red
            0,1,0; %green
            0,1,1]; %cyan

        i=i+3;
        names = [names, {'colinear', 'phaseRev','popOut'}];
   case 'colin+3'
        
       %only alligned phases
        colinear=TFangleDiff<delta & PFangleDiff<delta & TFPhaseDiff<delta;
        popTargetConsistent=TFangleDiff>delta & (PFangleDiff<delta) & TFPhaseDiff<delta;  % global position angle (C)onsistent with target angle, use PTangleDiff if more than 2 flankPosAngles
        popTargetInconsistent=TFangleDiff>delta & (PFangleDiff>delta) & TFPhaseDiff<delta;  % global position angle (I)nconsistent with target angle, use PTangleDiff if more than 2 flankPosAngles
        parallel=TFangleDiff<delta & (PFangleDiff>delta) & TFPhaseDiff<delta; 
        
        conditionInds(i+1,:)=colinear;
        conditionInds(i+2,:)=popTargetConsistent;
        conditionInds(i+3,:)=popTargetInconsistent;
        conditionInds(i+4,:)=parallel;

        
           colors=[1 ,0 ,0;%colinear=red
            0,1,1; %cyan
            0,1,1; %cyan
            0,0,0]; %black
        
        i=i+4;
        %names = [names, {'colin','popTC','popTI', 'para'}]
        names = [names, {'---','|-|','-|-', '|||'}];
        
    case 'noFlank'
        addFlank=1;
    otherwise
        error('undefined type flanker conditions')
end



%disp(sprintf('\t all \tcolinear \t orthogonal\t orthogonal2 \tparallel \tnumTrials'))

if addFlank
    conditionInds(i+1,:)= d.flankerContrast==0;
    i=i+1;
    names = [names, {'noF'}];
end

for j=1:size(conditionInds,1)
    conditionInds(j,:)= restrictedSubset & conditionInds(j,:);
end

%filter conditions wih no data
haveData=find(sum(conditionInds')>0);
% if size(conditionInds,1)~=length(haveData)
%     conditionInds=conditionInds(haveData,:);
%     warning('returning fewer condition inds than requested');
% end
conditionInds=logical(conditionInds);
