clear all
close all
%% transfers regioning information from analysis files in a main folder
%% onto analysis files in a subfolder.
%% this allows a single set of regioned data to be applied to new analysis easily

%% to run, set your current folder to the folder with existing regioning
%% and set the appropriate variables below to specific the data to be transferred


% stim_name = 'sin gratings 7 steps'
% % suffix = '_denoised_Zbin95_singratings_110922';
% % outFolder = 'Singratings_Z95_110922/'
% suffix = '_denoised_Zbin95_8way_110822';
% stim_name = '8 way gratings 2ISI'
% outFolder = '8way_110822/'
%% select files to analyze

suffix = '_SN1_denoised_zbinned_110822';
stim_name = 'sparse noise 1'
outFolder = 'SN1_110922/'
[sbx_fname acq_fname mat_fname quality regioned runBatch] = compileFilenames('CombinedBatch_GoodOnes.xlsx',stim_name,suffix);

warning('off','MATLAB:load:variableNotFound')


%for iFile = 1:length(sbx_fname);
for iFile = 1:length(sbx_fname)
    %%% criteria as to whether to analyze this one
    %use = ~exist(mat_fname{iFile},'file');
    use = strcmp(runBatch{iFile},'Y') & exist([outFolder mat_fname{iFile}],'file');
    basename = mat_fname{iFile}(1:(end-length(suffix)-4));
    clear xb yb
    if use
        load([outFolder mat_fname{iFile}],'xb');
    end
    
    if use & ~exist('xb','var')
        basename;
        matfiles = dir([basename '*.mat']);
        %display(sprintf('found %d matching mat files',length(matfiles)));
        found = 0;
        for f = 1:length(matfiles)
            load(matfiles(f).name,'xb','yb');
            if exist('xb','var')
                display(sprintf('found regioning in %s',matfiles(f).name))
                save([outFolder mat_fname{iFile}],'xb','yb','-append');
                found =1;
                break
            end
        end
        if found ==0
            display(sprintf('couldnt find regioning for %s',mat_fname{iFile}));
        end
    end
end

warning('on','MATLAB:load:variableNotFound')

