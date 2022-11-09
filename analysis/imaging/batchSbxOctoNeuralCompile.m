clear all
close all
%% Analyze multiple files using sbxOctoNeural function.
%% uses excel compile file to choose files, stim, etc

stim_name = '8 way gratings 2ISI'
suffix = '_denoised_Zbin95_8way_110822';
outFolder = '8way_110822/'
%%% select files to analyze
[sbx_fname acq_fname mat_fname quality regioned runBatch] = compileFilenames('CombinedBatch_GoodOnes.xlsx',stim_name,suffix);



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
    use = strcmp(runBatch{iFile},'Y') & ~exist([outFolder mat_fname{iFile}],'file');
    Results(iFile).name = mat_fname{iFile};
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
            Opt.fPDF = [outFolder mat_fname{iFile}(1:end-4)  '.pdf'];

        end
        
        if Opt.SaveOutput
            Opt.pOut = folder;
            Opt.fOut = [outFolder mat_fname{iFile}(1:end-4) '.mat']  %%%% change this line to add extra terms
        end
        
        %% Run sutterOctoNeural
        Results(iFile).Input = Opt;       
%         try
            sbxOctoNeural(Opt);
            Results(iFile).Output = 'success'
%         catch
%             fprintf('Error in sutterOctoNeural script - Continuing onto next file');
%             Results(iFile).Output = [];
%         end
   
    elseif ~strcmp(runBatch{iFile},'Y')
        Results(iFile).Output = 'not in runBatch';
    else
        Results(iFile).Output = 'file exists';
    end
end
