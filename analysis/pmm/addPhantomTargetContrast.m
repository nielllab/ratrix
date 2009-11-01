function d=addPhantomTargetContrast(d,respectGroups,assignmentMethod)
% inserts what the contrast "would have been" if the target was not absent
% this method only makes sense for detection and is actually a really bad
% thing to do for discrimination data that happens to have zero contrast.


% caviotes:  will only assign as many noTargets as there are a contrasts of
% that value
% since these are usuually mathced, but random, on average, half the time
% there will be nan's unfilled in a no flank condition and the other half 
% that condition will have had not enough noTargets, and cropped them...
% for many grouped conditions this leads to a net reduction of
% noFlanks...they wont get assigned when there are to few contrasted
% pairs... We could randomly fill in these extra contrasts by randomly
% sampling some of the exitsing trials twice...


hasAllPhantomContrastLabeled=false;
if isfield(d,'phantomContrast')
    if all(~isnan(d.phantomContrast))
        % has em all, so just use em!
        hasAllPhantomContrastLabeled=true;
        else
        %has some but not all... never happened, but could
        error('this data has the phantom contrast stored... need to rethink... only deal with nan data?')
    end

end

if ~exist('respectGroups','var') || isempty(respectGroups)
    respectGroups=ones(size(d.date)); % combine all into one group.  bad for mixed conditions or pooling with noFlank probes
else
if  size(d.date,2)~=size(respectGroups,2)
    numTrials=size(d.date,2)
    sx=size(respectGroups)
    error('respectGroups must be numGroups x numTrials')
end
end

if ~exist('assignmentMethod','var') || isempty(assignmentMethod)
    assignmentMethod='nearestWithOverlap';
end

% check if its dteection no discrimination...
leftContrasts=unique(d.targetContrast(d.correctResponseIsLeft==1));
rightContrasts=unique(d.targetContrast(d.correctResponseIsLeft==-1));

isRightDetection=(all(leftContrasts==0) && all(~ismember(rightContrasts,0)));
isLeftDetection=(all(rightContrasts==0) && all(~ismember(leftContrasts,0)));  % all becomes "any" to tolerate that bad early data
isDetection= isRightDetection || isLeftDetection;

if special138_139data(d)
    isDetection=true
    isRightDetection=true;
    rightContrasts(rightContrasts==0)=[];  %remove the one contrast condition that has no contrats, don't analyze
end

if ~isDetection
    error('don''t use this code for non-detection data')
end

if isLeftDetection
    contrasts=leftContrasts;
    targetAbsent=d.correctResponseIsLeft==-1;
elseif isRightDetection
    contrasts=rightContrasts;
    targetAbsent=d.correctResponseIsLeft==1;
else
    error('never!')
end


phantomContrast=nan(size(d.date));
phantomContrast(~targetAbsent)=d.targetContrast(~targetAbsent); % add in the known contrast

if hasAllPhantomContrastLabeled
   phantomContrast(targetAbsent)=d.phantomContrast(targetAbsent);
end

for i=1:size(respectGroups,1)
    
    if hasAllPhantomContrastLabeled
        %don't need to assign, just continue to the error checking at the end
        break
    end
    
    candidates=targetAbsent &  respectGroups(i,:);
    for c=1:length(contrasts)
        
        matchThese=d.targetContrast==contrasts(c) & respectGroups(i,:);
        numSamples=min(sum(matchThese),sum(candidates)); ...only take as many as are there... no more...
        %if numSamples<sum(candidates)
            
        
        switch assignmentMethod
            case 'random'
                % randomly draw N samples from the available candidates
                randIndex=randperm(sum(candidates));
                index=randIndex(1:numSamples); % not nearby but statistically fair for a homogenous analysis

            case 'nearestIndices'
                error('not yet')
                % the ones at the end of the loop have more chance to be  offset, i think

                reduceEventsTo=fractionOfNoTargtesAvialable; % a fraction or number...maybe fraction can solve the which contrasts get less noTargts fairly
                nearest=nearestIndices(candidates,matchThese,reduceEventsTo)
                index=find(nearest);
            case 'nearestWithOverlap'
                error('not yet')
                overlapIsAcceptable=true;
                nearest=nearestIndices(candidates,matchThese,reduceEventsTo,overlapIsAcceptable)
                
            otherwise
                assignmentMethod
                error('bad assignmentMethod')
        end
        
        try
            candsLeft=find(candidates);
            phantomContrast(candsLeft(index))=contrasts(c);
            candidates(candsLeft(index))=0; % remove the ones that are assigned;  garaunteed no-overlap  (may run out of trials! what do you double up on?)
        catch
            max(index)
            size(phantomContrast)
            keyboard
            
        end
    end
end


if any(isnan(phantomContrast))
    warning('failed to assign %2.2g%% of noTargets to a contrasts (%d extra trials)',100*sum(isnan(phantomContrast))/ sum(targetAbsent),sum(isnan(phantomContrast)))
end

if all(phantomContrast(~targetAbsent)~=d.targetContrast(~targetAbsent));
error('violated truth on the targets real value... this should never happen.. means a method its wrong.')
end

d.phantomTargetContrastCombined=phantomContrast;