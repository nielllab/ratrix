function [img, framerate,mv] = readAlign2color(fname, align,showImg,fwidth)

Img_Info = imfinfo(fname);

nframes = length(Img_Info);
%nframes = 300;
mag = 1;
img = zeros(mag*Img_Info(1).Height,mag*Img_Info(1).Width,nframes/2,2);

eval(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;

if align
    disp('doing alignement')
    rigid = input('Rigid compensation (1) or Non-rigid(0): ');
    tic
    if rigid == 1
        %% Rigid Compensation
        r = sbxalign_tif(fname,2:2:nframes);
        
        figure
        plot(r.T(:,1));
        hold on
        plot(r.T(:,2),'g');
        
        % Apply gaussian filter to each frame?
        filt = fspecial('gaussian',5,fwidth);

        for f = 1:nframes/2
            img(:,:,f,1) = imfilter(double(imread(fname,(f-1)*2+1)),filt);
            img(:,:,f,2) = imfilter(double(imread(fname,(f-1)*2+2)),filt);
        end
        
        %Calculate the mean over all frames and display non-aligned image
        mn=squeeze(mean(img,3));
        %mn= prctile(img,99,3);
        
        if showImg
            figure
            for i = 1:2
                range = [prctile(mn(:),2) prctile(mn(:),98)];
                imagesc(squeeze(mn(:,:,i)),range);
                title('non aligned mean img')
                colormap(gray)
            end
        end
        
        %Shift raw images by the transformation calculated by sbxalign_tif
        for f=1:nframes/2
            % Do so for each channel
            for i = 1:2
                img(:,:,f,i) = circshift(squeeze(img(:,:,f,i)),[r.T(f,1),r.T(f,2)]);
            end
        end
        
        %Display aligned mean image
        if showImg
            %mn= prctile(img,99,3);
            figure
            for i = 1:2
                mn=squeeze(mean(img(:,:,:,i),3));
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
        mv = r.T;
        
    else
        %% Non-Rigid Compensation
        % Get Image Size
        Img_Info = imfinfo(fname);
        nframes = length(Img_Info);
        
        % PreAllocate
        Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes/2);
        
        % Read in Green channel
        for iFrame = 1:nframes/2
            Img_Seq(:,:,iFrame) = double(imread(fname,(iFrame-1)*2+1));
        end

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

%     figure
%     imagesc(r.m{1}); colormap gray; axis equal
    
else
    mv = NaN;
end