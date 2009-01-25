function bursts = findBursts( spiketrain, assigned, maxInterspikeDiff, maxTotalDiff, minSpikes)
%
%finds bursts in a spiketrain of minimum minSpikes length, each separated
%by <= maxInterspikeDiff ms and not longer than maxTotalDiff in total.
%assigned: assignments for each spike (neruon #)
%
%ueli rutishauser, urut@caltech.edu, jan04
%

%look for bursts
nrOfBurstPulses=0;
nrOfBursts=0;
bursts = [];
beginTimeStamp=0;
endTimeStamp=0;
indBeginTimeStamp=0;
indEndTimeStamp=0;

diffAdd=0;

for i=2:length(spiketrain)
    
    % ignore spikes which are associated to the noise cluster (invalid
    % spikes)
    
    diff = spiketrain(i)-spiketrain(i-1);
    
    if (assigned(i) == 999) || (assigned(i-1) == 999)
        diffAdd=diffAdd+diff;
        continue;
    else
        diffAdd=0;
    end
    
    diff=diff+diffAdd;          %offset in case a spike was jumped over
    
        if diff <= maxInterspikeDiff 
            if nrOfBurstPulses==0
                beginTimeStamp=spiketrain(i-1);   
                nrOfBurstPulses=1;
                indBeginTimeStamp=i-1;
            end
            nrOfBurstPulses=nrOfBurstPulses+1;
            endTimeStamp=spiketrain(i);
            indEndTimeStamp=i;
        else
            if nrOfBurstPulses > 0
                if nrOfBurstPulses >= minSpikes && (endTimeStamp-beginTimeStamp) <= maxTotalDiff
                    nrOfBursts = nrOfBursts+1;
                    bursts(nrOfBursts,1) = nrOfBurstPulses;
                    bursts(nrOfBursts,2) = endTimeStamp-beginTimeStamp;
                    bursts(nrOfBursts,3) = beginTimeStamp;
                    bursts(nrOfBursts,4) = endTimeStamp;
                    bursts(nrOfBursts,5) = indBeginTimeStamp;
                    bursts(nrOfBursts,6) = indEndTimeStamp;
                    
                end
                nrOfBurstPulses=0; 
            end
        end
end

