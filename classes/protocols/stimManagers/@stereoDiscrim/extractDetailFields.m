function out=extractDetailFields(sm,basicRecords,trialRecords)

if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];

        out.isCorrection=ensureScalar({stimDetails.correctionTrial});
        out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});
        out.leftAmplitude=ensureEqualLengthVects({stimDetails.leftAmplitude});
        out.rightAmplitude=ensureEqualLengthVects({stimDetails.rightAmplitude});

        checkTargets(sm,out.leftAmplitude,out.rightAmplitude,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
    end
end
verifyAllFieldsNCols(out,length(trialRecords));
end