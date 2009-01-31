%
%calculate bursts currectly classified
%
%
%
function [nrSpikesInBursts, nrSpikesCorrect] = quantifySortedBursts( spikesConsidered, spikes, assigned)

nrSpikesInBursts=0;
nrSpikesCorrect=0;

for i=1:length(spikesConsidered)
    inds = spikesConsidered{i};

    nrSpikesInBursts = nrSpikesInBursts + length(inds);
    
    cellsRepresented = unique(assigned(inds));
    cellsCount=zeros(1,length(cellsRepresented));
    
    for j=1:length(cellsRepresented)
        cellsCount(j) = length( find(assigned(inds)==cellsRepresented(j)));
    end

    
    nrSpikesCorrect = nrSpikesCorrect + max(cellsCount);  %assume the max number assigned is correct (so minority is wrongly associated)
end