function testLED
close all
dbstop if error

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
    load('C:\eflister\led test\run2.mat')
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

if true
    trigs = trigs(trigs>find(diff(time>110)));
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

figure
if false
    cs = getUniformSpectrum(linspace(0,1,length(trigs)));
    for i=1:length(trigs)
        plot(time(1:dur)*1000,data(trigs(i)+(1:dur),3),'Color',cs(i,:))
        hold on
    end
else
    cellfun(@plotSome,num2cell(0:3),{'r','g','b','c'})
end

    function plotSome(i,cc)
        these = trigs(mod(1:length(trigs),4)==i)';
        plot(time(1:dur)*1000,reshape(data(repmat(these,dur,1)+repmat((1:dur)',1,size(these,2)),3),[dur size(these,2)]),cc)
        hold on
    end

xlabel('ms')

keyboard
end