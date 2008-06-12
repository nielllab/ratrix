function t=fillLUT(t,method,linearizedRange,plotOn)
%function s=fillLUT(s,method,linearizedRange [,plotOn]);
%stim=fillLUT(stim,'linearizedDefault');
%note: this calculates and fits gamma with finminsearch each time
%might want a fast way to load the default which is the same each time

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
grayColors= [ramp;ramp;ramp]';

if ~exist('plotOn','var')
    plotOn=0;
end

useUncorrected=0;

switch method
    case 'mostRecentLinearized'

        method
        error('that method for getting a LUT is not defined');
    case 'linearizedDefault'

        %WARNING:  need to get gamma from measurements of ratrix workstation with NEC monitor and new graphics card


        LUTBitDepth=8;

        %sample from lower left of triniton, pmm 070106
        %sent=       [0      0.0667    0.1333    0.2000    0.2667    0.3333    0.4000    0.4667    0.5333  0.6000    0.6667    0.7333    0.8000    0.8667    0.9333    1.0000];
        %measured_R= [0.0052 0.0058    0.0068    0.0089    0.0121    0.0167    0.0228    0.0304    0.0398  0.0510    0.065     0.080     0.097     0.117     0.139     0.1645];
        %measured_G= [0.0052 0.0053    0.0057    0.0067    0.0085    0.0113    0.0154    0.0208    0.0278  0.036     0.046     0.059     0.073     0.089     0.107     0.128 ];
        %measured_B= [0.0052 0.0055    0.0065    0.0077    0.0102    0.0137    0.0185    0.0246    0.0325  0.042     0.053     0.065     0.081     0.098     0.116     0.138];

        %sample values from FE992_LM_Tests2_070111.smr: (actually logged them: pmm 070403) -used physiology graphic card
        sent=       [0      0.0667    0.1333    0.2000    0.2667    0.3333    0.4000    0.4667    0.5333  0.6000    0.6667    0.7333    0.8000    0.8667    0.9333    1.0000];
        measured_R= [0.0034 0.0046    0.0077    0.0128    0.0206    0.0309    0.0435    0.0595    0.0782  0.1005    0.1260    0.1555    0.189     0.227     0.268     0.314 ];
        measured_G= [0.0042 0.0053    0.0073    0.0110    0.0167    0.0245    0.0345    0.047     0.063   0.081     0.103     0.127     0.156     0.187     0.222     0.260 ];
        measured_B= [0.0042 0.0051    0.0072    0.0105    0.0160    0.0235    0.033     0.0445    0.0595  0.077     0.097     0.120     0.1465    0.176     0.208     0.244 ];
        
        numColors = size(sent,2);
        sensorValues = [measured_R, measured_G, measured_B];
        sensorRange = [min(sensorValues), max(sensorValues)];
        gamutRange = [min(sent), max(sent)];
        
        t.calib.RGBgamutValues = ([ramp; ramp; ramp]);
        t.calib.RGBsensorValues = reshape(sensorValues, 3,numColors);
        t.calib.sensorRange = sensorRange;
        t.calib.gamutRange = gamutRange;
        %oldCLUT = Screen('LoadNormalizedGammaTable', w, linearizedCLUT,1);
    case 'useThisMonitorsUncorrectedGamma'

        %maybe ask for red / green / blue gun only
        uncorrected=grayColors;
        useUncorrected=1; 
    case 'calibrateNow'


        %define inputs
        sensorMode = 'daq'; % 'spyder' is the other option
        trialManager=t;
        screenNum=[];
        screenType = 'CRT';
        patchRect=[0 0 1 1];
        numFramesPerValue=int8(30);
        numInterValueFrames=int8(30);
        clut=grayColors; % comperable to repmat(linspace(0,1,2^8)',1,3);
        stim=[];
        positionFrame=[];
        interValueRGB= uint8(zeros(1,1,3));%uint8(round(2^8/2)*ones(1,1,3));
        background=[];
        parallelPortAddress=[];
        framePulseCode=[];
        
        %make stim
        sampleBitDepth=4;
        numColors=2^sampleBitDepth; 
        
        maxColorID=2^8-1; %numColors-1; %ptb: accepts 255 as white, this could change one day
        fraction=(maxColorID)/(numColors-1);
        ramp=[0:fraction:maxColorID]; %ramp=[0:fraction:1];
        dark = zeros(size(ramp));
        sampleColors = [ramp dark dark; ...
                        dark ramp dark; ...
                        dark dark ramp];
        stim = reshape(sampleColors,1,1,3,numColors*3);  %confirm its good
        stim = uint8(stim);
        %%%%%%%%%%%%%%%%%%%%%%%
       
        
        calibrationPhase='homogenousIntensity'; 
        [luminanceData, details] = getScreenCalibrationData(trialManager,sensorMode,calibrationPhase,screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode);

        measured_R=luminanceData(0*numColors+[1:numColors])
        measured_G=luminanceData(1*numColors+[1:numColors])
        measured_B=luminanceData(2*numColors+[1:numColors])
        
        sent = ramp';       
        sensorRange = [min(luminanceData), max(luminanceData)];
        gamutRange = [min(sent), max(sent)];
        
        t.calib.RGBgamutValues = ([ramp; ramp; ramp]);
        t.calib.RGBsensorValues = reshape(luminanceData, 3,numColors);
        t.calib.sensorRange = sensorRange;
        t.calib.gamutRange = gamutRange;
        %[measured_R measured_G measured_B] measureRGBscale()
        

    otherwise
        method
        error('that method for getting a LUT is not defined');
end

if useUncorrected
    linearizedCLUT=uncorrected;
else
    linearizedCLUT=zeros(2^LUTBitDepth,3);
    if plotOn
        subplot([311]);
    end
    [linearizedCLUT(:,1) g.R]=fitGammaAndReturnLinearized(sent, measured_R, linearizedRange, sensorRange, gamutRange, 2^LUTBitDepth,plotOn);

    if plotOn
        subplot([312]);
    end
    [linearizedCLUT(:,2) g.G]=fitGammaAndReturnLinearized(sent, measured_G, linearizedRange, sensorRange, gamutRange, 2^LUTBitDepth,plotOn);

    if plotOn
        subplot([313]);
    end
    [linearizedCLUT(:,3) g.B]=fitGammaAndReturnLinearized(sent, measured_B, linearizedRange, sensorRange, gamutRange, 2^LUTBitDepth,plotOn);
end

t.LUT=linearizedCLUT;
