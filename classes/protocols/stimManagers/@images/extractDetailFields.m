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

        ims={stimDetails.imageDetails};
%         [indices compiledLUT] = addOrFindInLUT(compiledLUT,newRecs.(fn));
        out.leftIm=ensureTypedVector(cellfun(@(x)x{1}.name,ims,'UniformOutput',false),'char');
        out.rightIm=ensureTypedVector(cellfun(@(x)x{3}.name,ims,'UniformOutput',false),'char');
        out.suffices=nan*zeros(2,length(trialRecords)); %for some reason these are turning into zeros in the compiled file...  why?
    catch ex
        out=handleExtractDetailFieldsException(sm,ex,trialRecords);
        verifyAllFieldsNCols(out,length(trialRecords));
        return
    end

    % 12/15/08 - now we have the trialDistribution in stimDetails, so check that either leftIm or rightIm was a target,
    % and that the other one was a distractor in the same image list (in trialDistribution)
    if ~any(strcmp(out.leftIm,out.rightIm))
        % leftIm and rightIm are not the same, now check that only one of them is a target
        tds = {stimDetails.trialDistribution};
        % for each trialDistribution, check that either the leftIm or rightIm is a target
        leftImIsTarget=zeros(1,length(tds));
        rightImIsTarget=zeros(1,length(tds));
        for i=1:length(tds)
            leftImIsTarget(i)=isATargetInTrialDistribution(out.leftIm{i},out.rightIm{i},tds{i});
            rightImIsTarget(i)=isATargetInTrialDistribution(out.rightIm{i},out.leftIm{i},tds{i});
        end
        % now check the XOR of leftImIsTarget and rightImIsTarget (one of them must be the target)
        if ~all(xor(leftImIsTarget,rightImIsTarget))
            leftImIsTarget
            out.leftIm
            rightImIsTarget
            out.rightIm
            error('found a trial without a valid target image');
        end
        % check that the target/distractor based on trialDistribution and imageDetails matches basicRecords.targetPorts/distractorPorts
        targetIsRight=logical(rightImIsTarget);
        checkNafcTargets(targetIsRight,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
        
    else
        error('left and right images are equal');
    end
    
    % 1/2/09 - LUT-ize
    [indices newLUT] = addOrFindInLUT(newLUT, out.leftIm);
    out.leftIm = indices+LUTparams.lastIndex;
    [indices newLUT] = addOrFindInLUT(newLUT, out.rightIm);
    out.rightIm = indices+LUTparams.lastIndex;
    
    % we dont need this check ? 12/12/08
%     if ~any(strcmp(out.leftIm,out.rightIm))
%         %assume lower suffix is target and prefix is paintbrush_flashlight
%         %to generalize this, need to have saved the constructor's image distribution argument in trialRecord.stimDetails
%         prefix='paintbrush_flashlight';
%         [a b]=textscan([out.leftIm{:}],[prefix '%d']);
%         [c d]=textscan([out.rightIm{:}],[prefix '%d']);
%         if b==length([out.leftIm{:}]) && d==length([out.rightIm{:}])
%             out.suffices=[a{1} c{1}]';
%             targetIsRight=a{1}>c{1};
%             checkNafcTargets(targetIsRight,basicRecords.targetPorts,basicRecords.distractorPorts,basicRecords.numPorts);
%         else
%             unique(out.leftIm)
%             warning('prefix wasn''t paintbrush_flashlight or suffix wasn''t number -- bailing on checking target')
%         end
%     else
%         error('left and right images are equal')
%     end
end
verifyAllFieldsNCols(out,length(trialRecords));

end % end main function


%% HELPER FUNCTION
function out = isATargetInTrialDistribution(target, distractor, td)
% returns the index of the trialDistribution in which target is the target image
% also checks that if out~=0 (ie target is a target for the trialDistribution) that the distractor is a member of that td list
out=0;
for i=1:length(td)
    if strcmp(target,td{i}{1}{1}) % check against target in this list of the td
        if out~=0
            error('found image to be target in multiple trialDistribution lists');
        else
            out=i;
            % check that distractor is in this td list
            foundDistractor = ismember(distractor,td{i}{1});
            if ~foundDistractor
                error('found target image, but no corresponding distractor in trialDistribution list');
            end
        end
    end
end

end % end function
        