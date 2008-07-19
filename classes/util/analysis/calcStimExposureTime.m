function [totalTime numTargetPresentations more]=calcStimExposureTime(trialRecords,plotOn)
% out=calcStimExposureTime(data{1}.trialRecords,1)
%[totalTime numTargetPresentations]=calcStimExposureTime(data{1}.trialRecords,1)

numTrials=size(trialRecords,2);
totalTime=zeros(1,numTrials);
numTargetPresentations=zeros(1,numTrials);

for i=1:numTrials   
    flipMissTimes1=(trialRecords(i).responseDetails.afterMissTimes-trialRecords(i).responseDetails.startTime);
    flipMissTimes2=(trialRecords(i).responseDetails.afterApparentMissTimes-trialRecords(i).responseDetails.startTime); 
    flipMissTimes=sort([flipMissTimes1 flipMissTimes2]);
    responseTimes=cell2mat(trialRecords(i).responseDetails.times);  
    
    switch trialRecords(1).stimManagerClass
        case 'ifFeatureGoRightWithTwoFlank'
            timeStimsAreUp=diff(responseTimes);  % first value of this variable is the dur of the first stim 1
            everyOther=(((-1).^([1:size(responseTimes,2)-1]))<0);
            durFirstStimUp=timeStimsAreUp(everyOther);   %this is stim index 1 which has the target
            durSecondStimUp=timeStimsAreUp(~everyOther);  %this is the second stim index which is also a mean screen
            %more.durFirstStimUp=durFirstStimUp
            totalTime(i)=sum(durFirstStimUp);
            numTargetPresentations(i)=size(durFirstStimUp,2);
        otherwise
            checkIfAfterTimeWindow=[];
            out1='not defined for this stimManagerClass'
            error('not defined for this stimManagerClass')
    end
    
end


