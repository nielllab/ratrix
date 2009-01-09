function [analysisdata]=getNeuralAnalysis(subjectDataPath,when,what);
%analysisdata=getNeuralAnalysis(analysisPath,'last','RFEstimate')
%should be improved to return more general data

if ~exist('when','var') || isempty(when)
    when=daterange;
    
    %should be improved to return more general data
end

if ~exist('what','var') || isempty(what)
    what='anything';
    %should be improved to return more general data
end

d=dir(fullfile(subjectDataPath,'analysis'));
if isempty(d)
    warning('no analysis records found at path');
    analysisdata=[];
else
    % first sort the neuralRecords by trial number
    goodFiles=[];
    for i=1:length(d)
        [matches tokens] = regexpi(d(i).name, 'analysis_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            %         warning('not a neuralRecord file name');
        else
            goodFiles(end+1).trialNum = str2double(tokens{1}{1});
            goodFiles(end).timestamp = tokens{1}{2};
        end
    end
    [sorted order]=sort([goodFiles.trialNum]);
    goodFiles=goodFiles(order);
    
    
    % load the last analysis and corresponding stimRecord
    analysisFilename = sprintf('analysis_%d-%s.mat', goodFiles(end).trialNum, goodFiles(end).timestamp);
    load(fullfile(subjectDataPath,'analysis', analysisFilename));
    
    % get contrast and stim rect from stim records.
    stimRecordFilename = sprintf('stimRecords_%d-%s.mat', goodFiles(end).trialNum, goodFiles(end).timestamp);
    load(fullfile(subjectDataPath, 'stimRecords', stimRecordFilename));
    analysisdata.contrast=stimulusDetails.contrast;  %this needs to be added
    analysisdata.stimRect=stimulusDetails.stimRect;  %this needs to be added
    % could get it from the raw files.. but where are they stored?
    
    switch what
        case 'RFEstimate'
            if ~all(ismember({'cumulativeSpikeCount','cumulativeSTA'},fields(analysisdata)))
                error('last analysis trial was not a receptive field estimate');
                %need to improve this code...hunt backwards until you find
                %one?
            end
        case 'anything'
            %no check require
        otherwise
            what
            error('bad request');
    end
end