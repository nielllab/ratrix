function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
newLUT=LUTparams.compiledLUT;

nAFCindex = find(strcmp(LUTparams.compiledLUT,'nAFC'));
if ~isempty(nAFCindex) && ~all([basicRecords.trialManagerClass]==nAFCindex)
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];
        [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
        [out.dotDirection newLUT] = extractFieldAndEnsure(stimDetails,{'dotDirection'},'scalar',newLUT);
        [out.coherence newLUT] = extractFieldAndEnsure(stimDetails,{'coherence'},'equalLengthVects',newLUT);
        [out.dot_size newLUT] = extractFieldAndEnsure(stimDetails,{'dot_size'},'equalLengthVects',newLUT);
        [out.contrast newLUT] = extractFieldAndEnsure(stimDetails,{'contrast'},'equalLengthVects',newLUT);
        [out.speed newLUT] = extractFieldAndEnsure(stimDetails,{'speed'},'equalLengthVects',newLUT);
        
        [out.selectedCoherence newLUT] = extractFieldAndEnsure(stimDetails,{'selectedCoherence'},'scalar',newLUT);
        [out.selectedDotSize newLUT] = extractFieldAndEnsure(stimDetails,{'selectedDotSize'},'scalar',newLUT);
        [out.selectedContrast newLUT] = extractFieldAndEnsure(stimDetails,{'selectedContrast'},'scalar',newLUT);
        [out.selectedSpeed newLUT] = extractFieldAndEnsure(stimDetails,{'selectedSpeed'},'scalar',newLUT);
        [out.selectedDuration newLUT] = extractFieldAndEnsure(stimDetails,{'selectedDuration'},'scalar',newLUT);
        
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
