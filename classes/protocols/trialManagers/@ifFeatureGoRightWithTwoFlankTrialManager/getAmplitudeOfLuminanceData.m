function [amplitude, SNR] = getAmplitudeOfLuminanceData(t, luminanceData, contrastMethod, plotOn)


%get rid of bad nans
% haveDate=find(~isnan(sum(luminanceData)));  % redundant with getScreenCalibrationData
% luminanceData=luminanceData(:,haveDate);

totalFrames = findTotalCalibrationFrames(t);
numOrientations = size(t.goRightOrientations,2); % how to
numPhases = size(t.phase,2);

numRepeats = size(luminanceData,2);

if size(luminanceData, 1) ~= totalFrames
    blackWhite = luminanceData(totalFrames+1: totalFrames + 2, : );
    luminanceData = luminanceData(1: totalFrames, : );
end

switch t.calib.method
    case 'sweepAllPhasesPerTargetOrientation'
        ss = [1:numPhases:totalFrames];
        ee = [ss(2:end)-1, totalFrames];
    otherwise
        error('not an acceptable method');
end

SNR = zeros(1, length(ss));
amplitude = zeros(1, length(ss));

for i = 1:length(ss) % for each chunk of luminance data
    luminanceDataSegment = luminanceData(ss(i): ee(i),:);
    if size(luminanceDataSegment,2)>1
        mn = mean(luminanceDataSegment');
    else
        mn = luminanceDataSegment;
    end

    switch contrastMethod
        case 'peakToPeak'
            indexMax = find(mn == max(mn)); % this code will go away when an alternative method surfaces
            indexMin = find(mn == min(mn));
            st = std(luminanceDataSegment(indexMax,:) - luminanceDataSegment(indexMin, :));
            stdError = st ./ sqrt(numRepeats);
            amplitudeTop = max(mn) - mean(mn);
            amplitudeBottom = mean(mn) - min(mn);
            
            if abs(amplitudeTop - amplitudeBottom) < 0.01
                amplitude(i) = (amplitudeTop + amplitudeBottom)/2;
            else

                amplitude(i) = (amplitudeTop + amplitudeBottom)/2;

                warning('amplitudes are too different to trust this method of calculating signal strength');
            end
        case 'std'
            amplitude(i)=std(mn);

            if numRepeats>1
                demeaned=luminanceDataSegment-repmat(mn', 1, numRepeats);
                st = max(std(demeaned')); %max causes you to overestimate noise, underestimate SNR
                stdError = st ./ sqrt(numRepeats);
            else
                stdError=NaN;
            end

        otherwise
            contrastMethod
            error ('unsupported contrastMethod')
    end
    SNR(i) = (amplitude(i))/stdError;

    if plotOn
        [m n] = meshgrid( 1: size(luminanceDataSegment, 2), 1: size(luminanceDataSegment, 1));
        figure;

        offset = 0.2;
        scatter(n(:)+offset, luminanceDataSegment(:));

        hold on;
        if size(luminanceDataSegment,2)>1
            noisePerPhase = std(luminanceDataSegment')./sqrt(numRepeats);
        else
            noisePerPhase = zeros(size(luminanceDataSegment,1),1);
        end
        top = (noisePerPhase/2);
        bottom = -(noisePerPhase/2);
        %         size(top)
        %         size(bottom)
        %         size(mn)
        %         size([1:size(luminanceDataSegment,1)])
        errorbar([1:size(luminanceDataSegment,1)], mn, top, bottom);

        plot(mn, 'r');

        hold off;

    end
end

