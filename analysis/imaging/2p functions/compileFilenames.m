function [sbx_fname acq_fname mat_fname quality] = compileFilenames(xlsfile,stimname);
%%% reads in excel batch file and generates standardized filenames 
%%% for sbx file , stimrec, and analsyis .mat file
%%% cmn 2019

T = readtable(xlsfile);

%%% find entries with proper stimulus
use = find(strcmp(T.Stim,stimname));


%%% generate list of filenames
for j = 1:length(use);
    i = use(j);
    %%% generate sbx filename
    sbx_fname{j} = [T.Date{i} '_Octopus_Cal520_000_' sprintf('%03d',T.RecordingNumber(i)) '.sbx'];
    if ~exist(sbx_fname{j},'file')
        sprintf('couldnt find %s',sbx_fname{j})
    end
    
    %%% generate stimrec filename
    acq_fname{j}  = [T.Date{i} '_Acq' num2str(T.RecordingNumber(i)) '.mat'];
    if ~exist(acq_fname{j},'file')
        sprintf('couldnt find %s',acq_fname{j});
    end
    
    %%% generate analysis filename
    mat_fname{j} = [T.Date{i} '_' T.Loc{i} '_Acq' num2str(T.RecordingNumber(i)) '_' T.Stim{i} '.mat'];
 
    %%% other fields?
    quality{j} = T.GoodQuality{i};
end
