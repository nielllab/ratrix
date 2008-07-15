function recordLight
clc

file='C:\Documents and Settings\rlab\Desktop\ratrixData\lightSamps.mat';
waitTime=2;
doPlot=true;

while true
    daqreset;
    ai=analoginput('nidaq','Dev1');
    addchannel(ai,0);
    ai.Channel(1).InputRange=[-10 10];
    set(ai,'InputType','SingleEnded');
    
    x=getsample(ai);
    try
        r=load(file);
        r=r.r;
    catch
        r=[];
    end
    r(end+1,:)=[now,x];
    
    if doPlot
    close all
    plot(r(:,1),r(:,2))
    datetick
    end
    
    disp(sprintf('light level %s: %g',datestr(r(end,1)),r(end,2)));
    save(file,'r');
    delete(ai)
    clear r
    clear ai
    pause(waitTime)
end