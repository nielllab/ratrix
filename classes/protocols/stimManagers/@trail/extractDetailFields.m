function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;

nAFCindex = find(strcmp(LUTparams.compiledLUT,'ball'));
if isempty(nAFCindex) || (~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex))
    warning('only works for ball trial manager')
    out=struct;
else
    
    %     keyboard
    
    %     trialRecords.stimManagerClass %25
    %     trialRecords.stimManager.stim.originalType
    %     trialRecords.stimDetails
    
    try
        
        stimDetails=[trialRecords.stimDetails];
        
        if isfield(stimDetails,'subDetails')
            for i=1:length(stimDetails)
                tr(i).stimDetails = stimDetails(i).subDetails;
            end
            
            sms = [trialRecords.stimManager];
            sms = [sms.stim];
            try
                smt = unique([sms.originalType]);
                if isscalar(smt)
                    s = eval(LUTparams.sessionLUT{smt});
                    [out newLUT]=extractDetailFields(s,basicRecords,tr,LUTparams);
                else
                    warning('only works for homogenous sessions so far')
                end
            catch
                error('if we have subDetails, stim should have been a stimManager')
            end
        end                
        
        %         sms = [trialRecords.stimManager];
        %         smt = unique([sms.originalType]);
        %         if isscalar(smt)
        %             if strcmp(LUTparams.sessionLUT{smt},'trail')
        %                 sms = [sms.stim];
        %                 try
        %                     smt = unique([sms.originalType]);
        %                     if isscalar(smt)
        %                         s = eval(LUTparams.sessionLUT{smt});
        %                         [sOut sNewLUT]=extractDetailFields(s,basicRecords,tr,LUTparams);
        %                     else
        %                         warning('only works for homogenous sessions so far')
        %                     end
        %                 catch
        %                     %pass -- trail can have stim field that isn't a stimManager
        %                 end
        %             else
        %                 error('can''t happen -- caller only calls on homogenous chunks right?')
        %             end
        %         else
        %             error('can''t happen -- caller only calls on homogenous chunks right?')
        %         end
        
        %         [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        %         [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
        %         [out.pixPerCyc newLUT] = extractFieldAndEnsure(stimDetails,{'pixPerCyc'},'none',newLUT);
        %         [out.orientations newLUT] = extractFieldAndEnsure(stimDetails,{'orientations'},'none',newLUT);
        %         [out.phases newLUT] = extractFieldAndEnsure(stimDetails,{'phases'},'none',newLUT);
        %         [out.xPosPcts newLUT] = extractFieldAndEnsure(stimDetails,{'xPosPcts'},'none',newLUT);
        %         [out.contrast newLUT] = extractFieldAndEnsure(stimDetails,{'contrast'},'scalar',newLUT);
        
        % 12/16/08 - this stuff might be common to many stims
        % should correctionTrial be here in compiledDetails (whereas it was originally in compiledTrialRecords)
        % or should extractBasicRecs be allowed to access stimDetails to get correctionTrial?
        
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end
    
end
verifyAllFieldsNCols(out,length(trialRecords));
end