clear all
close all
clc
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath('C:\pmeier\Ratrix\Server\'));
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix('C:\pmeier\Ratrix\ServerData\',0);
boxID=1;
st=getStationsForBoxID(r,boxID);

%set bag pressure to just below letters that say "PRESSURE"

numSquirts=2;
squirtDuration = [0.2 0.2 0.2];
ifi = .2;
i=1;

testValves=0;
if testValves  
    valveErrorDetails=[];
    frameNum=[];  %not used but gets logged by setAndCheckValves
    expectedValveState=[0 0 0];s
    disp(expectedValveState)

    requestedValves=[1 0 0 ];
    [expectedValveState valveErrorDetails]=setAndCheckValves(st, requestedValves,expectedValveState,valveErrorDetails,frameNum);
    disp(expectedValveState)
    
    WaitSecs(ifi);
    
    requestedValves=[0 1 0 ];
    [expectedValveState valveErrorDetails]=setAndCheckValves(st, requestedValves,expectedValveState,valveErrorDetails,frameNum);
    disp(expectedValveState)
    
    WaitSecs(ifi);
    
    requestedValves=[0 0 1 ];
    [expectedValveState valveErrorDetails]=setAndCheckValves(st, requestedValves,expectedValveState,valveErrorDetails,frameNum);
    disp(expectedValveState)
    
    WaitSecs(ifi);
    
    requestedValves=[0 0 0 ];
    [expectedValveState valveErrorDetails]=setAndCheckValves(st, requestedValves,expectedValveState,valveErrorDetails,frameNum);
    disp(expectedValveState)
    
    valveErrorDetails
end


times=zeros(3,numSquirts);
for i=1:numSquirts
    

    setValves(st,[1 0 0 ]);
    times(1,i)=GetSecs();
    WaitSecs(squirtDuration(1));
    times(1,i)=times(1,i)-GetSecs();
    setValves(st,[0 0 0 ]);
    
    WaitSecs(ifi);
    
    setValves(st,[0 1 0 ]);
    times(2,i)=GetSecs();
    WaitSecs(squirtDuration(2));
    times(2,i)=times(1,i)-GetSecs();
    setValves(st,[0 0 0 ]);
    
    WaitSecs(ifi);
    
    setValves(st,[0 0 1 ]);
    times(3,i)=GetSecs();
    WaitSecs(squirtDuration(3));
    times(3,i)=times(2,i)-GetSecs();
    setValves(st,[0 0 0 ]);    
        
    WaitSecs(ifi);
end