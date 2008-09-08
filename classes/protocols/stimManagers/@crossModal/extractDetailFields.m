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
out.sessionNumber=ensureScalar({trialRecords.sessionNumber});
out.date=datenum(reshape([trialRecords.date],6,length(trialRecords))')';
out.trainingStepNum=ensureScalar({trialRecords.trainingStepNum});
temp=[trialRecords.protocolVersion];
out.manualProtocolVersion=ensureScalar({temp.manualVersion});
out.autoProtocolVersion=ensureScalar({temp.autoVersion});
out.protocolDate=datenum(reshape([temp.date],6,length(temp))')';
out.protocolAuthor={temp.author};
out.correct=ensureScalar({trialRecords.correct});
out.targetPort=ensureScalar({trialRecords.targetPorts});
out.distractorPort=ensureScalar({trialRecords.distractorPorts});

out.response=cellfun(@encodeResponse,{trialRecords.response});

if any(out.response==0)
    error('got zero response')
end

out.containedManualPokes=ensureScalar({trialRecords.containedManualPokes});
out.didHumanResponse=ensureScalar({trialRecords.didHumanResponse});
out.containedForcedRewards=ensureScalar({trialRecords.containedForcedRewards});
out.didStochasticResponse=ensureScalar({trialRecords.didStochasticResponse});

%specific to crossModal

if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    error('only works for nAFC trial manager')
end

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

if size(out.HFdetailsXPosPcts,1)==size(out.HFdetailsContrasts,1)
    if size(out.HFdetailsContrasts,1)>1
        [junk inds]=sort(out.HFdetailsXPosPcts);
        sz=size(out.HFdetailsContrasts);
        inds=sub2ind(sz,inds,repmat(1:sz(2),sz(1),1));
        temp=out.HFdetailsContrasts(inds);
        [junk inds]=max(temp);
        [answers cols]=find(repmat(max(temp),size(temp,1),1)==temp);
        targetIsRight=logical(answers-1);
        if ~all(cols==1:size(temp,2))
            error('nonunique answer')
        end
    else
        if ~any(out.HFdetailsXPosPcts==.5)
            targetIsRight=out.HFdetailsXPosPcts>.5;
        else
            error('XPosPct at .5')
        end
    end
else
    size(out.HFdetailsXPosPcts,1)
    size(out.HFdetailsContrasts,1)
    error('dims of HFdetailsContrasts and HFdetailsXPosPcts don''t match')
end
checkTargs(targetIsRight,out.HFtargetPorts,out.HFdistractorPorts);

if ~any(out.SDdetailsLeftAmplitude==out.SDdetailsRightAmplitude)
targetIsRight=out.SDdetailsLeftAmplitude<out.SDdetailsRightAmplitude;
else
    error('left and right amplitude are equal')
end
checkTargs(targetIsRight,out.SDtargetPorts,out.SDdistractorPorts);

out.HFisCorrection=ensureScalar({stimDetails.HFisCorrection});
out.SDisCorrection=ensureScalar({stimDetails.SDisCorrection});

if ~all(out.HFisCorrection==out.HFdetailsCorrectionTrial) ||...
        ~all(out.SDisCorrection==out.SDdetailsCorrectionTrial)
    error('SD or HF isCorrection doesn''t match detailsCorrectionTrial')
end

out.currentModality=ensureScalar({stimDetails.currentModality});

if ~all(arrayfun(@checkAnswers,out.currentModality,out.HFtargetPorts,out.HFdistractorPorts,out.SDtargetPorts,out.SDdistractorPorts,out.correct,out.response,out.targetPort,out.distractorPort))
    error('inconsistent record')
end

out.isCorrection=nan*ones(1,length(trialRecords));
out.isCorrection(out.currentModality==0)=out.HFisCorrection(out.currentModality==0);
out.isCorrection(out.currentModality==1)=out.SDisCorrection(out.currentModality==1);
if any(isnan(out.isCorrection))
    error('not all isCorrections assigned')
end

out.blockingLength=ensureScalar({stimDetails.blockingLength});
out.isBlocking=ensureScalar({stimDetails.isBlocking});
out.currentModalityTrialNum=ensureScalar({stimDetails.currentModalityTrialNum});

out.modalitySwitchMethod={stimDetails.modalitySwitchMethod};
out.modalitySwitchType={stimDetails.modalitySwitchType};

fn=fieldnames(out);
for i=1:length(fn)
    if ~all(size(out.(fn{i}))==[1 length(trialRecords)])
        fn{i}
        size(out.(fn{i}))
        error('bad return size')
    else
        %fprintf('good conversion of %s\n',fn{i})
    end
end
end

function out=checkAnswers(modality,HFtarg,HFdistr,SDtarg,SDdistr,correct,resp,targ,distr)
if (resp==targ) == correct
    %pass
else
    error('bad correct calc')
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

function out=encodeResponse(in)
if islogical(in)
    if isscalar(find(in))
        out=find(in);
    else
        out=-1; %multiple blocked ports
    end
elseif ischar(in)
    switch in
        case 'none'
            out=-2;
        case 'manual kill'
            out=-3;
        case 'shift-2 kill'
            out=-4;
        case 'server kill'
            out=-5;
        otherwise
            out=-6;
            in
            warning('unrecognized response')
    end
else
    in
    class(in)
    error('unrecognized response type')
end
end

function checkTargs(targetIsRight,targetPorts,distractorPorts)
%assumes 3 ports, left is port 1, right is port 3, port 2 never target or
%distractor.  how verify this or make it dynamic?

targets(targetIsRight)=3;
targets(~targetIsRight)=1;
if ~all(targets==targetPorts)
    error('bad targets')
end
distractors(targetIsRight)=1;
distractors(~targetIsRight)=3;
if ~all(distractors==distractorPorts)
    error('bad distractors')
end
end