function goodEnough = qualityCheck(trialManager, luminanceData, calibrationPhase)

haveData=find(sum(~isnan(luminanceData)));
numRecordedSoFar = length(haveData);
numRecordedSoFar

goodEnough = 0;

switch calibrationPhase
    case 'homogenousIntensity'
        goodEnough = 1;  %only do it once
    case 'patterenedIntensity'

        %using number of repetitions to limit
        maxAllowed = 9;
        if numRecordedSoFar >= maxAllowed-1
            goodEnough = 1;
        end

        %alternately stop if sufficient SNR
        contrastMethod='std';
        [amplitude, SNR] = getAmplitudeOfLuminanceData(trialManager, luminanceData(:,haveData), contrastMethod, 1)
        requiredSNR=60;
        if all(SNR>requiredSNR)
            goodEnough = 1;
        end

    otherwise
        error('bad phase')
end


% goodEnough = 1;  %only do it once