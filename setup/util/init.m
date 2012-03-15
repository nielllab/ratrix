function r=init
[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(pathstr)),'bootstrap'));
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file