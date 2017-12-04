function MakeMovieFromTiff(fname)

%Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info)/2;
trash = evalc(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;

%Preallocate 3D arrays 
RedChannel = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);
GrnChannel = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);

%Read in frames
for iFrame = 1:nframes
    GrnChannel(:,:,iFrame) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
    RedChannel(:,:,iFrame) = double(imread(fname,(iFrame-1)*2+2)); %Red channel
end

%Movie File Names
GrnMovieFile = sprintf('%sNonAlignedGreenChannel.mp4',fname(1:end-4));
RedMovieFile = sprintf('%sNonAlignedRedChannel.mp4',fname(1:end-4));

%Calculate Range for scaled image display
sm = floor(nframes/4) - 1;
GrnRange = zeros(1,2);
RedRange = zeros(1,2);
for iFrame = 1:sm:nframes
    tmp = GrnChannel(:,:,iFrame);
    GrnRange(1) = GrnRange(1) + prctile(tmp(:),2);
    GrnRange(2) = GrnRange(2) + prctile(tmp(:),98);
    
    tmp = RedChannel(:,:,iFrame);
    RedRange(1) = RedRange(1) + prctile(tmp(:),2);
    RedRange(2) = RedRange(2) + prctile(tmp(:),98);
end

GrnRange = GrnRange./4;
RedRange = RedRange./4;

%% Display Green Channel Movie and Save if file doesn't exist already
GrnVideo = VideoWriter(GrnMovieFile);
GrnVideo.FrameRate = framerate*10;
GrnVideo.Quality = 100;
open(GrnVideo);
MakeMov = 1;

GrnFig = figure;
colormap pink
for iFrame = 1:nframes
    imagesc(GrnChannel(:,:,iFrame),GrnRange);
    sTitle = sprintf('Non-Aligned Green Channel: Frame %u',iFrame);
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    frame = getframe;
    writeVideo(GrnVideo,frame);
end

%Close Video
close(GrnVideo);
close(GrnFig);
%% Display Red Channel Movie and Save if file doesn't exist already
RedVideo = VideoWriter(RedMovieFile);
RedVideo.FrameRate = framerate*10;
RedVideo.Quality = 100;
open(RedVideo);
MakeMov = 1;

RedFig = figure;
colormap gray
for iFrame = 1:nframes
    imagesc(RedChannel(:,:,iFrame),RedRange);
    sTitle = sprintf('Non-Aligned Red Channel: Frame %u',iFrame);
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    frame = getframe;
    writeVideo(RedVideo,frame);

end

%Close Video
close(RedVideo);
close(RedFig)

end

