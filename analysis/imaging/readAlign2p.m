function [Aligned_Seq, mv] = readAlign2p(fname, Opt)

if Opt.SaveFigs
    psfile = Opt.psfile;
end
% Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info)/2;

% Construct rotationally symmetric gaussian lowpass filter with a size of
% sigma of fwidth
filt = fspecial('gaussian',5,Opt.fwidth);

%Preallocate 3D array (i.e. 1 image channel movie)
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);
RAligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);

%Read in frames
for iFrame = 1:nframes
    Img_Seq(:,:,iFrame) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
end

if Opt.align
    disp('Doing Alignment!')
    
    %Get Alignment Channel indices
    alignIndices = 1:1:nframes;

    %% Perform Rigid Compensation regardless
    r = sbxalign_tif(fname,alignIndices);
    mv = r.T;
    buffer = max(abs(mv(:)))+2;
    
    %Plot xy translations for each frame
    figure
    plot(r.T(:,1));
    hold on
    plot(r.T(:,2),'g');
    title('XY Translations');
    
    % Apply translation determined by sbxalign_tif to each frame
    for iFrame = 1:nframes
        %First apply gaussian filter to non-aligned image
        Img_Seq(:,:,iFrame) = imfilter(Img_Seq(:,:,iFrame),filt);
        
        %Then apply xy rigid translation determined by sbxalign
        RAligned_Seq(:,:,iFrame) = circshift(squeeze(Img_Seq(:,:,iFrame)),[r.T(iFrame,1),r.T(iFrame,2)]);
    end
    % what is largest offset? Clip image edges by buffer value to remove
    % rigid translation artifacts
    RAligned_all = RAligned_Seq;  %%% keep a copy that hasn't been clipped;
    RAligned_Seq = RAligned_Seq(buffer:end-buffer,buffer:end-buffer,:,:);
    
    keyboard
    %Plot Mean image of rigidly aligned image sequence
    figure
    R_Mean = mean(RAligned_Seq,3);
    imagesc(R_Mean);colormap gray
    title('Mean Image after Rigid Alignment of full frame sequence');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    zplane = input('Z-plane Binning? yes(1)/no(0): ');
    %% Perform cluster analysis on image sequence to determine which
    %images stay within a similar z-plane
    if zplane == 1
        [FrameIndices, FrameBool] = bin_Zplane(Img_Seq, RAligned_Seq, Opt);
        
        %Plot Mean image of rigidly aligned image sequence
        figure
        R_Mean = mean(RAligned_Seq(:,:,FrameIndices),3);
        imagesc(R_Mean);colormap gray
        title(sprintf('Mean Image after Rigid Alignment of %u out of %u total frames',length(FrameIndices),nframes));
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    else
        FrameIndices = 1:1:nframes;
        FrameBool = ones(nframes,1);
    end
    
    %Get alignment options
    disp('Keeping in mind that the following algorithm is very computationally intensive (runtime > 10mins for 1000 frames),');
    rigid = input('Do you want to correct for rotations as well? yes(1)/no(0): ');
    
    %% Now that we have a subset of frames that are presumably in the same 
    % z-plane, re-run the alignment process with only that subset using
    % either the non-rigid or rigid alignment algorithms
    if rigid == 1
        % Rigid/rotation Compensation on a Rigidly aligned image seq
        tic; nr = sbxalign_tif_rot(RAligned_Seq,FrameIndices);toc
        
        % Apply translation determined by sbxalign_tif_nonrigid to each 
        % frame in the subset, while setting those not in subset to NaN
        ii = 1;
        Aligned_Seq = zeros(size(RAligned_Seq));
        Rfixed = imref2d(size(R_Mean));
        for iFrame = 1:nframes
            if FrameBool(iFrame) == 1
                tform = affine2d(nr.T{1,ii});
                Aligned_Seq(:,:,iFrame) = imwarp(RAligned_Seq(:,:,iFrame),tform,'OutputView',Rfixed);
                ii = ii + 1; 
            else
                Aligned_Seq(:,:,iFrame) = NaN;
            end
        end
        
        %Plot Mean image of nonrigidly aligned image sequence
        figure
        NR_Mean = mean(Aligned_Seq(:,:,FrameIndices),3);
        imagesc(NR_Mean);colormap gray
        title(sprintf('Mean Image after Rigid + Rotation Alignment of %u out of %u total frames',length(FrameIndices),nframes));
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   
    end
    
    % Make an aligned movie from Aligned_Seq
    if Opt.MakeMov
        MakeMovieFromImgSeq(fname, Aligned_Seq,FrameIndices);
    end
        
else
    mv = NaN;
    Aligned_Seq = Img_Seq;
end