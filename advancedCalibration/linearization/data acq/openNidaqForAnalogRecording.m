function [ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile)

%closes any hanging open devices
existingDevices=daqfind;
for i=1:length(existingDevices)
    delete(existingDevices(i));
end
clear existingDevices

if isempty(recordingFile)
    mkdir('data');
    recordingFile=fullfile('.' , 'data' , ['data.' datestr(now,30) '.daq']);
end

deviceTypes={'nidaq'};
constructor='analoginput';
config='SingleEnded'; %'Differential' or 'NonReferencedSingleEnded' or 'SingleEnded'

devices=daqhwinfo;
devices=devices.InstalledAdaptors;
foundAnalogInDevice = false;

%go through installed daq devices to find one that meets our requirements
for j=1:length(devices)
    device=devices{j};
    if ~foundAnalogInDevice && any(strcmp(device,deviceTypes))
        deviceInfo=daqhwinfo(device);
        for k=1:length(deviceInfo.InstalledBoardIds)
            board=deviceInfo.InstalledBoardIds{k};
            for i=1:length(deviceInfo.ObjectConstructorName)
                if ~foundAnalogInDevice && strncmpi(deviceInfo.ObjectConstructorName{i},constructor,length(constructor))
                    ai=analoginput(device,board);
                    aiInfo=daqhwinfo(ai);

                    configs = propinfo(ai,'InputType');
                    configs = configs.ConstraintValue;
                    if any(strcmp(configs,config))
                        if ~strcmp(setverify(ai,'InputType',config),config)
                            error('couln''t set requested config')
                        end

                        switch config
                            case 'Differential'
                                hwChans=aiInfo.DifferentialIDs;
                            case {'NonReferencedSingleEnded','SingleEnded'}
                                hwChans=aiInfo.SingleEndedIDs;
                            otherwise
                                error('bad requested config')
                        end

                        rates = propinfo(ai,'SampleRate');
                        rates = rates.ConstraintValue;
                        switch aiInfo.SampleType
                            case 'Scanning'
                                minRate=floor(rates(1)/numChans);
                                maxRate=floor(rates(2)/numChans);
                            case 'Simultaneous'
                                minRate=rates(1);
                                maxRate=rates(2);
                            otherwise
                                error('unknown sample type')
                        end

                        if length(hwChans)>=numChans && sampRate<=maxRate && sampRate>=minRate
                            chans=addchannel(ai,hwChans(1:numChans));
                            if length(chans)~=numChans
                                error('didn''t get requested num chans even though hardware appears to support it')
                            end
                            sampRateProp=propinfo(ai,'SampleRate');
                            disp(sprintf('max samp rate: %g',max(sampRateProp.ConstraintValue)));
                            if setverify(ai,'SampleRate',sampRate)~=sampRate %errors when sampRate is over max?  shouldn't it just fail?
                                propinfo(ai,'SampleRate')
                                error('couldn''t set requested sample rate even though hardware appears to support it')
                            end

                            if ~isempty(inputRanges)

                                if all(size(inputRanges)==[numChans 2]) && isnumeric(inputRanges) && all(diff(inputRanges')>0)
                                    for rangeNum=1:numChans
                                        rangeVerify=setverify(ai.Channel(rangeNum),'InputRange',inputRanges(rangeNum,:));
                                        disp(sprintf('chan %d range: %s',rangeNum,num2str(rangeVerify)))
                                    end
                                else
                                    error('inputRanges should be [] (default) or numchans x 2, each row being [min max] for expected input range, min<max')
                                end
                            end

                            foundAnalogInDevice = true;
                        end

                        if setverify(ai,'SamplesPerTrigger',inf)~=inf
                            error('couldn''t set continuous logging')
                        end
                        if ~strcmp(setverify(ai,'LogToDiskMode','Index'),'Index')
                            error('couldn''t set LogToDiskMode to Index')
                        end
                        if ~strcmp(setverify(ai,'LogFileName',recordingFile),recordingFile)
                            error('couldn''t set LogFileName')
                        end
                        if ~strcmp(setverify(ai,'LoggingMode','Disk&Memory'),'Disk&Memory')
                            error('couldn''t set LoggingMode to disk streaming + memory')
                        end

                        %                         set(ai)
                        %                         get(ai)
                        %                         get(ai,'Channel')
                        %                         set(chans(1))
                        %                         get(chans(1))

                        %                         '---'
                        %                         chans
                        %                         '---'
                        %                         daqhwinfo(ai)
                        %                         '---'
                        %                         ai
                        %                         '---'
                        %                         set(ai)
                        %                         '---'



                    end
                end
            end
        end
    end
end


if ~foundAnalogInDevice
    error('no analog in of that type with that many channels or that high a sampling rate')
end