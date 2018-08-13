clear all
close all
%% Analyze multiple files using sutterOctoNeural function. Instead of
% providing user input interactively, input the parameters below
% Change the DataDir to the folder containing the files you want analyzed
batchOctoNLW

%%% select files to analze
used = 1:length(files)


fprintf('%u  files to process\n',length(used));
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

% %Options for alignment ___ not in NLW yet
% Opt.ZBinning = 1;           %Option to correct for z motion by binning
% Opt.Zclusters = 2;          %Number of z-plane clusters to identify
% Opt.Rotation = 0;           %Option to correct for rotation
% Opt.AlignmentChannel = 2;   %What channel do you want to use for alignment? Green(1)/Red(2)

%Options for finding cells
Opt.selectPts = 0;          %Select points automatically (0) rather than manually
Opt.mindF = 350;            %Minimum delta-f value
Opt.nclust = 5;             %Number of cell population clusters
Opt.selectCrop = 0;         %whether to manually crop image region

%% Loop through the filelist and analyze each tif stack
Results = struct;
for iFile = 1:length(used)
    
    folder = [pathname '\' files(used(iFile)).path]
    Opt.pSbx = folder;
    Opt.fSbx = files(used(iFile)).sbx;
    fprintf('Processing file %s\n',Opt.fSbx);
    
    Opt.pStim = folder;
    Opt.fStim = files(used(iFile)).stimrec;
    
    %Name of pdf save file
    if Opt.SaveFigs == 1
        Opt.pPDF = folder;
        Opt.fPDF = sprintf('loc%d_Acq%d_%s.pdf',files(used(iFile)).loc,files(used(iFile)).acq,files(used(iFile)).stim) ;
    end
    
    if Opt.SaveOutput
        Opt.pOut = folder;
        Opt.fOut = [Opt.fSbx(1:end-4),'.mat'];
    end
    
    %% Run sutterOctoNeural
    Results(iFile).Input = Opt;
    
    if ~exist(fullfile(Opt.pPDF, Opt.fPDF),'file') | ~exist(fullfile(Opt.pOut, Opt.fOut),'file')
        %    try
        sbxOctoNeural(Opt);
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
