function [dfofInterp, im_dt, MeanGrnChannel, Rigid, Rotation] = get2colordata(fname, dt, Opt)
if Opt.SaveFigs
    psfile = Opt.psfile;
end
% Display Movies for Non-aligned image sequences for both channels & save
% the movie if it does not exist already
if Opt.MakeMov
    MakeMovieFromTiff(fname);
end

% Performs Image registration for both channels
[imgAll, Rigid, Rotation] = readAlign2color(fname,Opt);

%Replace Inf Values with NaN
for iFrame = 1:size(imgAll,3)
    for iChannel = 1:2
       frm = imgAll(:,:,iFrame,iChannel);
       frm(isinf(frm(:))) = NaN;
       imgAll(:,:,iFrame,iChannel) = frm;
    end
end

%Get Info
Img_Info = imfinfo(fname);
trash = evalc(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;
im_dt = 1/framerate;

%Calculate the mean of each channel
MeanRedChannel = squeeze(nanmean(imgAll(:,:,:,2),3));
MeanGrnChannel = squeeze(nanmean(imgAll(:,:,:,1),3));

%%
disp('Doing percentile for delta-f/f calculations');
for iChannel = 1:2
    %Separate 4D array into a 3D array
    Aligned_Seq = squeeze(imgAll(:,:,:,iChannel));
    nframes = size(Aligned_Seq,3);
    
    %Calculate the 10th percentile of a representative sample 
    m{iChannel} = prctile(Aligned_Seq(:,:,40:40:end),10,3);

    %Display the figure
    figure
    imagesc(m{iChannel});
    title(sprintf('Mean 10th percentile of Channel %u',iChannel))
    colormap(gray)
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    dfof = zeros(size(Aligned_Seq));
    if iChannel == 1 %i.e. the green channel
        for iFrame = 1:nframes
            dfof(:,:,iFrame)=(Aligned_Seq(:,:,iFrame)-m{iChannel})./m{iChannel};
        end
        
        %Interpolate to desired frame rate if different than acquisition rate
        if im_dt ~= dt
            dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
            dfofInterp = shiftdim(dfofInterp,1);
        else
            dfofInterp = dfof;
        end
    end
end

%Replace Inf Values with NaN
for iFrame = 1:size(dfofInterp,3)
    frm = dfofInterp(:,:,iFrame);
    frm(isinf(frm(:))) = NaN;
    dfofInterp(:,:,iFrame) = frm; 
end

