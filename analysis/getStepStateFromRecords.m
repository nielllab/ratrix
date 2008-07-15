function out = getStepStateFromRecords(subjects)
%
% rootPath='C:\pmeier';
% warning('off','MATLAB:dispatcher:nameConflict')
% addpath(genpath(fullfile(rootPath, 'Ratrix','classes')));
% warning('on','MATLAB:dispatcher:nameConflict')

if ~exist('subjects','var')
    subjects = getCurrentSubjects;
end

dataStorageIPAndPath=getDataStorageIPAndPath;

subjects=subjects(:);
numSubjects=size(subjects,1);


for i=1:numSubjects
    disp(subjects{i})
    smallData = getSmalls(subjects{i});
    steps{i,1}=subjects{i};
    steps{i,2}=max(smallData.step);
    if any(strcmp(fields(smallData), 'currentShapedValue'))
        steps{i,3}=smallData.currentShapedValue(end);
    else
        steps{i,3}= NaN;
    end
end

[a order]=unique(steps(:,1));
out=steps(order,:);