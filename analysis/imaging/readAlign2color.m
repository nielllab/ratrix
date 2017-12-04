function [Aligned_Seq, r, nr] = readAlign2color(fname, Opt)
if Opt.SaveFigs
    psfile = Opt.psfile;
end
% Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info)/2;

% Construct rotationally symmetric gaussian lowpass filter with a size of
% sigma of fwidth
filt = fspecial('gaussian',5,Opt.fwidth);

%Preallocate 4D array (i.e. two image channel movies)
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);
RAligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);

%Read in frames
for iFrame = 1:nframes
    Img_Seq(:,:,iFrame,1) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
    Img_Seq(:,:,iFrame,2) = double(imread(fname,(iFrame-1)*2+2)); %Red channel
end

%Display non-aligned mean image
figure
NA_Mean = mean(Img_Seq(:,:,:,1),3);
imagesc(NA_Mean,[0, 0.70].*max(NA_Mean(:)));colormap gray
title('Mean Green Image of Non-Aligned full frame sequence');
ax = gca; ax.XTick = []; ax.YTick = [];
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

if Opt.align
    disp('Doing Alignment!')
    
    %Get Alignment Channel
    if isfield(Opt,'AlignmentChannel')
        AC = Opt.AlignmentChannel;
    else
        AC = input('Red channel(2) or Green channel(1) for alignment?: ');
    end
    
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
            Img_Seq(:,:,iFrame,iChannel) = imfilter(Img_Seq(:,:,iFrame,iChannel),filt);
            
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
    imagesc(R_Mean,[0, 0.70].*max(R_Mean(:)));colormap gray
    title('Mean Green Image after Rigid Alignment of full frame sequence');
    ax = gca; ax.XTick = []; ax.YTick = [];
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %Should we bin for z-motion?
    if isfield(Opt,'ZBinning')
        zplane = Opt.ZBinning;
    else
        zplane = input('Z-plane Binning? yes(1)/no(0): ');
    end
    
    %% Perform cluster analysis on image sequence to determine which
    %images stay within a similar z-plane
    if zplane == 1
        [FrameIndices, FrameBool] = bin_Zplane(Img_Seq(:,:,:,AC), RAligned_Seq(:,:,:,AC), Opt);
        
        %Plot Mean image of rigidly aligned image sequence
        figure
        R_Mean = mean(RAligned_Seq(:,:,FrameIndices,1),3);
        imagesc(R_Mean,[0, 0.70].*max(R_Mean(:)));colormap gray
        title(sprintf('Mean Image after Rigid Alignment of %u out of %u total frames',length(FrameIndices),nframes));
        ax = gca; ax.XTick = []; ax.YTick = [];
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    else
        FrameIndices = 1:1:nframes;
        FrameBool = ones(nframes,1);
    end
    
    %Get alignment options
    if isfield(Opt,'Rotation')
        rigid = Opt.Rotation;
    else
        disp('Keeping in mind that the following algorithm is very computationally intensive (runtime > 10mins for 1000 frames),');
        rigid = input('Do you want to correct for rotations as well? yes(1)/no(0): ');
    end
    
    %% Now that we have a subset of frames that are presumably in the same 
    % z-plane, re-run the alignment process with only that subset using
    % either the non-rigid or rigid alignment algorithms
    if rigid == 1
        % Rigid/rotation Compensation on a Rigidly aligned image seq
        tic; nr = sbxalign_tif_rot(RAligned_Seq(:,:,:,AC),FrameIndices);toc
        
        % Apply translation determined by sbxalign_tif_nonrigid to each 
        % frame in the subset, while setting those not in subset to NaN
        ii = 1;
        Aligned_Seq = zeros(size(RAligned_Seq));
        Rfixed = imref2d(size(R_Mean));
        for iFrame = 1:nframes
            if FrameBool(iFrame) == 1
                tform = affine2d(nr.T{1,ii});
                Aligned_Seq(:,:,iFrame,1) = imwarp(RAligned_Seq(:,:,iFrame,1),tform,'OutputView',Rfixed);
                Aligned_Seq(:,:,iFrame,2) = imwarp(RAligned_Seq(:,:,iFrame,2),tform,'OutputView',Rfixed);
                ii = ii + 1; 
            else
                Aligned_Seq(:,:,iFrame,1) = NaN;
                Aligned_Seq(:,:,iFrame,2) = NaN;
            end
        end
        
        %Plot Mean image of nonrigidly aligned image sequence
        figure
        NR_Mean = mean(Aligned_Seq(:,:,FrameIndices,1),3);
        imagesc(NR_Mean,[0, 0.80].*max(NR_Mean(:)));colormap gray
        title(sprintf('Mean Image after Rigid + Rotation Alignment of %u out of %u total frames',length(FrameIndices),nframes));
        ax = gca; ax.XTick = []; ax.YTick = [];
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
      
    else
        nr = [];
        Aligned_Seq = RAligned_Seq;
    end
    
    %% Quantify alignment quality
%     NA_Mean = mean(Img_Seq(:,:,:,1),3);
%     for iFrame = 1:size(Img_Seq,3)
%         iiImg = Img_Seq(:,:,iFrame,1);
%         NACorrCoeff(iFrame,1) = corr2(iiImg,NA_Mean);
%         
%     end
%         
%     R_Mean = mean(RAligned_Seq(:,:,:,1),3);
%     for iFrame = 1:size(RAligned_Seq,3)
%         iiImg = RAligned_Seq(:,:,iFrame,1);
%         RigidCorrCoeff(iFrame,1) = corr2(iiImg,R_Mean);
%         
%     end
%         
%     RZ_Mean = mean(RAligned_Seq(:,:,FrameIndices,1),3);
%     for iFrame = 1:length(FrameIndices)
%         iiImg = RAligned_Seq(:,:,FrameIndices(iFrame),1);
%         RigidZBin_CorrCoeff(iFrame,1) = corr2(iiImg,RZ_Mean);
%         
%     end
%         
%     NR_Mean = mean(Aligned_Seq(:,:,FrameIndices,1),3);
%     for iFrame = 1:length(FrameIndices)
%         iiImg = Aligned_Seq(:,:,FrameIndices(iFrame),1);
%         RigidRotationZbin_CorrCoeff(iFrame,1) = corr2(iiImg,NR_Mean);
%         
%     end
%     
%     %Plot Correlation Coefficients for various alignment methods
%     CorrCoeff_Align = [mean(NACorrCoeff), mean(RigidCorrCoeff), mean(RigidZBin_CorrCoeff), mean(RigidRotationZbin_CorrCoeff)];
%     figure
%     plot(1:1:4,CorrCoeff_Align,'ob','MarkerFaceColor','b')
%     ax = gca; ax.XLim = [0.5 4.5];
%     ax.YLabel.String = '2D Correlation Coefficient';
%     ax.YLabel.FontSize = 12;
%     ax.YLabel.FontWeight = 'bold';
%     ax.TickLabelInterpreter = 'latex';
%     ax.YLim = [0.82 1];
%     ax.XTick = [1 2 3 4];
%     ax.XTickLabel = {'\bf Non-Aligned','\bf Rigid Alignment','\bf Z-Binning','\bf Rotation'};
%     ax.XTickLabelRotation = 45;
%     ax.XGrid = 'on';
%     ax.YGrid = 'on';
%     title('Mean Correlation Coefficient');

    %% Make an aligned movie from Aligned_Seq
    if Opt.MakeMov
        MakeMovieFromImgSeq(fname, Aligned_Seq,FrameIndices);
    end
        
else
    nr = [];
    r = [];
    Aligned_Seq = Img_Seq;
end