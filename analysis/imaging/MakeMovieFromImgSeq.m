function MakeMovieFromImgSeq(fname, Aligned_Seq)
%% Input:
%   fname: Tiff Image filename
%   Aligned_Seq: 4D image matrix (i.e. two image channel movies)

%Get Info
Img_Info = imfinfo(fname);
nframes = size(Aligned_Seq,3);
trash = evalc(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;

%Movie File Names
GrnMovieFile = sprintf('%sAlignedGreenChannel.avi',fname(1:end-4));
RedMovieFile = sprintf('%sAlignedRedChannel.mp4',fname(1:end-4));

%Calculate Range for scaled image display
sm = floor(nframes/4) - 1;
GrnRange = zeros(1,2);
RedRange = zeros(1,2);
for iFrame = 1:sm:nframes
    tmp = Aligned_Seq(:,:,iFrame,1);
    GrnRange(1) = GrnRange(1) + prctile(tmp(:),2);
    GrnRange(2) = GrnRange(2) + prctile(tmp(:),98);
    
    tmp = Aligned_Seq(:,:,iFrame,2);
    RedRange(1) = RedRange(1) + prctile(tmp(:),2);
    RedRange(2) = RedRange(2) + prctile(tmp(:),98);
end

GrnRange = GrnRange./4;
RedRange = RedRange./4;

%% Display Green Channel Movie and Save if file doesn't exist already
if exist(GrnMovieFile) == 0
    GrnVideo = VideoWriter(GrnMovieFile);
    GrnVideo.FrameRate = framerate*10;
    GrnVideo.Quality = 100;
    open(GrnVideo);
    MakeMov = 1;
end

GrnFig = figure;
colormap gray
for iFrame = 1:nframes
    imagesc(Aligned_Seq(:,:,iFrame,1),GrnRange);
    sTitle = sprintf('Non-Aligned Green Channel: Frame %u',iFrame);
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    if MakeMov == 1
        frame = getframe;
        writeVideo(GrnVideo,frame);
    end
end

%Close Video
if MakeMov == 1
    close(GrnVideo);
end

close(GrnFig);
%% Display Red Channel Movie and Save if file doesn't exist already
if exist(RedMovieFile) == 0
    RedVideo = VideoWriter(RedMovieFile);
    RedVideo.FrameRate = framerate*10;
    RedVideo.Quality = 100;
    open(RedVideo);
    MakeMov = 1;
end

RedFig = figure;
colormap gray
for iFrame = 1:nframes
    imagesc(Aligned_Seq(:,:,iFrame,2),RedRange);
    sTitle = sprintf('Non-Aligned Red Channel: Frame %u',iFrame);
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    if MakeMov == 1
        frame = getframe;
        writeVideo(RedVideo,frame);
    end
end

%Close Video
if MakeMov == 1
    close(RedVideo);
end
close(RedFig)

end

