%% selectAndGenerateActivityReport.m
% Pops up a file-selection dialog so you can manually pick one or more
% suite2p Fall.mat files, then builds an activity report PDF for each one
% (saved next to its Fall.mat by default), using
% suite2pTracesStimOnset_AAClaude101226.
%
% For each Fall.mat, you'll also be asked whether you have that
% recording's scanbox companion .mat file (the one next to the .sbx
% file, e.g. "100926_ASW150E28_000_007.mat"). If you provide it, stimulus
% onset times are read from its sync channel and overlaid on every trace
% panel in the report. Say no/skip and the report is built exactly as
% before, with no stimulus overlay.
%
% You can select multiple Fall.mat files at once by Ctrl+clicking (or
% Shift+click for a range) within the dialog, as long as they're in the
% same folder. To do several animals in different folders, just re-run
% the script.

[fileNames, pathName] = uigetfile('Fall.mat', ...
    'Select suite2p Fall.mat file(s)', 'MultiSelect', 'on');

if isequal(fileNames, 0)
    disp('No file selected - cancelled.');
    return
end

if ischar(fileNames)
    fileNames = {fileNames}; % uigetfile returns a plain char if only one was picked
end

for k = 1:numel(fileNames)
    fallPath = fullfile(pathName, fileNames{k});

    % Guess an animal ID from the folder structure, combining the animal
    % folder with the acquisition/session folder - e.g. for a path like
    % .../ASW150E28/2p/acq7/suite2p/plane0/Fall.mat, that's "ASW150E28"
    % (4 folders up) plus "acq7" (2 folders up), giving "ASW150E28_acq7".
    % Adjust the "-4"/"-2" below if your folder layout is shallower/
    % deeper - the dialog below lets you fix it by hand either way.
    folderParts = strsplit(fileparts(fallPath), filesep);
    folderParts(cellfun(@isempty, folderParts)) = [];
    if numel(folderParts) >= 5
        guessID = sprintf('%s_%s', folderParts{end-4}, folderParts{end-2});
    else
        guessID = folderParts{1};
    end

    answer = inputdlg(sprintf('Animal ID for:\n%s', fallPath), 'Animal ID', 1, {guessID});
    if isempty(answer)
        animalID = guessID; % user hit Cancel on the label prompt - fall back to the guess
    else
        animalID = answer{1};
    end

    % Optional: a scanbox companion .mat file with stimulus sync info.
    % Defaults to the same folder as Fall.mat, since that's usually
    % where it lives too.
    extraArgs = {};
    wantStim = questdlg(sprintf(['Select the .mat file that ends in the acquisition number to ' ...
        'include stimulus onset information for:\n%s'], fallPath), ...
        'Stimulus onset overlay', 'Yes', 'No', 'No');
    if strcmp(wantStim, 'Yes')
        [stimFile, stimPath] = uigetfile('*.mat', 'Select the scanbox companion .mat file', pathName);
        if ~isequal(stimFile, 0)
            stimMatPath = fullfile(stimPath, stimFile);
            extraArgs = {'StimMatPath', stimMatPath};
        else
            disp('No stimulus file selected - continuing without the onset overlay.');
        end
    end

    % PDF is saved in the same folder as Fall.mat. Change outFolder below
    % if you'd rather collect all reports somewhere else.
    outFolder = fileparts(fallPath);
    outPath = fullfile(outFolder, sprintf('%s_activity_report.pdf', animalID));

    fprintf('Building report for %s -> %s\n', fallPath, outPath);
    try
        suite2pTracesStimOnset_AAClaude101226(fallPath, outPath, 'AnimalID', animalID, extraArgs{:});
    catch ME
        warning('Failed on %s:\n  %s', fallPath, ME.message);
    end
end

disp('Done.');
