%%% loops through multiple sessions and extract cell body signals
close all
clear all
alignStdMap; %%% inputs multiple filenames, gets max std deviation map and selects shared potential cell body points

%%% get parameters for cell extraction
sprintf('enter width of window for cell body extraction')
sprintf('typical = 4 or 5 for cell body on scanbox 1x, but depends of fov and zoom')
w = input('width : ');

showImg = input('show images? 0/1 ');

suffix = input('suffix for pts file : ','s');

%%% loop through each file and select points
for f = 1:length(filename);
    display(sprintf('loading %s',sessionName{f}))
    tic, load(filename{f}); toc
    [pts dF ptsfname icacorr cellImg usePts] = get2pPtsAuto(dfofInterp,greenframe,x,y,refFrame,w, showImg);
    
    outname = [filename{f}(1:end-4) '_' suffix '.mat'];
    save(outname, 'pts','dF','greenframe','usePts');
end
