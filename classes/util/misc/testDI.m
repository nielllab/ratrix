function testDI
clear all
close all
clc

dbstop if error

hSys = dabs.ni.daqmx.System();

taskName = 'TTLrec';
hDin = dabs.ni.daqmx.Task(taskName);

% Dev1 PCI-6110 (s series, PMT inputs, mirror + shutter outputs) has 8 DIO (software timed)
% Dev2 PCIe-6321 (x series, pockels output) has 24 DIO (8 hardware-timed up to 1 MHz -- port0 hardware timed, ports1-2 PFI-able)
ttlChans = hDin.createDIChan('Dev2','port0/line0:1','ttlFramePhase','DAQmx_Val_ChanForAllLines');

hz = 10000; %frame pulses definitely > 100us
mins = .5; %?
num = round(hz * 60 * mins);

% how make sure we get hardware timed?  and same clock as PMT scans?
% source = state.init.hAI.sampClkSrc;
hDin.cfgSampClkTiming(hz, 'DAQmx_Val_ContSamps', num); % , source);

% hDin.cfgDigEdgeStartTrig(state.init.triggerInputTerminal); %PFI0
% hDin.cfgDigEdgeStartTrig('10MHzRefClock')
hDin.disableStartTrig %should "Configures the task to start acquiring or generating samples immediately upon starting the task."

t = GetSecs;
hDin.start();

%keyboard
while ~isTaskDone(hDin)
    if rand>.99
        fprintf('%g secs remaining\n',mins*60 - GetSecs + t);
    end
end

try
    [outputData, sampsPerChanRead] = readDigitalData(hDin, inf, 'logical'); %logical will be 1 byte/sample/line -- uint8 will pack them better
    % columns = channels
    % rows = samples * lines
    
    find(outputData)
    
    if sampsPerChanRead>size(outputData,1)
        sampsPerChanRead
    end
    
    %         if size(outputData,2)>1
    size(outputData)
    %         end
    
    if ~isa(outputData,'logical')
        class(outputData)
    end
    
    keyboard
catch e
    % after first iteration of LOOP, or on abortAcquisitionEnd, hDin is no good, can't read
    
    %  DAQmx Error (-200983) encountered in DAQmxGetReadAvailSampPerChan:
    %  You only can get the specified property while the task is reserved, committed or while the task is running.
    %
    % Reserve, commit or start the task prior to getting the property.
    
    getReport(e)
    % keyboard
end
end