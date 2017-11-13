function [Aligned_Seq, mv] = readAlign2color(fname, align, makeFigs, fwidth)
if makeFigs
    psfile = 'C:\temp\TempFigs.ps';
end
% Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info)/2;

% Construct rotationally symmetric gaussian lowpass filter with a size of
% sigma of fwidth
filt = fspecial('gaussian',5,fwidth);

%Preallocate 4D array (i.e. two image channel movies)
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);
RAligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);

%Read in frames
for iFrame = 1:nframes
    Img_Seq(:,:,iFrame,1) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
    Img_Seq(:,:,iFrame,2) = double(imread(fname,(iFrame-1)*2+2)); %Red channel
end

if align
    disp('Doing Alignment!')
    
    %Get alignment options
    rigid = input('Only Rigid compensation (1) or Both Rigid & Non-rigid(0): ');
    %Get Alignment Channel
    AC = input('Red channel(2) or Green channel(1) for alignment?: ');
    
    if AC == 2
        alignIndices = 2:2:nframes*2;
    else
        alignIndices = 1:2:nframes*2;
    end

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
        for iChannel = 1:2
            %First apply gaussian filter to non-aligned image
            Img_Seq(:,:,iFrame,1) = imfilter(Img_Seq(:,:,iFrame,1),filt);
            
            %Then apply xy rigid translation determined by sbxalign
            RAligned_Seq(:,:,iFrame,iChannel) = circshift(squeeze(Img_Seq(:,:,iFrame,iChannel)),[r.T(iFrame,1),r.T(iFrame,2)]);
        end
    end
    % what is largest offset? Clip image edges by buffer value to remove
    % rigid translation artifacts
    RAligned_Seq = RAligned_Seq(buffer:end-buffer,buffer:end-buffer,:,:);
    
    %Plot Mean image of rigidly aligned image sequence
    figure
    R_Mean = mean(RAligned_Seq(:,:,:,1),3);
    imagesc(R_Mean);colormap gray
    title('Mean Image after Rigid Alignment of full frame sequence');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    zplane = input('Z-plane Binning? yes(1)/no(0): ');
    %% Perform cluster analysis on image sequence to determine which
    %images stay within a similar z-plane
    if zplane == 1
        [FrameIndices, FrameBool] = bin_Zplane(Img_Seq(:,:,:,AC), RAligned_Seq(:,:,:,AC), makeFigs);
    else
        FrameIndices = 1:1:nframes;
        FrameBool = ones(nframes,1);
    end
    
    %Plot Mean image of rigidly aligned image sequence
    figure
    R_Mean = mean(RAligned_Seq(:,:,FrameIndices,1),3);
    imagesc(R_Mean);colormap gray
    title(sprintf('Mean Image after Rigid Alignment of %u out of %u total frames',length(FrameIndices),nframes));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %% Now that we have a subset of frames that are presumably in the same 
    % z-plane, re-run the alignment process with only that subset using
    % either the non-rigid or rigid alignment algorithms
    if rigid == 0
        % Non-Rigid Compensation on a Rigidly aligned image seq
        nr = sbxalign_tif_nonrigid2(RAligned_Seq(:,:,:,AC),FrameIndices);
        
        % Apply translation determined by sbxalign_tif_nonrigid to each 
        % frame in the subset, while setting those not in subset to NaN
        ii = 1;
        Aligned_Seq = zeros(size(RAligned_Seq));
        for iFrame = 1:nframes
            if FrameBool(iFrame) == 1
                Aligned_Seq(:,:,iFrame,1) = imwarp(RAligned_Seq(:,:,iFrame,1),nr.T{1,ii});
                Aligned_Seq(:,:,iFrame,2) = imwarp(RAligned_Seq(:,:,iFrame,2),nr.T{1,ii});
                ii = ii + 1; 
            else
                Aligned_Seq(:,:,iFrame,1) = NaN;
                Aligned_Seq(:,:,iFrame,2) = NaN;
            end
        end
        
        %Plot Mean image of nonrigidly aligned image sequence
        figure
        NR_Mean = mean(Aligned_Seq(:,:,FrameIndices,1),3);
        imagesc(NR_Mean);colormap gray
        title(sprintf('Mean Image after Rigid & NonRigid Alignment of %u out of %u total frames',length(FrameIndices),nframes));
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   
    elseif (rigid == 1 && zplane == 1)
        % Only re-run the rigid alignment algorithm, sbxalign_tif, if a
        % subset of frames were identified in bin_Zplane
        rr = sbxalign_tif(fname,FrameIndices*2); %Recursive Rigid
        mv = rr.T;
        buffer = max(abs(mv(:)))+2;
    
        % Apply translation determined by sbxalign_tif to each frame in 
        % the subset, while setting those not in subset to NaN
        ii = 1;
        Aligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);
        for iFrame = 1:nframes
            if FrameBool(iFrame) == 1
                Aligned_Seq(:,:,iFrame,1) = circshift(squeeze(Img_Seq(:,:,iFrame,1)),[rr.T(ii,1),rr.T(ii,2)]);
                Aligned_Seq(:,:,iFrame,2) = circshift(squeeze(Img_Seq(:,:,iFrame,2)),[rr.T(ii,1),rr.T(ii,2)]);
                ii = ii + 1;
            else
                Aligned_Seq(:,:,iFrame,1) = NaN;
                Aligned_Seq(:,:,iFrame,2) = NaN;
            end
        end
        Aligned_Seq = Aligned_Seq(buffer:end-buffer,buffer:end-buffer,:,:);
    end
    
    %Plot Mean image of recursive rigid aligned image sequence
    figure
    RR_Mean = mean(Aligned_Seq(:,:,FrameIndices,1),3);
    imagesc(RR_Mean);colormap gray
    title(sprintf('Mean Image after Recursive Rigid Alignment of %u out of %u total frames',length(FrameIndices),nframes));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end 
    
    % Make an aligned movie from Aligned_Seq
%     MakeMovieFromImgSeq(fname, Aligned_Seq,FrameIndices);
        
else
    mv = NaN;
end