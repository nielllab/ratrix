function out=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)

%ok, trialRecords could just be the stimDetails, determined by this class's
%calcStim.  but you might want to do some processing that is sensitive to
%the combination of stimDetails and trialRecord values outside of stimDetails.

%basicRecords is most things outside of stimDetails (already processed into our format), but trialRecords is more complete

if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    error('only works for nAFC trial manager')
end

try
    stimDetails=[trialRecords.stimDetails];
    temp=[stimDetails.HFdetails];
    out.HFdetailsPctCorrectionTrials=ensureScalar({temp.pctCorrectionTrials});
    out.HFdetailsCorrectionTrial=ensureScalar({temp.correctionTrial});
    out.HFdetailsContrasts=ensureEqualLengthVects({temp.contrasts});
    out.HFdetailsXPosPcts=ensureEqualLengthVects({temp.xPosPcts});

    temp=[stimDetails.SDdetails];
    out.SDdetailsPctCorrectionTrials=ensureScalar({temp.pctCorrectionTrials});
    out.SDdetailsCorrectionTrial=ensureScalar({temp.correctionTrial});
    out.SDdetailsLeftAmplitude=ensureScalar({temp.leftAmplitude});
    out.SDdetailsRightAmplitude=ensureScalar({temp.rightAmplitude});

    out.HFtargetPorts=ensureScalar({stimDetails.HFtargetPorts});
    out.SDtargetPorts=ensureScalar({stimDetails.SDtargetPorts});
    out.HFdistractorPorts=ensureScalar({stimDetails.HFdistractorPorts});
    out.SDdistractorPorts=ensureScalar({stimDetails.SDdistractorPorts});

    checkTargets(sm.hemifieldFlicker,out.HFdetailsXPosPcts,out.HFdetailsContrasts,num2cell(out.HFtargetPorts),num2cell(out.HFdistractorPorts),basicRecords.numPorts);
    checkTargets(sm.stereoDiscrim,out.SDdetailsLeftAmplitude,out.SDdetailsRightAmplitude,num2cell(out.SDtargetPorts),num2cell(out.SDdistractorPorts),basicRecords.numPorts);
    
    out.HFcorrectionTrial=ensureScalar({stimDetails.HFcorrectionTrial});
    out.SDcorrectionTrial=ensureScalar({stimDetails.SDcorrectionTrial});

    if ~all(out.HFcorrectionTrial==out.HFdetailsCorrectionTrial) ||...
            ~all(out.SDcorrectionTrial==out.SDdetailsCorrectionTrial)
        error('SD or HF correctionTrial doesn''t match detailsCorrectionTrial')
    end

    out.currentModality=ensureScalar({stimDetails.currentModality});

    if ~all(arrayfun(@checkAnswers,out.currentModality,out.HFtargetPorts,out.HFdistractorPorts,out.SDtargetPorts,out.SDdistractorPorts,basicRecords.targetPorts,basicRecords.distractorPorts))
        error('inconsistent record')
    end

    out.correctionTrial=nan*ones(1,length(trialRecords));
    out.correctionTrial(out.currentModality==0)=out.HFcorrectionTrial(out.currentModality==0);
    out.correctionTrial(out.currentModality==1)=out.SDcorrectionTrial(out.currentModality==1);
    if any(isnan(out.correctionTrial))
        error('not all correctionTrial assigned')
    end

    out.blockingLength=ensureScalar({stimDetails.blockingLength});
    out.isBlocking=ensureScalar({stimDetails.isBlocking});
    out.currentModalityTrialNum=ensureScalar({stimDetails.currentModalityTrialNum});

    out.modalitySwitchMethod=ensureTypedVector({stimDetails.modalitySwitchMethod},'char');
    out.modalitySwitchType=ensureTypedVector({stimDetails.modalitySwitchType},'char');
catch ex
    out=handleExtractDetailFieldsException(sm,ex,trialRecords);
end

verifyAllFieldsNCols(out,length(trialRecords));
end

function out=checkAnswers(modality,HFtarg,HFdistr,SDtarg,SDdistr,targs,distrs)
if isscalar(targs) && isscalar(distrs)
    targ=targs{1};
    distr=distrs{1};
else
    error('only works with scalar targs and distrs')
end
switch modality
    case 0
        if targ==HFtarg && distr==HFdistr
            %pass
        else
            error('HF targ or distr mismatch')
        end
    case 1
        if targ==SDtarg && distr==SDdistr
            %pass
        else
            error('SD targ or distr mismatch')
        end
    otherwise
        modality
        error('unrecognized modality')
end
out=true;
end