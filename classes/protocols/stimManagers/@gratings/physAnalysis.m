function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData)
% stimManager is the stimulus manager
% spikes is an index into neural data samples of the time of a spike
% correctedFrameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain
% all the information needed to reconstruct stimData)
% plotParameters - currently not used


%CHOOSE CLUSTER
spikes=spikeRecord.spikes; %all waveforms
if isstruct(spikeRecord.spikeDetails) && ismember({'processedClusters'},fields(spikeRecord.spikeDetails)) 
    processedClusters=[];
    for i=1:length(spikeRecord.spikeDetails)
        processedClusters=[processedClusters spikeRecord.spikeDetails(i).processedClusters];  %this is not a cumulative analysis so by default analyze all chunks available
    end
    thisCluster=processedClusters==1;
else
    thisCluster=logical(ones(size(spikes))); 
    %use all (photodiode uses this)
end
spikes(~thisCluster)=[]; % remove spikes that dont belong to thisCluster


%SET UP RELATION stimInd <--> frameInd
numStimFrames=max(spikeRecord.stimInds);
analyzeDrops=true;
if analyzeDrops
    stimFrames=spikeRecord.stimInds;
    correctedFrameIndices=spikeRecord.correctedFrameIndices;
else
    stimFrames=1:numStimFrames;
    firstFramePerStimInd=~[0 diff(spikeRecord.stimInds)==0];
    correctedFrameIndices=spikeRecord.correctedFrameIndices(firstFramePerStimInd);
end


if stimulusDetails.doCombos==1
    comboMatrix = generateFactorialCombo({stimulusDetails.spatialFrequencies,stimulusDetails.driftfrequencies,stimulusDetails.orientations,...
        stimulusDetails.contrasts,stimulusDetails.phases,stimulusDetails.durations,stimulusDetails.radii,stimulusDetails.annuli});
    pixPerCycs=comboMatrix(1,:);
    driftfrequencies=comboMatrix(2,:);
    orientations=comboMatrix(3,:);
    contrasts=comboMatrix(4,:); %starting phases in radians
    startPhases=comboMatrix(5,:);
    durations=round(comboMatrix(6,:)*parameters.refreshRate); % CONVERTED FROM seconds to frames
    radii=comboMatrix(7,:);
    annuli=comboMatrix(8,:); 

    repeat=ceil(stimFrames/sum(durations));
    numRepeats=ceil(numStimFrames/sum(durations));
    chunkEndFrame=[cumsum(repmat(durations,1,numRepeats))];
    chunkStartFrame=[0 chunkEndFrame(1:end-1)]+1;
    %chunkStartFrame(chunkStartFrame>numStimFrames)=[]; %remove chunks that were never reached. OK TO LEAVE IF WE INDEX BY OTHER THINGS
    %chunkEndFrame(chunkStartFrame>numStimFrames)=[]; %remove chunks that were never reached.
    numChunks=length(chunkStartFrame);
    numTypes=length(durations);
else
    error('analysis not handled yet for this case')
end

% 
% if numStimFrames<max(chunkEndFrame)
%     analysisdata=[];
%     cumulativedata=[];
%     warning('skipping analysis of gratings untill all the chunks are there')
%     return; % don't analyze partial data
% end
    
% find out what parameter is varying
numValsPerParam=...
    [length(unique(pixPerCycs)) length(unique(driftfrequencies))  length(unique(orientations))  length(unique(contrasts)) length(unique(startPhases)) length(unique(durations))  length(unique(radii))  length(unique(annuli))];
if sum(numValsPerParam>1)==1
    names={'pixPerCycs','driftfrequencies','orientations','contrasts','startPhases','durations','radii','annuli'};
    sweptParameter=names(find(numValsPerParam>1));
else
    error('analysis only for one value at a time now')
    return % to skip
end

% determine the type of stim on each frame
if length(unique(durations))==1
    duration=unique(durations);
    type=repmat([1:numTypes],duration,numRepeats);
    type=type(stimFrames); % vectorize matrix and remove extras
else
    error('multiple durations can''t rely on mod to determine the frame type')
end

%empirically is the old way
%samplingRate=round(diff(minmax(spikes'))/ diff(spikeRecord.spikeTimestamps([1 end])));
samplingRate=parameters.samplingRate;

% calc phase per frame, just like dynamic
x = 2*pi./pixPerCycs(type); % adjust phase for spatial frequency, using pixel=1 which is likely offscreen if rotated
cycsPerFrameVel = driftfrequencies(type)*1/(parameters.refreshRate); % in units of cycles/frame
offset = 2*pi*cycsPerFrameVel.*stimFrames';
phases=x + offset+startPhases(type);
phases=mod(phases,2*pi);

% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCount=zeros(1,size(correctedFrameIndices,1));
for i=1:length(spikeCount) % for each frame
     spikeCount(i)=length(find(spikes>=correctedFrameIndices(i,1)&spikes<=correctedFrameIndices(i,2))); % inclusive?  policy: include start & stop
end

% probablity of a spike per phase
numPhaseBins=8;
edges=linspace(0,2*pi,numPhaseBins+1);
events=zeros(numRepeats,numTypes,numPhaseBins);
possibleEvents=events;
phaseDensity=zeros(numRepeats*numTypes,numPhaseBins);
pow=nan(numRepeats,numTypes);
for i=1:numRepeats
    for j=1:numTypes
        chunk=(i-1)*numTypes+j;
        sf=min(find(stimFrames==chunkStartFrame(chunk)));
        ef=max(find(stimFrames==chunkEndFrame(chunk)));
                
        whichType=find(type==j & repeat==i);
        if length(whichType)>5  % need some spikes, 2 would work mathematically
            [n phaseID]=histc(phases(whichType),edges);
            for k=1:numPhaseBins
                whichPhase=find(phaseID==k);
                events(i,j,k)=sum(spikeCount(whichType(whichPhase)));
                possibleEvents(i,j,k)=length(whichPhase);
                
                %in last repeat density = 0, for parsing and avoiding misleading half data
                if numRepeats~=i
                    y=(j-1)*(numRepeats)+i;
                    phaseDensity(y,k)=events(i,j,k)/possibleEvents(i,j,k);
                end
            end
            
            % find the power in the spikes at the freq of the grating
            fy=fft(.5+cos(phases(whichType))/2); %fourier of stim
            fx=fft(spikeCount(whichType)); % fourier of spikes
            fy=abs(fy(2:floor(length(fy)/2))); % get rid of DC and symetry
            fx=abs(fx(2:floor(length(fx)/2)));
            peakFreqInd=find(fy==max(fy)); % find the right freq index using stim
            pow(i,j)=fx(peakFreqInd); % determine the power at that freq

            
            warning('had to turn coherency off... there is possibly a formating error b/c stimFrames is a sawtooth which we could fix here, but ought to be fixed at the concatenation point')
            if ~isempty(ef) & 0 % turn off until matrices are the right size
                chrParam.tapers=[3 5]; % same as default, but turns off warning
                chrParam.err=[2 0.05];  % use 2 for jacknife
                fscorr=true;
                % should check chronux's chrParam,trialave=1 to see how to
                % handle CI's better.. will need to do all repeats at once
                [C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=coherencycpb(cos(phases(whichType)'),spikeCount(sf:ef)',chrParam,fscorr);
            end
            
            if 0 && ~isempty(ef) && ~zerosp 
                peakFreqInds=find(S1>max(S1)*.95); % a couple bins near the peak of 
                [junk maxFreqInd]=max(S1);
                coh(i,j)=mean(C(peakFreqInds));
                cohLB(i,j)=Cerr(1,maxFreqInd);  
            else
                coh(i,j)=nan;
                cohLB(i,j)=nan;  
            end
            
            if 0 & j==3  & ~isempty(ef) % 1; %chunk==6 %chronuxDev
                

                %get the spikes times as a pt process
                sf=min(find(stimFrames==chunkStartFrame(chunk)));
                ef=max(find(stimFrames==chunkEndFrame(chunk)));
                
                ss=correctedFrameIndices(sf,1); % start samp
                es=correctedFrameIndices(ef,2); % end samp
                whichSpikes=spikes>=ss & spikes<=es;
                
                %durE=durations(j)/parameters.refreshRate; %expected if not frame drops
                %samplingRate/driftfrequencies(j)
                %dur=(es-ss)/samplingRate; % actual w/ frame drops
                
                cycs=driftfrequencies(j)*durations(j)/parameters.refreshRate;
               eFreq=1/cycs; % in normalized units
               
                %fRange=(1./(cycs*[2 1/2]));

                
                
                %chrParam.tapers=[dur/3 dur 1];  %width, dur, 
                %chrParam.pad=[0];
                %chrParam.Fs=[1];
                %chrParam.fpass=fRange;
                %chrParam.err=[2 0.05];  % use 2 for jacknife
                
                

                                
                chrParam.tapers=[3 5];
                chrParam.pad=[0];
                chrParam.Fs=[1];
                chrParam.fpass=[0 .5];
                chrParam.err=[2 0.05];  % use 2 for jacknife
                
                chrParam.fpass=[0.0 0.08] % these values are not dynamic to stim type... just for viewing
                fscorr=true;   % maybe should be true so that the finit size correction for spikes is used
                [C3,phi3,S13,S1,S3,f,zerosp,confC3,phistd3,Cerr3]=coherencycpb(cos(phases(whichType)'),spikeCount(sf:ef)',chrParam,fscorr);
                [junk maxFreqIndFewTapers]=max(S1);         
                                
                figure
                t1s=[3 5]% [1 3 5 20];
                t2s=[5 9]% [ 5 10 20]
                for ii=1:length(t1s)
                    for jj=1:length(t2s)
                        chrParam.tapers=[t1s(ii) t2s(jj)];
                        [C3,phi3,S13,S1,S3,f,zerosp,confC3,phistd3,Cerr3]=coherencycpb(cos(phases(whichType)'),spikeCount(sf:ef)',chrParam,fscorr);
                        
                        [junk expectedFreqInd]=min(abs(eFreq-f));
                        [junk maxFreqInd]=max(S1);
                        peakFreqInds=find(S1>max(S1)*.95);
                        
                        subplot(length(t2s),length(t1s),(ii-1)*length(t1s)+jj)
                        hold off
                                                fill([f, fliplr(f)],[Cerr3(1,:), fliplr(Cerr3(2,:))],'m','faceAlpha',0.2,'edgeAlpha',0);
                                                hold on;
                        plot(f,S1/max(S1),'k');             
                        plot(f,S3/max(S3),'b');
                        plot(f,C3/max(C3),'r');

                        %plot(f(expectedFreqInd),0,'r*')
                        plot(f(maxFreqInd),0,'b*')
                        plot(f(peakFreqInds),0.1,'b.')
                        plot(f(maxFreqIndFewTapers),0.1,'g*')
                    end
                    
                end
                
                if 0 % compare pt process estimates, which seem noiser
                    pt.times=[spikeRecord.spikeTimestamps(whichSpikes)];  % are times in the right format?  seconds in a range
                    t=[]; % should calc the time grid for the start and stop of the trial.
                    fscorr=true;   % maybe should be true so that the finit size correction for spikes is used
                    if chrParam.err(1)==2
                        [C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=coherencycpt(cos(phases(whichType)'),pt,chrParam,fscorr,t);
                        [C3,phi3,S13,S1,S3,f,zerosp,confC3,phistd3,Cerr3]=coherencycpb(cos(phases(whichType)'),spikeCount(sf:ef)',chrParam,fscorr);
                    else
                        [C,phi,S12,S1,S2,f,zerosp]=coherencycpt(cos(phases(whichType)'),pt,chrParam,fscorr,t);
                        [C3,phi3,S13,S1,S3,f,zerosp]=coherencycpb(cos(phases(whichType)'),spikeCount(sf:ef)',chrParam,fscorr);
                    end
                    
                    
                    figure
                    plot(f,S1/max(S1),'k');             hold on;
                    plot(f,S2/max(S2),'b');
                    fill([f, fliplr(f)],[Cerr(1,:), fliplr(Cerr(2,:))],'c','faceAlpha',0.2,'edgeAlpha',0);
                    plot(f,S3/max(S3),'r');
                    fill([f, fliplr(f)],[Cerr3(1,:), fliplr(Cerr3(2,:))],'m','faceAlpha',0.2,'edgeAlpha',0);
                    plot(f(expectedFreqInd),0,'r*')
                    
                end
                
                
            
            end
            
            if 0 %development
                
                [b,a] = butter(1,.1);
                x=spikeCount(whichType);
                y=.5+cos(phases(whichType))/2;
                
                %could smooth spikes, but we only care about an accurate power
                %estimate of a fixed freq, don't care about the presence of
                %higher freqs in the data
                xx=filtfilt(b,a,x);
                xxx=conv2(x,fspecial('gauss',[1 20],2),'same'); % similar to bw filter
                figure; plot(y,'k'); hold on; plot(x/3,'g');  plot(xx,'r'); plot(xxx,'b');
                
                fy=fft(y);  fx=fft(x);
                fy=abs(fy(2:length(fy)/2));
                fx=abs(fx(2:length(fx)/2));
                peakFreqInd=find(fy==max(fy));
                pow=fx(peakFreqInd); % thi is what we use
                figure; plot(fy); hold on; plot(fx,'r')
            end 
            
                if 0 % fancier spectral ideas not used
                    Fs=parameters.refreshRate;
                    
                    %Hs = spectrum.music(2);  % supported setup
                    %[POW,F]=powerest(Hs,y,Fs)%,) strange error
                    [freq,pow] = rootmusic(y,2,Fs); % this works
                    %pmusic(x,2) % see the est
                    
                    h = spectrum.welch;                  % Create a Welch spectral estimator.
                    Xpsd = psd(h,x,'Fs',Fs);             % Calculate the PSD
                    Ypsd = psd(h,y,'Fs',Fs);             % Calculate the PSD
                    %peakFreqInd=find(Ypsd.data==max(Ypsd.data));  % might not be as reliable
                    
                    f_diff=abs(Ypsd.Frequencies-freq(1));
                    peakFreqInd=find(f_diff==min(f_diff)); % index nearest music freq est
                    f=Ypsd.Frequencies(peakFreqInd);
                    pow=Ypsd.data(peakFreqInd);
                    
                    plot(Xpsd)
                end
        end
    end
end

%get eyeData for phase-eye analysis
if ~isempty(eyeData)
    [px py crx cry]=getPxyCRxy(eyeData,10);
    eyeSig=[crx-px cry-py];
    eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)

    if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions
        
         regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
        [within ellipses]=selectDenseEyeRegions(eyeSig,1,regionBoundsXY);
        
        whichOne=0; % various things to look at
        switch whichOne
            case 0
                %do nothing
            case 1 % plot eye position and the clusters
                regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
                within=selectDenseEyeRegions(eyeSig,3,regionBoundsXY,true);
            case 2  % coded by phase
                [n phaseID]=histc(phases,edges);
                figure; hold on;
                phaseColor=jet(numPhaseBins);
                for i=1:numPhaseBins
                    plot(eyeSig(phaseID==i,1),eyeSig(phaseID==i,2),'.','color',phaseColor(i,:))
                end
            case 3
                density=hist3(eyeSig);
                imagesc(density)
            case 4
                eyeMotion=diff(eyeSig(:,1));
                mean(eyeMotion>0)/mean(eyeMotion<0);   % is close to 1 so little bias to drift and snap
                bound=3*std(eyeMotion(~isnan(eyeMotion)));
                motionEdges=linspace(-bound,bound,100);
                count=histc(eyeMotion,motionEdges);
                
                figure; bar(motionEdges,log(count),'histc'); ylabel('log(count)'); xlabel('eyeMotion (crx-px)''')
                
                figure; plot(phases',eyeMotion,'.'); % no motion per phase (more interesting for sqaure wave single freq)
        end
    else
        disp(sprintf('no good eyeData on trial %d',parameters.trialNumber))
    end
end




% events(events>possibleEvents)=possibleEvents % note: more than one spike could occur per frame, so not really binomial
% [pspike pspikeCI]=binofit(events,possibleEvents);

fullRate=events./possibleEvents;
rate=reshape(sum(events,1)./sum(possibleEvents,1),numTypes,numPhaseBins); % combine repetitions
[repInds typeInds]=find(isnan(pow));
pow(unique(repInds),:)=[];   % remove reps with bad power estimates
coh(unique(repInds),:)=[];   % remove reps with bad power estimates
cohLB(unique(repInds),:)=[]; % remove reps with bad power estimates
if numRepeats>2
    rateSEM=reshape(std(events(1:end-1,:,:)./possibleEvents(1:end-1,:,:)),numTypes,numPhaseBins)/sqrt(numRepeats-1);
else
    rateSEM=nan(size(rate));
end

if size(pow,1)>1
    powSEM=std(pow)/sqrt(size(pow,1));
    pow=mean(pow);
    
    cohSEM=std(coh)/sqrt(size(coh,1));
    coh=mean(coh);
    cohLB=mean(cohLB);  % do you really want the mean of the lower bound?  
else
    powSEM=nan(1,size(pow,2));
    cohSEM=nan(1,size(pow,2));
    cohLB_SEM=nan(1,size(pow,2));
end


% setup for plotting
vals=eval(char(sweptParameter));
if strcmp(sweptParameter,'orientations')
    vals=rad2deg(vals);
end

if all(rem(vals,1)==0)
    format='%2.0f';
else
    format='%1.2f';
end
for i=1:length(vals); 
    valNames{i}=num2str(vals(i),format); 
end; 

colors=jet(numTypes);
figure(parameters.trialNumber); % new for each trial
set(gcf,'position',[100 400 560 620])
subplot(3,2,1); hold off; %p=plot([1:numPhaseBins]-.5,rate')
plot([0 numPhaseBins], [rate(1) rate(1)],'color',[1 1 1]); hold on;% to save tight axis chop
x=[1:numPhaseBins]-.5;
for i=1:numTypes
    plot(x,rate(i,:),'color',colors(i,:))
    plot([x; x]+(i*0.05),[rate(i,:); rate(i,:)]+(rateSEM(i,:)'*[-1 1])','color',colors(i,:))
end
maxPowerInd=find(pow==max(pow));
plot(x,rate(maxPowerInd,:),'color',colors(maxPowerInd,:),'lineWidth',2);
xlabel('phase');  set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)); ylabel('rate'); set(gca,'YTickLabel',[0:.1:1]*parameters.refreshRate,'YTick',[0:.1:1])
axis tight

%rate density over phase... doubles as a legend
subplot(3,2,2); hold off; 
im=zeros([size(phaseDensity) 3]);
hues=rgb2hsv(colors);  % get colors to match jet
hues=repmat(hues(:,1)',numRepeats,1); % for each rep
hues=repmat(hues(:),1,numPhaseBins);  % for each phase bin
im(:,:,1)=hues; % hue
im(:,:,2)=1; % saturation
im(:,:,3)=phaseDensity/max(phaseDensity(:)); % value
rgbIm=hsv2rgb(im);
image(rgbIm); hold on
axis([0 size(im,2) 0 size(im,1)]+.5);
ylabel(sweptParameter); set(gca,'YTickLabel',valNames,'YTick',size(im,1)*([1:length(vals)]-.5)/length(vals))
xlabel('phase');  set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)+.5);

subplot(3,2,3); hold off; plot(mean(rate'),'k','lineWidth',2); hold on; %legend({'Fo'})
xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('rate (f0)'); set(gca,'YTickLabel',[0:.1:1]*parameters.refreshRate,'YTick',[0:.1:1])
set(gca,'XLim',[1 length(vals)])

modulation=pow./(parameters.refreshRate*mean(rate'))
subplot(3,2,4); hold off
plot(pow,'k','lineWidth',1); hold on; 
plot(modulation,'--k','lineWidth',2); hold on;
cohScaled=coh*max(pow); %1 is peak FR
plot(cohScaled,'color',[.8 .8 .8],'lineWidth',1); 
sigs=find(cohLB>0);
plot(sigs,cohScaled(sigs),'o','color',[.6 .6 .6]); 
legend({'f1','f1/f0','coh'})


plot([1:length(vals); 1:length(vals)],[pow; pow]+(powSEM'*[-1 1])','k')
%plot([1:length(vals); 1:length(vals)],[pow; pow]+(powSEM'*[-1 1])','k')
plot([1:length(vals); 1:length(vals)]+0.1,[coh; coh]+(cohSEM'*[-1 1])','color',[.8 .8 .8])
xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('modulation (f1/f0)');
ylim=get(gca,'YLim'); yvals=[ ylim(1) mean(ylim) ylim(2)];set(gca,'YTickLabel',yvals,'YTick',yvals)
set(gca,'XLim',[1 length(vals)])

meanRate=(length(spikes))/diff(spikeRecord.spikeTimestamps([1 end]));
isi=diff(spikeRecord.spikeTimestamps(thisCluster))*1000;
N=sum(isi<parameters.ISIviolationMS); percentN=100*N/length(isi);
%datestr(parameters.date,22)
infoString=sprintf('subj: %s  trial: %d Hz: %d',parameters.subjectID,parameters.trialNumber,round(meanRate));
text(1.2,ylim(2),infoString);

subplot(3,2,5);
numBins=40; maxTime=10; % ms
edges=linspace(0,maxTime,numBins); [count]=histc(isi,edges);
hold off; bar(edges,count,'histc'); axis([0 maxTime get(gca,'YLim')]);
hold on; plot(parameters.ISIviolationMS([1 1]),get(gca,'YLim'),'k' )
xvalsName=[0 parameters.ISIviolationMS maxTime]; xvals=xvalsName*samplingRate/(1000*numBins);
set(gca,'XTickLabel',xvalsName,'XTick',xvals)
infoString=sprintf('viol: %2.2f%%\n(%d /%d)',percentN,N,length(isi))
text(xvals(3),max(count),infoString,'HorizontalAlignment','right','VerticalAlignment','top');
ylabel('count'); xlabel('isi (ms)')

subplot(3,2,6); hold off;
if ~isempty(eyeData)
    plot(eyeSig(1,1),eyeSig(1,2),'.k');  hold on; % plot one dot to flush history
    if exist('ellipses','var')
        plotEyeElipses(eyeSig,ellipses,within,true)
    else
        text(.5,.5,'no good eye data')
    end
    xlabel('eye position (cr-p)')
else
    text(.5,.5,'no eye data')
end

%rasterDurationSec=1;
%linesPerChunk=round((unique(durations/parameters.refreshRate))/rasterDurationSec);

if 0
    %old raster per type- not that informative
    figure; hold on
    for j=1:numTypes
        for i=1:numRepeats
            sf=chunkStartFrame((i-1)*numTypes+j); %frame start
            ef=min(chunkEndFrame((i-1)*numTypes+j),numFrames); % frame end
            
            %TIME
            %st=correctedFrameIndices(sf,1); % time start index
            %et=correctedFrameIndices(ef,2); % time stop index
            %times=find(spikes(st:et))/samplingRate; error('wrong spike definition'))
            %times=times*pixPerCycs(j);  % hack rescaling of time, to match phases... increases "apparent" firing rate
            %plot(times,(j-1)*numRepeats+i,'.','color',colors(j,:))
            
            %PHASE - scatter
            spikedPhases=phases(find(spikeCount(sf:ef)>0));
            disp(length(unique(spikedPhases)))
            %allPhases=phases(sf:ef);
            %allPhases=allPhases+0.02*randn(1,length(allPhases));
            %spikedPhases=spikedPhases+0.02*randn(1,length(spikedPhases)); %%NOISE - visualize overlap?
            if length(spikedPhases>0)
                plot(spikedPhases,(j-1)*numRepeats+i,'.','MarkerSize',5,'color',colors(j,:))
            end
            %DENSITY IN PHASE
            
        end
    end
    %axis([0 max(times) 0 numTypes*numRepeats]) % hack rescaling of time, to match phases... increases "apparent" firing rate
end


%CUMULATIVE IS NOT USED YET:
% % fill in analysisdata with new values if the cumulative values don't exist (first analysis)
% if ~isfield(analysisdata, 'cumulativeEvents') % && check that params did not change
%     analysisdata.cumulativeEvents = events;
%     analysisdata.cumulativePossibleEvents=possibleEvents
% else
%     analysisdata.cumulativeEvents = analysisdata.cumulativeEvents + events;
%     analysisdata.cumulativePossibleEvents = analysisdata.cumulativePossibleEvents + possibleEvents;
% end

analysisdata.rate=rate;
analysisdata.sweptParameter=sweptParameter;
analysisdata.vals=vals;
analysisdata.spikeCount = spikeCount;
cumulativedata=[]; % why are we emptying out cumulativedata? do we not have anything cumulative in gratings?

end % end function
% ===============================================================================================