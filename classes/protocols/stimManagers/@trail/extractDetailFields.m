function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;

nAFCindex = find(strcmp(LUTparams.compiledLUT,'ball'));
if isempty(nAFCindex) || (~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex))
    warning('only works for ball trial manager')
    out=struct;
else
    
    keyboard
    
    trialRecords.stimManagerClass %25
    trialRecords.stimManager.stim.originalType
    trialRecords.stimDetails
    
    try
        stimDetails=[trialRecords.stimDetails];
        
        sms = [trialRecords.stimManager];
        if isfield(sms,'originalType')
            smt = unique([sms.originalType]);
            if isscalar(smt)
                smt = LUTparams.sessionLUT{smt};
            end
            if isfield(stimDetails,'subDetails')
            end
        end
        
        
        [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
        [out.pixPerCyc newLUT] = extractFieldAndEnsure(stimDetails,{'pixPerCyc'},'none',newLUT);
        [out.orientations newLUT] = extractFieldAndEnsure(stimDetails,{'orientations'},'none',newLUT);
        [out.phases newLUT] = extractFieldAndEnsure(stimDetails,{'phases'},'none',newLUT);
        [out.xPosPcts newLUT] = extractFieldAndEnsure(stimDetails,{'xPosPcts'},'none',newLUT);
        [out.contrast newLUT] = extractFieldAndEnsure(stimDetails,{'contrast'},'scalar',newLUT);
        
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