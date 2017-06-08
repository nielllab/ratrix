%%%plotTopoPatch2p_Joe

close all
clear all
dbstop if error

%select batch file
batch2pBehaviorFix;

%%% select files to analyze
%alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))
alluse = find( strcmp({files.notes},'good imaging session'))
%alluse = files  %all files

%%%set up savepaths
savepsfile = 'C:\tempJoe2pbehav.ps';
if exist(savepsfile,'file')==2;delete(savepsfile);end
savefilename = 'TopoMaps_vs_behavior_Joe';
savepathname = 'C:\';
%savepathname = '\\Joze-Monster\f\'    %pathname = '\\langevin\backup\twophoton\Newton\data\'



%%% create empty variables for data appending
 xAll = {}; yAll = {}; polImgX={}; polImgY={};mapx={};mapy={};behavResp = {};
cnt=1;

%%%create figures
txfig = figure;
tyfig = figure;
location1fig = figure;
location0fig = figure;
location1_0fig = figure;


rows=4;
%%%populate the figures
numAni=length(alluse)/rows; %for subplots
% if mod(numAni,4)~=0
%     numAni = ceil(numAni);
% end

for z = 1:length(alluse)   %%length(files) %incase we look at ones already tossed
    
    %%%%load topography data
    %get polar Image for X
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoX],'polarImg');
    polImgX{z} = polarImg;
    figure(txfig)
    subplot(rows,ceil(numAni),cnt)
    imshow(polImgX{z})
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    
    %get polar Image for Y
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoY],'polarImg');
    polImgY{z} = polarImg;
    figure(tyfig)
    subplot(rows,ceil(numAni),cnt)
    imshow(polImgY{z})
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    
    
        %%% get other topography data (from batchBehavCompile)
        %%%not used yet
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoX],'map'); 
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoXpts],'cropx','cropy','usePts')
    mapx{z} = getMapPhase(map,cropx,cropy,usePts); close(gcf); %%% get topography based on neuropil
    mapx{z} = mapx{z}*128/(2*pi) - (0.05*128);  %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoY],'map')
    mapy{z} = getMapPhase(map,cropx,cropy,usePts); close(gcf); %%% get topography based on neuropil
    mapy{z} = mapy{z}*72/(2*pi) - (0.05 *72);   %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
       
    %load other useful data from compile- (rf info,passive resp, behavTrialdata, behavdf
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).compileData],'rfAmp','rf','behavTrialData','passiveData3x','passiveData2sf','correctRate','resprate','stoprate','behavdF');
    
    %%% apply manual cutoff for cell numbers if included
    clear cutoff
    if ~isempty(files(alluse(z)).ncells)
        cutoff = files(alluse(z)).ncells;
    else
        cutoff = size(behavTrialData,1);
    end

    xAll{z} = [xAll mapx{z}(1:cutoff)]; yAll{z} = [yAll mapy{z}(1:cutoff)]; % append topography
    
    %%%%load pixelwise behavior data here
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).behavPts],'pixResp');   
   behavResp{z} = pixResp;
    
    %%%(what are the dimensions of pixResP?
    %%%pixResp(x,y,timepoint?,top/bottom/top-bottom?)
    figure; for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,1)) 
    end; %location1?
    figure; for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,2))
    end; %location0?
    figure; for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,3))
    end;  %location 1-0?
    %what is best timepoint to use? 200-300ms?  
    
    timepoint = 6;

     
 %%%%may need to change this to fit pixResp data structure
 %%%assign pixelwise response for top and bottom locations and for top-bottom
        imgLocation1 = squeeze(pixResp(:,:,timepoint,1)); %location1?
        imgLocation0 = squeeze(pixResp(:,:,timepoint,2)); %location0
        imgLocation1_0 = squeeze(pixResp(:,:,timepoint,3)); %location 1-0

 
 %plot figures       
    figure(location1fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1,[-0.01,0.1])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation0,[-0.01,0.1])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location1_0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1_0,[-0.01,0.1])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    cnt=cnt+1;
   % drawnow;
end

figure(txfig)
mtit('topoX maps')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(tyfig)
mtit('topoY maps')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(location1fig)
mtit('location1 response')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(location0fig)
mtit('location0 response')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(location1_0fig)
mtit('location1_0 response')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

try
    dos(['ps2pdf ' savepsfile ' "' [fullfile(savepathname,savefilename) '.pdf'] '"'] )
    display('successfully generated pdf');
catch
    display('couldnt generate pdf phils way');
end

