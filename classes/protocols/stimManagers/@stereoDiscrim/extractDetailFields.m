function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)

newLUT={};
if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];

        [out.correctionTrial newLUT] = extractFieldAndEnsure(stimDetails,{'correctionTrial'},'scalar',newLUT);
        [out.pctCorrectionTrials newLUT] = extractFieldAndEnsure(stimDetails,{'pctCorrectionTrials'},'scalar',newLUT);
        [out.leftAmplitude newLUT] = extractFieldAndEnsure(stimDetails,{'leftAmplitude'},'equalLengthVects',newLUT);
        [out.rightAmplitude newLUT] = extractFieldAndEnsure(stimDetails,{'rightAmplitude'},'equalLengthVects',newLUT);
%         out.correctionTrial=ensureScalar({stimDetails.correctionTrial});
%         out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});
%         out.leftAmplitude=ensureEqualLengthVects({stimDetails.leftAmplitude});
%         out.rightAmplitude=ensureEqualLengthVects({stimDetails.rightAmplitude});

        checkTargets(sm,out.leftAmplitude,out.rightAmplitude,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
    end
end
verifyAllFieldsNCols(out,length(trialRecords));
end