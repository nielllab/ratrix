function d=recoverStepTransition(d)
% recover step from flankerStim on basic 12 step training

% p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition,vvVH,vvPhases,vvOffsets,vvPhasesOffset,vvVHOffsets})
%                                         4         5      6          7       8        9           10              11j
%

newStep=d.step;

%start with what's there
%error checking shouldn't do this
%this is just faster for a poster
availableSteps=unique(d.step);
stepStart=nan(1,length(availableSteps));
for i=availableSteps
    stepStart(i)=min(find(d.step==i));
end

stepStart(4)=min(find(~isnan(d.flankerContrast)));
stepStart(5)=min(find(d.msPenalty>2000)); %changing reward or penalty

% switch char(d.info.subject)
%     case 'rat_134'
%         stepStart(5)=stepStart(4)+300;
%         stepStart([6 7 8]) = nan;
%         %guess
%         stepStart(6)=min(find(diff(d.redLUT)<0)+1); %9659
%         stepStart(7)=min(find(d.pixPerCycs==32));  %10172
%         stepStart(8)=min(find(d.stdGaussMask==1/16));% 10908;
%         %min(find(diff(d.devPix)>0)+1) seems weird...  ///now use dev
%         instead of devPix b/c devPixX & devPixY
%         %9=12268
%     case 'rat_135'
%         stepStart([6 8]) = nan;
%         %guess
%         stepStart(6)=min(find(diff(d.redLUT)<0)+1); %5809
%         stepStart(7)=min(find(d.pixPerCycs==32)); %9024
%         stepStart(8)=min(find(d.stdGaussMask==1/16))%9223
%         %9=10282
%     otherwise
%         stepStart(6)=min(find(diff(d.redLUT)<0)+1); %changing linearity
%         stepStart(7)=min(find(d.pixPerCycs==32));
%         stepStart(8)=min(find(d.stdGaussMask==1/16));
% end

stepStart(6)=min(find(diff(d.redLUT)<0)+1); %changing linearity
stepStart(7)=min(find(d.pixPerCycs==32));
stepStart(8)=min(find(d.stdGaussMask==1/16));
stepStart(9)=min(find(d.flankerContrast>0));


stepStart(end+1)=length(d.date);
newStep=zeros(size(d.date));
for i=1:max(availableSteps)
    newStep(stepStart(i):stepStart(i+1))=i;
end
d.step=newStep;
