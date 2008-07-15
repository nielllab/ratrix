function out=getCompiledDirForRack(rackNum)
switch rackNum
    case 1
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled';
    case 2
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords\';
    case 3 %female
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    case 101
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\compiled'
    otherwise
        error('bad')
end