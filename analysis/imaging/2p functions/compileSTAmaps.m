%%% compiles data from sparse noise analysis in Octo data
%%% cmn 2019

close all
clear all

fullfigs = 0; %%% 0 - for abbreviated figures, 1 - full figures

%%% select files to analyze based on compile file

%%% select files to analyze based on compile file
stimlist = {'sparse noise 1','sparse noise 2'};  %%% add others here
for i = 1:length(stimlist)
    display(sprintf('%d) %s',i,stimlist{i}))
end
stimnum = input('which stim : ');
stimname = stimlist{stimnum};

xyswap = 1;  %%% swap x and y for retinotopy?

if strcmp(stimname,'sparse noise 2')
    nsz = 4;
else
    nsz = 3;
end

%batch_file = 'ForBatchFileAngeliquewregioned.xlsx';

[batch_fname batch_pname] = uigetfile('*.xlsx','.xls batch file');
batch_file = fullfile(batch_pname,batch_fname);

[sbx_fname acq_fname mat_fname quality regioned runBatch metadata] = compileFilenames(batch_file,stimname, '');

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';

if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2;delete(psfile);end
end

% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = strcmp(quality{i},'Y');
end


useN = find(usefile); clear goodfile
n=0;
display(sprintf('%d recordings, %d labeled good',length(usefile),length(useN)));



%%% collect filenames and make sure the files are there
for i = 1:length(useN)
%for i = 1:3
    try
        base = mat_fname{useN(i)}(1:end-4);
        goodfile{n+1} = dir([base '*']).name;
        goodfileN(n+1) = useN(i);
        n= n+1;
    catch
        sprintf('cant do %s',mat_fname{useN(i)})
    end
end
mat_fname = goodfile;

nfiles = length(mat_fname);
display(sprintf('%d good files found',nfiles))

rLabels = {'OGL','Plex','IGL','Med'};

    %%% threshold for good RF
    zthresh = 5.5;
    
    %%% threshold for # of units to include data
    nthresh = 5;

    figure
    subplot(2,2,1)
    plot(metadata.eyeSize,metadata.lobeSize,'o');
    xlabel('eyeSize'); ylabel('lobeSize');
    axis equal

    subplot(2,2,2)
    hist(metadata.lobeSize);
    xlabel('lobe size mm')
    xlim([0 1.1*max(metadata.lobeSize)]);
    
    subplot(2,2,3)
    hist(metadata.screenDist);
    xlabel('screen distance mm')
    xlim([0 1.1*max(metadata.screenDist)]);
    
    
    brainScale = metadata.lobeSize.*metadata.screenDist;
    subplot(2,2,4)
    hist(brainScale);
    xlabel('screenDist * lobeSize');
    xlim([0 1.1*max(brainScale)]);
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

for f = 1:nfiles
    n = goodfileN(f);
    fname_clean = strrep(mat_fname{f},'_',' '); %%% underscores mess up titles so this is a better filename to use
    fname_clean = fname_clean(1:20);
    meta_label = sprintf('pupil %0.1f lobe %0.1f dist %0.0f %s %s',metadata.eyeSize(n), metadata.lobeSize(n),metadata.screenDist(n), metadata.illumination{n}, metadata.lobeOrientation{n});
    fname_clean = [fname_clean ' ' meta_label]

    eye(f) = metadata.eyeSize(n);
    lobe(f) = metadata.lobeSize(n);
    %%% load data
   % mat_fname{f}
   clear xb yb
   warning('off','MATLAB:load:variableNotFound')
   
   load(mat_fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg','stas')
   warning('on','MATLAB:load:variableNotFound')


    
    %%% select RFs that have zscore(ON, OFF) greater than zthresh
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    
%     %%% only ON or OFF (no mixed)
%     useOn = find(zscore(:,1)>zthresh & zscore(:,2)>-zthresh);  
%     useOff = find(zscore(:,2)<-zthresh & zscore(:,1)<zthresh);

    %%% if there's no Off responsive (or On) just use the first three units.
    %%% this allows subsequent code to run, and can be filtered out later
    %%% based on nOn and nOff
    if length(useOn)<3
        useOn =1:3;
    end
    if length(useOff)<3
        useOff = 1:3;
    end
    
    useOnOff = intersect(useOn,useOff);
    notOn = find(zscore(:,1)<zthresh); notOff = find(zscore(:,2)>-zthresh);
    
    fractionResponsive(f)=length(use)/length(zscore);
    nOn(f) = length(useOn);
    nOff(f) = length(useOff);
    nTot(f) = length(zscore);
    
    %%% do topographic maps for X and Y, for both On and Off responses
    if xyswap ==1
        xptsnew = ypts;
        yptsnew = xpts;
    else
        xptsnew = xpts;
        yptsnew = ypts;
    end
    %%% center RF positions
%     x0 = nanmedian(rfx(useOn,1));
%     y0 = nanmedian(rfy(useOn,1));
 

    rfxs = [rfx(useOn,1); rfx(useOff,2)];
    rfys = [rfy(useOn,1); rfy(useOff,2)];
    x0 = nanmedian(rfxs);
    y0 = nanmedian(rfys);
    
    axLabel = {'X','Y'};
    onoffLabel = {'On','Off'};
    figure
    for ax = 1:2
        for rep = 1:2;
            subplot(2,2,2*(rep-1)+ax)
            
            imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
            hold on
            if rep==1
                data = useOn;
            else data = useOff;
            end
            
            for i = 1:length(data)
                if ax ==1
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfx(data(i),rep)-x0,-25, 25, jet));
                else
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfy(data(i),rep)-y0,-25, 25, jet));
                end
            end
            if ax ==1 & rep==1
                title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
            else
                title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
            end
            
        end
    end
    sgtitle(fname_clean)
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(rfx(useOn,1),rfy(useOn,1),'r.')
    hold on
    plot(rfx(useOff,2),rfy(useOff,2),'b.')
    axis equal; axis([0 256 0 192]); 
    title('rf locations')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        pixpercm = 256/95;  %%% screen is 256 pix, 95mm wide
    rf_az = (rfx - 128)/pixpercm;
    rf_el = (rfy - 96)/pixpercm;
    rf_az = atan2d(rf_az, metadata.screenDist(n));
    rf_el = atan2d(rf_el, metadata.screenDist(n));
    
       figure
    plot(rf_az(useOn,1),rf_el(useOn,1),'r.')
    hold on
    plot(rf_az(useOff,2),rf_el(useOff,2),'b.')
    axis equal; axis([-90 90 -70 70]); 
    title('rf locations deg')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        regionID = zeros(size(xpts));
           for r = 1:length(xb)
            if length(xb{r})>0
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                regionID(inRegion) = r;
            end       
        end
    
    
    
    zthreshRF = 5.5;
    useOnRF = find(zscore(:,1)>zthreshRF); useOffRF = find(zscore(:,2)<-zthreshRF);
    if f ==1
        p_on = []; wx_on = [];wy_on = []; sess_on = []; region_on = [];z_on=[];
        p_off = []; wx_off = [];wy_off = []; sess_off = []; region_off = []; z_off = [];
    end
    for rfn= 1:length(useOnRF)
        p = fitOctorf(stas(:,:,useOnRF(rfn),1));
        p_on = [p_on; p]; sess_on = [sess_on; f]; region_on = [region_on; regionID(useOnRF(rfn))]; z_on = [z_on; zscore(useOnRF(rfn),1)];
    end
    dist = metadata.screenDist(n);
    [center_az center_el] = octoPix2Deg(p_on(:,3),p_on(:,4),dist);
    edge_az = octoPix2Deg(p_on(:,3)+ p_on(:,5),p_on(:,4),dist);
    wx_on = [wx_on ;edge_az- center_az];
    [center_az edge_el] = octoPix2Deg(p_on(:,3),p_on(:,4)+ p_on(:,6),dist);
    wy_on = [wy_on  ;edge_el - center_el];
    
    
    %%% fit OFF receptive fields
    for rfn= 1:length(useOffRF)
        p = fitOctorf(stas(:,:,useOffRF(rfn),2));
        p_off = [p_off; p];sess_off = [sess_off; f]; region_off = [region_off; regionID(useOffRF(rfn))]; z_off = [z_off; zscore(useOffRF(rfn),2)];
    end
    dist = metadata.screenDist(n);
    [center_az center_el] = octoPix2Deg(p_off(:,3),p_off(:,4),dist);
    edge_az = octoPix2Deg(p_off(:,3)+ p_off(:,5),p_off(:,4),dist);
    wx_off = [wx_off; edge_az- center_az];
    [center_az edge_el] = octoPix2Deg(p_off(:,3),p_off(:,4)+ p_off(:,6),dist);
    wy_off = [wy_off ; edge_el - center_el];
    
    figure
    plot(wx_on(sess_on ==f), wy_on(sess_on==f),'r.'); 
    hold on
    plot(wx_off(sess_off ==f), wy_off(sess_off==f),'b.'); axis([0 20 0 20]);
    xlabel('rf width x deg'); ylabel('rf width y deg');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    
    %%% plot zscore check
    figure
    for rep = 1:2
        subplot(1,2,rep);
        plot(zscore(:,rep),rfx(:,rep),'.');
        xlabel('zscore'); ylabel('rfx');
        hold on
        plot([zthresh zthresh], [min(rfx(:,rep)) max(rfx(:,rep))],'r');
        plot(-[zthresh zthresh], [min(rfx(:,rep)) max(rfx(:,rep))],'r');
    end
    sgtitle('zscore check');
   if fullfigs
       if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   end 
    
    %%% calculate amplitude of response based on size response tuning(cells,on/off,size, time)
    %%% average over 3 spot sizes and response time window
    amp = nanmean(nanmean(tuning(:,:,1:end-1,8:15),4),3);
    
    %%% positive rectify amp, to calculate preference index for ON/OFF
    ampPos = amp; ampPos(ampPos<0)=0;
    onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
    onOff(notOn)=-1; onOff(notOff)=1;
    
    %%% histogram of On/Off selectivity
    onOffHist = hist(onOff(use),[-1:0.1:1]);
    figure
    bar([-1:0.1:1],onOffHist); xlabel('on off pref')
    
   if fullfigs
       if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   end   
    %%% calculate size tuning curve, by averaging over peak response window
    sz_tune = nanmean(tuning(:,:,:,8:15),4);  %%% sz_tune(cell,on/off,size)
    
    %%% calculate preferred size as weighted average
    if nsz==3
        szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3)./sum(sz_tune(:,:,1:3),3);
    else
        szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3  + sz_tune(:,:,4)*4)./sum(sz_tune(:,:,1:4),3);
    end
    
    %%% calculate distance correlation of on/off pref
    clear szPairs onOffPairs dist
    n=0;
    %%% loop over all pairs of good cells and get pairwise on/off pref, and  size pref
    for i = 1:length(use)-1;
        for j=i+1:length(use)
            n=n+1;
            dist(n) = sqrt((xpts(use(i))-xpts(use(j))).^2 + (ypts(use(i))-ypts(use(j))).^2 );
            onOffpairs(n,1) = onOff(use(i));
            onOffpairs(n,2) = onOff(use(j));
            szPairs(n,1) = szPref(use(i),1);
            szPairs(n,2) = szPref(use(j),2);
        end
    end
    %
    %     figure
    %     plot(dist,abs(onOffpairs(:,1)-onOffpairs(:,2)),'.');
    
    %%% for each range of distances, calculate correlation coeffs
    %%% similarity coeff
    onoffSim = 1 - 0.5*abs(onOffpairs(:,1)-onOffpairs(:,2));
    bins = 0:25:200;  %%% distance bins
    for i = 1:length(bins)-1;
        %%% choose pairs in range
        inrange = dist>bins(i) & dist<bins(i+1);
        %%% similarity coefficient
        simHist(i,f) = mean(onoffSim(inrange));
        %%% correlation coefficient (OnOff)
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        if length(cc)==1
            simCorr(i,f)=NaN;
        else
            simCorr(i,f) = cc(2,1);
        end
        %%% correlation coefficient (size)
        cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        if length(cc)==1
            szCorr(i,f)=NaN;
        else
            szCorr(i,f) = cc(2,1);
        end
    end
    
    %%% do the same thing, but with shuffled distances
    distShuff = dist(ceil(n*rand(n,1)));
    for i = 1:length(bins)-1;
        inrange = distShuff>bins(i) & distShuff<bins(i+1);
        simHistShuff(i,f) = mean(onoffSim(inrange));
        
        cc = corrcoef(onOffpairs(inrange,1),onOffpairs(inrange,2));
        if length(cc)==1
            simCorrShuff(i,f)=NaN;
        else
            simCorrShuff(i,f) = cc(2,1);
        end
        
        cc = corrcoef(szPairs(inrange,1),szPairs(inrange,2));
        if length(cc)==1
            szCorrShuff(i,f)=NaN;
        else
            szCorrShuff(i,f) =cc(2,1);
        end
    end
    
    %     figure
    %     plot(simHist(:,f)); hold on; plot(simHistShuff(:,f));
    %
    
    %%% plot on off correlation vs dist
    figure
    plot(bins(2:end)*2,simCorr(:,f)); hold on; plot(bins(2:end)*2,simCorrShuff(:,f),'r:');
    ylabel('On / Off correlation');
    xlabel('distance (um)');
    title(mat_fname{f})
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% plot mean size tuning for on and off
    figure
    subplot(2,2,1)
    plot(squeeze(mean(tuning(useOn,1,:,:),1))');
    colororder(jet(nsz+1)*0.75)
    title('ON')
    
    subplot(2,2,2)
    plot(squeeze(mean(tuning(useOff,2,:,:),1))');
    colororder(jet(nsz+1)*0.75)
    title('OFF')
   if fullfigs
       if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   end 
    %%% store tuning for all files
    szTuning(1,:,:,f) = nanmean(tuning(useOn,1,:,:),1);
    szTuning(2,:,:,f) = nanmean(tuning(useOff,2,:,:),1);
    
    %%% retinotopy
    
    
    figure
    
    subplot(2,2,1)
    plot(rfx(useOff,2),xptsnew(useOff),'.'); xlabel('RFx location'); ylabel('cell x location')
    title('off')
    
    subplot(2,2,2)
    plot(rfx(useOff,2),yptsnew(useOff),'.'); xlabel('RF x location'); ylabel('cell y location')
    title('off')
    
    subplot(2,2,3)
    plot(rfx(useOn,1),xptsnew(useOn),'.'); xlabel('RFx location'); ylabel('cell x location')
    title('on')
    
    subplot(2,2,4)
    plot(rfx(useOn,1),yptsnew(useOn),'.'); xlabel('RF x location'); ylabel('cell y location')
    title('on')
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    
    %%% mean rf centers
    mx = mean(rfx(useOn,1),1);
    my = mean(rfy(useOn,1),1);
    
        %%% create values for shuffle
    n= length(rfx);
    xshuff = xptsnew(ceil(n*rand(n,1)));
    yshuff = yptsnew(ceil(n*rand(n,1)));
    
    ethresh = 20;
    [beta(1,1,:,f) topoErr(1,1,f) topoCC(1,1,f) bad] = fitTopo(xptsnew(useOn),yptsnew(useOn), rf_az(useOn,1),ethresh)
    [beta(1,2,:,f) topoErr(1,2,f) topoCC(1,2,f) bad] = fitTopo(xptsnew(useOn),yptsnew(useOn), rf_el(useOn,1),ethresh)
    [beta(2,1,:,f) topoErr(2,1,f) topoCC(2,1,f) bad] = fitTopo(xptsnew(useOff),yptsnew(useOff), rf_az(useOff,2),ethresh)
    [beta(2,2,:,f) topoErr(2,2,f) topoCC(2,2,f) bad] = fitTopo(xptsnew(useOff),yptsnew(useOff), rf_el(useOff,2),ethresh)

    try
        [beta_sh(1,1,:,f) topoErrshuff(1,1,f) topoCCshuff(1,1,f) bad] = fitTopo(xshuff(useOn),yshuff(useOn), rf_az(useOn,1),ethresh)
        [beta_sh(1,2,:,f) topoErrshuff(1,2,f) topoCCshuff(1,2,f) bad] = fitTopo(xshuff(useOn),yshuff(useOn), rf_el(useOn,1),ethresh)
        
        [beta_sh(2,1,:,f) topoErrshuff(2,1,f) topoCCshuff(2,1,f) bad] = fitTopo(xshuff(useOff),yshuff(useOff), rf_az(useOff,2),ethresh)
        [beta_sh(2,2,:,f) topoErrshuff(2,2,f) topoCCshuff(2,2,f) bad] = fitTopo(xshuff(useOff),yshuff(useOff), rf_el(useOff,2),ethresh)
    catch
        display('not enough points for shuffle topo OFF')
        topoErrshuff(:,:,f) = NaN; topoCCshuff(:,:,f) = NaN;
    end
    
    
%     %%% calculate correlation coeffs for RF location and cell location
%     cc = corrcoef(rfx(useOn,1)-mx,xptsnew(useOn));
%     topoCC(1,1,f) = cc(2,1);
%     cc = corrcoef(rfy(useOn,1)-my,yptsnew(useOn));
%     topoCC(2,1,f) = -cc(2,1);
%     cc = corrcoef(rfx(useOff,2)-mx,xptsnew(useOff));
%     topoCC(1,2,f) = cc(2,1);
%     cc = corrcoef(rfy(useOff,2)-my,yptsnew(useOff));
%     topoCC(2,2,f) = -cc(2,1);
%     
% 
%     
%     cc = corrcoef(rfx(useOn,1)-mx,xshuff(useOn));
%     topoCCshuff(1,1,f) = cc(2,1);
%     cc = corrcoef(rfy(useOn,1)-my,yshuff(useOn));
%     topoCCshuff(2,1,f) = -cc(2,1);
%     cc = corrcoef(rfx(useOff,2)-mx,xshuff(useOff));
%     topoCCshuff(1,2,f) = cc(2,1);
%     cc = corrcoef(rfy(useOff,2)-my,yshuff(useOff));
%     topoCCshuff(2,2,f) = -cc(2,1);
    
        %%% diagnostic of topography
        figure
        plot(topoCC(:,:,f)); hold on; plot(topoCCshuff(:,:,f),':');
        title('topo CC'); set(gca,'Xtick',[1 2]); set(gca,'Xticklabel',{'x','y'})
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
       
        figure
        plot(topoErr(:,:,f)); hold on; plot(topoErrshuff(:,:,f),':');
        title('topo err'); set(gca,'Xtick',[1 2]); set(gca,'Xticklabel',{'x','y'})
             if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    
    %%% center RF positions
    x0 = nanmedian(rfx(useOn,1));
    y0 = nanmedian(rfy(useOn,1));
    
    figure
    subplot(1,2,1)
    plot(xpts(useOn),rfx(useOn,1)-x0,'r.'); hold on;
    plot(xpts(useOff),rfx(useOff,2)-x0,'b.'); %ylim([-30 30]); axis square
    title('X topography'); legend('ON','OFF')
    xlabel('x location'); ylabel('x RF');
    ylim([-50 50])
   
    subplot(1,2,2)
    plot(ypts(useOn),rfy(useOn,1)-y0,'r.');hold on;
    %ylim([-30 30]); axis square
    plot(ypts(useOff),rfy(useOff,2)-y0,'b.');
    title('Y topography'); legend('ON','OFF')
    xlabel('y location'); ylabel('y RF');
    ylim([-50 50])

    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% map of On/Off ratio
    figure
    imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    hold on
    for i = 1:length(use)
        plot(xpts(use(i)),ypts(use(i)),'o','Color',cmapVar(onOff(use(i)),-0.5, 0.5, jet));
    end
    title('on off ratio')
   if fullfigs
       if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   end   
    
    %     %%% size map for On
    %     figure
    %     imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    %     hold on
    %     for i = 1:length(useOn)
    %         plot(xpts(useOn(i)),ypts(useOn(i)),'o','Color',cmapVar(szPref(useOn(i),1),1.5 , 2.5, jet));
    %     end
    %     title('size pref On')
    %     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    %
    %     %%% size map for Off
    %     figure
    %     imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    %     hold on
    %     for i = 1:length(useOff)
    %         plot(xpts(useOff(i)),ypts(useOff(i)),'o','Color',cmapVar(szPref(useOff(i),2),1.5 , 2.5, jet));
    %     end
    %     title('size pref OFF')
    %     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    %
    
    
    %%% region-wise analysis
    if ~exist('xb','var')
        display(sprintf('no regioning for %s',mat_fname{f}))
    else
        
        %%% show regions
        col = 'rgbc';
        figure
        imagesc(meanGreenImg); hold on
        for r = 1:length(xb)
            if length(xb{r})>0
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                plot(xpts(inRegion),ypts(inRegion),'.','Color',col(r));
            end       
        end
        axis equal
   if fullfigs
       if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   end    
        
        %%% compile data
        for r = 1:4
            if r<=length(xb) && length(xb{r})>0 && sum(inpolygon(xpts,ypts,xb{r},yb{r}))>nthresh
                inRegion = inpolygon(xpts,ypts,xb{r},yb{r});
                fracUsed(r,f) = length(intersect(use, find(inRegion)))/sum(inRegion);
                nUsed(r,f) = length(intersect(use, find(inRegion)));
                fracOnOff(r,f,1) = length(intersect(useOn, find(inRegion)))/sum(inRegion);
                fracOnOff(r,f,2) = length(intersect(useOff, find(inRegion)))/sum(inRegion);

                onOffHistAll(r,:,f) = hist(onOff(intersect(use,find(inRegion))),[-1:0.1:1])/ length(intersect(use,find(inRegion)));
                if length(intersect(useOn, find(inRegion)))>nthresh
                    onSizeDist(r,1:5,f) = hist(szPref(intersect(useOn, find(inRegion)),1),1:0.5:3)/length(intersect(useOn, find(inRegion)));
                    regionTuning(r,1,1:size(tuning,3),1:size(tuning,4),f) = nanmean(tuning(intersect(useOn, find(inRegion)),1,:,:),1);
                else
                    onSizeDist(r,1:5,f) = NaN;
                    regionTuning(r,1,1:size(tuning,3),1:size(tuning,4),f) =NaN;
                end
                
                if length(intersect(useOff, find(inRegion)))>nthresh                   
                    offSizeDist(r,1:5,f) = hist(szPref(intersect(useOff, find(inRegion)),2),1:5)/length(intersect(useOff, find(inRegion)));
                    regionTuning(r,2,1:size(tuning,3),1:size(tuning,4),f) = nanmean(tuning(intersect(useOff, find(inRegion)),2,:,:),1);
                else
                    offSizeDist(r,1:5,f) = NaN;
                   regionTuning(r,2,1:size(tuning,3),1:size(tuning,4),f)  = NaN;
                end
            else
                fracUsed(r,f) = NaN;
                nUsed(r,f) = NaN;
                fracOnOff(r,f,:) = NaN;
                onSizeDist(r,1:5,f) = NaN;
                offSizeDist(r,1:5,f) = NaN;
                onOffHistAll(r,:,f) =NaN;
                regionTuning(r,1:2,1:size(tuning,3),1:size(tuning,4),f) = NaN;
                
            end
        end
        
        %%% fraction used figure
%         figure
%         bar(fracUsed(:,f)); ylabel('fraction'); title('fraction used'); xlabel('region'); ylim([0 1])
%         if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%         
        %%% on/off preference figure
        figure
        for r = 1:4
            subplot(2,2,r)
            bar(-1:0.1:1,onOffHistAll(r,:,f)); ylim([0 1]); xlabel('on off index'); title(rLabels{r});
        end
        %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% ON size preference
        figure
        for r = 1:4
            subplot(2,4,r)
            bar(1:5,onSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' ON']);
        end
        %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% OFF size preference
       % figure
        for r = 1:4
            subplot(2,4,r+4)
            bar(1:5,offSizeDist(r,:,f)); ylim([0 1]); xlabel('size'); title([rLabels{r} ' OFF']);
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% ON size tuning
        figure
        for r = 1:4
            subplot(2,4,r);
            plot(squeeze(regionTuning(r,1,:,:,f))'); title([rLabels{r} ' ON']); ylim([-0.1 0.2])
        end
        colororder(jet(nsz+1)*0.75)
        %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% Off size tuning
       % figure
        for r = 1:4
            subplot(2,4,r+4);
            plot(squeeze(regionTuning(r,2,:,:,f))'); title([rLabels{r} ' OFF']); ylim([-0.1 0.2])
        end
        colororder(jet(nsz+1)*0.75)
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        
    end
    
    close all
end

%%% plot On/Off correlation as function of distance
centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(simCorr,2),nanstd(simCorr,[],2)/sqrt(nfiles));
hold on
errorbar(centers*2,nanmean(simCorrShuff,2),nanstd(simCorrShuff,[],2)/sqrt(nfiles),'r:');
ylabel('On / Off correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% size prefernce correlation
centers = 0.5*(bins(1:end-1) + bins(2:end))
figure
errorbar(centers*2,nanmean(szCorr,2),nanstd(szCorr,[],2)/sqrt(nfiles));
hold on
errorbar(centers*2,nanmean(szCorrShuff,2),nanstd(szCorrShuff,[],2)/sqrt(nfiles),'r:');
ylabel('size pref correlation');
xlabel('distance (um)');
legend('data','shuffle');
xlim([0 400]); ylim([-0.1 0.6])
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot response timecourses
t = 0.1*((1:21)-3);  %%% time in seconds
labels = {'ON','OFF'};

col = 'bcgyr'
for rep = 1:2  %%% on vs off
    figure
    hold on
    for sz = 1:nsz+1;
        errorbar(t, squeeze(mean(szTuning(rep,sz,:,:),4))',squeeze(std(szTuning(rep,sz,:,:),[],4))'/sqrt(nfiles) );
        xlabel('sec');
        ylabel('dF/F');
    end
    colororder(jet(nsz+1)*0.75)
    xlim([-0.2 2]); ylim([-0.03 0.125])
    title(labels{rep})
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end


%%% make a legend (since shaded errorbars mess up legend
figure
for i = 1:nsz+1
    hold on
    plot(1,1,col(i));
end
legend({'3deg','6deg','12deg','full-field'});
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate mean values for topography
for rep = 1:2 %%% should select only recordings with adequate off sampling
    if rep ==1
        useTopo = nOn>100;
    else
        useTopo = nOff>100;
    end
    
    clear data
    data(:,1) = mean(topoCC(rep,:,useTopo),3);
    err(:,1) = std(topoCC(rep,:,useTopo),[],3) / sqrt(f);
    
    data(:,2) = mean(topoCCshuff(rep,:,useTopo),3);
    err(:,2) = std(topoCCshuff(rep,:,useTopo),[],3) / sqrt(f);
    
    %%% errorbar plots of topography
    figure
    barweb(data,err); ylim([0 1]);
    set(gca,'Xticklabel',{'azimuth','elevation'});
    ylabel('correlation coeff');
    legend({'data','shuffle'})
    title(['topography correlation ',onoffLabel{rep}])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

%%% calculate mean values for topography
for rep = 1:2 %%% should select only recordings with adequate off sampling
    if rep ==1
        useTopo = nOn>100;
    else
        useTopo = nOff>100;
    end
    clear data
    data(:,1) = mean(topoErr(rep,:,useTopo),3);
    err(:,1) = std(topoErr(rep,:,useTopo),[],3) / sqrt(f);
    
    data(:,2) = mean(topoErrshuff(rep,:,useTopo),3);
    err(:,2) = std(topoErrshuff(rep,:,useTopo),[],3) / sqrt(f);
    
    %%% errorbar plots of topography
    figure
    barweb(data,err); 
    set(gca,'Xticklabel',{'azimuth','elevation'});
    ylabel('correlation coeff');
    legend({'data','shuffle'})
    title(['topography error (deg) ',onoffLabel{rep}])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

%%% trying for tuning across recordings
%
% fracUsed(r,f)
% onSizeDist(r,1:5,f)
% offSizeDist(r,1:5,f)
% onOffHistAll(r,:,f)
% regionTuning(r,1,:,:,f)
% regionTuning(r,2,:,:,f)

%%% fraction responsive
figure
bar(nanmean(fracUsed,2)); %%% add error bars
title('fraction used'); set(gca,'Xtick',1:4); set(gca,'Xticklabels',rLabels); ylim([0 1])

%%% on size distribution
figure
for r = 1:4
    subplot(2,2,r);
    bar(1:0.5:3,squeeze(nanmean(onSizeDist(r,:,:),3)));
    xlabel('size'); title([rLabels{r} ' ON']);
end

%% off size distribution
figure
for r = 1:4
    subplot(2,2,r);
    bar(1:0.5:3,squeeze(nanmean(offSizeDist(r,:,:),3)));
    xlabel('size'); title([rLabels{r} ' OFF']);
end

%%% on/off bias
figure
for r = 1:4
    subplot(2,2,r)
    bar(-1:0.1:1,nanmean(onOffHistAll(r,:,:),3)); xlabel('Off - On ratio'); ylim([0 1]); title(rLabels{r})
end


%%% region tuning
labels = {'ON','OFF'};
 figure
 for rep = 1:2   
    for r = 1:4
        subplot(2,4,r+(rep-1)*4);
        plot(1:21,squeeze(nanmean(regionTuning(r,rep,:,:,:),5)));
        title([rLabels{r} ' ' labels{rep}]); ylim([-0.05 0.1])
        colororder(jet(nsz+1)*0.75)
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

illumination = {metadata.illumination{useN}};
types = {'Proj','LCDwNewGoo'};
for i = 1:2
    for j = 1:length(illumination)
        include(j) = strcmp(illumination{j},types{i});
    end
    %%% region tuning
    labels = {'ON','OFF'};
    figure
    for rep = 1:2
        
        
        for r = 1:4
            subplot(2,4,r+(rep-1)*4);
            plot(1:21,squeeze(nanmean(regionTuning(r,rep,:,:,include),5)));
            title([rLabels{r} ' ' labels{rep}]); ylim([-0.05 0.1])
            colororder(jet(nsz+1)*0.75)
        end
        sgtitle(types{i});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
end


types = {'small lobe','large lobe'};
for i = 1:2
    if i ==1
        include = metadata.eyeSize(useN)<nanmedian(metadata.eyeSize(useN))
    else
        include = metadata.eyeSize(useN)>nanmedian(metadata.eyeSize(useN))
    end
    %%% region tuning
    labels = {'ON','OFF'};
    figure
    for rep = 1:2
        
        
        for r = 1:4
            subplot(2,4,r+(rep-1)*4);
            plot(1:21,squeeze(nanmean(regionTuning(r,rep,:,:,include),5)));
            title([rLabels{r} ' ' labels{rep}]); ylim([-0.05 0.1])
            colororder(jet(nsz+1)*0.75)
        end
        sgtitle(types{i});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
end

types = {'close screen','far screen'};
for i = 1:2
    if i ==1
        include = metadata.screenDist(useN)<nanmedian(metadata.screenDist(useN))
    else
        include = metadata.screenDist(useN)>nanmedian(metadata.screenDist(useN))
    end
    %%% region tuning
    labels = {'ON','OFF'};
    figure
    for rep = 1:2
        
        
        for r = 1:4
            subplot(2,4,r+(rep-1)*4);
            plot(1:21,squeeze(nanmean(regionTuning(r,rep,:,:,include),5)));
            title([rLabels{r} ' ' labels{rep}]); ylim([-0.05 0.1])
            colororder(jet(nsz+1)*0.75)
        end
        sgtitle(types{i});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
end

types = {'low brainscale','high brainscale'};
for i = 1:2
    if i ==1
        include = brainScale(useN)<nanmedian(brainScale(useN))
    else
        include = brainScale(useN)>nanmedian(brainScale(useN))
    end
    %%% region tuning
    labels = {'ON','OFF'};
    for rep = 1:2
        figure
        
        for r = 1:4
            subplot(2,2,r);
            plot(1:21,squeeze(nanmean(regionTuning(r,rep,:,:,include),5)));
            title([rLabels{r} ' ' labels{rep}]); ylim([-0.05 0.1])
            colororder(jet(nsz+1)*0.75)
        end
        sgtitle(types{i});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
end


illumination = {metadata.illumination{useN}};
types = {'Proj','LCDwOldGoo','LCDwNewGoo'};
figure
for i = 1:3
    subplot(2,2,i)
    for j = 1:length(illumination)
        include(j) = strcmp(illumination{j},types{i});
    end
    plot(fracOnOff(:,include,1),'ro');
    hold on
    plot(nanmean(fracOnOff(:,include,1),2),'r','Linewidth',2);
    plot(fracOnOff(:,include,2),'bo');
    plot(nanmean(fracOnOff(:,include,2),2),'b','Linewidth',2);
    xlim([0.5 4.5]); ylim([0 1]);
    xlabel('layer'); ylabel('fraction');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    title(types{i});
end

layerLabels = {'OGL', 'Plex','IGL','Med'};

figure
for r = 1:4
    subplot(2,2,r)
    w_on = 0.5*(wx_on + wy_on);
    w_off = 0.5*(wx_off + wy_off);
    h_on = hist (w_on(region_on==r)',0:1:15)/length(w_on(region_on==r));
    h_off = hist (w_off(region_off==r)',0:1:15)/length(w_off(region_off==r));
    plot(h_on, 'r'); hold on; plot(h_off,'b');
    xlabel('rf radius deg'); ylabel('fraction'); legend({'ON','OFF'})
    title(layerLabels{r})
end

figure
plot(fracOnOff(:,:,1),'ro');
hold on
plot(nanmean(fracOnOff(:,:,1),2),'r','Linewidth',2);
plot(fracOnOff(:,:,2),'bo');
plot(nanmean(fracOnOff(:,:,2),2),'b','Linewidth',2);
xlim([0.5 4.5]); ylim([0 1]);
xlabel('layer'); ylabel('fraction'); 
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


figure
%plot(fracOnOff(:,:,1),'ro');
nrec = size(fracOnOff,2);
hold on
errorbar(nanmean(fracOnOff(:,:,1),2),nanstd(fracOnOff(:,:,1),[],2)/sqrt(nrec), 'r','Linewidth',2);
%plot(fracOnOff(:,:,2),'bo');
errorbar(nanmean(fracOnOff(:,:,2),2),nanstd(fracOnOff(:,:,2),[],2)/sqrt(nrec), 'b','Linewidth',2);
xlim([0.5 4.5]); ylim([0 0.6]);
xlabel('layer'); ylabel('fraction'); 
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
set(gca,'Xtick',[1 2 3 4])
set(gca,'Xticklabel',layerLabels)
legend({'ON','OFF'})


figure
plot(fractionResponsive);
xlabel('session #')
ylabel('fraction of cells responsive'); ylim([0 1]);
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

display('saving pdf')
if Opt.SaveFigs
    if ~isfield(Opt,'pPDF')
        [Opt.fPDF, Opt.pPDF] = uiputfile('*.pdf','save pdf file');
    end
    
    newpdfFile = fullfile(Opt.pPDF,Opt.fPDF);
    try
        dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end