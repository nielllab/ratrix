function [ao bits]=openNidaqForAnalogOutput(sampRate,range)
devices=findDevicesOfTypeWithConstructor('analogoutput','nidaq');
foundMatch=false;
numChans=size(range,1);
%go through installed daq devices to find one that meets our requirements
for j=1:length(devices)
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
                chans=addchannel(ao,hwChans(1:numChans));
                if length(chans)~=numChans
                    error('didn''t get requested num chans even though hardware appears to support it')
                end
                
                if setverify(ao,'SampleRate',sampRate)~=sampRate
                    propinfo(ao,'SampleRate')
                    error('couldn''t set requested sample rate even though hardware appears to support it')
                end
                
                if all(size(range)==[numChans 2]) && isnumeric(range) && all(diff(range,1,2)>0)
                    
                    bits=[];
                    foundMatch=[];
                    for cNum=1:numChans
                        if all(foundMatch)
                            verifyRange=setverify(ao.Channel(cNum),'OutputRange',range(cNum,:));
                            if verifyRange(1)<=range(cNum,1)&& verifyRange(2)>=range(cNum,2)
                                
                                uVerifyRange=setverify(ao.Channel(cNum),'UnitsRange',verifyRange);
                                if any(uVerifyRange~=verifyRange)
                                    verifyRange
                                    uVerifyRange
                                    error('could not set UnitsRange to match OutputRange')
                                end
                                
                                bits(end+1)=aoInfo.Bits;
                                foundMatch(end+1) = true;
                                
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
                                foundMatch=false;
                            end
                        else
                            
                            break
                        end
                    end
                else
                    error('ranges should be numChans x 2, [min max] for expected output range, min<max')
                end
            end
        end
    end
    if ~foundMatch
        delete(ao);
    end
end

if ~foundMatch
    error('no analog out with those ranges and that sampling rate on that many channels')
end