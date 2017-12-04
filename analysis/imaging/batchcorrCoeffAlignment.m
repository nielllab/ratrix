%% Quantifying the quality of Alignment Algorithms
DataDir = 'D:\GSchool\Niell\Data\files_for_motion_stats';


%Selects only those files that are relevant
Tif_list = dir(fullfile(DataDir,'*.tif'));
Mat_list = dir(fullfile(DataDir,'Loc*.mat'));

fprintf('%u tif files to process\n',length(Tif_list));

%% General Parameters
Opt.align = 1;
Opt.NumChannels = 2; 
Opt.SaveFigs = 0;
Opt.psfile = 'C:\temp\TempFigs.ps';
Opt.MakeMov = 0;
Opt.fwidth = 0.5;
Opt.Resample = 0;           %Option to resample at a different framerate
Opt.Resample_dt = 0.5;
Opt.SaveOutput = 0;

%Options for alignment
Opt.ZBinning = 1;           %Option to correct for z motion by binning
% Opt.Zclusters = 2;          %Number of z-plane clusters to identify
Opt.Rotation = 1;           %Option to correct for rotation
Opt.AlignmentChannel = 2;   %What channel do you want to use for alignment? Green(1)/Red(2)

%% Loop through the filelist and analyze each tif stack
% CorrCoeff_Align = zeros(length(Tif_list),4);
FileNames = cell(length(Tif_list),1);
Results = struct;
for iFile = 1:length(Tif_list)
    Opt.pTif = Tif_list(iFile).folder;
    Opt.fTif = Tif_list(iFile).name;
    fprintf('Processing file %s\n',Opt.fTif);
          
    %% Run sutterOctoNeural
    FileNames{iFile,1}= Opt.fTif(1:11);
    % Performs Image registration for both channels
    [~, ~, tmp] = readAlign2color(fullfile(Opt.pTif,Opt.fTif),Opt);
    CorrCoeff_Align(iFile,:) = tmp;
end

    figure
    ColorPalette = lines(8);
    plot(1:1:4,CorrCoeff_Align(1,:),'-o','Color',ColorPalette(1,:),'MarkerFaceColor',ColorPalette(1,:)),hold on
    plot(1:1:4,CorrCoeff_Align(2,:),'-o','Color',ColorPalette(2,:),'MarkerFaceColor',ColorPalette(2,:)),hold on
    plot(1:1:4,CorrCoeff_Align(3,:),'-o','Color',ColorPalette(3,:),'MarkerFaceColor',ColorPalette(3,:)),hold on
    plot(1:1:4,CorrCoeff_Align(4,:),'-o','Color',ColorPalette(4,:),'MarkerFaceColor',ColorPalette(4,:)),hold on
    plot(1:1:4,CorrCoeff_Align(5,:),'-o','Color',ColorPalette(5,:),'MarkerFaceColor',ColorPalette(5,:)),hold on
    plot(1:1:4,CorrCoeff_Align(6,:),'-o','Color',ColorPalette(6,:),'MarkerFaceColor',ColorPalette(6,:)),hold on
    plot(1:1:4,CorrCoeff_Align(7,:),'-o','Color',ColorPalette(7,:),'MarkerFaceColor',ColorPalette(7,:)),hold on
    plot(1:1:4,CorrCoeff_Align(8,:),'-o','Color',ColorPalette(8,:),'MarkerFaceColor',ColorPalette(8,:)),hold on
    legend(FileNames)
    ax = gca; ax.XLim = [0.5 4.5];
    ax.YLabel.String = '2D Correlation Coefficient';
    ax.YLabel.FontSize = 12;
    ax.YLabel.FontWeight = 'bold';
    ax.TickLabelInterpreter = 'latex';
    ax.YLim = [0.65 1];
    ax.XTick = [1 2 3 4];
    ax.XTickLabel = {'\bf Non-Aligned','\bf Rigid Alignment','\bf Z-Binning','\bf Rotation'};
    ax.XTickLabelRotation = 45;
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    title('Mean Correlation Coefficient');
