% this function moves .mat files from all subfolders of
% user-selected parent directory to a different user-selected directory. 


clear all
% pick the parent directory
parentDir = uigetdir('F:\Kristen','pick parent folder');
% pick the directory to transfer .mat files into
outputDir = uigetdir('F:\Kristen','pick output folder');
% make a structure containing the name of each .mat file in each row.
% the first field 'name' contains the file name
allMatFiles = subdir(fullfile(parentDir, '*.mat'));

% moving each .mat file to the output folder:

% for each .mat file in the struct array defined previously
for i = length(allMatFiles)
    % variable to s the i-th file
    oneFile = allMatFiles(i).name;
    % move the 
    movefile(oneFile, 'outputDir');
end
