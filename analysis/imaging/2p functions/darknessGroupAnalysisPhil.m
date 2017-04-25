%%%darknessGroupAnalysisPhil
%%%loads in darkness data and incorporates either grating data or topo data

close all
clear all

%%choose dataset
batchPhil2pSizeSelect
% batchPhil2pSizeSelect22min

path = '\\langevin\backup\twophoton\Phil\Compiled2p\'

psfile = 'c:\tempPhil2p.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pDarkness'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineTrained2pDarkness'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pDarkness'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pDarkness'
else
    sprintf('please restart and choose a number 1-4')
end

if isempty(use)
    sprintf('No animals in this group')
    return
end

if redogrp
    gratSpikes = nan(10000,3000,2); %%cell, timepts, pre/post
    topoSpikes = nan(10000,3000,2); %%cell, timepts, pre/post
    gratsession = nan(10000,1); %%make an array for animal #/session for gratings data
    toposession = nan(10000,1); %%array for animal #/session for topo data
    gratrf = nan(10000,2); %%cell, x/y receptive field location grat data
    toporf = nan(10000,2); %%cell, x/y receptive field location topo data
    osi = nan(10000,2); %%cell, osi sit/run
    dsi = nan(10000,2); %%cell, dsi sit/run
    bestsftf = nan(10000,2,2); %%cell, sf/tf, sit/run
    gratori = nan(10000,2); %%cell, sit/run
    gratcells = nan(10000,1); %%cell #, all cells w/good grat data
    topocells = nan(10000,1); %%cell #, all cells w/good rf data
    gratcnt=1; %%counter for gratings data
    topocnt=1; %%counter for topo data
    for i = 1:2:length(use)
        aniFile = files(use(i)).sizeanalysis; load(aniFile,'userf','useosi','usedsi','usebestsftf','useprefthetaQuad','usecells','rf','allgoodTopo');

        %%%grat relevant data
        gratrange = gratcnt:gratcnt+length(usecells)-1;
        gratrf(gratrange,:) = userf;
        gratcells(gratrange) = usecells;
        gratsession(gratrange) = (i+1)/2;
        osi(gratrange,:) = useosi;
        dsi(gratrange,:) = usedsi;
        bestsftf(gratrange,:,:) = usebestsftf;
        gratori(gratrange,:) = useprefthetaQuad;

        %%%topo relevant data
        toporange = topocnt:topocnt+length(allgoodTopo)-1;
        toporf(toporange,:) = rf(allgoodTopo,:);
        topocells(toporange) = allgoodTopo;
        toposession(toporange) = (i+1)/2;

        %%%darkness data pre
        aniFile = files(use(i)).darknesspts; load(aniFile,'spikes');
        gratSpikes(gratrange,:,1) = spikes(usecells,size(spikes,2)-2999:end);
        topoSpikes(toporange,:,1) = spikes(allgoodTopo,size(spikes,2)-2999:end);

        %%%darkness data post
        aniFile = files(use(i+1)).darknesspts; load(aniFile,'spikes');
        gratSpikes(gratrange,:,2) = spikes(usecells,size(spikes,2)-2999:end);
        topoSpikes(toporange,:,2) = spikes(allgoodTopo,size(spikes,2)-2999:end);
        
        gratcnt = gratcnt+length(usecells);
        topocnt = topocnt+length(allgoodTopo);
    end
    
    gratcnt=gratcnt-1;topocnt=topocnt-1;
    gratSpikes = gratSpikes(1:gratcnt,:,:); %%cell, timepts, pre/post
    topoSpikes = topoSpikes(1:topocnt,:,:); %%cell, timepts, pre/post
    gratsession = gratsession(1:gratcnt); %%make an array for animal #/session for gratings data
    toposession = toposession(1:topocnt); %%array for animal #/session for topo data
    gratrf = gratrf(1:gratcnt,:); %%cell, x/y receptive field location grat data
    toporf = toporf(1:topocnt,:); %%cell, x/y receptive field location topo data
    osi = osi(1:gratcnt,:); %%cell, osi sit/run
    dsi = dsi(1:gratcnt,:); %%cell, dsi sit/run
    bestsftf = bestsftf(1:gratcnt,:,:,:); %%cell, sf/tf, sit/run, pre/post
    gratori = gratori(1:gratcnt,:,:); %%cell, sit/run, pre/post
    gratcells = gratcells(1:gratcnt); %%cell #, all cells w/good grat data
    topocells = topocells(1:topocnt); %%cell #, all cells w/good rf data
    
    dpix = 0.8022; %%%degrees per pixel
    topodistance = {}; %%%Cartesian distance between cells in pixels
    for h = 1:length(unique(toposession))
        k = find(toposession==h);
        for i = 1:length(k)
            for j = 1:length(k)
                topodistance{h}(i,j) = sqrt((toporf(k(i),1)-toporf(k(j),1))^2 + (toporf(k(i),2)-toporf(k(j),2))^2);
            end
        end
        topodistance{h} = topodistance{h}*dpix; %%%convert to degrees
        topoFR{h} = topoSpikes(k,:,:);
        k = find(gratsession==h);
        gratoripref{h} = gratori(k,1);
        gratFR{h} = gratSpikes(k,:,:);
    end
    
    
    sprintf('saving group file...')
    save(grpfilename,'gratFR','topoFR','gratoripref','topodistance')
    sprintf('done')
else
    sprintf('loading data')
    load(grpfilename)
end


