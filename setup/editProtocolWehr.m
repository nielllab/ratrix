function editProtocolWehr(r,subIDs,stepNums,comment,auth)
%can't be used remotely cuz ratrices use their own stored path to themselves, which is a local path

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'wehrData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('stepNums','var') || isempty(stepNums)
    stepNums='all';
end

if ~exist('subIDs','var') || isempty(subIDs)
    subIDs=getSubjectIDs(r);
end

if ~all(ismember(subIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

if ~exist('auth','var')
    auth='unspecified'; %bad idea?
end

if ~exist('comment','var')
    comment='';
end

subs=getSubjectsFromIDs(r,subIDs);

for i=1:length(subs)
    [~, r]=setReinforcementParam(subs{i},'rewardULorMS',30,stepNums,r,comment,auth);
end

reportSettings(r)
end