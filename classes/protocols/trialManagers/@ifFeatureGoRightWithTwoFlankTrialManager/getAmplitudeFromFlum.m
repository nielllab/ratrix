function [amplitude, overallMean, SNR, peak, trough] = getAmplitudeFromFlum(trialManager, measuredData, numRepeats, contrastMethod)

% returns a value for measured contrast, mean, snr, and amplitude


luminanceDataSegment = reshape(measuredData, numRepeats, numel(measuredData)/numRepeats)'

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
            amplitude = (amplitudeTop + amplitudeBottom)/2;
        else

            amplitude = (amplitudeTop + amplitudeBottom)/2;

            warning('amplitudes are too different to trust this method of calculating signal strength');
        end
    case 'std'
        amplitude=std(mn);

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
SNR= amplitude/stdError;
overallMean = mean(mn);
trough = min(mn);
peak = max(mn);



%     if plotOn
%         [m n] = meshgrid( 1: size(luminanceDataSegment, 2), 1: size(luminanceDataSegment, 1));
%         figure;
%
%         offset = 0.2;
%         scatter(n(:)+offset, luminanceDataSegment(:));
%
%         hold on;
%         if size(luminanceDataSegment,2)>1
%             noisePerPhase = std(luminanceDataSegment')./sqrt(numRepeats);
%         else
%             noisePerPhase = zeros(size(luminanceDataSegment,1),1);
%         end
%         top = (noisePerPhase/2);
%         bottom = -(noisePerPhase/2);
%         %         size(top)
%         %         size(bottom)
%         %         size(mn)
%         %         size([1:size(luminanceDataSegment,1)])
%         errorbar([1:size(luminanceDataSegment,1)], mn, top, bottom);
%
%         plot(mn, 'r');
%
%         hold off;
%
%     end
end


