function [spikes spikeWaveforms photoDiode]=getSpikesFromPhotodiode(photoDiodeData,photoDiodeDataTimes,frameIndices,samplingRate)
% get spikes from neuralData and neuralDataTimes, and given frameTimes
spikeWaveforms=[];
photoDiode = getPhotoDiode(photoDiodeData,frameIndices);
% now calculate spikes in each frame
spikes = [];
if isempty(photoDiode)
    % that means frameIndices was empty
    return;
end

method='logistic'; %'threshold','logistic'
switch method
    case 'threshold'
        squaredVals = (photoDiode).^2;  % rescale so zero is smallest value... a bit funny
        % now sort the values, and choose the first 5% to show threshold
        %fractionBaselineSpikes=0.05; % chance of a single spike on a frame % not used
        fractionStimSpikes=0.1;      % chance of any spikes on a frame caused by stim
        maxNumStimSpikes=1;         % per frame
        valuesToCalcThreshold = sort(squaredVals,'descend');
        pivot = ceil(length(squaredVals) * fractionStimSpikes);
        threshold = (valuesToCalcThreshold(pivot) + valuesToCalcThreshold(pivot+1)) / 2;
        threshold=25000;
        %numSpikes=ceil(maxNumStimSpikes*(squaredVals-threshold)/(valuesToCalcThreshold(1)-threshold));
        
        % for each frame, see if it passes a threshold
        for i=1:size(frameIndices,1)
            if squaredVals(i) > threshold
                numSpikes=ceil(maxNumStimSpikes*(squaredVals(i)-threshold)/(valuesToCalcThreshold(1)-threshold));
                numSpikes=min(numSpikes,maxNumStimSpikes);
                randInds=randperm(diff(frameIndices(i,:)))+frameIndices(i,1); % randomly order the candidate locations
                spikes=[spikes;randInds(1:numSpikes)'];  % put N spikes at random locations (doesn't respect refractory)
            end
        end
    case 'logistic'
        %having dynamic params is usefull if you only have one chunk,
        %but dangerous for multiple chunks
        u=250; %mean
        B=30;   %slope
        pSpike=1./(1+exp((u-photoDiode)/B));
        
        if 0 % inspect parmater range for this luminance data
            figure;
            subplot(2,1,1); hist(photoDiode,100)
            x=linspace(min(photoDiode(:)),max(photoDiode(:)),100);
            subplot(2,1,2); plot(x,1./(1+exp((u-x')./B)));
        end
        for i=1:size(frameIndices,1)
            if pSpike(i) > rand % only 1 spike per frame at most
                randInd=ceil(rand*diff(frameIndices(i,:)))+frameIndices(i,1); % randomly order the candidate locations
                spikes=[spikes;randInd];  % put a spikes at a random locations (doesn't respect refractory)
            end
        end     
end

pre=floor(.58*samplingRate/1000);
post=floor(1.0*samplingRate/1000); % hard-coded 1.5ms and 0.5ms for now... matches the 64 samps made by osort
for j=1:length(spikes)
    if (spikes(j)+post)<length(photoDiodeData) && (spikes(j)-pre)>0
        try
            spikeWaveforms=[spikeWaveforms; photoDiodeData(spikes(j)-pre:spikes(j)+post)'];
        catch
            size(spikeWaveforms)
            length(photoDiodeData)
            spikes(j)-pre
            spikes(j)+post
            error('waveform prob')
        end
    elseif isempty(spikeWaveforms) %make noise if first
        spikeWaveforms=rand(1,length(pre:post));
    else  %copy previous waveform if at end
        
        %sometimes the spike goes off the end of the samples
        %available (tail is off the chunk boundary)
        %if so, add repeat the prev waveform
        spikeWaveforms=[spikeWaveforms; spikeWaveforms(end,:)];
    end
end
disp('got spikes from photo diode');

end % end function
% ===============================================================================================

