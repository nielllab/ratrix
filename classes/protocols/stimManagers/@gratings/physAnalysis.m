function [analysisdata] = physAnalysis(stimManager,spikeData,stimulusDetails,plotParameters,parameters,analysisdata,eyeData)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% frameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain
% all the information needed to reconstruct stimData)
% plotParameters - currently not used


spikes=spikeData.spikes; %all waveforms
waveInds=find(spikes); % location of all waveforms
thisCluster=spikeData.spikeDetails.processedClusters==1;
spikes(waveInds(~thisCluster))=0; % set all the non-spike waveforms to be zero;
%spikes(waveInds(spikeData.assignedClusters~=1))=0; this should select the noise only!  just for testing

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
    
    numFrames=length(spikeData.frameIndices);
    frames=1:numFrames;
    repeat=ceil(frames/sum(durations));
    numRepeats=ceil(numFrames/sum(durations));
    chunkEndFrame=[cumsum(repmat(durations,1,numRepeats))];
    chunkStartFrame=[1 chunkEndFrame(1:end-1)];
    %chunkStartFrame(chunkStartFrame>numFrames)=[]; %remove chunks that were never reached. OK TO LEAVE IF WE INDEX BY OTHER THINGS
    %chunkEndFrame(chunkStartFrame>numFrames)=[]; %remove chunks that were never reached.
    numChunks=length(chunkStartFrame);
    numTypes=length(durations);
else
    error('analysis not handled yet for this case')
end

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
    type=type(1:numFrames); % vectorize matrix and remove extras
else
    error('multiple durations can''t rely on mod to determine the frame type')
end

%empirically
samplingRate=round(diff(minmax(find(spikeData.spikes)'))/ diff(spikeData.spikeTimestamps([1 end])));


% calc phase per frame, just like dynamic
x = 2*pi./pixPerCycs(type); % adjust phase for spatial frequency, using pixel=1 which is likely offscreen if rotated
cycsPerFrameVel = driftfrequencies(type)*1/(parameters.refreshRate); % in units of cycles/frame
offset = 2*pi*cycsPerFrameVel.*frames;
phases=x + offset+startPhases(type);
phases=mod(phases,2*pi);

% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCount=zeros(1,size(spikeData.frameIndices,1));





for i=1:length(spikeCount) % for each frame
    spikeCount(i)=sum(spikes(spikeData.frameIndices(i,1):spikeData.frameIndices(i,2)));  % inclusive?  policy: include start & stop
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
            fy=abs(fy(2:length(fy)/2)); % get rid of DC and symetry
            fx=abs(fx(2:length(fx)/2));
            peakFreqInd=find(fy==max(fy)); % find the right freq index using stim
            try
                pow(i,j)=fx(peakFreqInd); % determine the power at that freq
            catch
                h=1
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
end

% events(events>possibleEvents)=possibleEvents % note: more than one spike could occur per frame, so not really binomial
% [pspike pspikeCI]=binofit(events,possibleEvents);

fullRate=events./possibleEvents;
rate=reshape(sum(events)./sum(possibleEvents),numTypes,numPhaseBins); % combine repetitions
[repInds typeInds]=find(isnan(pow));
pow(unique(repInds),:)=[]; % remove reps with bad power estimates
if numRepeats>2
    rateSEM=reshape(std(events(1:end-1,:,:)./possibleEvents(1:end-1,:,:)),numTypes,numPhaseBins)/sqrt(numRepeats-1);
else
    rateSEM=nan(size(rate));
end

if size(pow,1)>1
    powSEM=std(pow)/sqrt(size(pow,1));
    pow=mean(pow);
else
    powSEM=nan(1,size(pow,2));
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
figure;
subplot(2,2,1); hold on; %p=plot([1:numPhaseBins]-.5,rate')
plot([0 numPhaseBins], [rate(1) rate(1)],'color',[1 1 1]); % to save tight axis chop
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
subplot(2,2,2); hold on
im=zeros([size(phaseDensity) 3]);
hues=rgb2hsv(colors);  % get colors to match jet
hues=repmat(hues(:,1)',numRepeats,1); % for each rep
hues=repmat(hues(:),1,numPhaseBins);  % for each phase bin
im(:,:,1)=hues; % hue
im(:,:,2)=1; % saturation
im(:,:,3)=phaseDensity/max(phaseDensity(:)); % value
rgbIm=hsv2rgb(im);
image(rgbIm);
axis([0 size(im,2) 0 size(im,1)]+.5);
ylabel(sweptParameter); set(gca,'YTickLabel',valNames,'YTick',size(im,1)*([1:length(vals)]-.5)/length(vals))
xlabel('phase');  set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)+.5);

subplot(2,2,3); plot(mean(rate'),'k','lineWidth',2); %legend({'Fo'})
xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('rate (f0)'); set(gca,'YTickLabel',[0:.1:1]*parameters.refreshRate,'YTick',[0:.1:1])
set(gca,'XLim',[1 length(vals)])

subplot(2,2,4); plot(pow,'k','lineWidth',2); hold on; %legend({'f1'})
plot([1:length(vals); 1:length(vals)],[pow; pow]+(powSEM'*[-1 1])','k')
xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('rate (f1)');
ylim=get(gca,'YLim'); yvals=[ ylim(1) mean(ylim) ylim(2)];set(gca,'YTickLabel',yvals,'YTick',yvals)
set(gca,'XLim',[1 length(vals)])

meanRate=(sum(spikes))/diff(spikeData.spikeTimestamps([1 end]));
isi=diff(spikeData.spikeTimestamps(thisCluster))*1000;
N=sum(isi<parameters.ISIviolationMS); percentN=100*N/length(isi);
%datestr(parameters.date,22)
infoString=sprintf('subj: %s  trial: %d\nHz: %d  viol: %2.2f%% (%d /%d)',parameters.subjectID,parameters.trialNumber,round(meanRate),percentN,N,length(isi));
disp(infoString);
text(1.2,ylim(2),infoString);

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
            %st=spikeData.frameIndices(sf,1); % time start index
            %et=spikeData.frameIndices(ef,2); % time stop index
            %times=find(spikes(st:et))/samplingRate;
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


end % end function
% ===============================================================================================