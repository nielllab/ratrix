dt = 0.25;
framerate=1/dt;
[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');

if strcmp(f(end-3:end),'.mat')
    display('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    display('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
else
  

  % [cleanStimRec ImageStim startFrame] = analyze2pSync({fullfile(p,f),fullfile(stimp,stimf)});

    cycLength = input('cycle length : ');
    [dfofInterp dtRaw] = get2pdata(fullfile(p,f),dt,cycLength);
    [fs ps] = uiputfile('*.mat','session data');
    
    display('saving data')
    sessionName= fullfile(ps,fs);
    save(sessionName,'dfofInterp','cycLength','-v7.3');
    display('done')
end

cycFrames =cycLength/dt; 
map=0; clear cycAvg mov

for f = 1:cycFrames;
    cycAvg(:,:,f) = mean(dfofInterp(:,:,f:cycFrames:end),3);
    map = map + cycAvg(:,:,f)*exp(2*pi*sqrt(-1)*f/cycFrames);
end

figure
imshow(imresize(polarMap(map),2)); axis square;
title('polar map')


