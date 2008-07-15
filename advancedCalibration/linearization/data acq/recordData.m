clear all
close all
clc
format long g

numChans=2;
sampRate=10000;
[ai chans recordFile]=openNidaqForAnalogRecording(numChans,sampRate,[-1 1;-1 6],[]);

ai
set(ai)
get(ai)
get(ai,'Channel')
daqhwinfo(ai)
chans
set(chans(1))
get(chans(1))


start(ai);

doPlot=1;
runSecs=200;
waitBtw=.5;
for p=1:(runSecs/waitBtw)
    WaitSecs(waitBtw);
    if doPlot
        data=peekdata(ai,get(ai,'SamplesAvailable'));
        plot(data(floor(linspace(1,size(data,1),1000)),:))
        drawnow
    end
    disp(sprintf('%g secs out of %g',p*waitBtw,runSecs))
end

stop(ai);

delete(ai)
clear ai


if doPlot
    [data,time,abstime,events,daqinfo] = daqread(recordFile);
    figure
    plot(data)
    
    abstime
    events
    events.Type
    events.Data

    daqinfo
    daqinfo.ObjInfo
    daqinfo.HwInfo
    
    chaninfo = daqinfo.ObjInfo.Channel
    events = daqinfo.ObjInfo.EventLog
    event_type = {events.Type}
    event_data = {events.Data}
end