function [ao bits]=openNidaqForAnalogOutput(sampRate,range)


existingDevices=daqfind;
for i=1:length(existingDevices)
    delete(existingDevices(i));
end
clear existingDevices

deviceTypes={'nidaq'};
constructor='analogoutput';

devices=daqhwinfo;
devices=devices.InstalledAdaptors;
foundMatch = false;

%go through installed daq devices to find one that meets our requirements
for j=1:length(devices)
    device=devices{j};
    if ~foundMatch && any(strcmp(device,deviceTypes))
        deviceInfo=daqhwinfo(device);
        for k=1:length(deviceInfo.InstalledBoardIds)
            board=deviceInfo.InstalledBoardIds{k};
            for i=1:length(deviceInfo.ObjectConstructorName)
                if ~foundMatch && strncmpi(deviceInfo.ObjectConstructorName{i},constructor,length(constructor))
                    ao=analogoutput(device,board);
                    aoInfo=daqhwinfo(ao);

                    if strcmp(aoInfo.Polarity,'Bipolar') && strcmp(aoInfo.SampleType,'SimultaneousSample')

                        rates = propinfo(ao,'SampleRate');
                        rates = rates.ConstraintValue;

                        minRate=rates(1);
                        maxRate=rates(2);

                        if sampRate<=maxRate && sampRate>=minRate

                            hwChans=aoInfo.ChannelIDs;
                            chans=addchannel(ao,hwChans(1));
                            if length(chans)~=1
                                error('didn''t get requested num chans even though hardware appears to support it')
                            end

                            if setverify(ao,'SampleRate',sampRate)~=sampRate
                                propinfo(ao,'SampleRate')
                                error('couldn''t set requested sample rate even though hardware appears to support it')
                            end

                            if all(size(range)==[1 2]) && isnumeric(range) && all(diff(range')>0)

                                if ~all(setverify(ao.Channel(1),'OutputRange',range)==range)
                                    aoInfo.OutputRanges
                                    error('couldn''t set requested range')
                                end
                            else
                                error('ranges should be 1 x 2, [min max] for expected output range, min<max')
                            end

                            bits=aoInfo.Bits;
                            foundMatch = true;

                            ao
                            chans
                            daqhwinfo(ao)
                            set(ao)
                            get(ao)
                            get(ao,'Channel')
                            set(chans(1))
                            get(chans(1))


                        end
                    end
                end
            end
        end
    end
end

if ~foundMatch
    error('no analog out of that type with that high a sampling rate')
end