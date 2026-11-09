function sbx2stack_batch(folder)
%%% runs sbx2stack_multichan on every .sbx file in a folder
%%% example usage: sbx2stack_batch('C:\data\mouse1')
%%% with no input, a folder picker opens

if nargin < 1 || isempty(folder)
    folder = uigetdir(pwd, 'Select folder with .sbx files');
    if folder == 0, return; end
end

files = dir(fullfile(folder, '*.sbx'));
if isempty(files)
    fprintf('No .sbx files found in %s\n', folder);
    return
end

origdir = pwd;
cleanup = onCleanup(@() cd(origdir));  % return to original folder even on error
cd(folder);  % sbxread looks for files relative to the current directory

for i = 1:numel(files)
    [~, fname] = fileparts(files(i).name);  % strip the .sbx extension
    fprintf('(%d/%d) Processing %s\n', i, numel(files), fname);
    try
        sbx2stack_multichan(fname);
    catch ME
        fprintf(2, 'FAILED on %s: %s\n', fname, ME.message);  % keep going to the next file
    end
end

fprintf('Done.\n');
end
