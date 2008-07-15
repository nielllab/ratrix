setupEnvironment;
permanentStorePath = 'C:\Documents and Settings\RLab\Desktop\RemoteStore\subjects';
[succ msg msgid]=mkdir(permanentStorePath);
if ~succ
    msg
    msgid
    permanentStorePath
    error('couldn''t access permanent store')
end
makeNewRatrix = true;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
rx=crossModalMakeRatrix(dataPath,permanentStorePath,true,'localTimed',makeNewRatrix);

standAloneRun(rx);