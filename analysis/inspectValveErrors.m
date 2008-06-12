%inspectValveErrors(trialRecords)

trialRecords=data{1}.trialRecords
%problemTrial=[]
problemTrialNum=0;
problemTrialNums=[];

for i=1:size(trialRecords,2)
    %trialRecords(i).responseDetails.valveErrorDetails
    if ~isempty(trialRecords(i).responseDetails.valveErrorDetails)
        problemTrialNum=problemTrialNum+1;
        problemTrialNums(problemTrialNum)=i;
    end
end

for i=problemTrialNums
    trialRecords(i).responseDetails.valveErrorDetails
end

problemTrialNums