
spatialBin = input('avi spatial binning factor: ');
temporalBin = input('avi temporal binning factor: ');
movierate = input('avi framerate :');
alignData=input('avi align data? 0/1 :');
fullMovie = 1;

d = dir('*.sbx');
for i=1:length(d)

    fn = strtok(d(i).name,'.');
 
    avifname = [fn '_FULL.avi'];
    if ~exist(avifname,'file')
        sprintf('making %s',avifname)
        
        %%% read in sbx data and perform motion correction (if not already done)
        display('reading data')
        tic
         showImages=1;
        
        [img framerate] = readAlign2p_sbx(fn,alignData,showImages);
        toc
        
        
        %%% spatial downsampling
        display('resizing')
        tic
        img = imresize(img,1/spatialBin,'box');
        toc
        
        %%% temporal binning, to improve SNR before interpolation
        %%% a gaussian temporal filter might be better, but slow!
        display('temporal downsampling')
        binsize=temporalBin;
        downsampleLength = binsize*floor(size(img,3)/binsize);
        tic
        img= downsamplebin(img(:,:,1:downsampleLength),3,binsize)/binsize;  %%% downsamplebin based on patick mineault's code
        toc
        
        dimg = img(5:5:end,5:5:end,5:5:end);
        figure
        hist(dimg(:),100);
        lb = 0.8*prctile(dimg(:),1); ub = 1.5*prctile(dimg(:),99.9);
        
        if fullMovie
            display('converting to movie')
            cycMov= mat2im(img,gray,[lb ub]);
            mov = immovie(permute(cycMov,[1 2 4 3]));
            vid = VideoWriter([avifname(1:end-4) '_FULL.avi']);
            vid.FrameRate=movierate;
            open(vid);
            display('writing movie')
            writeVideo(vid,mov);
            close(vid)
        end
        
      
    else
        sprintf('already made %s',avifname)
    end
    
end