function [dfofInterp, im_dt, MeanRedChannel, Grn95Percentile, mv] = get2colordata(fname, dt, cycLength,makeFigs)
if makeFigs
    psfile = 'C:\temp\TempFigs.ps';
end
% Display Movies for Non-aligned image sequences for both channels & save
% the movie if it does not exist already
% MakeMovieFromTiff(fname);

% Performs Image registration for both channels
[imgAll, mv] = readAlign2color(fname,1,1,0.5);

%Get Info
Img_Info = imfinfo(fname);
trash = evalc(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;
im_dt = 1/framerate;

%Calculate the mean of the red images
MeanRedChannel = squeeze(mean(imgAll(:,:,:,2),3));

%Calculate the 95% of the green images
Grn95Percentile = squeeze(prctile(imgAll(:,:,:,1),95,3));

%Preallocate arrays
imgInterp = zeros(size(imgAll));

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
       
    %Interpolate to desired frame rate if different than acquisition rate
    if im_dt ~= dt
        imgInterpAll{iChannel} = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(Aligned_Seq,2),0:dt:(nframes-1)*im_dt);
        imgInterpAll{iChannel} = shiftdim(imgInterpAll{iChannel},1);
    else
        imgInterpAll{iChannel} = Aligned_Seq;
    end
end
imgInterp(:,:,:,1) = imgInterpAll{1};
imgInterp(:,:,:,2) = imgInterpAll{2};

% cycFrames =cycLength/dt;
% range = [prctile(m{1}(:),2) 2*prctile(m{1}(:),99)];
% redframes = squeeze(imgInterp(:,:,:,2));
% rangered = [ 0 prctile(m{2}(:),99)];
% clear mov;
% [Range] = clims(Img_Seq, nSample)
% figure
% for f = 1:cycFrames
%     cycAvg(:,:,f,:) = mean(imgInterp(:,:,f:cycFrames:end,:),3);
%     im(:,:,1) = squeeze(cycAvg(:,:,f,2))/rangered(2);
%     im(:,:,2) = (squeeze(cycAvg(:,:,f,1)) - range(1))/(range(2)-range(1));
%     im(:,:,3) = 0;
%     imshow(im);
%     mov(:,:,:,f)=im;
% end

% mov = immovie(mov)
% title('raw img frames')
% vid = VideoWriter(sprintf('%sCycleMov.avi',fname(1:end-4)));
% vid.FrameRate=10;
% open(vid);
% writeVideo(vid,mov);
% close(vid)

% fullMov = zeros(size(imgInterp));
% fullMov(:,:,:,3)=0;
%
%     fullMov(:,:,:,1) = imgInterp(:,:,:,2)/rangered(2);
%     fullMov(:,:,:,2) = (imgInterp(:,:,:,1)-range(1))/(range(2) - range(1)) ;
%
%
%
% % fullMov= mat2im(imresize(img(25:end-25,25:end-25,150:550),2),gray,[prctile(m(:),2) 1.5*prctile(m(:),99)]);
% % %fullMov = squeeze(fullMov(:,:,:,1));
%  mov = immovie(permute(fullMov,[1 2 4 3]));
% %mov = immovie(fullMov);
% vid = VideoWriter(sprintf('%sfullMov.avi',fname(1:end-4)));
% vid.FrameRate=10;
%
% vid.Quality=100;
% open(vid);
% writeVideo(vid,mov(50:250));
% close(vid)

% cycTimecourse = squeeze(mean(mean(cycAvg,2),1));
% figure
% plot(cycTimecourse);