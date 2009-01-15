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
        out.dotDirection=ensureScalar({stimDetails.dotDirection});
%         out.dotxy=ensureTypedVector({stimDetails.dotxy},'numeric'); % this is a matrix - so don't include in compiled
        out.coherence=ensureEqualLengthVects({stimDetails.coherence});
        out.dot_size=ensureEqualLengthVects({stimDetails.dot_size});
        out.contrast=ensureEqualLengthVects({stimDetails.contrast});
        out.speed=ensureEqualLengthVects({stimDetails.speed});
        
        out.selectedCoherence=ensureScalar({stimDetails.selectedCoherence});
        out.selectedDotSize=ensureScalar({stimDetails.selectedDotSize});
        out.selectedContrast=ensureScalar({stimDetails.selectedContrast});
        out.selectedSpeed=ensureScalar({stimDetails.selectedSpeed});
        
        % 12/16/08 - this stuff might be common to many stims
        % should correctionTrial be here in compiledDetails (whereas it was originally in compiledTrialRecords)
        % or should extractBasicRecs be allowed to access stimDetails to get correctionTrial?
        
    catch 
        ex=lasterror;
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end

end
verifyAllFieldsNCols(out,length(trialRecords));
end
