function [Aligned_Seq, mv] = readAlign2color(fname, align, showImg, fwidth)

% Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info)/2;

% Construct rotationally symmetric gaussian lowpass filter with a size of
% sigma of fwidth
filt = fspecial('gaussian',5,fwidth);

%Preallocate 4D array (i.e. two image channel movies)
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);
Aligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes,2);

%Read in frames
for iFrame = 1:nframes
    Img_Seq(:,:,iFrame,1) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
    Img_Seq(:,:,iFrame,2) = double(imread(fname,(iFrame-1)*2+2)); %Red channel
end

%Calculate Mean Image for each non-aligned channel
% mn = squeeze(mean(Img_Seq,3));
% GrnMean_NA = mn(:,:,1); %Non-aligned Green Channel Mean
% RedMean_NA = mn(:,:,2); %Non-aligned Red Channel Mean

if align
    disp('doing alignement')
    rigid = input('Rigid compensation (2) or Non-rigid(1) or Both(0): ');
    channel = input('Red channel(1) or Green channel(0) for alignment?: ');
    if channel
        alignIndices = 2:2:nframes*2;
    else
        alignIndices = 1:2:nframes*2;
    end
       
    if rigid == 2 || rigid == 0
        %% Rigid Compensation
        r = sbxalign_tif(fname,alignIndices);
        
        %Plot xy translations for each frame
        figure
        plot(r.T(:,1));
        hold on
        plot(r.T(:,2),'g');

        % Apply translation determined by sbxalign_tif to each frame
        for iFrame = 1:nframes
            for iChannel = 1:2
                %First apply gaussian filter to non-aligned image
                Img_Seq(:,:,iFrame,1) = imfilter(Img_Seq(:,:,iFrame,1),filt);
                
                %Then apply xy rigid translation determined by sbxalign
                Aligned_Seq(:,:,iFrame,iChannel) = circshift(squeeze(Img_Seq(:,:,iFrame,iChannel)),[r.T(iFrame,1),r.T(iFrame,2)]);
            end
        end     

        %Not used in upper-level functions???
        mv = r.T;
        
    end
    
    if rigid == 1 
        %% Non-Rigid Compensation        
        % Align full sequence without considering z-displacement
        r = sbxalign_tif(fname,alignIndices);
        mv = r.T;
        
        % Apply translation determined by sbxalign_tif to each frame
        for iFrame = 1:nframes
            for iChannel = 1:2
                %First apply gaussian filter to non-aligned image
                Img_Seq(:,:,iFrame,1) = imfilter(Img_Seq(:,:,iFrame,1),filt);
                
                %Then apply xy rigid translation determined by sbxalign
                Aligned_Seq(:,:,iFrame,iChannel) = circshift(squeeze(Img_Seq(:,:,iFrame,iChannel)),[r.T(iFrame,1),r.T(iFrame,2)]);
            end
        end   
        
        %Add function to find frames in the correct z-plane
        %Output an index matrix of correct-z-plane frames to input into sbxalign_tif_nonrigid
%         ZIndices = bin_Zplane(Img_Seq(:,:,:,2), Aligned_Seq(:,:,:,2), alignIndices);
        ZIndices = alignIndices;
        
        % Re-align sequence of frames that are in the correct z-plane
        nr = sbxalign_tif_nonrigid(fname,ZIndices);
        disp('Oiy');
        
        %Create New image stack that only takes the subset of images that
        %were in the same z-plane
        Aligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,length(ZIndices),2);
        
        % Apply transformation matrix determined by sbxalign_tif_nonrigid to each frame
        for iFrame = 1:length(ZIndices)
            for iChannel = 1:2
                
                %Apply xy rigid translation determined by sbxalign_nonrigid
                Aligned_Seq(:,:,iFrame,iChannel) = imwarp(Img_Seq(:,:,iFrame,iChannel),nr.T{1,iFrame});
                
                %Replace NaN/Inf values with 0s
%                 pos = find(Aligned_Seq(:,:,iFrame,iChannel) == NaN || Aligned_Seq(:,:,iFrame,iChannel) == Inf);
            end
        end   
        
        % Make an aligned movie from Aligned_Seq
%         MakeMovieFromImgSeq(fname, Aligned_Seq)
        
        % Show Mean image of non-aligned image sequence and aligned
%         if showImg
%             figure
%             NonAligned_Mean = mean(Img_Seq, 3);
%             imshowpair(NonAligned_Mean, nr.m{1,1}, 'montage')
%             title('Non-Aligned Mean Image vs Aligned Mean Image');
%         end
           
    elseif rigid == 0
        %% Non-Rigid Compensation on a Rigidly aligned image seq
        
        
    end
    
    
    %% Display Aligned Mean Image vs Non-Aligned

else
    mv = NaN;
end