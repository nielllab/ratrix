[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');

numchan = input('num channels : ');
if numchan ==1
    for f = 1:1000
        img(:,:,f)=imread(fullfile(p,f),f);
    end
else
       for f = 1:1000
        img(:,:,f)=imread(fullfile(p,f),f*2-1);
    end 
end

mn = mean(img,3);
figure
imagesc(mn,[prctile(mn(:),1) prctile(mn(:),99)]); colormap gray

inf = imfinfo(fullfile(p,f))
eval(inf(1).ImageDescription);
framerate = state.acq.frameRate;
rawdt= 1/framerate;

for f=1:1000
    dfof(:,:,f) = (img(:,:,f)-mn)./mn;
end

    [ttlf ttlp] = uigetfile('*.mat','ttl file')
    [stimPulse framePulse] = getTTL(fullfile(ttlp,ttlf));
    
     startTime = round(stimPulse(1)/dt);
     
     dfofInterp = dfofInterp(:,:,startTime:end);
     
     