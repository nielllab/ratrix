%% analyzePassive: choose batch file and filter experiments w/batch file fields, comment/uncomment stimulus-specific analyses below
close all
clear all
warning off

% pick animals
batchEnrichmentCohort2 %batch file
cd(pathname)

%filter based on fields of batch file that define the animals you want
alluse = find(strcmp({files.cond},'enrichment') & strcmp({files.notes},'good imaging session'))

savename = ['AF_' files(alluse(1)).cond '.mat'];

%% run doTopography (use this one to average all sessions that meet criteria)
length(alluse)
allsubj = unique({files(alluse).subj})

psfilename = fullfile(pathname,'tempWF.ps'); 
if exist(psfilename,'file')==2;delete(psfilename);end

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    

for s=1:1
    use = alluse;
    allsubj{s}

    %%% calculate gradients and regions
    clear map merge

    x0=0; y0=0; sz=128;
    doTopography;

    %% pick which gratings analysis to run

    %%%UNCOMMENT FOR 3X2Y
    % disp('doing 3x2y')
    % rep=2;
    % doGratingsNew;

    % %%% UNCOMMENT FOR 4X3Y
    disp('doing 4x3y')
    rep=4;
    doGratingsNew;
    disp('saving data')
    save(fullfile(pathname,savename),'allsubj','shiftData','fit','mnfit','cycavg',...
            'tuningall','sftcourse','trialcycavgRunAll','trialcycavgSitAll','-v7.3');



    %%%UNCOMMENT FOR NATURAL IMAGES
    disp('doing natural images')
    doNaturalImages
    disp('saving data')
    try
        save(fullfile(pathname,savename),'natimcyc','natimcycavg','allfam','allims','allfiles','-append','-v7.3');
    catch
        save(fullfile(pathname,savename),'allsubj','natimcyc','natimcycavg','allfam','allims','allfiles','-v7.3');
    end


end


%%%phil note to self- where did sessiondata go/come from and why was it originally
%%%being saved out? removed from save 6/13/19 after error said it didn't
%%%exist

%make the pdf
try
    dos(['ps2pdf ' psfilename ' "' [fullfile(pathname,savename(1:end-4)) '.pdf'] '"'])
    delete(psfilename);
catch
    disp('couldnt generate pdf');
    keyboard
end


