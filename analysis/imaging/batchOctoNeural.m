clear all
close all
%% Analyze multiple files using sutterOctoNeural function. Instead of 
% providing user input interactively, input the parameters below
% Change the DataDir to the folder containing the files you want analyzed
DataDir = 'D:\GSchool\Niell\Data\112517_Octopus_Cal520';
Opt.Date = '112517'; %Folder name for stimrec as well

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
Opt.ZBinning = 0;           %Option to correct for z motion by binning
Opt.Zclusters = 2;          %Number of z-plane clusters to identify
Opt.Rotation = 1;           %Option to correct for rotation
Opt.AlignmentChannel = 1;   %What channel do you want to use for alignment? Green(1)/Red(2)

%Options for finding cells
Opt.selectPts = 0;          %Select points automatically (0) rather than manually
Opt.mindF = 0.5;            %Minimum delta-f value 
Opt.nclust = 5;             %Number of cell population clusters

%% Loop through the filelist and analyze each tif stack
Results = struct;
for iFile = 1:length(Tif_list)
    Opt.pTif = Tif_list(iFile).folder;
    Opt.fTif = Tif_list(iFile).name;
    fprintf('Processing file %s\n',Opt.fTif);
    
    %Find corresponding ttl file
    LocAcq = Opt.fTif(1:10);
    mainFilename = Opt.fTif(1:end-7);
    pos = strfind({Mat_list(:).name},mainFilename); Indy = [];
    for i = 1:length(pos)
        if ~isempty(pos{i})
            Indy = [Indy, i];
        end
    end
    %Continue onto next tif file if no TTL could be determined
    if isempty(Indy)
        fprintf('Could not determine TTL File\n\n');
        continue;
    end
    Opt.pTTL = Mat_list(Indy(end)).folder;
    Opt.fTTL = Mat_list(Indy(end)).name;
    
    %find corresponding stimulus record file
    pos = strfind({Stim_list(:).name},LocAcq); Indy = [];
    for i = 1:length(pos)
        if ~isempty(pos{i})
            Indy = [Indy, i];
        end
    end
    %Continue onto next tif file if no stimulus record could be determined
    if isempty(Indy)
        fprintf('Could not determine stimulus record file\n\n');
        continue;
    end
    Opt.pStim = Stim_list(Indy(end)).folder; 
    Opt.fStim = Stim_list(Indy(end)).name; 
    
    %Name of pdf save file
    if Opt.SaveFigs == 1
        Opt.pPDF = Tif_list(iFile).folder;
        Opt.fPDF = [Opt.fTif(1:end-4),'.pdf'];
    end
    
    %% Run sutterOctoNeural
    Results(iFile).Input = Opt;
%     try
%         Results(iFile).Output = sutterOctoNeural(Opt);
%     catch
%         fprintf('Error in sutterOctoNeural script - Continuing onto next file');
%         Results(iFile).Output = [];
%     end
    
end


