function [ao bits]=openNidaqForAnalogOutput(sampRate,range)
devices=findDevicesOfTypeWithConstructor('analogoutput','nidaq');
foundMatch = false;

%go through installed daq devices to find one that meets our requirements
for j=1:size(devices,1)
    if ~foundMatch
        ao=analogoutput(devices{j}{1},devices{j}{2});
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

                    verifyRange=setverify(ao.Channel(1),'OutputRange',range);
                    if verifyRange(1)<=range(1)&& verifyRange(2)>=range(2)
                        
                        uVerifyRange=setverify(ao.Channel(1),'UnitsRange',verifyRange);
                        if any(uVerifyRange~=verifyRange)
                            verifyRange
                            uVerifyRange
                            error('could not set UnitsRange to match OutputRange')
                        end
                        
                        bits=aoInfo.Bits;
                        foundMatch = true;

%                         ao
%                         chans
%                         daqhwinfo(ao)
%                         set(ao)
%                         get(ao)
%                         get(ao,'Channel')
%                         set(chans(1))
%                         get(chans(1))

                    else
                        devices{j}{:}
                        'has ranges'
                        aoInfo.OutputRanges
                    end
                else
                    error('ranges should be 1 x 2, [min max] for expected output range, min<max')
                end
            end
        end
    end
    if ~foundMatch
        delete(ao);
    end
end

if ~foundMatch
    error('no analog out of that type with that high a sampling rate')
end