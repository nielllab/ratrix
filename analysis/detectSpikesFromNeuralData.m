function [spikes spikeWaveforms spikeTimestamps]= detectSpikesFromNeuralData(neuralData,...
    neuralDataTimes,spikeDetectionParams)
% Get spikes using some spike detection method - plugin to Osort, WaveClus, KlustaKwik
% Outputs:
%   spikes - a vector of indices into neuralData that indicate where a spike happened
%   spikeWaveforms - a matrix containing a 4x32 waveform for each spike
%   spikeTimestamps - timestamp of each spike


spikes=[];


% default inputs for all methods

if ~isfield(spikeDetectionParams, 'ISIviolationMS')
    spikeDetectionParams.ISIviolationMS=2; % used for plots and reports of violations
end
% =====================================================================================================================
% SPIKE DETECTION

% handle spike detection
% the spikeDetectionParams struct must contain a 'method' field
if isfield(spikeDetectionParams, 'method')
    spikeDetectionMethod = spikeDetectionParams.method;
else
    error('must specify a method for spike detection');
end

% switch on the detection method
switch upper(spikeDetectionMethod)
    case 'OSORT'
        % spikeDetectionParams should look like this:
        %   method - osort
        %   samplingFreq - sampling frequency of raw signal
        %   Hd - (optional) bandpass frequencies
        %   nrNoiseTraces - (optional) number of noise traces as a parameter to osort's extractSpikes
        %   detectionMethod - (optional) spike detection method to use as a parameter to osort's extractSpikes
        %   extractionThreshold - (optional) threshold for extraction as a parameter to osort's extractSpikes
        %   peakAlignMethod - (optional) peak alignment method to use as a parameter to osort's extractSpikes
        %   alignMethod - (optional) align method to use if we are using "find peak" peakAlignMethod
        %   prewhiten - (optional) whether or not to prewhiten
        %   limit - (optional) the maximal absolute valid value (bigger/smaller than this is treated as out of range)
        
        % ============================================================================================================
        % from Osort's extractSpikes
        %extractionThreshold default is 5
        %params.nrNoiseTraces: 0 if no noise should be estimated
        %               >0 : # of noise traces to be used to estimate autocorr of
        %               noise, returned in variable autocorr
        %
        %
        %params.detectionMethod: 1 -> from power signal, 2 threshold positive, 3 threshold negative, 4 threshold abs, 5 wavelet
        %params.detectionParams: depends on detectionMethod.
        %       if detectionmethod==1, detectionParams.kernelSize
        %       if detectionmethod==4, detectionParams.scaleRanges (the range of scales (2 values))
        %                              detectionParams.waveletName (which wavelet to use)
        %
        %params.peakAlignMethod: 1-> find peak, 2->none, 3->peak of power signal, 4->peak of MTEO signal.
        %params.alignMethod: 1=pos, 2=neg, 3=mix (order if both peaks are sig,otherwise max) - only used if peakAlignMethod==1
        % ============================================================================================================
        
        % check params
        if ~isfield(spikeDetectionParams, 'samplingFreq')
            error('samplingFreq must be defined');
        end
        if isfield(spikeDetectionParams, 'Hd')
            Hd = spikeDetectionParams.Hd;
        else
            % default to bandpass 300Hz - 3000Hz
            n = 4;
            Wn = [300 3000]/(spikeDetectionParams.samplingFreq/2);
            [b,a] = butter(n,Wn);
            Hd=[];
            Hd{1}=b;
            Hd{2}=a;
        end
        if ~isfield(spikeDetectionParams, 'nrNoiseTraces')
            warning('nrNoiseTraces not defined - using default value of 0');
        end
        if ~isfield(spikeDetectionParams, 'detectionMethod')
            spikeDetectionParams.detectionMethod=1;
            spikeDetectionParams.kernelSize=25;
            warning('detectionMethod not defined - using default value of 1; also overwriting kernelSize param if set');
        end
        if ~isfield(spikeDetectionParams, 'extractionThreshold')
            spikeDetectionParams.extractionThreshold = 5;
            warning('extractionThreshold not defined - using default value of 5');
        end
        if ~isfield(spikeDetectionParams, 'peakAlignMethod')
            spikeDetectionParams.peakAlignMethod=1;
            warning('peakAlignMethod not defined - using default value of 1');
        end
        if ~isfield(spikeDetectionParams, 'prewhiten')
            spikeDetectionParams.prewhiten = false;
            warning('prewhiten not defined - using default value of false');
        end
        if ~isfield(spikeDetectionParams, 'limit')
            spikeDetectionParams.limit = 2000;
            warning('limit not defined - using default value of 2000');
        end
        % check that correct params exist for given detectionMethods
        if spikeDetectionParams.detectionMethod==1
            if ~isfield(spikeDetectionParams, 'kernelSize')
                warning('kernelSize not defined - using default value of 25');
            end
        elseif spikeDetectionParams.detectionMethod==5
            if ~isfield(spikeDetectionParams, 'scaleRanges')
                warning('scaleRanges not defined - using default value of [0.5 1.0]');
                spikeDetectionParams.scaleRanges = [0.5 1.0];
            end
            if ~isfield(spikeDetectionParams, 'waveletName')
                warning('waveletName not defined - using default value of ''haar''');
                spikeDetectionParams.waveletName = 'haar';
            end
        end
        
        if spikeDetectionParams.peakAlignMethod==1
            if ~isfield(spikeDetectionParams, 'alignMethod')
                warning('alignMethod not defined - using default value of 1');
                spikeDetectionParams.alignMethod = 1;
            end
        end
        
        channelIDUsedForDetection=1;  % the first be default... never used anything besides this so far
        
        % call to Osort spike detection
        [rawMean, filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestampIndices, runStd2, upperlim, noiseTraces] = ...
            extractSpikes(neuralData, Hd, spikeDetectionParams );
        spikeTimestamps = neuralDataTimes(spikeTimestampIndices);
        spikes=spikeTimestampIndices';
        
    case 'FILTEREDTHRESH'
        %         spikeDetectionParams.method = 'filteredThresh'
        %         spikeDetectionParams.freqLowHi = [200 10000];
        %         spikeDetectionParams.threshHoldVolts = [-1.2 Inf];
        %         spikeDetectionParams.waveformWindowMs= 1.5;
        %         spikeDetectionParams.peakWindowMs= 0.5;
        %         spikeDetectionParams.alignMethod = 'atPeak'; %atCrossing
        %         spikeDetectionParams.peakAlignment = 'filtered' % 'raw'
        %         spikeDetectionParams.returnedSpikes = 'filtered' % 'raw'
        %         spikeDetectionParams.spkBeforeAfterMS=[0.6 0.975];
        %         spikeDetectionParams.bottomTopCrossingRate=[];
        
        %   NOT USED
        %         spikeDetectionParams.maxDbUnmasked = [-1.2 Inf];  % this  is not used
        
        if ~isfield(spikeDetectionParams, 'samplingFreq')
            error('samplingFreq must be a field in spikeDetectionParams');
        end
        if ~isfield(spikeDetectionParams, 'freqLowHi')
            spikeDetectionParams.freqLowHi=[200 10000];
            warning('freqLowHi not defined - using default value of [200 10000]');
        end
        if ~isfield(spikeDetectionParams, 'threshHoldVolts')
            if ~isfield(spikeDetectionParams, 'bottomTopCrossingRate') || isempty(spikeDetectionParams.bottomTopCrossingRate)
                spikeDetectionParams.threshHoldVolts = [-1.2 Inf];
                warning('thresholdVolts not defined - using default value of [-1.2 Inf]');
            else
                spikeDetectionParams.threshHoldVolts = []; % will be determined from rate
            end
        end
        if ~isfield(spikeDetectionParams, 'waveformWindowMs')
            spikeDetectionParams.waveformWindowMs=1.5;
            warning('waveformWindowMs not defined - using default value of 1.5');
        end
        if ~isfield(spikeDetectionParams, 'peakWindowMs')
            spikeDetectionParams.peakWindowMs=0.5;
            warning('peakWindowMs not defined - using default value of 0.5');
        end
        if ~isfield(spikeDetectionParams, 'alignMethod')
            spikeDetectionParams.alignMethod='atPeak';
            warning('alignMethod not defined - using default value of ''atPeak''');
        end
        if ~isfield(spikeDetectionParams, 'peakAlignment')
            spikeDetectionParams.peakAlignment='filtered';
            warning('peakAlignment not defined - using default value of ''filtered''');
        end
        if ~isfield(spikeDetectionParams, 'returnedSpikes')
            spikeDetectionParams.returnedSpikes = 'filtered';
            warning('returnedSpikes not defined - using default value of ''filtered''');
        end
        
        if isfield(spikeDetectionParams, 'bottomTopCrossingRate') && ~isempty(spikeDetectionParams.bottomTopCrossingRate)
            if ~isempty(spikeDetectionParams.threshHoldVolts)
                threshHoldVolts=spikeDetectionParams.threshHoldVolts
                bottomTopCrossingRate=spikeDetectionParams.bottomTopCrossingRate
                error('can''t define threshold and crossing rate at the same time')
            end
            doThreshFromRate=true;
            bottomRate=spikeDetectionParams.bottomTopCrossingRate(1);
            topRate=spikeDetectionParams.bottomTopCrossingRate(2);
        else
            loThresh=spikeDetectionParams.threshHoldVolts(1);
            hiThresh=spikeDetectionParams.threshHoldVolts(2);
            doThreshFromRate=false;
        end
        
        N=min(spikeDetectionParams.samplingFreq/200,floor(size(neuralData,1)/3)); %how choose filter orders? one extreme bound: Data must have length more than 3 times filter order.
        [b,a]=fir1(N,2*spikeDetectionParams.freqLowHi/spikeDetectionParams.samplingFreq);
        filteredSignal=filtfilt(b,a,neuralData);
        
        if doThreshFromRate
            % get threshold from desired rate of crossing
            [loThresh hiThresh] = getThreshForDesiredRate(neuralDataTimes,filteredSignal,bottomRate,topRate);
            disp(sprintf('spikeDetectionParams.threshHoldVolts=[%2.3f %2.3f]  %%fit from desired rate',loThresh,hiThresh))
            spikeDetectionParams.threshHoldVolts=[loThresh hiThresh]; % for later display
        end
        
        spkBeforeAfterMS=[spikeDetectionParams.peakWindowMs spikeDetectionParams.waveformWindowMs-spikeDetectionParams.peakWindowMs];
        spkSampsBeforeAfter=round(spikeDetectionParams.samplingFreq*spkBeforeAfterMS/1000);
        %spikeDetectionParams.spkBeforeAfterMS=[0.6 0.975];
        %spkSampsBeforeAfter=[24 39] % at 40000 like default osort:
        %rawTraceLength=64; beforePeak=24; afterPeak=39;
        
        tops=[false; diff(filteredSignal(:,1)>hiThresh)>0]; % only using the first listed channel to detect
        %        tops=[false(1,size(neuralData));  diff(filteredSignal>hiThresh)>0];  % spikes on all channels
        topCrossings=   neuralDataTimes(tops);
        bottoms=[false; diff(filteredSignal(:,1)<loThresh)>0];
        bottomCrossings=neuralDataTimes(bottoms);
        
        [tops    uTops    topTimes]   =extractPeakAligned(tops,1,spikeDetectionParams.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData);
        [bottoms uBottoms bottomTimes]=extractPeakAligned(bottoms,-1,spikeDetectionParams.samplingFreq,spkSampsBeforeAfter,filteredSignal,neuralData);
        
        %maybe sort the order...
        spikes=[topTimes;bottomTimes];
        spikeTimestamps=neuralDataTimes(spikes);
        spikeWaveforms=[tops;bottoms];
        
        if doThreshFromRate
            dur=neuralDataTimes(end)-neuralDataTimes(1);
            disp(sprintf('the topRate goal was %2.2fHz but got: %2.2fHz ',topRate,length(topTimes)/dur))
            disp(sprintf('bottomRate  goal was %2.2fHz but got: %2.2fHz ',bottomRate,length(bottomTimes)/dur))
        end
        
    otherwise
        error('unsupported spike detection method');
end

% plotting to show results (for testing);   probably these tools should be
% supported in a gui outside this function...
if 0
    spikePoints=ones(1,length(spikeTimestamps));
    subplot(2,1,1)
    plot(neuralDataTimes,neuralData);
    title('rawSignal and spikes');
    hold on
    size(spikes)
    size(neuralData)
    plot(neuralDataTimes,spikes.*neuralData,'.r');
    hold off
    subplot(2,1,2)
    plot(neuralDataTimes,filteredSignal);
    title('filteredSignal and spikes');
    hold on
    plot(neuralDataTimes,spikes.*filteredSignal,'.r');
    hold off
end

% output of spike detection should be spikes (indices), spikeTimestamps, and spikeWaveforms
% END SPIKE DETECTION






end % end function


function [group uGroup groupPts]=extractPeakAligned(group,flip,sampRate,spkSampsBeforeAfter,filt,data)
maxMSforPeakAfterThreshCrossing=.5; %this is equivalent to a lockout, because all peaks closer than this will be called one peak, so you'd miss IFI's smaller than this.
% we should check for this by checking if we said there were multiple spikes at the same time.
% but note this is ONLY a consequence of peak alignment!  if aligned on thresh crossings, no lockout necessary (tho high frequency noise riding on the spike can cause it
% to cross threshold multiple times, causing you to count it multiple times w/timeshift).
% our remaining problem is if the decaying portion of the spike has high freq noise that causes it to recross thresh and get counted again, so need to look in past to see
% if we are on the tail of a previous spk -- but this should get clustered away anyway because there's no spike-like peak in the immediate period following the crossing.
% ie the peak is in the past, so it's a different shape, therefore a different cluster
maxPeakSamps=round(sampRate*maxMSforPeakAfterThreshCrossing/1000);

spkLength=sum(spkSampsBeforeAfter)+1;
spkPts=[-spkSampsBeforeAfter(1):spkSampsBeforeAfter(2)];
%spkPts=(1:spkLength)-ceil(spkLength/2); % centered

group=find(group)';
groupPts=group((group+spkLength-1)<length(filt) & group-ceil(spkLength/2)>0)';
group=data(repmat(groupPts,1,maxPeakSamps)+repmat(0:maxPeakSamps-1,length(groupPts),1)); %use (sharper) unfiltered peaks!

[junk loc]=max(flip*group,[],2);
groupPts=((loc-1)+groupPts);
groupPts=groupPts((groupPts+floor(spkLength/2))<length(filt));



group= filt(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
uGroup=data(repmat(groupPts,1,spkLength)+repmat(spkPts,length(groupPts),1));
uGroup=uGroup-repmat(mean(uGroup,2),1,spkLength);
end

function [loThresh hiThresh] = getThreshForDesiredRate(neuralDataTimes,filtV,bottomRate,topRate)

numSteps=50;
dRate=5000; % down sampled rate
secDur=neuralDataTimes(end)-neuralDataTimes(1);
dTimes=linspace(neuralDataTimes(1),neuralDataTimes(end),secDur*dRate);
whichChan=1;  % only detect off of the first listed chan
dFilt=interp1(neuralDataTimes,filtV(:,whichChan),dTimes,'linear'); %without downsampling, the following line runs out of memory even for singles when > ~15s @40kHz

mm=minmax(filtV);
if any(ismember(mm,[0 -999 999]))
    mm
    error('filtered voltages should always minmax non-zero, and not expected to be -999 or 999')
end

if mm(1)>0
    mm
    error('expected some negative values in filtered min')
end

if mm(2)<0
    mm
    error('expected some posiitve values in filtered max')
end

% loop through: coarse low, coarse high, fine low, fine high
for w=[mm -999 999]
    switch w
        case -999 % 2nd pass fine grain low
            stepSz=abs(mm(1))/numSteps;
            v=linspace(loThresh-stepSz,loThresh+stepSz,numSteps)';
        case 999  % 2nd pass fine grain high
            stepSz=abs(mm(2))/numSteps;
            v=linspace(hiThresh+stepSz,hiThresh-stepSz,numSteps)';
        otherwise % first pass coarse full rage: [min 0] and [max 0]
            v=linspace(w,0,numSteps)';
    end
    
    crossHz=sum(diff((w*repmat(dFilt,numSteps,1))>(w*repmat(single(v),1,length(dFilt))),1,2)>0,2)/secDur;
    if w>0
        hiThresh=v(find(crossHz>topRate,1,'first'));
        if isempty(hiThresh)
            hiThresh=0;
        end
    elseif w<0
        loThresh=v(find(crossHz>bottomRate,1,'first'));
        if isempty(loThresh)
            loThresh=0;
        end
    end
end

end