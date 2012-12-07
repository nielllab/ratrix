function testLED
close all

if false
    % Dev1 is PCI-6110 has 4 12-bit channels at 5MHz each
    
    d = daq.getDevices
    d = d(1)
    s = daq.createSession ('ni')
    s.addAnalogInputChannel('Dev1', 0:2, 'Voltage')
    
    s.RateLimit
    s.Rate = 10^5;
    s.DurationInSeconds = 120;
    
    c = s.Channels
    
    arrayfun(@f,c)
    
    [data,time] = s.startForeground;
    
    beep,beep,beep
    save(['LEDrec-' datestr(now,30)],'data','time')
    beep,beep,beep
    
    plot(time*1000,data+repmat([0 3 3.5],size(data,1),1))
    xlabel('ms');
else
    load('run2.mat')
end

    function f(x)
        % PDA100A max output is 10V
        x.Range=[-5 10]
    end

trigs = find(diff(data(:,1)>1)==1);
offsetMS = 5;

if false
    trigs = trigs(mod(1:length(trigs),4)==0);
end

trigs = trigs(2:end-1);
trigs = trigs-round(offsetMS/median(diff(time))/1000);
dur = min(diff(trigs));

    function plotTrace(ind,cc)
        plot(time(1:dur)*1000,reshape(data(repmat(trigs',dur,1)+repmat((0:dur-1)',1,length(trigs)),ind),[dur length(trigs)]),cc)
    end

figure
plotTrace(1,'b')
hold on
plotTrace(2,'g')
plotTrace(3,'r')

xlabel('ms')
title([num2str(length(trigs)) ' flashes'])

keyboard
end