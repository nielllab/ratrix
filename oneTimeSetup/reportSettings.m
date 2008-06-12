function reportSettings

p=pwd;
addpath(fullfile(p,'..','bootstrap'))


warning('off','MATLAB:dispatcher:nameConflict')
addpath(RemoveSVNPaths(removeSecretBackups(genpath(getRatrixPath))));
addpath('\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\');
warning('on','MATLAB:dispatcher:nameConflict')

%dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
dataPath=fullfile('C:\Documents and Settings\rlab\Desktop\','ratrixData');
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

ids=getSubjectIDs(r);

if ~isempty(ids)
    for i=1:length(ids)
        ratID=ids{i};
        s = getSubjectFromID(r,ratID);
        [p t]=getProtocolAndStep(s);
        tm=getTrialManager(getTrainingStep(p,t));
        fprintf('%s\tstep: %d\treward: %g\tpenalty: %g\n',ratID,t,getReward(tm),getPenalty(tm));
    end
else
    'no subjects defined'
end