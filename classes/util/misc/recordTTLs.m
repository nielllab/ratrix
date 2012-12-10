function recordTTLs(eventName, eventData)
%ScanImage 3.8 user function
%adapted from hantman_stimPulse

persistent hDin hSys ttlChans

global state

switch eventName
    
    case 'acquisitionStart'
        
        if isempty(hSys)
            hSys = dabs.ni.daqmx.System();
        end
        
        if isempty(hDin) || ~isvalid(hDin)
            taskName = 'TTLrec';
            if hSys.taskMap.isKey(taskName) %This shouldn't happen in usual operation
                delete(hSys.taskMap(taskName));
            end
            hDin = dabs.ni.daqmx.Task(taskName);
            
            % Dev1 PCI-6110 (s series) has 8 DIO (software timed)
            % Dev2 PCIe-6321 (x series) has 24 DIO (8 hardware-timed up to 1 MHz -- port0 hardware timed, ports1-2 PFI-able)
            ttlChans = hDin.createDIChan('Dev2','port0/line0:1','ttlFramePhase','DAQmx_Val_ChanForAllLines');
            
            % how make sure we get hardware timed?
            
            % how read out?  maybe doneEventCallbacks, maybe readDigitalData
            
            % maybe set sampQuantSampPerChan, sampTimingType, sampQuantSampMode, sampClkRate, sampClkSrc
            
            % maybe set startTrigType -- maybe hDin.cfgDigEdgeStartTrig(state.init.triggerInputTerminal);
            
        end
        
        if ~hDin.isTaskDone()
            fprintf(2,['WARNING: ' taskName ' Task was found to be active already.\n']);
            hDin.stop();
        end
        
        hDin.start();
        
    case {'acquisitionDone' 'abortAcquisitionEnd'}
        
        %Stop Task, to allow it to be re-used on next acquisition start
        if ~isempty(hDin) && isvalid(hDin)
            hDin.abort();
        end
        
        [outputData, sampsPerChanRead] = readDigitalData(hDin, inf, 'logical');
        % columns = channels
        % rows = samples * lines
        
        %   If outputFormat is 'logical'/'double', then DAQmxReadDigitalLines function in DAQmx API is used
        
end