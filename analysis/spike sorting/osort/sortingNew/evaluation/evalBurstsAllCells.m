% find performance of sorting regarding bursts
% find % of bursty neurons
% find % of all spikes associated to bursts
%
%
%this procedure is used to calculate the numbers for the "spike form
%variability" section of the paper.
%
%sept04/urut
%
%


path='F:\Data\new\';

sessions={'TS_032504','TS_032604','TS_032704','TS_032804','RA_051404','RA_051504','RA_051604'};

totalCellsAnalyzed=0;
burstsStatistics=[];
c=0;

totalSpikesInBursts = 0;
totalSpikesAllNeurons = 0;
totalNrNeurons=0;
totalNeuronsBursty=0;

relativeAmplitudeInBurst = [];
totalSpikesInBurst = [];

for z=1:length(sessions)
    basedir=[path sessions{z} '\'];

    for k=1:2
        prefix='a'; 
        if (k==2) prefix='b';  end
	        for channel=1:12
            fname=[basedir prefix num2str(channel) '_sorted_new' '.mat'];
            if exist(fname)~=2
                continue;
            end
        
            load(fname);
            fname

            for a=1:2
                    timestamps=[];                    
                    spikes=[];
                    assigned=[];
                    useCells=[];
                    
                    if a==1
                        timestamps=newTimestampsPositive;
                        spikes=newSpikesPositive;
                        assigned=assignedPositive;
                        useCells=usePositive;
                    else
                        timestamps=newTimestampsNegative;
                        spikes=newSpikesNegative;
                        assigned=assignedNegative;
                        useCells=useNegative;
                    end
                    
                    %analysis of # of bursts correctly associated
                    %
                    %only if there are multiple "usable" cells
                    if length(useCells)>1
                        totalCellsAnalyzed=totalCellsAnalyzed+length(useCells);
                    
                        [bursts, burstsOrig, spikesConsidered] = findBurstsEval(timestamps, spikes, assigned, useCells);
                        [nrSpikesInBursts, nrSpikesCorrect] = quantifySortedBursts( spikesConsidered, spikes, assigned);
		
                        correct=-1; %-1 == no bursts
                        if nrSpikesInBursts > 0
                            correct = nrSpikesCorrect*100/nrSpikesInBursts;
                        end
		
                        if correct > -1
                            c=c+1;
                            burstsStatistics(c) = correct ; % percentage correctly associated (worst case analysis)
                        end
                    end
                    
                    %find # of spikes which are part of a burst (for statistics)
                    for b=1:length(useCells)
                        indsOfCell = find(assigned==useCells(b));
		
                        totalSpikesAllNeurons = totalSpikesAllNeurons+length(indsOfCell);
                        
                        %max 10ms interspike distance, max 500ms for whole burst, min 3 spikes in burst (Quirk&Wilson96 definition)
                        bursts = findBursts( timestamps(indsOfCell)/1000, assigned(indsOfCell), 10, 500, 3); 
		
                        totalNrNeurons=totalNrNeurons+1;
                        
                        if size(bursts,1)>0
                            sum(bursts(:,1))
                            totalSpikesInBursts = totalSpikesInBursts + sum(bursts(:,1));
                            totalNeuronsBursty=totalNeuronsBursty+1;
                            
                            
                            %find overall bursts statistics
                            [avSpikesInBurst,avTimestampsInBurst] = calcAverageSpikeInBurst(bursts, spikes, assigned, timestamps);

                            maxNumberSpikes=length(avSpikesInBurst);
                            if maxNumberSpikes==0
                                continue;
                            end
                            
                            m100 = mean(max(avSpikesInBurst{1}'));

                            spikesAmpPerc=[]; %mean std for every spike
                            spikesAmpPerc(1,1)=100;
                            spikesAmpPerc(1,2)=0;

                            nrSpikes=[];
                            nrSpikes(1) = size(avSpikesInBurst{1},1);

                            for i=2:maxNumberSpikes
                                spikesInBurst = avSpikesInBurst{i};

                                nrSpikes(i) = size(spikesInBurst,1);
    
                                mm = max(spikesInBurst');

                                %in percent
                                pp = (mm*100)/m100;
    
                                spikesAmpPerc(i,1:2) = [mean(pp) std(pp)];
                            end

                            
                            relativeAmplitudeInBurst{totalNeuronsBursty} = spikesAmpPerc;
                            totalSpikesInBurst{totalNeuronsBursty} = nrSpikes;
                            
                            
                        end
                    end
                end
        end
    end
end

%total performance in terms of bursts:
mean ( burstsStatistics( find(burstsStatistics<=100) ) )
std ( burstsStatistics( find(burstsStatistics<=100) ) )

%total spikes, total % of spikes which are part of bursts
[totalSpikesInBursts totalSpikesAllNeurons (totalSpikesInBursts*100)/totalSpikesAllNeurons]
[totalNrNeurons totalNeuronsBursty]