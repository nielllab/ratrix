function seeCalibrationResults(t)

totalFrames = findTotalCalibrationFrames(t);
numOrientations = size(t.goRightOrientations,2);
numPhases = size(t.phase,2);

luminanceData=t.calib.rawData;
validationData=t.calib.rawValidationData;

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

figure;
hold on;

for i = 1:length(ss) % for each chunk of luminance data
    luminanceDataSegment =  luminanceData(ss(i): ee(i),:);
    validationDataSegment= validationData(ss(i): ee(i),:);

    if size(luminanceDataSegment,2)>1
        mn = mean(luminanceDataSegment');
        Vmn = mean(validationDataSegment');
    else
        mn = luminanceDataSegment;
        Vmn = validationDataSegment;
    end

    %SNR(i) = amplitude(i))/stdError;


    [m n] = meshgrid( 1: size(luminanceDataSegment, 2), 1: size(luminanceDataSegment, 1));

    offset = 0.2;
    scatter(n(:)+offset, luminanceDataSegment(:),'b');
    scatter(n(:)+offset, validationDataSegment(:),'r');

    if size(luminanceDataSegment,2)>1
        noisePerPhase = std(luminanceDataSegment')./sqrt(numRepeats);
        validationNoisePerPhase = std(validationDataSegment')./sqrt(numRepeats);
    else
        noisePerPhase = zeros(size(luminanceDataSegment,1),1);
        validationNoisePerPhase =zeros(size(luminanceDataSegment,1),1);
    end

    top = (noisePerPhase/2);
    bottom = -(noisePerPhase/2);
    Vtop = (validationNoisePerPhase/2);
    Vbottom = -(validationNoisePerPhase/2);
    %         size(top)
    %         size(bottom)
    %         size(mn)
    %         size([1:size(luminanceDataSegment,1)])
    errorbar([1:size(luminanceDataSegment,1)], mn, top, bottom,'b');
    errorbar([1:size(luminanceDataSegment,1)], mn, Vtop, Vbottom,'r');

    if i==1
        plot(mn, 'b');
        plot(Vmn, 'r');
    else
        plot(mn, 'k');
        plot(Vmn, 'k');
    end

end

