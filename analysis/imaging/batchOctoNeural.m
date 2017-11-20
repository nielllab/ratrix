%% Analyze multiple files using sutterOctoNeural function. Instead of 
% providing user input interactively, input the parameters below
% Change the DataDir to the folder containing the files you want analyzed
DataDir = 'D:\GSchool\Niell\Data\102017_Octopus_Cal520';
Opt.Date = '102017'; %Folder name for stimrec as well

%Selects only those files that are relevant
Tif_list = dir(fullfile(DataDir,'Loc*.tif'));
Mat_list = dir(fullfile(DataDir,'Loc*.mat'));
Stim_list = dir(fullfile(DataDir,Opt.Date,'Loc*.mat'));

fprintf('%u tif files to process\n',length(Tif_list));
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
Opt.Rotation = 1;           %Option to correct for rotation
Opt.AlignmentChannel = 1;   %What channel do you want to use for alignment?

%Options for finding cells
Opt.selectPts = 0;          %Select points automatically (0) rather than manually
Opt.mindF = 0.5;            %Minimum delta-f value 
Opt.nclust = 5;             %Number of cell population clusters

%% Loop through the filelist and analyze each tif stack
Output = struct;
for iFile = 1:length(Tif_list)
    Opt.pTif = Tif_list(iFile).folder;
    Opt.fTif = Tif_list(iFile).name;
    
    %Find corresponding ttl file
    LocAcq = Opt.fTif(1:9);
    pos = strfind({Mat_list(:).name},LocAcq);
    for i = 1:length(pos)
        if ~isempty(pos{i})
            pos = i;
            break;
        end
    end
    Opt.pTTL = Mat_list(pos).folder;
    Opt.fTTL = Mat_list(pos).name;
    
    %find corresponding stimulus record file
    pos = strfind({Stim_list(:).name},LocAcq);
    for i = 1:length(pos)
        if ~isempty(pos{i})
            pos = i;
            break;
        end
    end
    Opt.pStim = Stim_list(pos).folder; 
    Opt.fStim = Stim_list(pos).name; 
    
    %Name of pdf save file
    if Opt.SaveFigs == 1
        Opt.pPDF = Tif_list(iFile).folder;
        Opt.fPDF = [Opt.fTif(1:end-4),'.pdf'];
    end
    
    %% Run sutterOctoNeural
    fprintf('Processing file %s\n',Opt.fTif);
    tic;
    Output(iFile) = sutterOctoNeural(Opt);
    toc;
    
end


