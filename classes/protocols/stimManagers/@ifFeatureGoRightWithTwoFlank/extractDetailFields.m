function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
% extract details for flankers
%
% quick init test after load in a trialRecord.mat
%   LUTparams.compiledLUT='nAFC';
%   basicRecords.trialManagerClass=1;
%   x=extractDetailFields(ifFeatureGoRightWithTwoFlank,basicRecords,trialRecords,LUTparams)

newLUT=LUTparams.compiledLUT;

acceptableTmIndices = find(ismember(LUTparams.compiledLUT,{'nAFC','cuedGoNoGo'}));
if ~isempty(acceptableTmIndices) && ~all(ismember([basicRecords.trialManagerClass],acceptableTmIndices))
    warning('only works for nAFC trial managers or cuedGoNoGo')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];
        [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
%         out.correctionTrial=ensureScalar({stimDetails.correctionTrial});  %why did erik change correctionTrial to isCorrection in stim details?
%         out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});

        [out.correctResponseIsLeft newLUT] = extractFieldAndEnsure(stimDetails,{'correctResponseIsLeft'},'scalar',newLUT);
        [out.targetContrast newLUT] = extractFieldAndEnsure(stimDetails,{'targetContrast'},'scalar',newLUT);
        [out.targetOrientation newLUT] = extractFieldAndEnsure(stimDetails,{'targetOrientation'},'scalar',newLUT);
        [out.flankerContrast newLUT] = extractFieldAndEnsure(stimDetails,{'flankerContrast'},'scalar',newLUT);
%         out.correctResponseIsLeft=getDetail(trialRecords,'correctResponseIsLeft');
%         out.targetContrast=getDetail(trialRecords,'targetContrast');
%         out.targetOrientation=getDetail(trialRecords,'targetOrientation');
%         out.flankerContrast=getDetail(trialRecords,'flankerContrast');

        [out.deviation newLUT] = extractFieldAndEnsure(stimDetails,{'deviation'},'scalar',newLUT);
        [out.targetPhase newLUT] = extractFieldAndEnsure(stimDetails,{'targetPhase'},'scalar',newLUT);
        [out.flankerPhase newLUT] = extractFieldAndEnsure(stimDetails,{'flankerPhase'},'scalar',newLUT);
        [out.currentShapedValue newLUT] = extractFieldAndEnsure(stimDetails,{'currentShapedValue'},'scalar',newLUT);
        [out.pixPerCycs newLUT] = extractFieldAndEnsure(stimDetails,{'pixPerCycs'},'scalar',newLUT);
        [out.stdGaussMask newLUT] = extractFieldAndEnsure(stimDetails,{'stdGaussMask'},'scalar',newLUT);
        [out.xPosNoisePix newLUT] = extractFieldAndEnsure(stimDetails,{'xPosNoisePix'},'scalar',newLUT);
        [out.yPosNoisePix newLUT] = extractFieldAndEnsure(stimDetails,{'yPosNoisePix'},'scalar',newLUT);

%         out.deviation=getDetail(trialRecords,'deviation');
%         out.targetPhase=getDetail(trialRecords,'targetPhase');
%         out.flankerPhase=getDetail(trialRecords,'flankerPhase');
%         out.currentShapedValue=getDetail(trialRecords,'currentShapedValue');
%         out.pixPerCycs=getDetail(trialRecords,'pixPerCycs');
%         out.stdGaussMask=getDetail(trialRecords,'stdGaussMask');
%         out.xPosNoisePix=getDetail(trialRecords,'xPosNoisePix');
%         out.yPosNoisePix=getDetail(trialRecords,'yPosNoisePix');

        [out.blockID newLUT] = extractFieldAndEnsure(stimDetails,{'blockID'},'scalar',newLUT);
        [out.trialThisBlock newLUT] = extractFieldAndEnsure(stimDetails,{'trialThisBlock'},'scalar',newLUT);
%         out.blockID=getDetail(trialRecords,'blockID');
        
       
        % take part of the vector
        [out.flankerOrientation newLUT] = extractFieldAndEnsure(stimDetails,{'flankerOrientation'},{'NthValue',1},newLUT);
        [out.flankerPosAngle newLUT] = extractFieldAndEnsure(stimDetails,{'flankerPosAngles'},{'NthValue',1},newLUT);
        [out.flankerOff newLUT] = extractFieldAndEnsure(stimDetails,{'flankerOnOff'},{'NthValue',2},newLUT);
        [out.redLUT newLUT] = extractFieldAndEnsure(stimDetails,{'LUT'},{'NthValue',256},newLUT);
%         out.flankerOrientation=getDetail(trialRecords,'flankerOrientation',1);
%         out.flankerPosAngle=getDetail(trialRecords,'flankerPosAngles',1);
%         out.flankerOff=getDetail(trialRecords,'flankerOnOff',2);
%         out.redLUT=getDetail(trialRecords,'LUT',256);
        
        %if anything is defined
        [out.fitRF newLUT] = extractFieldAndEnsure(stimDetails,{'fitRF'},'isDefinedAndNotEmpty',newLUT);
        [out.blocking newLUT] = extractFieldAndEnsure(stimDetails,{'blocking'},'isDefinedAndNotEmpty',newLUT);
        [out.dynamicSweep newLUT] = extractFieldAndEnsure(stimDetails,{'dynamicSweep'},'isDefinedAndNotEmpty',newLUT);
%         out.fitRF=isDefined(trialRecords, 'fitRF');
%         out.blocking=isDefined(trialRecords, 'blocking');
%         out.dynamicSweep=isDefined(trialRecords, 'dynamicSweep');
        

        [out.toggleStim newLUT] = extractFieldAndEnsure(stimDetails,{'toggleStim'},'scalar',newLUT);

        % consider getting this into compiled records in the future...stimDetails.protocolType
            
        % 4/8/09 - actualTargetOnOffMs and actualFlankerOnOffMs
        % how to vectorize this? b/c we need to collect all the tries for a given trial
        % only works in nAFC (because we can assume that 2nd phase is where stim presentation happens!)
        % look in phaseRecords(2) for request times
        % start of stim is assumed to be startTime=0 at phase 2
        out.actualTargetOnSecs=ones(1,length(trialRecords))*nan;
        out.actualTargetOnsetTime=ones(1,length(trialRecords))*nan;
        out.actualFlankerOnSecs=ones(1,length(trialRecords))*nan;
        out.actualFlankerOnsetTime=ones(1,length(trialRecords))*nan;
        for i=1:length(trialRecords)
            
           if 0 && ~isnan(trialRecords(i).stimDetails.flankerOnOff) && isnan(trialRecords(i).stimDetails.targetOnOff) ...
                   && trialRecords(i).stimDetails.flankerOnOff(2)==21 && trialRecords(i).stimDetails.targetOnOff(2)==26
               warning('breaking here to inspect 231''s data, and method to calculate actualFlankerOnsetTime')
               keyboard
           end
            try
                % if we are doing new-style records (both toggle and timed mode)
                if isfield(trialRecords(i),'phaseRecords') && ~isempty(trialRecords(i).phaseRecords)
                    % toggle mode
                    if trialRecords(i).stimDetails.toggleStim
                        tries=trialRecords(i).phaseRecords(1).responseDetails.tries{end};
                        tries=[tries trialRecords(i).phaseRecords(2).responseDetails.tries];
                        times=[0 trialRecords(i).phaseRecords(2).responseDetails.times]; % start of phase is when we assume toggle started
                        nominalIFI=trialRecords(i).phaseRecords(2).responseDetails.nominalIFI;
                        dropIFI=0;
                        if any(trialRecords(i).phaseRecords(2).responseDetails.misses==1)
                            dropIFI=trialRecords(i).phaseRecords(2).responseDetails.missIFIs(1)-nominalIFI;
                        end
                        [out.actualTargetOnSecs(i) out.actualTargetOnsetTime(i) out.actualFlankerOnSecs(i) ...
                            out.actualFlankerOnsetTime(i)] = ...
                            getDurationsAndOnsetTimesFromToggleMode(cell2mat(tries'),times,nominalIFI,dropIFI);
                    else % timed mode
                        tm= trialRecords(i).trialManager.trialManager;
                        if isfield(tm,'dropFrames')
                            dropFrames=tm.dropFrames;
                        else
                            dropFrames=false;
                        end
                        targetOnOff=trialRecords(i).stimDetails.targetOnOff;
                        flankerOnOff=trialRecords(i).stimDetails.flankerOnOff;
                        misses=trialRecords(i).phaseRecords(2).responseDetails.misses;
                        missIFIs=trialRecords(i).phaseRecords(2).responseDetails.missIFIs;
                        nominalIFI=trialRecords(i).phaseRecords(2).responseDetails.nominalIFI;

                        [out.actualTargetOnSecs(i) out.actualFlankerOnSecs(i)] = ...
                            calculateIntervalDuration(targetOnOff,flankerOnOff,misses,missIFIs,nominalIFI,dropFrames);

                        % now figure out onset time...
                        targetOnsetDelay=[1 targetOnOff(1)];
                        flankerOnsetDelay=[1 flankerOnOff(1)];
                        [actualTargetOnsetDelay actualFlankerOnsetDelay] = ...
                            calculateIntervalDuration(targetOnsetDelay,flankerOnsetDelay,misses,missIFIs,nominalIFI,dropFrames);
                        % actual onset time is the delay + the lick time + nominalIFI
                        % do we want the absolute time or the time relative to the lick?
                        %                 lickTime=trialRecords(i).phaseRecords(1).responseDetails.times(end);
                        %                 lickTime=lickTime{1}+trialRecords(i).phaseRecords(1).responseDetails.startTime;
                        %                 out.actualTargetOnsetTime(i)=lickTime+actualTargetOnsetDelay+nominalIFI;
                        %                 out.actualFlankerOnsetTime(i)=lickTime+actualFlankerOnsetDelay+nominalIFI;
                        out.actualTargetOnsetTime(i)=actualTargetOnsetDelay+nominalIFI;
                        out.actualFlankerOnsetTime(i)=actualFlankerOnsetDelay+nominalIFI;
                    end

                else % old-style records (only toggle mode)
                    if trialRecords(i).stimDetails.toggleStim
                        tries=trialRecords(i).responseDetails.tries;
                        times=trialRecords(i).responseDetails.times;
                        nominalIFI=trialRecords(i).responseDetails.nominalIFI;
                        dropIFI=0;
                        [out.actualTargetOnSecs(i) out.actualTargetOnsetTime(i) out.actualFlankerOnSecs(i) ...
                            out.actualFlankerOnsetTime(i)] = ...
                            getDurationsAndOnsetTimesFromToggleMode(cell2mat(tries'),times,nominalIFI,dropIFI);
                    end
                end
            catch ex
                % if something goes wrong for this trial, just leave as nans
                getReport(ex)
                continue;
            end
        end           
            
        
        %     if 0 % FROM old COMPILED
        %         % 12/16/08 - first 3 entries might be common to many stims
        %         % should correctionTrial be here in compiledDetails (whereas it was originally in compiledTrialRecords)
        %         % or should extractBasicRecs be allowed to access stimDetails to get correctionTrial?
        %                 fieldNames={...
        %         'correctionTrial',{'stimDetails','correctionTrial'};...             odd one b/c its still in stim details now
        %         'pctCorrectionTrials',{'stimDetails','pctCorrectionTrials'};...     odd one b/c its still in stim details now
        %         'maxCorrectForceSwitch',{'stimDetails','maxCorrectForceSwitch'};... odd one b/c its still in stim details now
        %         ...
        %         'correctResponseIsLeft',{'stimDetails','correctResponseIsLeft'};...
        %         'targetContrast',{'stimDetails','targetContrast'};...
        %         'targetOrientation',{'stimDetails','targetOrientation'};...
        %         'flankerContrast',{'stimDetails','flankerContrast'};...
        %         'flankerOrientation',{''};...
        %         'deviation',{'stimDetails','deviation'};...
        %         ...'devPix',{'stimDetails','devPix'};... removed b/c 2D: xpix & yPix, pmm 080603
        %         'targetPhase',{'stimDetails','targetPhase'};...
        %         'flankerPhase',{'stimDetails','flankerPhase'};...
        %         'currentShapedValue',{'stimDetails','currentShapedValue'};...
        %         'pixPerCycs',{'stimDetails','pixPerCycs'};...
        %         'redLUT',{'stimDetails','redLUT'};...
        %         'stdGaussMask',{'stimDetails','stdGaussMask'};...
        %         'flankerPosAngle',{'stimDetails','flankerPosAngle'};...
        %         };
        %
        %         for m=1:size(fieldNames,1)
        %             switch fieldNames{m,1}
        %
        %                 case 'flankerOrientation'
        %                     compiledTrialRecords.flankerOrientation(ranges{i}(1,j):ranges{i}(2,j))=nan;
        %                     %some old managers had more than one orientation
        %                     for tr=1:length(newTrialRecs)
        %                         if ismember('stimDetails',fields(newTrialRecs(tr))) && ismember('flankerOrientation',fields(newTrialRecs(tr).stimDetails)) && ~isempty(newTrialRecs(tr).stimDetails.flankerOrientation)% if the field exists
        %                             compiledTrialRecords.flankerOrientation(ranges{i}(1,j)+tr-1)=newTrialRecs(tr).stimDetails.flankerOrientation(1);
        %                         end
        %                     end
        %
        %                 case 'flankerPosAngle'
        %                     compiledTrialRecords.flankerPosAngle(ranges{i}(1,j):ranges{i}(2,j))=nan;
        %                     %use the first flankerPosAngle
        %                     for tr=1:length(newTrialRecs)
        %                         if ismember('stimDetails',fields(newTrialRecs(tr))) && ismember('flankerPosAngles',fields(newTrialRecs(tr).stimDetails)) && ~isempty(newTrialRecs(tr).stimDetails.flankerPosAngles)% if the field exists
        %                             compiledTrialRecords.flankerPosAngle(ranges{i}(1,j)+tr-1)=newTrialRecs(tr).stimDetails.flankerPosAngles(1);
        %                         end
        %                     end
        %                 case 'redLUT'
        %                     compiledTrialRecords.redLUT(ranges{i}(1,j):ranges{i}(2,j))=nan;
        %                     %only a single val from the LUT
        %                     for tr=1:length(newTrialRecs)
        %                         if ismember('stimDetails',fields(newTrialRecs(tr))) && ismember('LUT',fields(newTrialRecs(tr).stimDetails)) && ~isempty(newTrialRecs(tr).stimDetails.LUT)% if the field exists
        %                             try
        %                                 compiledTrialRecords.redLUT(ranges{i}(1,j)+tr-1)=newTrialRecs(tr).stimDetails.LUT(end,1);
        %                             catch
        %                                 keyboard
        %                             end
        %
        %                         end
        %                     end
        %                 case {'maxCorrectForceSwitch','actualRewardDuration', 'manualVersion','autoVersion','didStochasticResponse','containedForcedRewards', 'didHumanResponse',...
        %                         'totalFrames', 'startTime', 'numMisses',...
        %                         'correctResponseIsLeft', 'targetContrast','targetOrientation', 'flankerContrast',...
        %                         'deviation','targetPhase','flankerPhase','currentShapedValue','pixPerCycs','stdGaussMask','xPosNoisePix'}
        %
        %                     for tr=1:length(newTrialRecs)
        %                         compiledTrialRecords.(fieldNames{m,1})(ranges{i}(1,j)+tr-1)=isThereAndNotEmpty(newTrialRecs(tr),fieldNames{m,2});
        %                     end
        %
        %                 otherwise
        %
        %                     error(sprintf('no converter for field: %s',fieldNames{m,1}))
        %             end
        %             fprintf('%s ',fieldNames{m,1})
        %         end
        %         fprintf('}\n');
        %     end % if 0

    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end
end
verifyAllFieldsNCols(out,length(trialRecords));
end


function [actualTargetOnSecs actualTargetOnsetTime actualFlankerOnSecs actualFlankerOnsetTime] = ...
    getDurationsAndOnsetTimesFromToggleMode(tries,times,nominalIFI,dropIFI)
firstRequest=find(tries(:,2),1,'first');
if isempty(firstRequest)
    firstRequest=1;
    firstResponse=1;
else
    firstLeft=find(tries(firstRequest:end,1),1,'first');
    firstRight=find(tries(firstRequest:end,3),1,'first');
    if isempty(firstLeft)
        firstLeft=Inf;
    end
    if isempty(firstRight)
        firstRight=Inf;
    end
    firstResponse=min(firstRight,firstLeft);
    if isempty(firstResponse)
        firstResponse=1;
    end
    firstResponse=firstResponse+firstRequest-1;
end
allTimes=cell2mat(times(firstRequest:firstResponse));

allDiffs=diff(allTimes);


actualTargetOnSecs=sum(allDiffs(1:2:end));
actualTargetOnsetTime=allTimes(1)+nominalIFI+dropIFI; % 4/13/09 - we estimate the onset time as the lick time of the first request + nominalIFI + dropIFI(if we know it from phaseRecords)!
actualFlankerOnSecs=actualTargetOnSecs; % how do we know if flankers are on or not?
actualFlankerOnsetTime=allTimes(1)+nominalIFI+dropIFI;
end



function [actualTargetOnSecs actualFlankerOnSecs] = ...
    calculateIntervalDuration(targetOnOff,flankerOnOff,misses,missIFIs,nominalIFI,dropFrames)

targetInds=misses>=targetOnOff(1)&misses<targetOnOff(2);
flankerInds=misses>=flankerOnOff(1)&misses<flankerOnOff(2);
if dropFrames % dropFrames==true (harder case)
    lastMissedFrameBeforeInterval=find(misses<targetOnOff(1),1,'last');
    lastMissedFrameOfInterval=find(misses<targetOnOff(2),1,'last');
    numFramesLost=round(missIFIs(lastMissedFrameBeforeInterval)/nominalIFI)-1 ...
        -(double(targetOnOff(1))-misses(lastMissedFrameBeforeInterval)); % equiv to (est. # of dropped frames eating into interval) - (distance away from interval)
    numFramesGained=round(missIFIs(lastMissedFrameOfInterval)/nominalIFI)-1 ...
        -(double(targetOnOff(2))-misses(lastMissedFrameOfInterval)); % equiv to (est. # of dropped frames extending interval) - (distance away from interval)
    
    if isempty(numFramesLost) || numFramesLost<0
        numFramesLost=0;
    end
    if isempty(numFramesGained) || numFramesGained<0
        numFramesGained=0;
    end
    estTargetFramesInInterval=double(targetOnOff(2)-targetOnOff(1))+numFramesGained-numFramesLost;

    lastMissedFrameBeforeInterval=find(misses<flankerOnOff(1),1,'last');
    lastMissedFrameOfInterval=find(misses<flankerOnOff(2),1,'last');
    numFramesLost=round(missIFIs(lastMissedFrameBeforeInterval)/nominalIFI)-1 ...
        -(double(flankerOnOff(1))-misses(lastMissedFrameBeforeInterval)); % equiv to (est. # of dropped frames eating into interval) - (distance away from interval)
    numFramesGained=round(missIFIs(lastMissedFrameOfInterval)/nominalIFI)-1 ...
        -(double(flankerOnOff(2))-misses(lastMissedFrameOfInterval)); % equiv to (est. # of dropped frames extending interval) - (distance away from interval)
    if isempty(numFramesLost) || numFramesLost<0
        numFramesLost=0;
    end
    if isempty(numFramesGained) || numFramesGained<0
        numFramesGained=0;
    end
    estFlankerFramesInInterval=double(flankerOnOff(2)-flankerOnOff(1))+numFramesGained-numFramesLost;

    allMissIFIs=sum(missIFIs(targetInds));
    % number of undropped frames depends on the estNum of frames in the interval and the number/duration of all dropped frames within the interval
    numUndroppedTarget=round((nominalIFI*estTargetFramesInInterval - allMissIFIs) / nominalIFI);
    numUndroppedFlanker=round((nominalIFI*estFlankerFramesInInterval - allMissIFIs) / nominalIFI);
else % dropFrames==false (easy case)
    % number of undropped frames is just the total expected number minus the number of drops
    numUndroppedTarget=double(targetOnOff(2)-targetOnOff(1))-length(find(targetInds));
    numUndroppedFlanker=double(flankerOnOff(2)-flankerOnOff(1))-length(find(flankerInds));
end
actualTargetOnSecs=sum(missIFIs(targetInds)) + ...
    numUndroppedTarget*nominalIFI;
actualFlankerOnSecs=sum(missIFIs(flankerInds)) + ...
    numUndroppedFlanker*nominalIFI;
end