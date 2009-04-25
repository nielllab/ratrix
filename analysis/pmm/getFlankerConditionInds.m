function [conditionInds names haveData colors d restrictedSubset]=getFlankerConditionInds(d,restrictedSubset,types);



if ~exist('d', 'var') || isempty(d)
    %allows you to get names and colors when you lack actual data
    d.flankerPosAngle=nan;
    d.targetOrientation=nan;
    d.flankerOrientation=nan;
    d.targetPhase=nan;
    d.flankerPhase=nan;
    d.pixPerCycs=nan;
    d.deviation=nan;
    d.date=nan;
end

if ~exist('restrictedSubset','var') || isempty(restrictedSubset)
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
    if size(d.date,2)>1  %only bother complaining if there is actually data
        if ~(length(fpas)==2 && diff(sign(fpas))==2)
            fpas
            d.info.subject{1}
            error('violates conditions for analysis: must have two positions, one CW and one CCW')
        end
    end
    TFangleDiff=abs(d.targetOrientation-d.flankerOrientation); %target-flanker angle
    TFPhaseDiff=abs(d.targetPhase-d.flankerPhase);             %target-flanker phase
    PFangleDiff=abs(d.flankerPosAngle-d.flankerOrientation);  %global (P)osition angle consistent with (F)lanker angle
    PTangleDiff=abs(d.flankerPosAngle-d.flankerOrientation);  %global (P)osition angle consistent with (T)arget angle
    delta=10*eps;
end



hasNF=strfind(types,'&nfBlock');
% this is a sneaky process where we "add in" the data for the same rat from
% what is likely to be another step.  we have to update the data d and the
% restrictedSubset to be analyzed  (likely to be the goods)
if ~isempty(hasNF)
    
    % remove the block request and get the main conditions
    types(hasNF:hasNF+7)=[];
    [c1 nm1 junk col1 d restrictedSubset]=getFlankerConditionInds(d,restrictedSubset,types);
    types='skip';
    
    % get the full data for this rat
    d2=getSmalls(char([d.info.subject]));
    
    % check it jives - current data is a subset of all data
    if ~all(ismember(d.date,d2.date))
        error('got the wrong data when looking for this rats no flank block')
    end
    
    % find the target only step
    step=min(d2.step(d2.stdGaussMask==0.0625));% probably 8
    d2=removeSomeSmalls(d2,d2.step~=step);
    
    if any(d2.flankerContrast>0)
        step
        error('no flanker contrast allowed in this step!')
    end
    
    if any(~ismember(unique(d2.targetContrast),[0 1]))
        warning('there are multiple contrasts in this step')
        keyboard
    end
    
    if any(ismember(d2.date,d.date))
        %multiple calls to getFlankerConditionInds can do this
        warning('removing the no flanker block from the original data... will combine again in conditions')
        
        remove=d.step==step;
        restrictedSubset(remove)=[]; %need to remove from goods
        c1(:,remove)=[];             %need to remove from conditions
        d=removeSomeSmalls(d,remove);%need to remove trials
        
        if size(d.date)<1
            error('all trials gone!  something wrong')
        end
        
        if length(restrictedSubset)~=length(d.date)
            error('restrictedSubset filter is out of sync with trial filter!')
        end
    end
    
    
    %add yes responses (d *might* have it)
    [d]=addYesResponse(d);
    [d2]=addYesResponse(d2);
    
    % check fields missing in the inital data
    if ~all(ismember(fields(d2),fields(d)))
        f=fields(d2);
        missed=f(~ismember(f,fields(d)))
        acceptableToMiss={'pixPerCyc'}; % these might have removed b/c they are nans in later data
        if all(ismember(missed,acceptableToMiss)) % these are fields that I have sanction its okay to be out of sync.  will be nanned on the missing side
            for i=1:length(missed)
                d.(missed{i})=nan(size(d.date));
            end
        else
            error('miss matched fields... might have grabbed the wrong small data file for this rat...')
        end
    end
    
    
    % check fields
    if  ~all(ismember(fields(d),fields(d2)))
        f=fields(d)
        f(~ismember(f,fields(d2)))
        error('miss matched fields... might have grabbed the wrong small data file for this rat...')
    end
    
    
    %get goods for the new data
    goods2=getGoods(d2,'withoutAfterError');
    
    % get conditions on the no flank block
    [c2 nm2 junk col2 ]=getFlankerConditionInds(d2,goods2,'noFlank');
    
    %combine the names and colors
    names=[nm1 'noFb'];
    colors=[col1; col2];
    
    %combine the new restricted subset and conditions, but first
    %check that analyzed flanker trials come after the block of target only
    if max(d2.trialNumber)>min(d.trialNumber)
        error('expect flanker trials come after the block of target only')
        restrictedSubset=[restrictedSubset goods2];  % in principle probably works if error check the other way around to avoid sandwiches, but don't expect to need it
        %also see order of conditionInds c1 c2
    else
        restrictedSubset=[goods2 restrictedSubset];
        conditionInds=[zeros([size(c1,1)  size(c2,2)]) c1;
            c2 zeros([1 size(c1,2)])];
    end
    
    % combine the data
    d=combineTwoSmallDataFiles(d,d2);
    
end

hasNF=strfind(types,'&nfMix');
if ~isempty(hasNF)
    types(hasNF:hasNF+5)=[];
    [c1 nm1 junk col1 ]=getFlankerConditionInds(d,restrictedSubset,types);
    [c2 nm2 junk col2 ]=getFlankerConditionInds(d,restrictedSubset,'noFlank');
    conditionInds=[c1;c2];
    names=[nm1 'noFm'];
    colors=[col1; col2];
    types='skip';
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
        
        colors=[1,0,0;%colinear=red
            0,1,1; %cyan
            0,1,1; %cyan
            0,0,0]; %black
        
    case 'FullTargetContrastSomeFlanker'
        conditionInds=d.targetContrast==1 & d.flankerContrast>0;
        names={'fullTarget'};
    case 'FullTargetContrastSomeFlankerAndMatchedNoSig'
        [conditionInds names]=getFlankerConditionInds(d,restrictedSubset,'FullTargetContrastSomeFlanker');
        noSig=d.targetContrast==0 & d.flankerContrast>0;
        conditionInds=matchWithNoSig(conditionInds,noSig);
        names={'fullTarget & matchedNoSig'};
    case 'twoFlankers'
        warning('only good for VH, not diagonal')
        VV=  d.targetOrientation==0 & d.flankerOrientation==0;
        VH=  d.targetOrientation==0 & d.flankerOrientation~=0;
        
        conditionInds(i+1,:)=VV;
        conditionInds(i+2,:)=VH;
        
        i=i+2;
        names = [names, {'VV', 'VH'}];
        
        colors=[1,0,0;%colinear=red
            0,1,1]; %cyan
        
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
        colors=jet(numOrientations);
    case 'allRelativeTFOrientationMag'
        TFangleDiff=abs(d.targetOrientation-d.flankerOrientation)*180/pi; %target-flanker angle magnitude
        %round to the nearest half degree to solve left vs. right rounding errors
        TFangleDiff=round(TFangleDiff*2)/2;
        
        orients=unique(TFangleDiff(~isnan(TFangleDiff)));
        numOrientations=length(orients);
        colors=[];
        for i=1:numOrientations
            conditionInds(i,:)= TFangleDiff==orients(i);
            names = [names, {num2str(orients(i),'%2.0f')}];
            colors(i,1:3)=hsv2rgb(abs((orients(i)+0)/180),1,1);
        end
        
    case 'allRelativeTFOrientations'
        TFangleDiff=d.targetOrientation-d.flankerOrientation; %target-flanker angle
        
        orients=unique(TFangleDiff(~isnan(TFangleDiff)));
        numOrientations=length(orients);
        colors=[];
        for i=1:numOrientations
            conditionInds(i,:)= TFangleDiff==orients(i);
            names = [names, {num2str(orients(i)*180/pi,'%2.0f')}];
            colors(i,1:3)=hsv2rgb(abs(orients(i)/pi),1,1);
        end
        
    case 'allRelativeTFOrientationsLR'
        %split into L and R global configs
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,'allRelativeTFOrientations');
        for i=1:size(tempConditionInds,1)
            ind=i;
            conditionInds(ind,:)= tempConditionInds(i,:) & d.flankerPosAngle<0;
            names{ind} = [tempNames{i} 'L?'];
            
            ind=size(tempConditionInds,1)+i;
            conditionInds(ind,:)= tempConditionInds(i,:) & d.flankerPosAngle>0;
            names{ind} = [tempNames{i} 'R?'];
            
        end
        colors=[tempColors; tempColors];
        %imtool(reshape(colors,[22 1 3]));
    case 'allTargetContrasts'
        contrasts=unique(d.targetContrast(~isnan(d.targetContrast)));
        numContrast=length(contrasts);
        for i=1:numContrast
            conditionInds(i,:)= d.targetContrast==contrasts(i);
            names = [names, {num2str(contrasts(i),'%2.2f')}];
        end
        colors=jet(numContrast);
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
        colors=jet(numDevs);
    case 'allPhases'
        tps=unique(d.targetPhase(~isnan(d.targetPhase)));
        fps=unique(d.flankerPhase(~isnan(d.flankerPhase)));
        for i=1:length(fps)
            for j=1:length(tps)
                conditionInds(length(tps)*(i-1)+j,:)= d.targetPhase==tps(i) & d.flankerPhase==fps(j);
                names = [names, {['fp' num2str(i) '-tp' num2str(j)]}];
            end
        end
        colors=jet(length(fps)*length(tps));
    case '3phases'
        relPhase=abs(d.targetPhase-d.flankerPhase);
        %rp=unique(relPhase(~isnan(relPhase)));
        names={'same','reverse','other'}
        conditionInds(1,:)=relPhase<10^-9;
        conditionInds(2,:)=abs(pi-relPhase)<10^-9;
        conditionInds(3,:)=~(sum(conditionInds));
        colors=[1 0 0; 0 1 1; 1 1 1];
        
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
        popTargetConsistent=TFangleDiff>delta & (PFangleDiff>delta) & TFPhaseDiff<delta;  % global position angle (C)onsistent with target angle, use PTangleDiff if more than 2 flankPosAngles
        popTargetInconsistent=TFangleDiff>delta & (PFangleDiff<delta) & TFPhaseDiff<delta;  % global position angle (I)nconsistent with target angle, use PTangleDiff if more than 2 flankPosAngles
        parallel=TFangleDiff<delta & (PFangleDiff>delta) & TFPhaseDiff<delta;
        
        conditionInds(i+1,:)=colinear;
        conditionInds(i+2,:)=popTargetConsistent;
        conditionInds(i+3,:)=popTargetInconsistent;
        conditionInds(i+4,:)=parallel;
        
        colors=[1 ,0 ,0;%colinear=red
            0,1,1; %cyan
            .5,.5,1; %purplish bc. no target has same colin flankers
            0,0,0]; %black
        
        i=i+4;
        %names = [names, {'colin','popTC','popTI', 'para'}]
        names = [names, {'---','l-l','-l-', 'lll'}];
    case 'colin+1'
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,'colin+3');
        conditionInds=tempConditionInds(1:2,:);
        names=tempNames(1:2);
        %intersect([1 2 ],tempHaveData) %unneccesarry
        colors=tempColors(1:2,:);
    case 'colin+3&contrasts'
        contrasts=unique(d.targetContrast(~isnan(d.targetContrast)));
        numContrast=length(contrasts);
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,'colin+3');
        names=repmat(tempNames,1,numContrast);
        colors=repmat(tempColors,numContrast,1);
        for i=1:size(tempConditionInds,1)
            for j=1:numContrast
                ind=((j-1)*size(tempConditionInds,1))+i;
                conditionInds(ind,:)= tempConditionInds(i,:) & d.targetContrast==contrasts(j);
                names{ind} = [names{ind} ' ' num2str(contrasts(j),'%2.2f')];
                colors(ind,:)=(0.5+contrasts(j)/2)*colors(ind,:);
            end
        end
        warndlg('while this works, its risky.  reasons: 1) did you think about flanker contrast=0 trials?  2) when do you pool the no sig conditions? 3) why not just use flankerAnalysis.m?')
    case {'colin+3&devs','colin+1&devs','2flanks&devs'}
        devs=unique(d.deviation(~isnan(d.deviation)));
        numDevs=length(devs);
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,types(1:7));
        names=repmat(tempNames,1,numDevs);
        colors=repmat(tempColors,numDevs,1);
        for i=1:size(tempConditionInds,1)
            for j=1:numDevs
                ind=((j-1)*size(tempConditionInds,1))+i;
                conditionInds(ind,:)= tempConditionInds(i,:) & d.deviation==devs(j);
                names{ind} = [names{ind} ' ' num2str(devs(j)*16,'%2.2f')];
                colors(ind,:)=(3*devs(j))*colors(ind,:);
            end
        end
        
    case '16flanks'
        %a hard coded double check
        %the same as:
        % orient= pi/12;
        % sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast'}; % last entry must be targetContrast
        % sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1]};
        % [junkImages junkNumTrials junkReturnSweptValues conditionInds2]=getStimSweep(r,d,sweptParameters,sweptValues,true);
        %      or=orient;   f.flankerOrientation=-or;f.targetOrientation=-or;f.flankerPosAngle=-or;f.targetContrast=0; [image details]= sampleStimFrame(sm,class(tm),f,3,800,800); figure; imagesc(image)
        %conclusion: we trust the images out of the function call to match,
        %as long as  d.targetContrast=1 as searched for above.  below is
        %general to all contrasts
        
        conditionInds( 1,:)=d.flankerOrientation<0 & d.targetOrientation<0 & d.flankerPosAngle<0 & d.targetContrast==0;
        conditionInds( 2,:)=d.flankerOrientation>0 & d.targetOrientation<0 & d.flankerPosAngle<0 & d.targetContrast==0;
        conditionInds( 3,:)=d.flankerOrientation<0 & d.targetOrientation>0 & d.flankerPosAngle<0 & d.targetContrast==0;
        conditionInds( 4,:)=d.flankerOrientation>0 & d.targetOrientation>0 & d.flankerPosAngle<0 & d.targetContrast==0;
        conditionInds( 5,:)=d.flankerOrientation<0 & d.targetOrientation<0 & d.flankerPosAngle>0 & d.targetContrast==0;
        conditionInds( 6,:)=d.flankerOrientation>0 & d.targetOrientation<0 & d.flankerPosAngle>0 & d.targetContrast==0;
        conditionInds( 7,:)=d.flankerOrientation<0 & d.targetOrientation>0 & d.flankerPosAngle>0 & d.targetContrast==0;
        conditionInds( 8,:)=d.flankerOrientation>0 & d.targetOrientation>0 & d.flankerPosAngle>0 & d.targetContrast==0;
        conditionInds( 9,:)=d.flankerOrientation<0 & d.targetOrientation<0 & d.flankerPosAngle<0 & d.targetContrast>0;
        conditionInds(10,:)=d.flankerOrientation>0 & d.targetOrientation<0 & d.flankerPosAngle<0 & d.targetContrast>0;
        conditionInds(11,:)=d.flankerOrientation<0 & d.targetOrientation>0 & d.flankerPosAngle<0 & d.targetContrast>0;
        conditionInds(12,:)=d.flankerOrientation>0 & d.targetOrientation>0 & d.flankerPosAngle<0 & d.targetContrast>0;
        conditionInds(13,:)=d.flankerOrientation<0 & d.targetOrientation<0 & d.flankerPosAngle>0 & d.targetContrast>0;
        conditionInds(14,:)=d.flankerOrientation>0 & d.targetOrientation<0 & d.flankerPosAngle>0 & d.targetContrast>0;
        conditionInds(15,:)=d.flankerOrientation<0 & d.targetOrientation>0 & d.flankerPosAngle>0 & d.targetContrast>0;
        conditionInds(16,:)=d.flankerOrientation>0 & d.targetOrientation>0 & d.flankerPosAngle>0 & d.targetContrast>0;
        
        colors=jet(16); colors(:)=0.9; %all gray at first
        names{ 1}='nRR';
        names{ 2}='nLR';
        names{ 3}='nRR';
        names{ 4}='nLR';
        names{ 5}='nRL';
        names{ 6}='nLL';
        names{ 7}='nRL';
        names{ 8}='nLL';
        names{ 9}='RRR';
        names{10}='RLR';
        names{11}='LRR';
        names{12}='LLR';
        names{13}='RRL';
        names{14}='RLL';
        names{15}='LRL';
        names{16}='LLL';
        
        colors(1:8,:)=.8; % no target is gray
        colors([9        16],:)=repmat([1 0 0],2,1); %colin
        colors([10 11 14 15],:)=repmat([0 1 1],4,1); %pop
        colors([  12 13  ],:)=repmat([0 0 0],2,1); %para
    case '8flanks'
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,'16flanks');
        names={tempNames{9:16}};
        colors=tempColors(9:16,:);
        n=size(tempConditionInds,1);
        for i=1:n/2
            %pair contrast with no contrast
            conditionInds(i,:)=tempConditionInds(i,:) | tempConditionInds(i+n/2,:);
        end
        
    case '8flanks+'
        [conditionInds names haveData colors]=getFlankerConditionInds(d,restrictedSubset,'8flanks');
        
        lumps=5;
        colors(9:13,1:3)=[colors(1:4,:); .6 .6 .6];
        names{end+1}='colin';
        names{end+1}='changeFlank';
        names{end+1}='changeTarget';
        names{end+1}='para';
        names{end+1}='other';
        conditionInds(end+1,:)=conditionInds(strcmp(names,'RRR'),:) | conditionInds(strcmp(names,'LLL'),:);
        conditionInds(end+1,:)=conditionInds(strcmp(names,'RLR'),:) | conditionInds(strcmp(names,'LRL'),:);
        conditionInds(end+1,:)=conditionInds(strcmp(names,'LRR'),:) | conditionInds(strcmp(names,'RLL'),:);
        conditionInds(end+1,:)=conditionInds(strcmp(names,'RRL'),:) | conditionInds(strcmp(names,'LLR'),:);
        conditionInds(end+1,:)=conditionInds(10,:) | conditionInds(11,:) | conditionInds(12,:);
    case '2flanks'
        [conditionInds names haveData colors]=getFlankerConditionInds(d,restrictedSubset,'8flanks+');
        whichInds=[find(strcmp({'colin'},names))  find(strcmp({'changeFlank'},names)) ];
        conditionInds=conditionInds(whichInds,:);
        names=names(whichInds);
        haveData=intersect(haveData,whichInds);
        colors=colors(whichInds,:);
    case 'colinSymetryCheck'
        
        
        [tempConditionInds tempNames tempHaveData tempColors]=getFlankerConditionInds(d,restrictedSubset,'colin+3');
        
        
        for i=1:length(tempNames)
            conditionInds(2*i,:)=colinear %& something>delta; %right-tipped
            conditionInds(2*i+1,:)=colinear %& something>delta; %left-tipped
            
        end
        
        
        error('not finished yet');
        
        
        colors=[1 ,0 ,0;%colinear=red
            0,1,1; %cyan
            0,1,1; %cyan
            0,0,0]; %black
        
        i=i+4;
        %names = [names, {'colin','popTC','popTI', 'para'}]
        names = [names, {'---','|-|','-|-', '|||'}];
        
        
    case 'noFlank'
        conditionInds=d.flankerContrast==0;
        colors=[.5 1 .5];
        names={'noF'};
    case 'hasFlank'
        conditionInds=d.flankerContrast>0;
        colors=[.6 .6 .6];
        names={'hasF'};
    case 'skip'
        % do nothing, this is a condition used to prevent overwriting
    otherwise
        types
        error('undefined type flanker conditions')
end



%disp(sprintf('\t all \tcolinear \t orthogonal\t orthogonal2 \tparallel \tnumTrials'))


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
