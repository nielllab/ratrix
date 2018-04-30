clear all
close all
%% Analyze multiple files using sutterOctoNeural function. Instead of
% providing user input interactively, input the parameters below
% Change the DataDir to the folder containing the files you want analyzed
batchOctoLobe

%%% select files to analze
used = 1:length(files)


fprintf('%u tif files to process\n',length(used));
%% General Parameters
Opt.align = 1;
Opt.NumChannels = 2;
Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';
Opt.MakeMov = 0;
Opt.fwidth = 0.5;
Opt.Resample = 0;           %Option to resample at a different framerate
Opt.Resample_dt = 0.5;
Opt.SaveOutput = 1;

%Options for alignment
Opt.ZBinning = 1;           %Option to correct for z motion by binning
Opt.Zclusters = 2;          %Number of z-plane clusters to identify
Opt.Rotation = 0;           %Option to correct for rotation
Opt.AlignmentChannel = 2;   %What channel do you want to use for alignment? Green(1)/Red(2)

%Options for finding cells
Opt.selectPts = 0;          %Select points automatically (0) rather than manually
Opt.mindF = 0.5;            %Minimum delta-f value
Opt.nclust = 5;             %Number of cell population clusters

%% Loop through the filelist and analyze each tif stack
Results = struct;
for iFile = 1:length(used)
    
    folder = [pathname '\' files(used(iFile)).path]
    Opt.pTif = folder;
    Opt.fTif = files(used(iFile)).tif;
    fprintf('Processing file %s\n',Opt.fTif);
    
    
    Opt.pTTL = folder;
    Opt.fTTL = files(used(iFile)).ttl;
    
    Opt.pStim = folder;
    Opt.fStim = files(used(iFile)).stimrec;
    
    %Name of pdf save file
    if Opt.SaveFigs == 1
        Opt.pPDF = folder;
        Opt.fPDF = [Opt.fTif(1:end-4),'.pdf'];
    end
    
    if Opt.SaveOutput
        Opt.pOut = folder;
        Opt.fOut = [Opt.fTif(1:end-4),'.mat'];
    end
    
    %% Run sutterOctoNeural
    Results(iFile).Input = Opt;
    
    if ~exist(fullfile(Opt.pPDF, Opt.fPDF),'file') | ~exist(fullfile(Opt.pOut, Opt.fOut),'file')
        %    try
        sutterOctoNeural(Opt);
        Results(iFile).Output = 'success'
        %         catch
        %             fprintf('Error in sutterOctoNeural script - Continuing onto next file');
        %             Results(iFile).Output = [];
        %         end
    else
        Results(iFile).Output = 'already done';
        display('already done')
    end
    
end
