function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;


    try
        stimDetails=[trialRecords.stimDetails];

        [out.startTone newLUT] = extractFieldAndEnsure(stimDetails,{'startTone'},'scalar',newLUT);
        [out.numTones newLUT] = extractFieldAndEnsure(stimDetails,{'numTones'},'scalar',newLUT);
        % 12/16/08 - this stuff might be common to many stims
        % should correctionTrial be here in compiledDetails (whereas it was originally in compiledTrialRecords)
        % or should extractBasicRecs be allowed to access stimDetails to get correctionTrial?
        
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return

end
verifyAllFieldsNCols(out,length(trialRecords));
end
