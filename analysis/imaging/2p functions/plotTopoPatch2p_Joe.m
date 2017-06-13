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

%%%create figures (group summaries)
txfig = figure;
tyfig = figure;
location1fig = figure;
location0fig = figure;
location1_0fig = figure;


rows=7;
%%%populate the figures
numAni=length(alluse)/rows; %for subplots
% if mod(numAni,4)~=0
%     numAni = ceil(numAni);
% end

for z = 1:length(alluse)   %%length(files) %incase we look at ones already tossed

    %%%create figures for individual plotting
    footprintsAll(z) = figure;
    footprintsCentered(z) = figure;
    loc0timecourse(z) = figure;
    loc1timecourse(z) = figure;
    loc1_0timecourse(z) = figure;
    summaryFig(z) = figure;
    FootprintsFig(z) = figure;
    
    
    
    %%%%load topography data
    %get polar Image for X
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoX],'polarImg');
    polImgX{z} = polarImg;
    figure(txfig)
    set(gcf,'Name',sprintf('TopoXpolar'));
    subplot(rows,ceil(numAni),cnt)
    imshow(polImgX{z})
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    
    %get polar Image for Y
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoY],'polarImg');
    polImgY{z} = polarImg;
    figure(tyfig)
    set(gcf,'Name',sprintf('TopoYpolar'));
    subplot(rows,ceil(numAni),cnt)
    imshow(polImgY{z})
    colormap(hsv); %colorbar
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    
    
        %%% get other topography data (from batchBehavCompile)
        %%%not used yet
        clear usePts
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoX],'map'); 
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).topoXpts],'cropx','cropy','usePts','phaseVal','meanShiftImg','spikes')
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
        

ph = angle(phaseVal);
ph = mod(ph,2*pi);


%%% get rf locations for all cells
%%% flip data so that centered on preferred location (top vs bottom)
d1 = sqrt((mapx{z}-46).^2 + (mapy{z}-34).^2);
d2 = sqrt((mapx{z}-78).^2 + (mapy{z}-34).^2);

%%% choose the ones within 12 deg of center
centered = (d1<12| d2<12)';


usenonzero = find(mean(spikes,2)~=0); %%% gets rid of generic points that were not identified in this session
usenonzeroCentered=usenonzero(centered);

usenonzero=usenonzero(usenonzero<cutoff); %restrict by cutoff if there is one
usenonzeroCentered=usenonzeroCentered(usenonzeroCentered<cutoff);


%draw all footprints
figure(footprintsAll(z));
 set(gcf,'Name',sprintf('footprintsAll %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
draw2pSegs(usePts,ph,hsv,size(meanShiftImg),intersect(usenonzero,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)]);

%%%draw 'centered' footprints (within 12 degrees of center)
figure(footprintsCentered(z));
 set(gcf,'Name',sprintf('footprintsCentered %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
%draw2pSegs(usePtsCentered,ph,hsv,size(meanShiftImg),intersect(usenonzeroCentered,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)]);
draw2pSegs(usePts,ph,hsv,size(meanShiftImg),intersect(usenonzeroCentered,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)]);


    %%%%load pixelwise behavior data here
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).behavPts],'pixResp');   
   behavResp{z} = pixResp;
    
   
    %%%pixResp(x,y,timepoint,top/bottom/top-bottom)
    %%%maybe subtract off baseline??
    figure(loc1timecourse(z)); 
    set(gcf,'Name',sprintf('location1timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,1),[-0.3 0.3])
        colormap jet
    end;
    
    figure(loc0timecourse(z));
     set(gcf,'Name',sprintf('location0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,2),[-0.3 0.3])
       colormap jet
    end;
    
    figure(loc1_0timecourse(z));
    set(gcf,'Name',sprintf('location1-0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    mtit(sprintf('location1_0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,3),[-0.3 0.3])
    colormap jet
    end;  %location 1-0
            if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
    
    %what is best timepoint to use? 8 or 9 look good (400-600ms? after onset)  
    
    timepts = -1:0.2:2;
    
    timepoint = 9; %select timepoint for behavioral response

     
 %%%assign pixelwise response for top and bottom locations and for top-bottom
 %%%could subtract off response at t=0 here?  or ^2 to make all same sign?
        imgLocation1 = squeeze(pixResp(:,:,timepoint,1)); %location1?
        imgLocation0 = squeeze(pixResp(:,:,timepoint,2)); %location0
        imgLocation1_0 = squeeze(pixResp(:,:,timepoint,3)); %location 1-0

 
 %%%plot figures (single timepoint from each session) defined above     
    figure(location1fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1,[-0.03,0.3])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation0,[-0.03,0.3])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location1_0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1_0,[-0.03,0.3])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    
      figure(summaryFig(z))
      set(gcf,'Name',sprintf('summary %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('summary %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel = {'topoX','topoY','behavResp','centeredFootprints'};
      for t=1:4
    subplot(2,2,t);
    
    if t==1  %show topox
        imshow(polImgX{z});
        %colormap(hsv);
    elseif t==2 %show topoY
        imshow(polImgY{z});
        %colormap(hsv); 
    elseif t==3 %show behavior resp (location 1-0)
        imshow(behavResp{z}(:,:,timepoint,3),[-0.03,0.3])
        %colormap hsv
        colormap (jet);
    elseif t==4 %usenonzerocentered
        draw2pSegs(usePts,ph,hsv,size(meanShiftImg),intersect(usenonzeroCentered,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)])
        %colormap hsv;
        colorbar ('off');
    end;
%     xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
%    axis equal 
     title(figLabel{t});
         colormap (jet);
      end;
        if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
      
          figure(FootprintsFig(z))
      set(gcf,'Name',sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel2 = {'allFootprints','centeredFootprints','behavResp_location1','behavResp_location0'};
      for t=1:4
    subplot(2,2,t);
    
    if t==1  %show all footprints
       draw2pSegs(usePts,ph,hsv,size(meanShiftImg),intersect(usenonzero,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)]);
     colorbar ('off');
    elseif t==2 %show 'centered' footprints
        draw2pSegs(usePts,ph,hsv,size(meanShiftImg),intersect(usenonzeroCentered,find(abs(phaseVal)>0.025)),[pi/2  (2*pi -pi/4)]);
     colorbar ('off');
    elseif t==3 %show behavior resp (location 1)
        imshow(behavResp{z}(:,:,timepoint,1),[-0.03,0.3])
        colormap (jet);
    elseif t==4 %show behavior resp (location 0)
        imshow(behavResp{z}(:,:,timepoint,2),[-0.03,0.3])
        colormap (jet);
    end;
%     xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
%    axis equal 
     title(figLabel2{t});
         colormap (jet);
      end;  
        if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
    
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
set(gcf,'Name',sprintf('location 1 response'));
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(location0fig)
set(gcf,'Name',sprintf('location 0 response'));
mtit('location0 response')
if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
end

figure(location1_0fig)
set(gcf,'Name',sprintf('location 1-0 response'));
mtit('location1-0 response')
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

