dataPath = '\\132.239.158.179\datanet_storage';
eventLogPath = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\physiology';
ratID = '261';

eventLogs = dir(fullfile(eventLogPath,ratID,''));
eventLogs = eventLogs(~ismember({eventLogs.name},{'.','..'}));

relevantLogs = [];

for i = 1:length(eventLogs)
    eventLogDirContent = dir(fullfile(eventLogPath,ratID,eventLogs(i).name,''));
    eventLogDirContent = eventLogDirContent(~ismember({eventLogDirContent.name},{'.','..'}));
    if(length(eventLogDirContent)>1)
        error('weird...toomany log files');
    else
        load(fullfile)
        relevantLogs = [relevantLogs; ]
    end