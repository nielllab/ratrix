clear all
close all
%% Analyze multiple files using sbxOctoNeural function.
%% uses excel compile file to choose files, stim, etc
%% sbx and acq files need to be in the current folder

stim_name = 'sparse noise'
%%% select files to analze
[sbx_fname acq_fname mat_fname runBatch] = compileFilenames('ForBatchFileAngeliquewregioned.xlsx',stim_name);


%% General Parameters
Opt.align = 1;
Opt.NumChannels = 1;
Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';
Opt.MakeMov = 0;
Opt.fwidth = 0.5;
Opt.Resample = 0;           %Option to resample at a different framerate
Opt.Resample_dt = 0.1;
Opt.SaveOutput = 1;

%Options for finding cells
Opt.selectPts = 0;          %Select points automatically (0) rather than manually
Opt.mindF = 5000;            %Minimum delta-f value
Opt.nclust = 5;             %Number of cell population clusters
Opt.selectCrop = 0;         %whether to manually crop image region

Opt.zbinning = 1;
Opt.binningThresh = 0.95;

Opt.sub_noise = 1;

Results = struct;

%for iFile = 1:length(sbx_fname);
    for iFile = 1:length(sbx_fname)
    %%% criteria as to whether to analyze this one
    %use = ~exist(mat_fname{iFile},'file');
    use = strcmp(runBatch{iFile},'Y');
    if use
        
        folder = '.';
        Opt.pSbx = folder;
        Opt.fSbx = sbx_fname{iFile};
        fprintf('Processing file %s\n',Opt.fSbx);
        
        Opt.pStim = folder;
        Opt.fStim = acq_fname{iFile};
        
        %Name of pdf save file
        if Opt.SaveFigs == 1
            Opt.pPDF = folder;
            Opt.fPDF = [mat_fname{iFile}(1:end-4)  'df5000.pdf']; %%% change to update name
        end
        
        if Opt.SaveOutput
            Opt.pOut = folder;
            Opt.fOut = [mat_fname{iFile}(1:end-4) '.mat'];  %%% change to update name
        end
        
        %% Run sbxOctoSTA
        Results(iFile).Input = Opt;       
%         try
            sbxOctoSTA(Opt);
            Results(iFile).Output = 'success'
%         catch
%             fprintf('Error in sutterOctoNeural script - Continuing onto next file');
%             Results(iFile).Output = [];
%         end
   
    end
end
