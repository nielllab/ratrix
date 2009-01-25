function [avSpikesInBurst,avTimestampsInBurst] = calcAverageSpikeInBurst(burstsOrig, spikes, assigned, timestamps)

%average of all 3 first spikes of all bursts
avSpikesInBurst=[];
avTimestampsInBurst=[];

maxSpikesInBurst=10;
counters=zeros(1,maxSpikesInBurst); %calculate for max 10 spikes in a burst
for j=1:size(burstsOrig,1)
    [j size(burstsOrig,1)]
    inds = burstsOrig(j,5):burstsOrig(j,6);

    %exclude the ones which contain noise spikes
    canUse=true;
    for z=1:length(inds)
        if assigned(inds(z))==999
            canUse=false;
            break;
        end
    end
    
    %if this burst only contains valid spikes (not part of noise cluster)
    if canUse
        for z=1:length(inds)
            if z>maxSpikesInBurst
                break;
            end
            
            spikesInBurst=[];
            timestampsInBurst=[];
            
            if counters(z)>0
                spikesInBurst = avSpikesInBurst{z};
                timestampsInBurst = avTimestampsInBurst{z};
            end
            counters(z) = counters(z) + 1;
            
            spikesInBurst(counters(z),:) = spikes(inds(z),:);
            
            timestampsInBurst(counters(z),:) = timestamps(inds(z));
            
            avSpikesInBurst{z} = spikesInBurst;
            avTimestampsInBurst{z} = timestampsInBurst;
            
        end
    end
end
