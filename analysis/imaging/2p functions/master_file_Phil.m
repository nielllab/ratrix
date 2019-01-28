%% SET ALL DEFAULT OPTIONS HERE
close all
clear all
dbstop if error

% [f p] = uiputfile('*.pdf','pdf file');
% newpdfFile = fullfile(p,f);
% psfilename = 'c:\temp.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end

% UPDATE Christmas 2016: number of clusters determined automatically, but
% do specify the "diameter" of an average cell for best results. You can do this with either
% db(iexp).diameter, or ops0.diameter

% check out the README file for detailed instructions (and extra options)
addpath('C:\Users\nlab\Desktop\GitHub\ratrix\analysis\imaging\2p functions') % add the path to your make_db file

% overwrite any of these default options in your make_db file for individual experiments
make_db_Phil; % RUN YOUR OWN MAKE_DB SCRIPT TO RUN HERE

ops0.toolbox_path = 'C:\Users\nlab\Desktop\old matlab files\Suite2P';
if exist(ops0.toolbox_path, 'dir')
	addpath(genpath(ops0.toolbox_path)) % add local path to the toolbox
else
	error('toolbox_path does not exist, please change toolbox_path');
end

% mex -largeArrayDims SpikeDetection/deconvL0.c (or .cpp) % MAKE SURE YOU COMPILE THIS FIRST FOR DECONVOLUTION

ops0.useGPU                 = 1; % if you can use an Nvidia GPU in matlab this accelerates registration approx 3 times. You only need the Nvidia drivers installed (not CUDA).
ops0.fig                    = 1; % turn off figure generation with 0
% ops0.diameter               = 12; % most important parameter. Set here, or individually per experiment in make_db file

% root paths for files and temporary storage (ideally an SSD drive. my SSD is C:/)
ops0.RootStorage            = 'C:\Users\nlab\Desktop\kate2p\'; % Suite2P assumes a folder structure, check out README file
ops0.temp_tiff              = 'C:\Users\nlab\Desktop\kate2p\temp.tif'; % copies each remote tiff locally first, into this file
ops0.RegFileRoot            = 'C:\Users\nlab\Desktop\kate2p\';  % location for binary file
ops0.DeleteBin              = 1; % set to 1 for batch processing on a limited hard drive
ops0.ResultsSavePath        = 'C:\Users\nlab\Desktop\kate2p\'; % a folder structure is created inside
ops0.RegFileTiffLocation    = 'C:\Users\nlab\Desktop\kate2p\'; %'F:\Phil'; %'D:/DATA/'; % leave empty to NOT save registered tiffs (slow)

% registration options
ops0.doRegistration         = 1; % skip (0) if data is already registered
ops0.showTargetRegistration = 1; % shows the image targets for all planes to be registered
ops0.PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
ops0.SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
ops0.NimgFirstRegistration  = 100; % number of images to include in the first registration pass 
ops0.nimgbegend             = 100; % frames to average at beginning and end of blocks
ops0.dobidi                 = 0; % infer and apply bidirectional phase offset

% cell detection options
ops0.ShowCellMap            = 1; % during optimization, show a figure of the clusters
ops0.sig                    = 1;  % spatial smoothing length in pixels; encourages localized clusters
ops0.nSVDforROI             = 50; % how many SVD components for cell clustering
ops0.NavgFramesSVD          = 100; % how many (binned) timepoints to do the SVD based on
ops0.signalExtraction       = 'raw'; % how to extract ROI and neuropil signals: 'raw', 'regression'

% spike deconvolution options
ops0.imageRate              = 10;   % imaging rate (cumulative over planes!). Approximate, for initialization of deconvolution kernel.
ops0.sensorTau              = 2; % decay half-life (or timescale). Approximate, for initialization of deconvolution kernel.
ops0.maxNeurop              = Inf; % for the neuropil contamination to be less than this (sometimes good, i.e. for interneurons)
ops0.recomputeKernel        = 1; % whether to re-estimate kernel during optimization (default kernel is "reasonable", if you give good timescales)
ops0.sameKernel             = 1; % whether the same kernel should be estimated for all neurons (robust, only set to 0 if SNR is high and recordings are long)

% red channel options
% redratio = red pixels inside / red pixels outside
% redcell = redratio > mean(redratio) + redthres*std(redratio)
% notred = redratio < mean(redratio) + redmax*std(redratio)
ops0.redthres               = 1.5; % the higher the thres the less red cells
ops0.redmax                 = 1; % the higher the max the more NON-red cells

%% RUN THE PIPELINE HERE
db0 = db;

for iexp = 1 %[3:length(db) 1:2]
    run_pipeline(db(iexp), ops0);
    
    % deconvolved data into (dat.)cl.dcell, and neuropil subtraction coef
    add_deconvolution_Phil(ops0, db0(iexp));
    
    % add red channel information (if it exists)
    if isfield(db0,'expred') && ~isempty(db0(iexp).expred)
        ops0.nchannels_red = db0(iexp).nchannels_red;
        
        run_REDaddon(iexp, db0, ops0) ; % create redcell array
        
        DetectRedCells; % fills dat.cl.redcell and dat.cl.notred
    end
    
end
%% STRUCTURE OF RESULTS FILE
% cell traces are in dat.Fcell
% neuropil traces are in dat.FcellNeu
% manual, GUI overwritten "iscell" labels are in dat.cl.iscell
%  
% stat(icell) contains all other information:
% iscell: automated label, based on anatomy
% neuropilCoefficient: neuropil subtraction coefficient, based on maximizing the skewness of the corrected trace (ICA)
% st: are the deconvolved spike times (in frames)
% c:  are the deconvolved amplitudes
% kernel: is the estimated kernel

% dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
% if exist(newpdfFile,'file')
% %     ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"']
%     display('generated pdf using dos ps2pdf')
% else
%     try
%         ps2pdf('psfile', psfilename, 'pdffile', newpdfFile)
%         newpdfFile
%         display('generated pdf using builtin matlab ps2pdf')
%     catch
%         display('couldnt generate pdf');
%         keyboard
%     end
% end
% 
% delete(psfilename);
