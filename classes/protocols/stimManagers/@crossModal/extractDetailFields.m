function out=extractDetailFields(sm,trialRecords)

%ok, trialRecords could just be the stimDetails, determined by this class's
%calcStim.  but you might want to do some processing that is sensitive to
%trialRecord values outside of stimDetails.

%base class stimManager would handle this differntly -- handling everything
%outside of stimDetails

%no way to guarantee that a stim manager's calcStim will make a stimDetails
%that includes all info its super class would have, so cannot call this
%method on every anscestor class.  must leave calling super class's
%extractDetailFields up to the sub class.  but can we at least always call
%the base class stimManager's?

%yes, but may of these are actually determined by the trialManager -- ie
%nAFC has scalar targetPorts, but freeDrinks doesn't.

%should move to base class stimManager
out.trialNumber=ensureScalar({trialRecords.trialNumber});
out.date=datenum(reshape([trialRecords.date],6,length(trialRecords))');
out.trainingStepNum=ensureScalar({trialRecords.trainingStepNum});
temp=[trialRecords.protocolVersion];
out.manualProtocolVersion=ensureScalar({temp.manualVersion});
out.autoProtocolVersion=ensureScalar({temp.autoVersion});
out.protocolDate=datenum(reshape([temp.date],6,length(temp))');
out.protocolAuthor={temp.author};
out.correct=ensureScalar({trialRecords.correct});
out.targetPort=ensureScalar({trialRecords.targetPorts});
out.distractorPort=ensureScalar({trialRecords.distractorPorts});


for i=1:length(trialRecords)
    if islogical(trialRecords(i).response)
        if isscalar(find(trialRecords(i).response))
            out.response(i)=find(trialRecords(i).response);
        else
            out.response(i)=-1; %multiple blocked ports
        end
    elseif ischar(trialRecords(i).response)
        switch trialRecords(i).response
            case 'none'
                out.response(i)=-2;
            case 'manual kill'
                out.response(i)=-3;
            case 'shift-2 kill'
                out.response(i)=-4;
            case 'server kill'
                out.response(i)=-5;
            otherwise
                out.response(i)=-6;
                trialRecords(i).response
                warning('unrecognized response')
        end
    else
        trialRecords(i).response
        class(trialRecords(i).response)
        error('unrecognized response type')
    end
end

if any(response==0)
    error('')
end

out.containedManualPokes=ensureScalar({trialRecords.containedManualPokes});
out.didHumanResponse=ensureScalar({trialRecords.didHumanResponse});

%specific to crossModal

stimDetails=[trialRecords.stimDetails];
temp=[stimDetails.HFdetails];
out.HFdetailsPctCorrectionTrials=ensureScalar({temp.pctCorrectionTrials});
out.HFdetailsCorrectionTrial=ensureScalar({temp.correctionTrial});
out.HFdetailsContrasts=ensureScalar({temp.contrasts}); %won't be scalar if distractor
out.HFdetailsXPosPcts=ensureScalar({temp.xPosPcts}); %won't be scalar if distractor

temp=[stimDetails.SDdetails];
out.SDdetailsPctCorrectionTrials=ensureScalar({temp.pctCorrectionTrials});
out.SDdetailsCorrectionTrial=ensureScalar({temp.correctionTrial});
out.SDdetailsLeftAmplitude=ensureScalar({temp.leftAmplitude});
out.SDdetailsRightAmplitude=ensureScalar({temp.rightAmplitude});


out.HFtargetPorts=ensureScalar({stimDetails.HFtargetPorts});
out.SDtargetPorts=ensureScalar({stimDetails.SDtargetPorts});
out.HFdistractorPorts=ensureScalar({stimDetails.HFdistractorPorts});
out.SDdistractorPorts=ensureScalar({stimDetails.SDdistractorPorts});

if size(out.HFdetailsXPosPcts,1)==size(out.HFdetailsContrasts,1)
    if size(out.HFdetailsContrasts,1)>1
        [junk inds]=sort(out.HFdetailsXPosPcts);
        sz=size(out.HFdetailsContrasts);
        inds=sub2ind(sz,inds,repmat(1:sz(2),sz(1),1));
        temp=out.HFdetailsContrasts(inds);
        [junk inds]=max(temp);
        [answers cols]=find(repmat(max(temp),size(temp,1),1)==temp);
        targetIsRight=answers-1;
        if ~all(cols==1:size(temp,2))
            error('nonunique answer')
        end
    else
        targetIsRight=out.HFdetailsXPosPcts>.5;
    end
else
    size(out.HFdetailsXPosPcts,1)
    size(out.HFdetailsContrasts,1)
    error('dims of HFdetailsContrasts and HFdetailsXPosPcts don''t match')
end
targets(targetIsRight)=3;
targets(targetIsLeft)=1;
if ~all(targets==out.HFtargetPorts)
    error('bad match between HF target ports, xPosPcts, and Contrasts')
end
distractors(targetIsRight)=1;
distractors(targetIsLeft)=3;
if ~all(distractors==out.HFdistractorPorts)
    error('bad match between HF distractor ports, xPosPcts, and Contrasts')
end

out.HFisCorrection=ensureScalar({stimDetails.HFisCorrection});
out.SDisCorrection=ensureScalar({stimDetails.SDisCorrection});

if ~all(out.HFisCorrection==out.HFdetailsCorrectionTrial) ||...
        ~all(out.SDisCorrection==out.SDdetailsCorrectionTrial)
    error('SD or HF isCorrection doesn''t match detailsCorrectionTrial')
end

out.currentModality=ensureScalar({stimDetails.currentModality});

if 

out.blockingLength=ensureScalar({stimDetails.blockingLength});
out.isBlocking=ensureScalar({stimDetails.isBlocking});
out.currentModalityTrialNum=ensureScalar({stimDetails.currentModalityTrialNum});

out.modalitySwitchMethod={stimDetails.modalitySwitchMethod};
out.modalitySwitchType={stimDetails.modalitySwitchType};

fn=fieldnames(out);
for i=1:length(fn)
    if ~all(size(out.(fn{i}))==[1 length(trialRecords)])
        fn{i}
        size(out.fn{i})
        error('bad return size')
    end
end
end

function arrayOut=ensureScalar(cellIn)
if isvector(cellIn)
    if all(cellfun(@isscalar,cellIn))
        arrayOut=[cellIn{:}];
    else
        error('not all scalar')
    end
else
    error('cellIn must be cell vector')
end
end