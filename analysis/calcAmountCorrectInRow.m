
function [correctInRow runEnds numSwitchesThisRun]=calcAmountCorrectInRow(correct,response)
%
%correctInRow - num trials long, for example, a value of 5 means it belongs to section
%of run length 5
%runStarts - true for the trial where each run length starts
%numSwitchesThisRun - %correctInRow - num trials long, for example, a value of 2 means it belongs to section
%which the animal switched sides twice and was still right
%
%USEFULL ACCESS METHOD:
%runLengths=correctInRow(runStarts)
%numSwitches=numSwitchesThisRun(runStarts)

debuggingThisCode=0;
if debuggingThisCode
    x=100; ln=10; x=ceil(rand*1000)
    correct=smallData.correct(x:x+ln-1)
    response=smallData.response(x:x+ln-1);
end

%nans are considered not correct!
correct(isnan(correct))=0;

correctInRow=zeros(size(correct));
numSwitchesThisRun=zeros(size(correct));

runStarts=diff([0 correct 0])==1;
runEnds=diff([0 correct 0])==-1;  % force an end with a 0


rE=find(runEnds)-1;
rS=find(runStarts);
runLengths=rE-rS+1;  % note this errored once b/c length(rE)~= length(rS), should catch and debug...



numRuns=sum(runStarts);
numSwitches=zeros(1,numRuns);
for i=1:numRuns
    if exist('response','var')
        numSwitchesThisRun(rS(i):rE(i))=sum(diff(int8(response(rS(i):rE(i))))~=0);
    end
    correctInRow(rS(i):rE(i))=1:runLengths(i);
end


%change it to reflect the -1 correction
runEnds=zeros(size(runEnds));
runEnds(rE)=1;
runEnds=logical(runEnds);



if debuggingThisCode
    correct
    response
    correctInRow
    numSwitchesThisRun
end