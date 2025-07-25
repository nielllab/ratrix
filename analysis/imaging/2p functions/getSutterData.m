%%%  get sutter data
%%%  workaround to get acanImage data into our current SBX pipeline 
% Get File Path for tiff Image
if ~isfield(Opt,'fTif')
    %Get tif file input
    [Opt.fTif, Opt.pTif] = uigetfile({'*.tif'},'.tif file');
end

%Get Image acquisition frame rate
if Opt.Resample == 0
    Img_Info = imfinfo(fullfile(Opt.pTif,Opt.fTif));
    trash = evalc(Img_Info(1).ImageDescription);
    framerate = state.acq.frameRate;
    dt = 1/framerate;
else
    dt = Opt.Resample_dt;
    framerate = 1/dt;
end

%Read in ttl file if used
Opt.ttl_file = 1;
if Opt.ttl_file
    % Get File Path for ttl Image
    if ~isfield(Opt,'fTTL')
        %Get tif file input
        [Opt.fTTL, Opt.pTTL] = uigetfile('*.mat','ttl file');
    end
    
    [stimPulse, framePulse] = getTTL(fullfile(Opt.pTTL,Opt.fTTL));
    
    % number of frames per cycle
    cycLength = mean(diff(stimPulse))/dt;
    % number of frames in window around each cycle. min of 4 secs, or actual cycle length + 2
    cycWindow = round(max(4/dt,cycLength));
    
    %Plot the Cycle Time
    figure
    plot(diff(stimPulse)); title('stimPulse cycle time');hold on
    plot(1:length(stimPulse),ones(size(stimPulse))*cycLength*dt); ylabel('secs');xlabel('stim #')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    startTime = round(stimPulse(1)/dt)-1;
else
    stimPulse = []; framePulse = []; startTime = 1;
end

%% Performs Image registration and resample at requested frame rate
% returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
% greenframe = mean fluorescence image
if Opt.NumChannels == 2
    [dfofInterp, dtRaw, greenframe, Rigid, Rotation] = get2colordata(fullfile(Opt.pTif,Opt.fTif),dt,Opt);
else
    [dfofInterp, dtRaw, greenframe] = get2pdata(fullfile(Opt.pTif,Opt.fTif),dt,Opt);
end

%Reduce Aligned stack to include only the stimulus times
dfofInterp = dfofInterp(:,:,startTime:end);

