function [Img_Seq, framerate, mv] = readAlign2color(fname, align, showImg, fwidth)

% Get file info
Img_Info = imfinfo(fname);
nframes = length(Img_Info);
eval(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;

%Preallocate 4D array (i.e. two image channel movies)
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes/2,2);
Aligned_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes/2,2);

%Read in frames
for iFrame = 1:nframes/2
    Img_Seq(:,:,iFrame,1) = double(imread(fname,(iFrame-1)*2+1)); %Green channel
    Img_Seq(:,:,iFrame,2) = double(imread(fname,(iFrame-1)*2+2)); %Red channel
end
        
if align
    disp('doing alignement')
    rigid = input('Rigid compensation (2) or Non-rigid(1) or Both(0): ');
    tic
    
    if rigid == 2 || rigid == 0
        %% Rigid Compensation
        r = sbxalign_tif(fname,2:2:nframes);
        
        figure
        plot(r.T(:,1));
        hold on
        plot(r.T(:,2),'g');
        
        % Apply gaussian filter to each frame?
        filt = fspecial('gaussian',5,fwidth);

        for iFrame = 1:nframes/2
            for iChannel = 1:2
                %First apply gaussian filter to non-aligned image
                Img_Seq(:,:,iFrame,1) = imfilter(Img_Seq(:,:,iFrame,1),filt);
                
                %Then apply xy rigid translation determined by sbxalign
                Aligned_Seq(:,:,iFrame,iChannel) = circshift(squeeze(Img_Seq(:,:,iFrame,iChannel)),[r.T(f,1),r.T(f,2)]);
            end
        end     

        %Not used in upper-level functions???
        mv = r.T;
        
    end
    
    if rigid == 1 || rigid == 0
        %% Non-Rigid Compensation        
        % Align full sequence without considering z-displacement
        r = sbxalign_tif_nonrigid(fname,2:2:nframes);
        
        %Add function to find frames in the correct z-plane
        %Output an index matrix of correct-z-plane frames to input into sbxalign_tif_nonrigid
        FrameIndices = bin_Zplane(Img_Seq, mean(Img_Seq,3));
        
        % Re-align sequence of frames that are in the correct z-plane
        r = sbxalign_tif_nonrigid(fname,FrameIndices);
        disp('Oiy');
        
        % Show Mean image of non-aligned image sequence and aligned
        if showImg
            figure
            NonAligned_Mean = mean(Img_Seq, 3);
            imshowpair(NonAligned_Mean, r.M{1}, 'montage')
            title('Non-Aligned Mean Image vs Aligned Mean Image');
        end
        
        
        
        
    end
    toc
    
    %% Display Aligned Mean Image vs Non-Aligned
    %Calculate the mean over all frames and display non-aligned image
    mn = squeeze(mean(Img_Seq,3));
        
    if showImg
        % Display Non-Aligned Mean Image
        figure
        
        for i = 1:2
            range = [prctile(mn(:),2) prctile(mn(:),98)];
            imagesc(squeeze(mn(:,:,i)),range);
            title('non aligned mean img')
            colormap(gray)
        end
        
        
        figure
        for i = 1:2
            mn=squeeze(mean(Img_Seq(:,:,:,i),3));
            subplot(1,2,i)
            range = [prctile(mn(:),2) prctile(mn(:),98)];
            imagesc(mn,range);
            title('aligned mean img')
            colormap(gray)
            axis equal
            im(:,:,3-i) = (mn-range(1))/(range(2)-range(1));
        end
        im(:,:,3)=0;
        figure
        imshow(im)
        
    end
else
    mv = NaN;
end