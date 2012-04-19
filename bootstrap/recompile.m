function recompile
d='C:\Users\nlab\Desktop\mouseData';

setupEnvironment;

d=fullfile(d, 'ServerData');
rx=ratrix(d,0);

compilePath=fullfile(fileparts(getStandAlonePath(rx)),'CompiledTrialRecords');

compileDetailedRecords([],getSubjectIDs(rx),true,getStandAlonePath(rx),compilePath);
end