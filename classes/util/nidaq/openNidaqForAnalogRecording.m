function [ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile)

if ~exist('recordingFile','var') || isempty(recordingFile)
    mkdir('data');
    recordingFile=fullfile('.' , 'data' , ['data.' datestr(now,30) '.daq']);
end

config='SingleEnded'; %'Differential' or 'NonReferencedSingleEnded' or 'SingleEnded'

foundMatch = false;
devices=findDevicesOfTypeWithConstructor('analoginput','nidaq');

%go through installed daq devices to find one that meets our requirements
for j=1:length(devices)
    if ~foundMatch
        ai=analoginput(devices{j}{1},devices{j}{2});
        aiInfo=daqhwinfo(ai);

        configs = propinfo(ai,'InputType');
        configs = configs.ConstraintValue;
        
        if any(strcmp(configs,config))
            if strcmp(setverify(ai,'InputType',config),config)

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
                        minRate=rates(1)/numChans;
                        maxRate=rates(2)/numChans;
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
                    %disp(sprintf('max samp rate: %g',max(sampRateProp.ConstraintValue)));
                    if setverify(ai,'SampleRate',sampRate)~=sampRate %errors when sampRate is over max?  shouldn't it just fail?
                        propinfo(ai,'SampleRate')
                        error('couldn''t set requested sample rate even though hardware appears to support it')
                    end

                    if exist('inputRanges','var') && ~isempty(inputRanges)

                        if all(size(inputRanges)==[numChans 2]) && isnumeric(inputRanges) && all(diff(inputRanges')>0)
                            passed=true;
                            for rangeNum=1:numChans
                                if passed
                                    try
                                        rangeVerify=setverify(ai.Channel(rangeNum),'InputRange',inputRanges(rangeNum,:));
                                    catch ex
                                        ple(ex)
                                        r=propinfo(ai.Channel(rangeNum),'InputRange');
                                        disp('range constraints:')
                                        r.ConstraintValue
                                        passed=false;
                                    end
                                    sensorVerify=setverify(ai.Channel(rangeNum),'SensorRange',rangeVerify);
                                    unitsVerify=setverify(ai.Channel(rangeNum),'UnitsRange',rangeVerify);
                                    passed = passed && rangeVerify(1)<=inputRanges(rangeNum,1) && rangeVerify(2)>=inputRanges(rangeNum,2) && all(sensorVerify==unitsVerify & unitsVerify==rangeVerify);
                                end
                            end
                            if passed && setverify(ai,'SamplesPerTrigger',inf)==inf && strcmp(setverify(ai,'LogToDiskMode','Index'),'Index') && strcmp(setverify(ai,'LogFileName',recordingFile), recordingFile) && strcmp(setverify(ai,'LoggingMode','Disk&Memory'),'Disk&Memory')

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
                                foundMatch = true;

                            end
                        else
                            error('inputRanges should be [] (default) or numchans x 2, each row being [min max] for expected input range, min<max')
                        end
                    end
                end
            end
        end
    end
    if ~foundMatch
        delete(ai);
    end
end

if ~foundMatch
    error('no analog in of that type with that many channels or that high a sampling rate')
end