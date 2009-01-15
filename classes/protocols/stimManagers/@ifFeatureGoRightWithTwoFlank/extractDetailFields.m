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
        out.correctionTrial=ensureScalar({stimDetails.correctionTrial});  %why did erik change correctionTrial to isCorrection in stim details?
        out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});

        out.correctResponseIsLeft=getDetail(trialRecords,'correctResponseIsLeft');
        out.targetContrast=getDetail(trialRecords,'targetContrast');
        out.targetOrientation=getDetail(trialRecords,'targetOrientation');
        out.flankerContrast=getDetail(trialRecords,'flankerContrast');

        out.deviation=getDetail(trialRecords,'deviation');
        out.targetPhase=getDetail(trialRecords,'targetPhase');
        out.flankerPhase=getDetail(trialRecords,'flankerPhase');
        out.currentShapedValue=getDetail(trialRecords,'currentShapedValue');
        out.pixPerCycs=getDetail(trialRecords,'pixPerCycs');
        out.stdGaussMask=getDetail(trialRecords,'stdGaussMask');
        out.xPosNoisePix=getDetail(trialRecords,'xPosNoisePix');
        out.yPosNoisePix=getDetail(trialRecords,'yPosNoisePix');

        out.blockID=getDetail(trialRecords,'blockID');
        
       
        % take part of the vector
        out.flankerOrientation=getDetail(trialRecords,'flankerOrientation',1);
        out.flankerPosAngle=getDetail(trialRecords,'flankerPosAngles',1);
        out.flankerOff=getDetail(trialRecords,'flankerOnOff',2);
        out.redLUT=getDetail(trialRecords,'LUT',256);
        
        %if anything is defined
        out.fitRF=isDefined(trialRecords, 'fitRF');
        out.blocking=isDefined(trialRecords, 'blocking');
        out.dynamicSweep=isDefined(trialRecords, 'dynamicSweep');
        
        
        
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

    catch
        ex=lasterror;
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end
end
verifyAllFieldsNCols(out,length(trialRecords));


function out=isDefined(trialRecords, field)
%returns a one if the field is there and contain anything

stimDetails=[trialRecords.stimDetails];
f=fields(stimDetails);
if ~strcmp(field,f)
    %if the field is missing, it's not there (false=0)
    out=zeros(size(trialRecords));
else
    cellValues={stimDetails.(field)};
    out = cell2mat(cellfun('isempty',cellValues, 'UniformOutput',false));
end
    
function out=getDetail(trialRecords,field,nthValue,ifNotEmpty)
%helper function puts in a single double per trial, a nan if the field is
%missing, or a single value from a matrix if there are mutliple values
%perTrial

if ~exist('nthValue','var')
    nthValue=[];
end

stimDetails=[trialRecords.stimDetails];
f=fields(stimDetails);
if ~strcmp(field,f)
    %missing field, put nans
    fprintf('%s: \t inserted nan [1,(%d:%d)] <-- %s \n ',char(trialRecords(1).subjectsInBox),trialRecords(1).trialNumber,trialRecords(end).trialNumber,field)
    out=nan(size(trialRecords));
else
    if size([stimDetails.(field)])==size(trialRecords)
        %get basic double
        out=[stimDetails.(field)]; 
    else
        if ~isempty(nthValue)
            %get nth value of matrix
            cellValues={stimDetails.(field)};
            cellNth=repmat({nthValue},1,(length(trialRecords)));
            out = cell2mat(cellfun(@takeNthValue,cellValues ,cellNth, 'UniformOutput',false));
            if size(out)~=size(trialRecords)
                cellValues
                out
                size(out)
                size(trialRecords)
                error('should have one value per trial! failed!  maybe nans emptys in values?')
            end
        else
            error('should have one value per trial! failed! and nthValue is undefined')
        end
    end
end

function out=takeNthValue(values,N)
out=values(N);