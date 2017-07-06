%%%plotTopoPatch2p_Joe

close all
clear all
dbstop if error

%select batch file
batch2pBehaviorFix;

%%% select files to analyze
%alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))
%alluse = find( ~strcmp({files.notes},'good imaging session'));
alluse = find( strcmp({files.notes},'good imaging session'));
%alluse = files  %all files

%%%set up savepaths
savepsfile = 'C:\tempJoe2pbehavTest.ps';
if exist(savepsfile,'file')==2;delete(savepsfile);end

savefilename = 'TopoMaps_vs_behavior_Joe';
%savefilename = 'TopoMaps_vs_behavior_Joe_notuse';

savepathname = 'C:\';
%savepathname = '\\Joze-Monster\f\'    %pathname = '\\langevin\backup\twophoton\Newton\data\'

%%% create empty variables for data appending
 xAll = {}; yAll = {}; polImgX={}; polImgY={};mapx={};mapy={};behavResp = {};
cnt=1; depth={};

%%%create figures (group summaries)
txfig = figure;
tyfig = figure;
location1fig = figure;
location0fig = figure;
location1_0fig = figure;
RFlocations2=figure

rows=7;
%%%populate the figures
numAni=length(alluse)/rows; %for subplots
% if mod(numAni,4)~=0
%     numAni = ceil(numAni);
% end

for z = 1:length(alluse)   %%length(files) %incase we look at ones already tossed

    %%%create figures for individual plotting
    footprintsAllX(z) = figure;
    footprintsCenteredX(z) = figure;
    footprintsAllY(z) = figure;
    footprintsCenteredY(z) = figure;
    loc0timecourse(z) = figure;
    loc1timecourse(z) = figure;
    loc1_0timecourse(z) = figure;
    summaryFig(z) = figure;
    FootprintsFig(z) = figure;
    topoAndFootprintsFig(z) = figure;
    topoAndFootprintsFig2(z) = figure;
    RFlocations{z}=figure;

    depth{z} = num2str(files(alluse(z)).depth);
 
    
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
    
    
        %%% get other topography data (for cell location based on neuropil)
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

    xAll{z} = [mapx{z}(1:cutoff)]; yAll{z} = [mapy{z}(1:cutoff)]; % append topography
      

ph = angle(phaseVal);
ph = mod(ph,2*pi);


%%% get rf locations for all cells
%%% flip data so that centered on preferred location (top vs bottom)
d1 = sqrt((mapx{z}-46).^2 + (mapy{z}-34).^2);
d2 = sqrt((mapx{z}-78).^2 + (mapy{z}-34).^2);

%%% choose the ones within 12 deg of center
centered = (d1<12| d2<12)';
centered1=centered(1:cutoff);

usenonzero = find(mean(spikes,2)~=0); %%% gets rid of generic points that were not identified in this session
usenonzeroCentered=usenonzero(centered);
usenonzeroNotCentered=usenonzero(~centered);

usenonzero=usenonzero(usenonzero<cutoff); %restrict by cutoff if there is one
usenonzeroCentered=usenonzeroCentered(usenonzeroCentered<cutoff);
usenonzeroNotCentered=usenonzeroNotCentered(usenonzeroNotCentered<cutoff);

%draw all footprints twice(color one with X phase and one with Y phase)
figure(footprintsAllX(z));
set(gcf,'Name',sprintf('footprintsAllX %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
title(sprintf('footprintsAll %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapx{z}))) ,[pi/2  (2*pi -pi/4)]*(128/(2*pi)));


figure(footprintsAllY(z));
set(gcf,'Name',sprintf('footprintsAllY %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
title(sprintf('footprintsAll %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*(72/(2*pi)));
 
 %%%draw 'centered' footprints (within 12 degrees of center)
 %%%draw centered footprints twice(color one with X phase and one with Y phase)
figure(footprintsCenteredX(z));
set(gcf,'Name',sprintf('footprintsCenteredX %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
title(sprintf('footprintsCentered %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*(128/(2*pi)));

figure(footprintsCenteredY(z));
set(gcf,'Name',sprintf('footprintsCenteredY %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
title(sprintf('footprintsCentered %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));


    %%%%load pixelwise behavior data here
    load([pathname files(alluse(z)).dir '\' files(alluse(z)).behavPts],'pixResp');   
   behavResp{z} = pixResp;
   
   %%%%%%load pixmaps for passives!!!!!!!!
    
   
    %%%pixResp(x,y,timepoint,top/bottom/top-bottom)
    %%%maybe subtract off baseline??
    figure(loc1timecourse(z)); 
    set(gcf,'Name',sprintf('location1timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    mtit(sprintf('location1timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    for i = 1:16  
        subplot(4,4,i), imagesc((pixResp(:,:,i,1)-pixResp(:,:,6,1)),[-0.3 0.3])
        colormap jet
        if i==1
         title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))   
        end
    end;
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
     
    
    figure(loc0timecourse(z));
     set(gcf,'Name',sprintf('location0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
   mtit(sprintf('location0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
     for i = 1:16  
        subplot(4,4,i), imagesc((pixResp(:,:,i,2)-pixResp(:,:,6,2)),[-0.3 0.3])
       colormap jet
               if i==1
         title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))   
        end
    end;
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
 
    
    figure(loc1_0timecourse(z));
    set(gcf,'Name',sprintf('location1-0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    mtit(sprintf('location1_0timecourse %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    for i = 1:16  
        subplot(4,4,i), imagesc(pixResp(:,:,i,3),[-0.3 0.3])
    colormap jet
            if i==1
         title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))   
        end
    end;  %location 1-0  
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
            if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
  

    
    
    %what is best timepoint to use? 8 or 9 look good (400-600ms? after onset)  
    
    timepts = -1:0.2:2;
    
    timepoint = 9; %select timepoint for behavioral response

     
 %%%assign pixelwise response for top and bottom locations and for top-bottom
 %%%subtract off response at t=0 for locatoin 1 and 0
        imgLocation1 = squeeze((pixResp(:,:,timepoint,1)-pixResp(:,:,6,1))); %location1?
        imgLocation0 = squeeze((pixResp(:,:,timepoint,2)-pixResp(:,:,6,2))); %location0
        imgLocation1_0 = squeeze(pixResp(:,:,timepoint,3)); %location 1-0

 
 %%%plot figures (single timepoint from each session) defined above     
    figure(location1fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1,[-0.3,0.3])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation0,[-0.3,0.3])
    colormap jet
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    set(gca,'ytick',[],'xtick',[])
    axis equal
    
    figure(location1_0fig)
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1_0,[-0.3,0.3])
    colormap jet
    %xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    xlabel(sprintf('depth %s um',depth{z}))
    set(gca,'ytick',[],'xtick',[])
    axis equal
 
    %%%plot receptive field locations on stimulus positions
       figure (RFlocations{z})   
       set(gcf,'Name',sprintf('RF locations %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    plot(yAll{z}(~centered1'),xAll{z}(~centered1'),'k.'); hold on;
    plot(yAll{z}(centered1' ),xAll{z}(centered1'),'g.');
    axis equal;  axis([0 72 0 128]); hold on
    circle(34,0.625*128-2,12);circle(34,0.375*128-2,12); set(gca,'Xtick',[]); set(gca,'Ytick',[]);
%            if exist('savepsfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',savepsfile,'-append');
%         end

    %%%plot receptive field locations on stimulus positions for each day
       figure (RFlocations2) 
    subplot(rows,ceil(numAni),cnt)
    imagesc(imgLocation1_0,[-0.3,0.3])
    set(gca,'ytick',[],'xtick',[]);
    set(gcf,'Name',sprintf('RF locations %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
    plot(yAll{z}(~centered1'),xAll{z}(~centered1'),'k.'); hold on;
    plot(yAll{z}(centered1' ),xAll{z}(centered1'),'g.');
    axis equal;  axis([0 72 0 128]); hold on
    circle(34,0.625*128-2,12);circle(34,0.375*128-2,12); set(gca,'Xtick',[]); set(gca,'Ytick',[]);
    xlabel(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))

    
 %%%%first sumary fig (see labels)   
      figure(summaryFig(z))
      set(gcf,'Name',sprintf('summary %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('summary %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel = {'topoX','topoY','behavResp','centeredFootprintsY'};
      for t=[4 1 2 3]
    subplot(2,2,t);
    
    if t==1  %show topox
        imshow(polImgX{z});
        %colormap(hsv);
    elseif t==2 %show topoY
        imshow(polImgY{z});
        %colormap(hsv); 
    elseif t==3 %show behavior resp (location 1-0)
        imshow(behavResp{z}(:,:,timepoint,3),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        %colormap hsv
        colormap (jet);
    elseif t==4 %usenonzerocentered    %%% color with y
       draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
       
       colorbar ('off');
    end;
if t==1
    title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    xlabel(figLabel{t});
else
     title(figLabel{t});
         colormap (jet);
end        
      end;
        if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
      
          figure(FootprintsFig(z))
      set(gcf,'Name',sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel2 = {'allFootprintsX','allFootprintsY','centeredFootprintsX','centeredFootprintsY','behavResp_location1','behavResp_location0'};
      for t=1:6
    subplot(3,2,t);
    
    if t==1  %show all footprints, color x phase
      draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==2 %show all footprints, color y phase
      draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==3  %show 'centered' footprints, color x phase
     draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==4 %show 'centered' footprints, color y phase
    draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==5 %show behavior resp (location 1)
        imshow((behavResp{z}(:,:,timepoint,1)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);
    elseif t==6 %show behavior resp (location 0)
        imshow((behavResp{z}(:,:,timepoint,2)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);

    end;
if t==1
    title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    xlabel(figLabel2{t});
else
     title(figLabel2{t});
         colormap (jet);
end 

      end;  
        if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end
        
        
           figure(topoAndFootprintsFig(z))
      set(gcf,'Name',sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel3 = {'allFootprintsX','centeredFootprintsX','polarmapX','allFootprintsY','centeredFootprintsY','polarmapY','behavResp_location1','behavResp_location0','behavResp_location 1-0'};
      for t=1:9
    subplot(3,3,t);
    
    if t==1  %show all footprints, color x phase
      draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==4 %show all footprints, color y phase
      draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==2  %show 'centered' footprints, color x phase
     draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==5 %show 'centered' footprints, color y phase
    draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==7 %show behavior resp (location 1)
        imshow((behavResp{z}(:,:,timepoint,1)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);
    elseif t==8 %show behavior resp (location 0)
        imshow((behavResp{z}(:,:,timepoint,2)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);
    elseif t==3  %show topox
        imshow(polImgX{z});
        %colormap(hsv);
    elseif t==6 %show topoY
        imshow(polImgY{z});
        %colormap(hsv); 
    elseif t==9 %show behavior resp (location 1-0)
        imshow(behavResp{z}(:,:,timepoint,3),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        %colormap hsv
        colormap (jet);   
    end;
if t==1
    title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    xlabel(figLabel3{t});
else
     title(figLabel3{t});
         %colormap (jet);
end 

      end;  
        if exist('savepsfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',savepsfile,'-append');
        end       
 

           figure(topoAndFootprintsFig2(z))
      set(gcf,'Name',sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      mtit(sprintf('footprints %s %s',files(alluse(z)).subj, files(alluse(z)).expt));
      figLabel3 = {'allFootprintsX','centeredFootprintsX','polarmapX',[],'allFootprintsY','centeredFootprintsY','polarmapY','centeredCellsRF','behavResp_location1','behavResp_location0','behavResp_location 1-0', 'footprints tossed'};
      for t=[12 5 6 1 2 9 10 3 7 11 8];
    subplot(3,4,t);
    
    if t==1  %show all footprints, color x phase
      draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==5 %show all footprints, color y phase
      draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzero, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==2  %show 'centered' footprints, color x phase
     draw2pSegs(usePts,mapx{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapx{z}))),[pi/2  (2*pi -pi/4)]*128/(2*pi));
     colorbar ('off');
    elseif t==6 %show 'centered' footprints, color y phase
    draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    elseif t==9 %show behavior resp (location 1)
        imshow((behavResp{z}(:,:,timepoint,1)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);
    elseif t==10 %show behavior resp (location 0)
        imshow((behavResp{z}(:,:,timepoint,2)-behavResp{z}(:,:,6,1)),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        colormap (jet);
    elseif t==3  %show topox
        imshow(polImgX{z});
        %colormap(hsv);
    elseif t==7 %show topoY
        imshow(polImgY{z});
        %colormap(hsv); 
    elseif t==11 %show behavior resp (location 1-0)
        imshow(behavResp{z}(:,:,timepoint,3),[-0.3,0.3])
        hold on
        plot([cropy(1) cropy(1) cropy(2) cropy(2) cropy(1)], [cropx(1) cropx(2) cropx(2) cropx(1) cropx(1)],'k','linewidth',2);
        %colormap hsv
        colormap (jet);  
    elseif  t==8 %cells maped onto stim position
  subplot(3,4,[4 8 ]);   
    plot(yAll{z}(~centered1'),xAll{z}(~centered1'),'k.'); hold on;
    plot(yAll{z}(centered1' ),xAll{z}(centered1'),'g.');
    axis equal;  axis([0 72 0 128]); hold on
    circle(34,0.625*128-2,12);circle(34,0.375*128-2,12); set(gca,'Xtick',[]); set(gca,'Ytick',[]);
  elseif  t==12 %footprints for thrown away celss (coloredY)
    draw2pSegs(usePts,mapy{z},hsv,size(meanShiftImg),intersect(usenonzeroNotCentered, find(~isnan(mapy{z}))),[pi/2  (2*pi -pi/4)]*72/(2*pi));
     colorbar ('off');
    end;
if t==1
    title(sprintf('%s %s',files(alluse(z)).expt,files(alluse(z)).subj))
    xlabel(figLabel3{t});

else
     title(figLabel3{t});
       %  colormap (jet);
end 

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

figure(RFlocations2)
mtit('RF locations')
set(gcf,'Name',sprintf('RF locations all'));
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

