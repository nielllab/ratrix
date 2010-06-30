function [assignedClusters rankedClusters] = sortSpikesDetected(spikes, spikeWaveforms, spikeTimestamps, spikeSortingParams, analysisPath)

% =====================================================================================================================
% BEGIN SPIKE SORTING
% Inputs are spikeTimestamps, spikeWaveforms

% check for a spike sorting method
if isfield(spikeSortingParams, 'method')
    spikeSortingMethod = spikeSortingParams.method;
else
    error('must specify a spike sorting method');
end

if isempty(spikeTimestamps)
    warning('NO SPIKES FOUND DURING SPIKE DETECTION');
    assignedClusters=[];
    rankedClusters=[];
    return;
end

% switch on the sorting method
switch upper(spikeSortingMethod)
    case 'OSORT'
        % spikeSortingParams can have the following fields:
        %   method - osort
        %   features - (optional) (default) 'allRaw' = use all features (all datapoints of each waveform)
        %           'tenPCs' = use first 10 principal components
        %           features should a cell array of a subset of these possible features
        %   doPostDetectionFiltering - (optional) specify whether or not to do post-detection filtering; see postDetectionFilter.m
        %   alignParam - (optional) alignParam to be passed in to osort's realigneSpikes method
        %   peakAlignMethod - (optional) peak alignment method used by osort's realigneSpikes method
        %   distanceWeightMode - (optional) mode of distance weight calculation used by osort's setDistanceWeight method
        %   minClusterSize - (optional) minimum number of elements in each cluster; passed in to osort's createMeanWaveforms method
        %   maxDistance - (optional) maxDistance parameter passed in to osort's assignToWaveform method; not sure what this does...
        %   envelopeSize - (optional) parameter passed in to osort's assignToWaveform method; not sure what this does...
        
        % check params
        % features
        if ~isfield(spikeSortingParams,'features')
            warning('features not defined - using default value of ''allRaw''');
            spikeSortingParams.features={'allRaw'};
        end
        if ~isfield(spikeSortingParams,'doPostDetectionFiltering')
            warning('doPostDetectionFiltering not defined - using default value of false');
            spikeSortingParams.doPostDetectionFiltering = false;
        end
        %alignParam:   this param is only considered if peakAlignMethod=1.
        %      1: positive (peak is max)
        %      2: negative (peak is min)
        %      3: mixed
        if ~isfield(spikeSortingParams,'alignParam')
            warning('alignParam not defined - using default value of 1');
            spikeSortingParams.alignParam=1;
        end
        %peakAlignMethod: (same as in detectSpikesFromPower.m, see for details).  1-> findPeak, 2 ->none, 3-> peak of power signal
        if ~isfield(spikeSortingParams,'peakAlignMethod')
            warning('peakAlignMethod not defined - using default value of 1');
            spikeSortingParams.peakAlignMethod=1;
        end
        %mode==1:mean waveforms
        %mode==2:assignment
        if ~isfield(spikeSortingParams,'distanceWeightMode')
            warning('distanceWeightMode not defined - using default value of 1');
            spikeSortingParams.distanceWeightMode=1;
        end
        % see createMeanWaveforms.m
        if ~isfield(spikeSortingParams,'minClusterSize')
            warning('minClusterSize not defined - using default value of 50');
            spikeSortingParams.minClusterSize=50;
        end
        % see assignToWaveform.m
        if ~isfield(spikeSortingParams,'maxDistance')
            warning('maxDistance not defined - using default value of 3');
            spikeSortingParams.maxDistance=3;
        end
        % see assignToWaveform.m
        if ~isfield(spikeSortingParams,'envelopeSize')
            warning('envelopeSize not defined - using default value of 4');
            spikeSortingParams.envelopeSize=4;
        end
        
        % end param checks
        % ===============================================================================
        % generate feature file for MClust manual use
        % write the feature file
        [features nrDatapoints] = calculateFeatures(spikeWaveforms,spikeSortingParams.features);
        
        fname = fullfile(analysisPath,'temp.fet.1');
        fid = fopen(fname,'w+');
        fprintf(fid,[num2str(nrDatapoints) '\n']);
        for k=1:length(spikeTimestamps)
            fprintf(fid,'%s\n', num2str(features(k,1:nrDatapoints)));
        end
        fclose(fid);
        
        % first upsample spikes
        spikeWaveforms=upsampleSpikes(spikeWaveforms);
        % get estimate of std from raw signal
        stdEstimate = std(neuralData); %stdEstimate: std estimate of the raw signal. only used if peakAlignMethod=1.
        
        if spikeSortingParams.doPostDetectionFiltering
            % optional post spike-detection filtering
            %filter raw waveforms to get rid of artifacts, non-real spikes and
            %other shit
            [newSpikes,newTimestamps,didntPass] = postDetectionFilter( spikeWaveforms, spikeTimestamps);
            newSpikes = realigneSpikes(newSpikes,spikeTimestamps,spikeSortingParams.alignParam,stdEstimate,spikeSortingParams.peakAlignMethod);
        else
            newSpikes=spikeWaveforms;
            newTimestamps=spikeTimestamps;
        end
        numSpikes=size(newSpikes,1);
        disp(sprintf('got %d spikes; about %2.2g Hz',numSpikes,  numSpikes/diff(neuralDataTimes([1 end]))))
        
        %convert to RBF and realign
        [spikesRBF, spikesSolved] = RBFconv( newSpikes );
        spikesSolved = realigneSpikes(spikesSolved,spikeTimestamps,spikeSortingParams.alignParam,stdEstimate,spikeSortingParams.peakAlignMethod);
        
        %calculate threshold
        x=1:size(spikesSolved,2);
        [weights,weightsInv] = setDistanceWeight(x,spikeSortingParams.distanceWeightMode);
        globalMean = mean(spikesSolved);
        globalStd  = std(spikesSolved);
        initialThres = ((globalStd.^2)*weights)/256;
        
        %cluster to find mean waveforms of cluster
        [NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters] = sortBlock(spikesSolved, newTimestamps, initialThres);
        
        %merge mean clusters
        [meanWaveforms,meanClusters] = ...
            createMeanWaveforms( size(spikesSolved,1), meanSpikeForms,rankedClusters,initialThres,spikeSortingParams.minClusterSize);
        
        %now re-cluster, using this new mean waveforms
        [assignedClusters, rankedClusters] = ...
            assignToWaveform(spikesSolved,newTimestamps,meanClusters,initialThres,stdEstimate,spikeSortingParams.maxDistance,spikeSortingParams.envelopeSize);
        % osort's assignToWaveform gives us rankedClusters as indices into the unique cluster numbers in assignedClusters
        % we want rankedClusters to be the actual cluster numbers, not indices - fix here
        % rankedClusters should be sorted in descending order of number of members in cluster, with noise cluster moved to last element
        uniqueClusters = unique(assignedClusters);
        uniqueClusters(uniqueClusters==999)=[]; % move noise cluster to end
        uniqueClusters(end+1)=999;
        rankedClusters=uniqueClusters;
        
        % write cluster file
        fname = fullfile(analysisPath,'temp.clu.1');
        fid = fopen(fname,'w+');
        fprintf(fid,[num2str(length(uniqueClusters)) '\n']);
        for k=1:length(assignedClusters)
            fprintf(fid,'%s\n', num2str(assignedClusters(k)));
        end
        fclose(fid);
        
    case 'KLUSTAKWIK'
        % spikeSortingParams can have the following fields:
        %   minClusters - (optional) (default 20) min number of initial clusters - final number may be different due to splitting/deleting
        %   maxClusters - (optional) (default 30) max number of initial clusters - final number may be different due to splitting/deleting
        %   nStarts - (optional) (default 1) number of starts of the algorithm for each initial cluster count
        %   splitEvery - (optional) (default 50) Test to see if any clusters should be split every n steps. 0 means don't split.
        %   maxPossibleClusters - (optional) (default 100) Cluster splitting can produce no more than this many clusters.
        %   features - (optional) (default) 'allRaw' = use all features (all datapoints of each waveform)
        %           'tenPCs' = use first 10 principal components
        %           features should a cell array of a subset of these possible features
        
        % check params
        % minClusters
        if ~isfield(spikeSortingParams,'minClusters')
            warning('minClusters not defined - using default value of 20');
            spikeSortingParams.minClusters=20;
        end
        % maxClusters
        if ~isfield(spikeSortingParams,'maxClusters')
            warning('maxClusters not defined - using default value of 30');
            spikeSortingParams.maxClusters=30;
        end
        % nStarts
        if ~isfield(spikeSortingParams,'nStarts')
            warning('nStarts not defined - using default value of 1');
            spikeSortingParams.nStarts=1;
        end
        % splitEvery
        if ~isfield(spikeSortingParams,'splitEvery')
            warning('splitEvery not defined - using default value of 50');
            spikeSortingParams.splitEvery=50;
        end
        % maxPossibleClusters
        if ~isfield(spikeSortingParams,'maxPossibleClusters')
            warning('maxPossibleClusters not defined - using default value of 100');
            spikeSortingParams.maxPossibleClusters=100;
        end
        % features
        if ~isfield(spikeSortingParams,'features')
            warning('features not defined - using default value of ''allRaw''');
            spikeSortingParams.features={'allRaw'};
        end
        
        % we need a file temp.fet.1 as input to KlustaKwik, and the output file will be temp.clu.1
        % change to ratrixPath/KlustaKwik directory
        currentDir=pwd;
        tempDir=fullfile(getRatrixPath,'analysis','spike sorting','KlustaKwik');
        cd(tempDir);
        
        [features nrDatapoints] = calculateFeatures(spikeWaveforms,spikeSortingParams.features);
        
        % write the feature file
        fid = fopen('temp.fet.1','w+');
        fprintf(fid,[num2str(nrDatapoints) '\n']);
        for k=1:length(spikeTimestamps)
            fprintf(fid,'%s\n', num2str(features(k,1:nrDatapoints)));
        end
        fclose(fid);
        
        % set which features to use
        featuresToUse='';
        for i=1:nrDatapoints
            featuresToUse=[featuresToUse '1'];
        end
        
        % now run KlustaKwik
        cmdStr=['KlustaKwik.exe temp 1 -MinClusters ' num2str(spikeSortingParams.minClusters) ' -MaxClusters ' num2str(spikeSortingParams.maxClusters) ...
            ' -nStarts ' num2str(spikeSortingParams.nStarts) ' -SplitEvery ' num2str(spikeSortingParams.splitEvery) ...
            ' -MaxPossibleClusters ' num2str(spikeSortingParams.maxPossibleClusters) ' -UseFeatures ' featuresToUse ' -Debug ' num2str(0) ];
        system(cmdStr);
        WaitSecs(0.1);
        % read output temp.clu.1 file
        try
            fid = fopen('temp.clu.1');
            assignedClusters=[];
            while 1
                tline = fgetl(fid);
                if ~ischar(tline),   break,   end
                assignedClusters = [assignedClusters;str2num(tline)];
            end
        catch
            warning('huh? no .clu?')
            keyboard
        end
        % throw away first element of assignedClusters - the first line of the cluster file is the number of clusters found
        assignedClusters(1)=[];
        % generate rankedClusters by a simple count of number of members
        rankedClusters = unique(assignedClusters);
        clusterCounts=zeros(length(rankedClusters),2);
        for i=1:size(clusterCounts,1)
            clusterCounts(i,1) = i;
            clusterCounts(i,2) = length(find(assignedClusters==rankedClusters(i)));
        end
        clusterCounts=sortrows(clusterCounts,-2);
        rankedClusters=rankedClusters(clusterCounts(:,1));
        %rankedClusters(rankedClusters==1)=[];  % how do we know that 1 is the noise cluster,  does k.kwik enforce or is it a guess based on num samples.
        rankedClusters(end+1)=1; % move noise cluster '1' to end
        fclose(fid);
        
        % now move files from the Klusta directory (temp) to analysisPath
        d=dir;
        for i=1:length(d)
            [matches tokens] = regexpi(d(i).name, 'temp\..*', 'match');
            if length(matches) ~= 1
                %         warning('not a neuralRecord file name');
            else
                [successM messageM messageIDM]=movefile(d(i).name,fullfile(analysisPath,d(i).name));
            end
        end
        
        
        % change back to original directory
        cd(currentDir);
        
        if 0
            kk=klustaModelTextToStruct(fullfile(analysisPath,'temp.model.1'));
            myAssign=clusterFeaturesWithKlustaModel(kk,features,'mvnpdf',assignedClusters) % plot verification
        end
    case 'KLUSTAMODEL'
        kk=klustaModelTextToStruct(fullfile(fileparts(analysisPath),'model'));
        assignedClusters=clusterFeaturesWithKlustaModel(kk,features,'mvnpdf');
        
        rankedClusters = unique(assignedClusters);
            rankedClusters = unique(assignedClusters);
        clusterCounts=zeros(length(rankedClusters),2);
        for i=1:size(clusterCounts,1)
            clusterCounts(i,1) = i;
            clusterCounts(i,2) = length(find(assignedClusters==rankedClusters(i)));
        end
        clusterCounts=sortrows(clusterCounts,-2);
        rankedClusters=rankedClusters(clusterCounts(:,1));
        rankedClusters(end+1)=1
   
    otherwise
        spikeSortingMethod
        error('unsupported spike sorting method');
end

% output of spike sorting should be assignedCluster and rankedClusters
% assignedCluster is a 1xN vector, which is the assigned cluster number for each spike (numbers are arbitrary)

if spikeSortingParams.plotSortingForTesting % view plots (for testing)
    
    switch upper(spikeSortingMethod)
        case 'OSORT'
            whichSpikes=find(assignedClusters~=999);
            whichNoise=find(assignedClusters==999);  % i think o sort only... need to be specific to noise clouds in other detection methods
        case 'KLUSTAKWIK'
            whichSpikes=find(assignedClusters==rankedClusters(1)); % biggest
            whichNoise=find(assignedClusters~=rankedClusters(1));  % not the biggest
        otherwise
            error('bad method')
    end
    
    candTimes=spikes;
    %candTimes=find(spikes);
    spikeTimes=candTimes(whichSpikes);
    noiseTimes=candTimes(whichNoise);
    
    
    N=20; %downsampling for the display of the whole trace; maybe some user control?
    
    %choose y range for raw, crop extremes is more than N std
    whichChan=1;  % the one used for detecting
    dataMinMax=1.1*minmax(neuralData(:,whichChan)');
    stdRange=6*(std(neuralData(:,whichChan)'));
    if range(dataMinMax)<stdRange*2
        yRange=dataMinMax;
    else
        yRange=mean(neuralData(:,whichChan)')+[-stdRange stdRange ];
    end
    
    %should do same for filt if functionized, but its not needed
    yRangeFilt= 1.1*minmax(filteredSignal(:,1)');
    
    
    % a smart way to choose a zoom center on a spike
    % this should be able to be a user selected spike (click on main timeline nearest x-val  AND  key combo for prev / next spike)
    % but for now its the last one
    zoomWidth=spikeDetectionParams.samplingFreq*0.05;  % 50msec default, key board zoom steps by a factor of 2
    lastSpikeTimePad=min([max(spikeTimes)+200 size(neuralDataTimes,1)]);
    zoomInds=[max(lastSpikeTimePad-zoomWidth,1):lastSpikeTimePad ];
    
    figure
    %         if ~isempty(whichNoise)
    %             plot(spikeWaveforms(whichNoise,:)','color',[.7 .7 .7])
    %         end
    %colors=brighten(brighten(bone(length(rankedClusters)),1),1);
    colors=cool(length(rankedClusters));
    subplot(1,3,3);hold on;
    subplot(2,3,4); hold on;
    for i=2:length(rankedClusters)
        thisCluster=find(assignedClusters==rankedClusters(i));
        if ~isempty(thisCluster)
            subplot(1,3,3); plot(spikeWaveforms(thisCluster,:)','color',colors(i,:))
            subplot(2,3,4); plot3(features(thisCluster,1),features(thisCluster,2),features(thisCluster,3),'.','color',colors(i,:))
        end
    end
    subplot(1,3,3); plot(spikeWaveforms(whichSpikes,:)','r')
    axis([ 1 size(spikeWaveforms,2)  1.1*minmax(spikeWaveforms(:)') ])
    subplot(2,3,4); plot3(features(whichSpikes,1),features(whichSpikes,2),features(whichSpikes,3),'r.')
    
    
    xlabel(sprintf('%d spikes, %2.2g Hz', length(spikeTimes),length(spikeTimes)/diff(neuralDataTimes([1 end]))))
    
    subplot(2,3,1)
    %inter-spike interval distribution
    ISI=diff(1000*neuralDataTimes(spikeTimes));
    edges=linspace(0,10,100);
    count=histc(ISI,edges);
    if sum(count)>0
        prob=count/sum(count);
        bar(edges,prob,'histc');
        axis([0 max(edges) 0 max(prob)])
    else
        text(0,0,'no ISI < 10 msec')
    end
    hold on
    lockout=1000*39/spikeDetectionParams.samplingFreq;  %why is there a algorithm-imposed minimum ISI?  i think it is line 65  detectSpikes
    lockout=edges(max(find(edges<=lockout)));
    plot([lockout lockout],get(gca,'YLim'),'k') %
    plot([2 2], get(gca,'YLim'),'k--')
    
    
    N=size(neuralData,2);
    colors=0.8*ones(N,3);
    colors(1,:)=0; %first one is black is main
    
    subplot(2,3,2)
    title('rawSignal zoom');
    %plot(neuralDataTimes(zoomInds),neuralData(zoomInds),'k');
    hold on
    
    steps=max(std(neuralData));
    for i=1:N
        plot(neuralDataTimes(zoomInds),neuralData(zoomInds,i)-steps*(i-1),'color',colors(i,:))
        %text(xMinMax(1)-diff(xMinMax)*0.05,steps*i,num2str(i-2)) % add the name of channel... consider doing all phys channels
    end
    set(gca,'ytick',[])
    
    someNoiseTimes=noiseTimes(ismember(noiseTimes,zoomInds));
    someSpikeTimes=spikeTimes(ismember(spikeTimes,zoomInds));
    plot(neuralDataTimes(someNoiseTimes),neuralData(someNoiseTimes),'.b');
    plot(neuralDataTimes(someSpikeTimes),neuralData(someSpikeTimes),'.r');
    axis([ minmax(neuralDataTimes(zoomInds)')   ylim ])
    
    
    if 0
        subplot(2,3,4)
        title('filtSignal and spikes');
        plot(downsample(neuralDataTimes,N),downsample(filteredSignal,N),'k');
        hold on
        plot(neuralDataTimes(noiseTimes),filteredSignal(noiseTimes),'.b');
        plot(neuralDataTimes(spikeTimes),filteredSignal(spikeTimes),'.r');
        axis([ minmax(neuralDataTimes')   1.1*minmax(filteredSignal') ])
    end
    % a button should allow selection between filtered or non-filtered (only show one kind)
    
    %     title('rawSignal and spikes');
    %     plot(downsample(neuralDataTimes,N),downsample(neuralData,N),'k');
    %     hold on
    %     plot(neuralDataTimes(noiseTimes),neuralData(noiseTimes),'.b');
    %     plot(neuralDataTimes(spikeTimes),neuralData(spikeTimes),'.r');
    %      axis([ minmax(neuralDataTimes')   yRange ])
    
    
    subplot(2,3,5)
    title('filtSignal zoom');
    %plot(neuralDataTimes(zoomInds),filteredSignal(zoomInds),'k');
    hold on
    steps=max(std(filteredSignal));
    for i=fliplr(1:N)
        plot(neuralDataTimes(zoomInds),filteredSignal(zoomInds,i)-steps*(i-1),'color',colors(i,:))
        %text(xMinMax(1)-diff(xMinMax)*0.05,steps*i,num2str(i-2)) % add the name of channel... consider doing all phys channels
    end
    
    xl=xlim;
    set(gca,'xtick',xlim,'xticklabel',{num2str(xl(1),'%2.2f'),num2str(xl(2),'%2.2f')})
    if isfield(spikeDetectionParams, 'threshHoldVolts')
        xlabel(sprintf('thresh = [%2.3f %2.3f]',spikeDetectionParams.threshHoldVolts))
        yTickVal=[spikeDetectionParams.threshHoldVolts(1) 0 spikeDetectionParams.threshHoldVolts(2)];
        set(gca,'ytick',yTickVal,'yticklabel',{num2str(yTickVal(1),'%2.2f'),'0',num2str(yTickVal(3),'%2.2f')})
        plot(xl,spikeDetectionParams.threshHoldVolts([1 1]),'color',[.8 .8 .8])
        plot(xl,spikeDetectionParams.threshHoldVolts([2 2]),'color',[.8 .8 .8])
    else
        set(gca,'ytick',[])
    end
    
    plot(neuralDataTimes(someNoiseTimes),filteredSignal(someNoiseTimes),'.b');
    plot(neuralDataTimes(someSpikeTimes),filteredSignal(someSpikeTimes),'.r');
    axis([ neuralDataTimes(zoomInds([1 end]))'   ylim])
    %axis([ minmax(neuralDataTimes(zoomInds)')   1.1*minmax(filteredSignal(zoomInds)') ])
    
    %     figure()
    %     allSpikesDecorrelated=spikeWaveforms; %this is not decorellated!
    %     allSpikesOrig=spikeWaveforms;
    %     assigned=?
    %     clNr1=just ID?
    %     clNr2=justID?
    %     plabel='';
    %     mode=1; %maybe 2 later
    %     [d,residuals1,residuals2,Rsquare1, Rsquare2] =
    %     figureClusterOverlap(allSpikesDecorrelated, allSpikesOrig, assigned, clNr1, clNr2,plabel ,mode , {'b','r'})
end
end

function kk=klustaModelTextToStruct(modelFile)

fid=fopen(modelFile,'r');  % this is only the first one!
if fid==-1
    modelFile
    error('bad file')
end
kk.headerJunk= fgetl(fid);
ranges= str2num(fgetl(fid));
sz=str2num(fgetl(fid));
kk.numDims=sz(1);
kk.numClust=sz(2);
kk.numOtherThing=sz(3); % this is not num features? 
kk.ranges=reshape(ranges,[],kk.numDims);
kk.mean=nan(kk.numClust,kk.numDims);
xx.cov=nan(kk.numDims,kk.numDims,kk.numClust);
for c=1:kk.numClust
    clustHeader=str2num(fgetl(fid));
    if clustHeader(1)~=c-1
        %just double check
        error('wrong cluster')
    end
    kk.mean(c,:)=str2num(fgetl(fid));
    kk.weight(c)=clustHeader(2);
    for i=1:kk.numDims
        kk.cov(i,:,c)=str2num(fgetl(fid));
    end
end
fclose(fid);
end

function assignments=clusterFeaturesWithKlustaModel(kk,features,distanceMethod,verifyAgainst)

%%

%normalize from 0-->1 extrema of training set
F=features;
n=size(F,1);
for d=1:kk.numDims
    F(:,d)=F(:,d)-kk.ranges(1,d);
    F(:,d)=F(:,d)/diff(kk.ranges(:,d));      
end

switch distanceMethod
    case 'mvnpdf'
        %calculate the probability that each point belongs to each cluster
        %OLD GUESS USING MVNPDF 
        thisMean=kk.mean; % verified empirically to be the mean per cluster after normalization
        p=nan(size(features,1),kk.numClust);
        for c=1:kk.numClust
            chol=reshape(kk.cov(:,:,c),[kk.numDims kk.numDims]);
            thisCov=chol*chol';
            p(:,c)=mvnpdf(F,kk.mean(c,:),thisCov);
        end
        [junk assignments]=max(p,[],2);
        distnce=abs(log(p));
        %distnce=abs(log(p)-log(repmat(kk.weight,n,1)));
        %[junk assignments]=max(distnce,[],2);
    case 'mah'
        %mimick Mahalanobis stuff in Klusta
        %calculate the distance from each point to each cluster
        invcov = cov(features)\eye( size(features,2)); % see pdist
        %Y = pdistmex(features','mah',invcov); % why fail mex?
        mahal = nan(size(features,1),kk.numClust);
        for c = 1:kk.numClust
            del = repmat(kk.mean(c,:),size(features,1),1) - features;
            mahal(:,c)= sqrt(sum((del*invcov).*del,2));
            
            chol=reshape(kk.cov(:,:,c),[kk.numDims kk.numDims]);
            LogRootDet(c)=sum(log(diag(chol)));
            distnce(:,c)=mahal(:,c)/2+log(kk.weight(c))-LogRootDet(c); %WHAT?
            % does klust calc an overall goodness of fit of all points?
            % and how does the weight relate to the classification?
            distnce(:,c)=mahal(:,c)%+log(kk.weight(c))/2; %;%-LogRootDet(c)+
        end
        %distnce(:,1)=Inf;
        [junk assignments]=min(distnce,[],2);
end

if exist('verifyAgainst','var')
    figure;
    subplot(1,2,1); plot(distnce,'.')
    subplot(1,2,2); hold on
    colors=jet(kk.numClust);
    darker=colors*.6;
    for c=1:kk.numClust
        which=verifyAgainst==c;
        plot3(F(which,1),F(which,2),F(which,3),'.','color',colors(c,:));
        which=assignments==c;
        plot3(F(which,1),F(which,2),F(which,3),'o','color',colors(c,:));
        plot3(kk.mean(c,1),kk.mean(c,2),kk.mean(c,3),'+','MarkerSize',20,'color',darker(c,:))
        
        which=verifyAgainst==c;
        plot3(mean(F(which,1)),mean(F(which,2)),mean(F(which,3)),'o','MarkerSize',20,'color',darker(c,:))
    end
end
%%
end