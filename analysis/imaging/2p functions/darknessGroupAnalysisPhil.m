%%%darknessGroupAnalysisPhil
%%%loads in darkness data and uses cells with good topo data for analysis

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
    grpSpikes = nan(10000,3000,2);
    session = nan(10000,1);%%%make an array for animal #/session
    cellcnt=1;
    for i = 1:2:length(use)
        expcells = files(use(i)).cutoff-1;
        aniFile = files(use(i)).darknesspts; load(aniFile,'spikes');
        session(cellcnt:cellcnt+expcells) = (i+1)/2;
        grpSpikes(cellcnt:cellcnt+expcells,:,1) = spikes(1:expcells+1,size(spikes,2)-2999:end);
        aniFile = files(use(i+1)).darknesspts; load(aniFile,'spikes');
        grpSpikes(cellcnt:cellcnt+expcells,:,2) = spikes(1:expcells+1,size(spikes,2)-2999:end);
        cellcnt = cellcnt+expcells;
    end
    session = session(1:cellcnt);
    grpSpikes = grpSpikes(1:cellcnt,:,:);
    
    sprintf('saving group file...')
    save(grpfilename,'grpSpikes','session')
    sprintf('done')
else
    sprintf('loading data')
    load(grpfilename)
end
