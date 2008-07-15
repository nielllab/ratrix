
numOppSoundAttempted=0;
numOppSoundCorrect=0;
numSameSoundAttempted=0;
numSameSoundCorrect=0;

numOppVisualAttempted=0;
numOppVisualCorrect=0;
numSameVisualAttempted=0;
numSameVisualCorrect=0;

numBlockAttempted=0;
numBlockCorrect=0;

oppVisualCorrect = [];
oppSoundCorrect = [];
sameVisualCorrect = [];
sameSoundCorrect = [];

trainingSet = 1; % Which set of trials are we on
ts=[];

for i=1:length(trialRecords)
    if trialRecords(i).stimDetails.isBlocking==0
        % Visual specific trials
        if trialRecords(i).stimDetails.currentModality==0
            if trialRecords(i).stimDetails.HFtargetPorts ~= trialRecords(i).targetPorts
                error('Current modality(0,Hemifield Flicker) target ports do not match!!')
            end
            if trialRecords(i).stimDetails.SDtargetPorts ~= trialRecords(i).targetPorts
                if trialRecords(i).correct == 1
                    numOppVisualCorrect = numOppVisualCorrect + 1;
                    oppVisualCorrect(end+1) = 1;
                else
                    oppVisualCorrect(end+1) = -1;
                end
                % These don't apply
                sameVisualCorrect(end+1)=0;
                oppSoundCorrect(end+1)=0;
                sameSoundCorrect(end+1)=0;
                numOppVisualAttempted = numOppVisualAttempted+1;
            else
                if trialRecords(i).correct == 1
                    numSameVisualCorrect = numSameVisualCorrect + 1;
                    sameVisualCorrect(end+1)= 1;
                else
                    sameVisualCorrect(end+1)= -1;
                end
                oppVisualCorrect(end+1)=0;
                oppSoundCorrect(end+1)=0;
                sameSoundCorrect(end+1)=0;
                numSameVisualAttempted = numSameVisualAttempted+1;
            end
        elseif trialRecords(i).stimDetails.currentModality==1
            % Sound specific trials
            if trialRecords(i).stimDetails.SDtargetPorts ~= trialRecords(i).targetPorts
                error('Current modality(0,Stereo Discrim) target ports do not match!!')
            end
            if trialRecords(i).stimDetails.HFtargetPorts ~= trialRecords(i).targetPorts
                if trialRecords(i).correct == 1
                    numOppSoundCorrect = numOppSoundCorrect + 1;
                    oppSoundCorrect(end+1)=1;
                else
                    oppSoundCorrect(end+1)=-1;
                end
                oppVisualCorrect(end+1)=0;
                sameVisualCorrect(end+1)=0;
                sameSoundCorrect(end+1)=0;
                numOppSoundAttempted = numOppSoundAttempted+1;
            else
                if trialRecords(i).correct == 1
                    numSameSoundCorrect = numSameSoundCorrect + 1;
                    sameSoundCorrect(end+1) = 1;
                else
                    sameSoundCorrect(end+1) = -1;
                end
                oppVisualCorrect(end+1)=0;
                sameVisualCorrect(end+1)=0;
                oppSoundCorrect(end+1)=0;
                numSameSoundAttempted = numSameSoundAttempted+1;
            end

        else
            error('Unknown modality type')
        end

    else
        if trialRecords(i).correct == 1
            numBlockCorrect = numBlockCorrect + 1;
        end
        numBlockAttempted = numBlockAttempted+1;
    end
    if (trialRecords(i).stimDetails.isBlocking == 1 && i-1 >= 1 && trialRecords(i-1).stimDetails.isBlocking == 0) || i==length(trialRecords)

        ts(trainingSet).oppVisualCorrect = oppVisualCorrect;
        ts(trainingSet).oppSoundCorrect = oppSoundCorrect;
        ts(trainingSet).sameVisualCorrect = sameVisualCorrect;
        ts(trainingSet).sameSoundCorrect = sameSoundCorrect;
        ts(trainingSet).allCorrect = sum([oppVisualCorrect; oppSoundCorrect; sameVisualCorrect; sameSoundCorrect]);

        oppVisualCorrect = [];
        oppSoundCorrect = [];
        sameVisualCorrect = [];
        sameSoundCorrect = [];
        trainingSet = trainingSet + 1;
    end

end


fprintf('Performance on contradictory trials with visual correct %f\n',numOppVisualCorrect/numOppVisualAttempted*100);
fprintf('Performance on contradictory trials with sound correct %f\n',numOppSoundCorrect/numOppSoundAttempted*100);

numOppCorrect=numOppSoundCorrect+numOppVisualCorrect;
numOppAttempted=numOppSoundAttempted+numOppVisualAttempted;
fprintf('Performance on trials where two modalities were contradictory %f\n',numOppCorrect/numOppAttempted*100);
numSameCorrect=numSameSoundCorrect+numSameVisualCorrect;
numSameAttempted=numSameSoundAttempted+numSameVisualAttempted;
fprintf('Performance on trials where two modalities matched %f\n',numSameCorrect/numSameAttempted*100);
fprintf('Performance on blocking trials %f\n',numBlockCorrect/numBlockAttempted*100);


% Now look at how well the rat did from the beginning of the block to the
% end
% 1 - Correct, 0 - Not tested, -1 Incorrect

tsFields=fields(ts);

for i=1:length(ts)
    for j=1:length(tsFields)
        d=ts(i).(tsFields{j});
        for k=1:length(d)
            corInd=find(d(1:k)>0); % Find only the correct ones
            ts(i).([tsFields{j} 'movAvg'])(k) = sum(d(corInd))/sum(abs(d(1:k)));
        end
    end
end

