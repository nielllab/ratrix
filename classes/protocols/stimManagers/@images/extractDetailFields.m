function out=extractDetailFields(sm,basicRecords,trialRecords)

if ~all(strcmp({trialRecords.trialManagerClass},'nAFC'))
    warning('only works for nAFC trial manager')
    out=struct;
else

    try
        stimDetails=[trialRecords.stimDetails];

        out.isCorrection=ensureScalar({stimDetails.correctionTrial});
        out.pctCorrectionTrials=ensureScalar({stimDetails.pctCorrectionTrials});

        ims={stimDetails.imageDetails};
        out.leftIm=ensureTypedVector(cellfun(@(x)x{1}.name,ims,'UniformOutput',false),'char');
        out.rightIm=ensureTypedVector(cellfun(@(x)x{3}.name,ims,'UniformOutput',false),'char');
        out.suffices=nan*zeros(2,length(trialRecords)); %for some reason these are turning into zeros in the compiled file...  why?
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end

    if ~any(strcmp(out.leftIm,out.rightIm))
        %assume lower suffix is target and prefix is paintbrush_flashlight
        %to generalize this, need to have saved the constructor's image distribution argument in trialRecord.stimDetails
        prefix='paintbrush_flashlight';
        [a b]=textscan([out.leftIm{:}],[prefix '%d']);
        [c d]=textscan([out.rightIm{:}],[prefix '%d']);
        if b==length([out.leftIm{:}]) && d==length([out.rightIm{:}])
            out.suffices=[a{1} c{1}]';
            targetIsRight=a{1}>c{1};
            checkNafcTargets(targetIsRight,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
        else
            unique(out.leftIm)
            warning('prefix wasn''t paintbrush_flashlight or suffix wasn''t number -- bailing on checking target')
        end
    else
        error('left and right images are equal')
    end
end
verifyAllFieldsNCols(out,length(trialRecords));
end