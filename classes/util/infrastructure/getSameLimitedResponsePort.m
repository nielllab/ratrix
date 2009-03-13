function [out hadToResample]=getSameLimitedResponsePort(responsePorts,maxSamePort,trialRecords)
%used to generate a random response from the ports but forcing a change if the last N+1 happen to be the same 
%set maxSamePort to -1 for pure random selection from available ports
%
%data=loadRatrixData([rootPath 'Boxes\box1\'],{'rat_112-113'},3); trialRecords=data{1}.trialRecords;
%[out hadToResample]=getSameLimitedResponsePort([1 3],4,trialRecords)
%
%future ideas: parameter to only switch is animal got all N correct on that side

hadToResample=0;

if maxSamePort==-1
    out=getRandomPort(responsePorts);
else
   
    %default
    correct=0;
    targetPorts=0;
    
    %make sure the field is there
    if all(size(trialRecords)>0)
        if any(strcmp(fields(trialRecords),'correct')) && any(strcmp(fields(trialRecords),'targetPorts'))
            correct=[trialRecords.correct];
            if isfield(trialRecords,'trialDetails')
                td=[trialRecords.trialDetails];
                correct=[td.correct];
            end
            targetPorts=[trialRecords.targetPorts];
        else
            error('**trialRecords does not have the ''correct'' field')
        end
    else
        warning('**trialRecords has size too small - probably this is the first trial')
    end
    %correct=rand(1,10)>0.5 debug testing

    %determine how many were same target in row before this
    sameInRow=diff([1 find(diff(targetPorts)) length(targetPorts)]);
    n=sameInRow(end);
   
    if n>maxSamePort
        resampleTillOkay=1;
        hadToResample=1;
    else
        resampleTillOkay=0;
        out=getRandomPort(responsePorts);
    end
    
    %this loop tries up to 100 times to draw from a different port than last
    k=0;
    lastTargetPort=targetPorts(end);
    while resampleTillOkay
        k=k+1;
        newSamp=getRandomPort(responsePorts);
        if newSamp~=lastTargetPort
            out=newSamp;
            resampleTillOkay=0;
        end
            
        if k>100
            error('maxNumber of resamples for same port')
        end
    end

end


function port=getRandomPort(responsePorts)
port=responsePorts(ceil(rand*length(responsePorts)));
