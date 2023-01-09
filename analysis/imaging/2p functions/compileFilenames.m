function [sbx_fname acq_fname mat_fname quality regioned runBatch metadata] = compileFilenames(xlsfile,stimname, suffix);
%%% reads in excel batch file and generates standardized filenames 
%%% for sbx file , stimrec, and analsyis .mat file
%%% cmn 2019

T = readtable(xlsfile,'Format','auto');

%%% find entries with proper stimulus
use = find(strcmp(T.Stim,stimname));

%%% generate list of filenames
for j = 1:length(use);
    i = use(j);
    %%% generate sbx filename
    sbx_fname{j} = [T.Date{i} '_octo_cal520_000_' sprintf('%03d',T.RecordingNumber(i)) '.sbx'];
    if ~exist(sbx_fname{j},'file')
        sbx_fname{j} = [T.Date{i} '_Octopus_Cal520_000_' sprintf('%03d',T.RecordingNumber(i)) '.sbx'];
        %sprintf('couldnt find %s',sbx_fname{j})
    end
    
    %%% generate stimrec filename
    acq_fname{j}  = [T.Date{i} '_Acq' num2str(T.RecordingNumber(i)) '.mat'];
    if ~exist(acq_fname{j},'file')
        %sprintf('couldnt find %s',acq_fname{j});
    end
    
    %%% generate analysis filename
    mat_fname{j} = [T.Date{i} '_' T.Loc{i} '_Acq' num2str(T.RecordingNumber(i)) suffix '.mat'];
    %%% some stim types have spaces in them
    mat_fname{j} = strrep(mat_fname{j},' ','_');
    
    %%% other fields?
    quality{j} = T.GoodQuality_Proj{i};
    
    %%% has it been regioned?
    regioned{j} = T.regioned{i};
    
    try
        runBatch{j}=T.runBatch{i};
    catch
        runBatch{j} = NaN;
    end


    
end

metadata.illumination = {T.Illumination{use}};
metadata.eyeSize = T.EyeSize(use);
metadata.lobeSize = T.LobeSize(use);
metadata.lobeOrientation = {T.LobeOrientation{use}};
metadata.fname = {mat_fname};
mmPerPix = (T.MirrorTypemm(use) - 5)./T.MirrorEdge_pixel(use);
metadata.screenDist  = 5 + (T.MirrorEdge_pixel(use)+T.PupilDist_pixel(use)).*mmPerPix;
