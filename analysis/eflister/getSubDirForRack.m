function out=getSubDirForRack(rackNum)

error('should now call getSubDirForServer()')
switch rackNum
    case 1 %male room 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
    case 2 %female room
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects\';
    case 3 %female
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\subjects\';
    case 4 % 11/26/08 - HACK to run one station
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
    case 101 %rig1 eyetracking computer on right, 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\subjects'      
    case 103 %rig3 the room with the drill press
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig3TrialRecords\subjects'      
    otherwise
        rackNum
        error('bad requested rackNum')
end