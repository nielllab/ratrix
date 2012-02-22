function copySubject
source = 'n8lt';
target= 'j7lt';

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData',filesep);
    %dataPath='\\mtrix2\Users\nlab\Desktop\mouseData\';
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~exist('stepNums','var') || isempty(stepNums)
    stepNums='all';
end

if ~exist('subIDs','var') || isempty(subIDs)
    %    subIDs=intersect(getEDFids,getSubjectIDs(r));
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

sub=getSubjectFromIDs(r,source);

[p t]=getProtocolAndStep(sub);
sub = setID(sub,target);
 
r = addSubject(r,sub,auth);
[~, r]=setProtocolAndStep(sub,p,true,true,false,1,r,comment,auth);

end