function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT={};

nAFCindex = find(strcmp(LUTparams.compiledLUT,'nAFC'));
if ~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex)
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];
        out.correctionTrial=ensureScalar({stimDetails.correctionTrial});
        out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});
        out.pixPerCyc=ensureScalar({stimDetails.pixPerCyc});
        out.orientations=[stimDetails.orientations];
        out.phases=[stimDetails.phases];
        out.xPosPcts=[stimDetails.xPosPcts];
        
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