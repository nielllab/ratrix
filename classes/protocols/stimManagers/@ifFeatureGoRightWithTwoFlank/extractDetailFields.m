function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
% extract details for flankers
%
% quick init test after load in a trialRecord.mat
%   LUTparams.compiledLUT='nAFC';
%   basicRecords.trialManagerClass=1;
%   extractDetailFields(ifFeatureGoRightWithTwoFlank,basicRecords,trialRecords,LUTparams)

newLUT={};

nAFCindex = find(strcmp(LUTparams.compiledLUT,'nAFC'));
if ~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex)
    warning('only works for nAFC trial manager')
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
        [out.fitRF newLUT] = extractFieldAndEnsure(stimDetails,{'fitRF'},'isNotEmpty',newLUT);
        [out.blocking newLUT] = extractFieldAndEnsure(stimDetails,{'blocking'},'isNotEmpty',newLUT);
        [out.dynamicSweep newLUT] = extractFieldAndEnsure(stimDetails,{'dynamicSweep'},'isNotEmpty',newLUT);
%         out.fitRF=isDefined(trialRecords, 'fitRF');
%         out.blocking=isDefined(trialRecords, 'blocking');
%         out.dynamicSweep=isDefined(trialRecords, 'dynamicSweep');
        
        % 4/8/09 - actualTargetOnOffMs and actualFlankerOnOffMs
        % how to vectorize this? b/c we need to collect all the tries for a given trial
        % only works in nAFC (because we can assume that 2nd phase is where stim presentation happens!)
        % look in phaseRecords(2) for request times
        % start of stim is assumed to be startTime=0 at phase 2
        out.actualTargetOnMs=ones(1,length(trialRecords))*nan;
        out.actualTargetOffMs=ones(1,length(trialRecords))*nan;
        out.actualFlankerOnMs=ones(1,length(trialRecords))*nan;
        out.actualFlankerOffMs=ones(1,length(trialRecords))*nan;
        for i=1:length(trialRecords)
            if trialRecords(i).stimDetails.toggleStim % toggle mode
                if isfield(trialRecords(i),'phaseRecords')
                    allTimes=cell2mat([0 trialRecords(i).phaseRecords(2).responseDetails.times]);
                else
                    tries=cell2mat(trialRecords(i).responseDetails.tries');
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
                    allTimes=cell2mat(trialRecords(i).responseDetails.times(firstRequest:firstResponse));
                end
                    
                allDiffs=diff(allTimes);
                out.actualTargetOnMs(i)=sum(allDiffs(1:2:end));
                out.actualTargetOffMs(i)=sum(allDiffs(2:2:end));
                out.actualFlankerOnMs=out.actualTargetOnMs; % how do we know if flankers are on or not?
                out.actualFlankerOffMs=out.actualTargetOffMs; 
            else % dropped frames
                tm= trialRecords(i).trialManager.trialManager;

                % numUndroppedFrames*nominalIFI + missIFIs that are in the targetOnOff interval
                targetOnOff=trialRecords(i).stimDetails.targetOnOff;
                flankerOnOff=trialRecords(i).stimDetails.flankerOnOff;
                misses=trialRecords(i).phaseRecords(2).responseDetails.misses;
                targetInds=misses>targetOnOff(1)&misses<=targetOnOff(2);
                flankerInds=misses>flankerOnOff(1)&misses<=flankerOnOff(2);
                if isfield(tm,'dropFrames') && tm.dropFrames  % tm.dropFrames is set
                    numUndroppedTarget=double(targetOnOff(2)-targetOnOff(1))-length(find(targetInds));
                    numUndroppedFlanker=double(flankerOnOff(2)-flankerOnOff(1))-length(find(flankerInds));
                else % tm.dropFrames is either not present or not set
                    numUndroppedTarget=double(targetOnOff(2)-targetOnOff(1));
                    numUndroppedFlanker=double(flankerOnOff(2)-flankerOnOff(1));
                end
                out.actualTargetOnMs(i)=sum(trialRecords(i).phaseRecords(2).responseDetails.missIFIs(targetInds)) + ...
                    numUndroppedTarget*trialRecords(i).phaseRecords(2).responseDetails.nominalIFI;
                out.actualFlankerOnMs(i)=sum(trialRecords(i).phaseRecords(2).responseDetails.missIFIs(flankerInds)) + ...
                    numUndroppedFlanker*trialRecords(i).phaseRecords(2).responseDetails.nominalIFI;
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


% function out=isDefined(trialRecords, field)
% %returns a one if the field is there and contain anything
% 
% stimDetails=[trialRecords.stimDetails];
% f=fields(stimDetails);
% if ~strcmp(field,f)
%     %if the field is missing, it's not there (false=0)
%     out=zeros(size(trialRecords));
% else
%     cellValues={stimDetails.(field)};
%     out = cell2mat(cellfun('isempty',cellValues, 'UniformOutput',false));
% end
%     
% function out=getDetail(trialRecords,field,nthValue,ifNotEmpty)
% %helper function puts in a single double per trial, a nan if the field is
% %missing, or a single value from a matrix if there are mutliple values
% %perTrial
% 
% if ~exist('nthValue','var')
%     nthValue=[];
% end
% 
% stimDetails=[trialRecords.stimDetails];
% f=fields(stimDetails);
% if ~strcmp(field,f)
%     %missing field, put nans
%     fprintf('%s: \t inserted nan [1,(%d:%d)] <-- %s \n ',char(trialRecords(1).subjectsInBox),trialRecords(1).trialNumber,trialRecords(end).trialNumber,field)
%     out=nan(size(trialRecords));
% else
%     if size([stimDetails.(field)])==size(trialRecords)
%         %get basic double
%         out=[stimDetails.(field)]; 
%     else
%         if ~isempty(nthValue)
%             %get nth value of matrix
%             cellValues={stimDetails.(field)};
%             cellNth=repmat({nthValue},1,(length(trialRecords)));
%             out = cell2mat(cellfun(@takeNthValue,cellValues ,cellNth, 'UniformOutput',false));
%             if size(out)~=size(trialRecords)
%                 cellValues
%                 out
%                 size(out)
%                 size(trialRecords)
%                 error('should have one value per trial! failed!  maybe nans emptys in values?')
%             end
%         else
%             error('should have one value per trial! failed! and nthValue is undefined')
%         end
%     end
% end
% 
% function out=takeNthValue(values,N)
% out=values(N);