function MakeMovieFromImgSeq(fname, Aligned_Seq,FrameIndices)
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
RedMovieFile = sprintf('%sAlignedRedChannel.avi',fname(1:end-4));

%Calculate Range for scaled image display
sm = floor(nframes/10) - 1;
GrnRange = zeros(1,2);
RedRange = zeros(1,2);
for iFrame = 1:sm:length(FrameIndices)
    tmp = Aligned_Seq(:,:,FrameIndices(iFrame),1);
    
    GrnRange(1) = GrnRange(1) + prctile(tmp(:),1);
    GrnRange(2) = GrnRange(2) + 0.9*max(tmp(:));
    
    tmp = Aligned_Seq(:,:,FrameIndices(iFrame),2);
    RedRange(1) = RedRange(1) + prctile(tmp(:),1);
    RedRange(2) = RedRange(2) + 0.9*max(tmp(:));
    
end

GrnRange = GrnRange./10;
RedRange = RedRange./10;

%% Display Green Channel Movie and Save if file doesn't exist already
GrnVideo = VideoWriter(GrnMovieFile);
GrnVideo.FrameRate = framerate*10;
GrnVideo.Quality = 100;
open(GrnVideo);
MakeMov = 1;

GrnFig = figure;
colormap gray
for iFrame = 1:length(FrameIndices)
    imagesc(Aligned_Seq(:,:,FrameIndices(iFrame),1),GrnRange);
    sTitle = sprintf('Aligned Green Channel: Frame %u',FrameIndices(iFrame));
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    frame = getframe(GrnFig);
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
for iFrame = 1:length(FrameIndices)
    imagesc(Aligned_Seq(:,:,FrameIndices(iFrame),2),RedRange);
    sTitle = sprintf('Aligned Red Channel: Frame %u',FrameIndices(iFrame));
    sInfo = sprintf('%2.2f Hz Acquisition, 10x Video',framerate);
    xlabel(sInfo);
    title(sTitle);
    
    drawnow
    frame = getframe(RedFig);
    writeVideo(RedVideo,frame);
    
end

%Close Video
close(RedVideo);
close(RedFig)

end

