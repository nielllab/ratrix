function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have found a receptive field given the analysis and stimRecord
% maybe add confident pixels and bounded region support to RFestimators...
% then just use one of those in here

warning('this criterion doesn''t know to be worried about a short circular buffer set in @station/doTrials (roughly line 76) -- how architect?')

%init
details=[];
graduate=false;

% try to load the most recent analysis file and corresponding stimRecord
if ~strcmp(trialRecords(end).stimManagerClass,'whiteNoise')
    error('this crierion is only supported for spatial white noise')
else
    getRecordOfType='spatialWhiteNoise';
end

%Failure mode: if you get a RFestimate from a previous run... force it to be this session
trialsThisSession=sum([trialRecords.sessionNumber]==trialRecords(end).sessionNumber);
filter={'lastNTrials',trialsThisSession-1};
% sca
% keyboard
%filter={'dateRange',[now-100 now]}; % only for testing
[data success]=getPhysRecords(fullfile(c.dataRecordsPath,getID(subject)),filter,{'stim','analysis'},getRecordOfType);
if ~success
    warning('no analysis records found - will not be able to graduate');
else
    if any(data.analysisdata.cumulativeSTA(:)>1) && ~any(data.analysisdata.cumulativeSTA(:)>255)
        whiteVal=255;
        mean=whiteVal*data.stimulusDetails.meanLuminance;
        contrast=whiteVal*data.stimulusDetails.std;
        % our estimate is conservative, b/c we know there are cropped tail
        % of the gaussian, the "horns"
        %adjustedContrast=std(double(uint8((randn(1,10000)*contrast)+mean)))
    else
        error('what''s the white value of this data?')
        whiteVal=1;
        mean=whiteVal*data.stimulusDetails.meanLuminance;
        contrast=whiteVal*data.stimulusDetails.std;
    end

    [bigSpots sigSpots sigSpots3D]=getSignificantSTASpots(data.analysisdata.cumulativeSTA,data.analysisdata.cumulativeNumSpikes,mean,contrast,c.medianFilter,c.atLeastNPixels,c.alpha);
    if (nargout > 1)
        details.bigSpots=bigSpots;
        details.sigSpots=sigSpots;
        details.sigSpots3D = sigSpots3D;
    end
    
    if length(setdiff(unique(bigSpots),[0]))<= c.numberSpotsAllowed
        graduate=true;
    end
    
    
end

%play graduation tone

if graduate
    beep;
    waitsecs(.2);
    beep;
    waitsecs(.2);
    beep;
end