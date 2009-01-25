%
%find and evaluate prospective bursts in a (unsorted) spiketrain.
%
%returns: spikesConsidered == cell array, where each element is a burst.
%For each bursts, all indices of partizipating spikes are returned.
%
function [bursts2, bursts, spikesConsidered] = findBurstsEval(timestamps, spikes, assigned, useCells)

timestampsMS=timestamps/1000;

%find series of spikes that qualify as bursts
bursts = findBursts( timestampsMS, assigned, 10, 500, 3); %max 10ms interspike distance, max 500ms for whole burst, min 3 spikes in burst (Quirk&Wilson96 definition)


bursts2 = quantifyBursts( bursts, spikes, assigned, useCells, 1); %

spikesConsidered=[];
for i=1:size(bursts2,1)
    inds=[bursts2(i,5):bursts2(i,6)];

    spikesIndsToAdd=[];
    c=0;
    for j=1:length(inds)
        %noise is black,otherwise choose different color for every cell
        color='';
        if assigned(inds(j))==999 || ismember( assigned(inds(j)), useCells)==0
            continue;
        else
            c=c+1;
            spikesIndsToAdd(c)=inds(j);
        end
    end
    spikesConsidered{i} = spikesIndsToAdd;
end
