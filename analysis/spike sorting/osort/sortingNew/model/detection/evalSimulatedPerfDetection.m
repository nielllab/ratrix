%
%determines whether detected spikes are real (true positives) or not.
%
%spiketimes is ground truth (from simulation)
%spikeTimestamps is what the algorithm detected
%tollerance is the number of samples the timestamp is allowed to be off and still counted as valid
%
%returns:
%trueDetections : true detections for each neuron in the simulation
%falseDetections: total number false positives
%misses:how many were not found
%hits: which waveforms were TPs and which class do they belong to. nx2 -> ind, class
%
%
%urut/april07 - transfered out of evalPerformance.m
function [trueDetections, falseDetections, misses, hits] = evalSimulatedPerfDetection( spiketimes, spikeTimestamps, tollerance )
hits=[];

timestampsDetected = spikeTimestamps;

nrNeurons=length(spiketimes);

trueDetections=zeros(1,nrNeurons);
falseDetections=0;

indUsed=[];
classIndOfUsed=[];
spikeIndOfUsed=[];

misses=0;
doubleDetections=0;

for i=1:nrNeurons
    origTimestampsOfClass = spiketimes{i};

    for j=1:length(origTimestampsOfClass) 
        origValue = origTimestampsOfClass(j);
        ind = find( origValue-tollerance < timestampsDetected & timestampsDetected < origValue+tollerance );

        if length(ind)>1
            %determine the closest
            diff = abs( timestampsDetected(ind) - origValue );
            indsMin = find( min(diff) == diff );
            indsMin=indsMin(1); %in case there are multiple
            ind = ind( indsMin );            
        end
        
        if length (  ind > 0 )
            
            %determine whether this spike has been matched before (double detection)
            if length(find(indUsed==ind))==0
                trueDetections(i)=trueDetections(i)+1;
                indUsed=[indUsed ind];
                classIndOfUsed=[classIndOfUsed i];
                spikeIndOfUsed=[spikeIndOfUsed j];
            else
                doubleDetections=doubleDetections+1;
            end
        else
            misses=misses+1;
        end 
    end    
end
hits=[indUsed' classIndOfUsed' spikeIndOfUsed'];  

falseDetections = length(spikeTimestamps) - sum(trueDetections);