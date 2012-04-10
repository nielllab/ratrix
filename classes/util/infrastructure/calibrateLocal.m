function calibrateLocal( numReps, amts, timeBtw, requiredAccuracy )
%ex: calibrateLocal( 10, [.03 .03 .03], .25, .1 )

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

id               = '1U';
path             = fullfile(dataPath, 'Stations',['station' id]);
[~,mac]          = getMACaddress;
physicalLocation = int8([1 1 1]);

s = makeDefaultStation(id,path,mac,physicalLocation);

valveErrorDetails=[];
currentValveStates=zeros(1,length(amts));

randomize=true;
plan=repmat(1:length(amts),numReps,1);
plan=plan(:);
if randomize
    plan=plan(randperm(length(plan)));
end

priorityLevel=Priority(MaxPriority('GetSecs','WaitSecs'));
started=GetSecs;
for i=1:length(plan)
    j=plan(i);
    
    if amts(j)>0
        rewardValves=zeros(1,getNumPorts(s));
        rewardValves(j)=1;
        
        %OPEN VALVE
        [currentValveStates valveErrorDetails]=...
            setAndCheckValves(s,rewardValves,currentValveStates,valveErrorDetails,...
            started,sprintf('opening valve %d (trial %d)',j,i));
        
        valveStart=GetSecs();
        WaitSecs(amts(j));
        
        %CLOSE VALVE
        [currentValveStates valveErrorDetails]=...
            setAndCheckValves(s,zeros(1,getNumPorts(s)),currentValveStates,valveErrorDetails,...
            started,sprintf('closing valve %d (trial %d)',j,i));
        
        actualRewardDuration = GetSecs()-valveStart;
        
        % fprintf('%g %g\n',amts(j),actualRewardDuration)
        
        pctRewardOff=-(1.0-(actualRewardDuration/amts(j)));
        if abs(pctRewardOff)>requiredAccuracy
            warning('reward duration was off by %g%% for valve %d, trial %d',round(10000*pctRewardOff)/100,j,i)
        end
        
        currentValveStates=verifyValvesClosed(s);
        if any(currentValveStates)
            currentValveStates
            warning('valves were all supposed to be closed but found some open')
        end
        WaitSecs(timeBtw);
    end
    
    fprintf('%d\t',i)
    if mod(i,10)==0
        fprintf('of %d\n',length(plan))
    end
end

Priority(priorityLevel);