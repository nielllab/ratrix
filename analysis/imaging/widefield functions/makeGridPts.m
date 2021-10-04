%%% makeGridPts
%%% multipurpose program to help with map alignment for widefield
%%% 1) allows generation of a new reference map (for alignment)
%%% 2) allows adjustment of map overlay grid
%%% 3) allows selection of new points file for subsequent analysis
%%%
%%% cmn + dmn 02/21

close all
clear all
warning off

%%%
[f p] = uigetfile('*.m','batch file')

run(fullfile(p,f))

%batchEnrichmentALL %enter batch file
cd(pathname)

%filter based on fields of batch file that define the animals you want-
%control or enrichment
alluse = find(strcmp({files.cond},'enrichment') & strcmp({files.notes},'good imaging session'))
%% run doTopography (use this one to average all sessions that meet criteria)
length(alluse)
allsubj = unique({files(alluse).subj})

%%% just one subject
use = alluse;
s = 1;

display('reference map is the average map that data is aligned to')
useReference = input('create new alignment reference (0) or use an existing one (1) : ');

%useReference=1; %%% use a reference map to align to? if not, just align to a single map
referenceMapName = 'referenceMap.mat'
mapOverlayName = 'G:\EnrichmentWidefield\enrichmentOverlay021321.mat';

if useReference ==0
    [f p] = uiputfile('*.mat','save reference file')
    if f~=0
        save(fullfile(p,f),'avgmap4d','avgmap')
    end
end

x0=0; y0=0; sz=128;
doTopography;

%%% adjust overlay grid
load(mapOverlayName)
done = 0;
display('use arrows to move grid')
display('use a to magnify, z to shrink')
display('any other key to quit');

figure
while ~done
    
    for m=1:2
        subplot(2,2,m);
        
        imshow(polarMap(meanpolar{m},95));
        title(allsubj{s})
        hold on
        plot(ypts,xpts,'w.','Markersize',2)
        im = polarMap(meanpolar{m},80);
        %        imwrite(im,sprintf('polarmap%d%s', m,'.tif'), 'tif')
    end
       
    subplot(2,2,3)
    imshow(avgmap);
    hold on
    plot(ypts,xpts,'w.','Markersize',2)
    
    subplot(2,2,4);
    imAmp = max(abs(meanpolar{1}),abs(meanpolar{2}));
    imAmp=imAmp/(prctile(imAmp(:),90));
    imAmp(imAmp>1)=1;imAmp = imAmp.^1.5;
    showGradient(allPhase,imAmp,xpts,ypts);
    hold on
    plot(ypts,xpts,'w.','Markersize',2)
    
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter'))
    % 28 leftarrow
    % 29 rightarrow
    % 30 uparrow
    % 31 downarrow
    
    if value == 28
        ypts = ypts-1;
    elseif value == 29
        ypts = ypts+1;
    elseif value == 30
        xpts =xpts-1;
    elseif value == 31
        xpts = xpts+1;
    elseif value == 97
        xpts = xpts*1.01;
        ypts = ypts*1.01;
    elseif value == 122
        xpts = xpts/1.01;
        ypts = ypts/1.01;
    else
        done = 1
    end
    
end

[f p] = uiputfile('*.mat','save overlay')
if f~=0
    save(fullfile(p,f),'xpts','ypts')
end



%%% select defined points for analysis
npts = input('how many points to select');
figure
imAmp = max(abs(meanpolar{1}),abs(meanpolar{2}));
imAmp=imAmp/(prctile(imAmp(:),90));
imAmp(imAmp>1)=1;imAmp = imAmp.^1.5;
showGradient(allPhase,imAmp,xpts,ypts);
hold on
plot(ypts,xpts,'w.','Markersize',2)
    
for i = 1:npts;
    [y(i) x(i)] = ginput(1);
    plot(y(i),x(i),'w*');
end

[f p] = uiputfile('*.mat','save pts')
if f~=0
    save(fullfile(p,f),'x','y')
end




