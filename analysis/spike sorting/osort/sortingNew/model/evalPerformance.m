%
%calculates performance of sorting algorithm by comparing to ground truth
%
%was previously part of plotGeneratedSpiketrain.m
%
%spikeTimestamps: ground truth (from simulation)
%spiketimes: timestamps of detected spikes (result of sorting)
%reorder: mapping of cluster numbers
%nrAssigned: mapping of cluster numbers to how many were found in this
%cluster
%assigned: mapping of each spike to its assigned cluster number
%
%
%urut/nov05
function [perf, indsNoiseWaveforms] = evalPerformance(nrNeurons, spikeTimestamps, spiketimes, reorder, nrAssigned, assigned)

%tollerance=15;  %allow 15 datasamples jitter due to re-sampling,re-alignment etc
tollerance=30;  %make relatively large,because some simulations were made with timestamps that dont take into account new alignment scheme

[trueDetections, falseDetections] = evalSimulatedPerfDetection( spiketimes, spikeTimestamps, tollerance );
detected=trueDetections;

indsNoiseWaveforms=[];

perf=[]; %TP FP Misses
for i=1:nrNeurons

        
    
    indsOfNeuron = find( nrAssigned(end-reorder(2,i)+1,1)==assigned);
    
    timestampsOfClass = spikeTimestamps( indsOfNeuron );
    origTimestampsOfClass = spiketimes{i};
    %origWaveformsOfClass = waveformsOrig{i};
    
    %origTimestampsOfClass = origTimestampsOfClass(100:end);  %discard first X (=initialization)
    
    %plot( 20:240,origWaveformsOfClass' ,colors{i});
    
    [detected(i) length(find( nrAssigned(end-reorder(2,i)+1,1)==assigned))];
    
    
    %find TP and misses
    TP=0;
    indsTP=[];
    FN=0;
    for j=1:length(origTimestampsOfClass) 
        origValue = origTimestampsOfClass(j);
        ind = find( origValue-tollerance < timestampsOfClass & timestampsOfClass < origValue+tollerance );
        if length (  ind > 0 )
            TP=TP+1;
            indsTP=[indsTP ind(1)];
        else
            FN=FN+1;
        end
    end
    
    %find FP
    indsFP = setdiff(1:length(timestampsOfClass),indsTP);
    
    FPotherClusters=0;

    %split up: which of those belong to an other cluster or are noise?
    for j=1:length(indsFP)
       origValue=timestampsOfClass(indsFP(j));  %point of time this misssorted spike occured
       
       foundInOtherCluster = false;
       for k=1:nrNeurons
           IndAlreadyUsedNeuron=[];
           
           %don't test against own neuron
           if k==i
               continue;
           end

           origTimestampsOfOtherClass = spiketimes{k};
           
           ind = find( origValue-tollerance < origTimestampsOfOtherClass & origTimestampsOfOtherClass < origValue+tollerance );
           if length (  ind > 0 )
              %assigned to the wrong cluster
              FPotherClusters=FPotherClusters+1; 
              IndAlreadyUsedNeuron = [ IndAlreadyUsedNeuron ind ];
              foundInOtherCluster = true;
              break;
           end
       end
       
       if foundInOtherCluster==false
        %caused by noise  
        indsOfNeuron(indsFP(j));
        
        indsNoiseWaveforms(length(indsNoiseWaveforms)+1)  = indsOfNeuron ( indsFP(j) );
       end

              
    end
    
    FP=length(indsFP);
    FPnoise = FP - FPotherClusters;

        
    missAlignedStat(i)=0;
    
    nrAssignedToCluster = length(find( nrAssigned(end-reorder(2,i)+1,1)==assigned));
    
    perf(i,:)=[size(origTimestampsOfClass,2) detected(i) missAlignedStat(i)  detected(i)-missAlignedStat(i) TP FP FPnoise FPotherClusters detected(i)-TP nrAssignedToCluster];
end

%perf(:,10) = perf(:,5)./perf(:,4);
%mean(perf(:,10))