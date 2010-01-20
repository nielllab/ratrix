function out=getCompiledDirForRack(rackNum)
switch rackNum
    case 1
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled';
    case 2
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords\';
    case 3 %female
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    case 4 % 11/26/08 - HACK to run one station
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled';
    case 5 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\prTrialRecords\compiled';
    case 101
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\compiled';
    case 103
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig3TrialRecords\CompiledTrialRecords';
     case -1 % 12/13/08 -for flanker paper analysis
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\enhancedCompile1';
    case -2 % 12/13/08 -for local testing
        out=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','CompiledTrialRecords');
    otherwise
        error('bad')
end