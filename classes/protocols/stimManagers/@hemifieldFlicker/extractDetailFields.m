function out=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)

if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];

        out.correctionTrial=ensureScalar({stimDetails.correctionTrial});
        out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});
        out.contrasts=ensureEqualLengthVects({stimDetails.contrasts});
        out.xPosPcts=ensureEqualLengthVects({stimDetails.xPosPcts});

        checkTargets(sm,out.xPosPcts,out.contrasts,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
    catch ex
        if strcmp(ex.message,'not all same length')
            warning('bailing: found trials with varying numbers of flickers -- happens rarely in some of dan''s early data')
            out=struct;
        else
            out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        end
    end
end
verifyAllFieldsNCols(out,length(trialRecords));
end