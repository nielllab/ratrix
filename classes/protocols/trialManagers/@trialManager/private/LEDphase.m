function [phaseRecords analogOutput outputsamplesOK] ...
    = LEDphase(tm,phaseInd,analogOutput,phaseRecords,spec,interTrialLuminance,stim,frameIndexed,indexedFrames,loop,trigger,timeIndexed,timedFrames,station)

fprintf('doing phase %d\n',phaseInd)

outputRange=[-5 0]; %hardcoded for our LED amp

if ~isempty(analogOutput)
    stop(analogOutput);
    
    evts=showdaqevents(analogOutput);
    if ~isempty(evts)
        evts
    end
    
    if phaseInd>1
        phaseRecords(phaseInd-1).LEDstopped=GetSecs; %need to preallocate
        phaseRecords(phaseInd-1).totalSampsOutput=get(analogOutput,'SamplesOutput'); %need to preallocate
    else
        error('shouldn''t happen')
    end
    
    %need to remove leftover data from previous putdata calls (no other way to do it that i see)
    if get(analogOutput,'SamplesAvailable')>0
        delete(analogOutput.Channel(1));
        
        %this block stolen from openNidaqForAnalogOutput -- need to refactor
        aoInfo=daqhwinfo(analogOutput);
        hwChans=aoInfo.ChannelIDs;
        chans=addchannel(analogOutput,hwChans(1));
        if length(chans)~=1
            error('didn''t get requested num chans even though hardware appears to support it')
        end
        if setverify(analogOutput,'SampleRate',getHz(spec))~=getHz(spec)
            rates = propinfo(analogOutput,'SampleRate')
            rates.ConstraintValue
            getHz(spec)
            error('couldn''t set requested sample rate')
        end
        verifyRange=setverify(analogOutput.Channel(1),'OutputRange',outputRange);
        if verifyRange(1)<=outputRange(1)&& verifyRange(2)>=outputRange(2)
            uVerifyRange=setverify(analogOutput.Channel(1),'UnitsRange',verifyRange);
            if any(uVerifyRange~=verifyRange)
                verifyRange
                uVerifyRange
                error('could not set UnitsRange to match OutputRange')
            end
        else
            aoInfo.OutputRanges
            outputRange
            error('couldn''t get requested output range')
        end
        %end refactor block
    end
    
else
    preAnalog=GetSecs;
    [analogOutput bits]=openNidaqForAnalogOutput(getHz(spec),outputRange); %should ultimately send bits back through stimOGL to doTrial so can be stored as trialRecords(trialInd).resolution.pixelSize
    fprintf('took %g secs to open analog out (mostly in call to daqhwinfo)\n',GetSecs-preAnalog)
end

if tm.dropFrames
    error('can''t have dropFrames set for LED')
end

if isscalar(interTrialLuminance) && interTrialLuminance>=0 && interTrialLuminance<=1
    scaledInterTrialLuminance=interTrialLuminance*diff(outputRange)+outputRange(1);
else
    error('bad interTrialLuminance')
end
verify=setverify(analogOutput,'OutOfDataMode','DefaultValue');
if ~strcmp(verify,'DefaultValue')
    error('couldn''t set OutOfDataMode to DefaultValue')
end

verify=setverify(analogOutput.Channel(1),'DefaultChannelValue',scaledInterTrialLuminance);
if verify~=scaledInterTrialLuminance
    error('couldn''t set DefaultChannelValue')
end

data=squeeze(stim);

%could move this logic to updateFrameIndexUsingTextureCache, it is related to that info
if frameIndexed
    %might also be loop, will handle below with 'RepeatOutput'
    data=data(indexedFrames);
elseif loop
    %pass
elseif trigger
    error('trigger not supported by LED') %would be easy to add with putsample, but a single 1x1 discriminandum frame can only be luminance discrimination - not very interesting
elseif timeIndexed
    oldData=data;
    data=[];
    for fNum=1:length(timedFrames)
        data(end+1:end+timedFrames(fNum))=oldData(fNum);
    end
    if timedFrames(end)==0
        data(end+1)=timedFrames(end);
        verify=setverify(analogOutput,'OutOfDataMode','Hold');
        if ~strcmp(verify,'Hold')
            error('couldn''t set OutOfDataMode to Hold')
        end
    end
end

if isvector(data) && all(data>=0) && all(data<=1)
    data=data*diff(outputRange)+outputRange(1);
else
    error('bad stim size for LED')
end

if get(analogOutput,'MaxSamplesQueued')>=length(data) %if BufferingMode set to Auto, should only be limited by system RAM, on rig computer >930 mins @ 1200 Hz
    preAnalog=GetSecs;
    if length(data)>1
        putdata(analogOutput,data); %crashes when length is 1! have to use putsample, then 'SamplesOutput' doesn't work... :(
        outputsamplesOK=true;
    else
        putsample(analogOutput,data);
        outputsamplesOK=false;
    end
    fprintf('took %g secs to put analog data\n',GetSecs-preAnalog)
else
    get(analogOutput,'MaxSamplesQueued')/length(data)
    error('need to manually buffer this much data for LED')
end

if loop
    if timeIndexed || trigger
        error('can''t have loop when timeIndexed or trigger')
    end
    rpts=inf;
else
    rpts=0; %sets *additional* repeats, 1 is assumed
end
verify=setverify(analogOutput,'RepeatOutput',rpts);
if rpts~=verify
    rpts
    verify
    error('couldn''t set to repeats')
end

if outputsamplesOK
    start(analogOutput);
end

phaseRecords(phaseNum).LEDstarted=GetSecs; %need to preallocate

setStatePins(station,'frame',true);
setStatePins(station,'frame',false);