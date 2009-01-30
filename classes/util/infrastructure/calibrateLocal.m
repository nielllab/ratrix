function calibrateLocal( numReps, amts, timeBtw, requiredAccuracy )
%ex: calibrateLocal( 10, [.03 .03 .03], .25, .1 )

clc

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

rewardMethod = 'localTimed';

stationNum=1;

id=int8(stationNum);
width=1024;
height=768;
path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
screenNum=int8(0);
macAddr='000000000000';
macLoc=int8([2 1 1]);

s=station(...
    id,...          %id
    width,...       %width
    height,...      %height
    path,...        %path
    screenNum,...   %screenNum
    true,...        %soundOn
    rewardMethod,...%rewardMethod
    macAddr,...     %MACaddress
    macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
    '0378',...      %parallelPortAddress
    'parallelPort',...%responseMethod
    int8([6,7,8]),... %valveOpenCodes
    int8([4,2,3]),... %portCodes
    int8(1));       %framePulseCodes

valveErrorDetails=[];
currentValveStates=zeros(1,length(amts));
started=GetSecs;
WaitSecs(.001); %to load function

for i=1:numReps
    for j=1:length(amts)
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
    end
    fprintf('%d\t',i)
    if mod(i,10)==0
        fprintf('of %d\n',numReps)
    end
end