%% Analyze multiple files using sbxOctoNeural function.
%% uses excel compile file to choose files, stim, etc
%%% cmn 2019

clear all
close all

stimname = 'sparse noise';
%%% select files to analze
[sbx_fname acq_fname mat_fname] = compileFilenames('For Batch File.xlsx',stimname);


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
Opt.binningThresh = 0.9;

Results = struct;

for iFile = 1:length(sbx_fname)
   iFile
    %%% criteria as to whether to analyze this one
    use = ~exist(mat_fname{iFile},'file');
    use = 1
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
            Opt.fPDF = [mat_fname{iFile}(1:end-4)  '.pdf'];
        end
        
        if Opt.SaveOutput
            Opt.pOut = folder;
            Opt.fOut = mat_fname{iFile};
        end
        
        %% Run sutterOctoNeural
        Results(iFile).Input = Opt;
        %         try
        if strcmp(stimname(1:6),'sparse')
            display('sparse noise')
            if strcmp(stimname,'sparse noise');
                Opt.noiseFile=1;   %%octo_sparse_flash_10min
            else
                Opt.noiseFile=2; %%%sparse_20min_1-8
            end
            sbxOctoSTA(Opt);
        else
            sbxOctoNeural(Opt);
        end
        
        Results(iFile).Output = 'success'
        %         catch
        %             fprintf('Error in sutterOctoNeural script - Continuing onto next file');
        %             Results(iFile).Output = [];
        %         end
        
    end
end
