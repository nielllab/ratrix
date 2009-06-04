function out=getCommonSubjectDir(ID)
% infrastructure has migrated to "server specific" code
% now simply an oracle-independant accessor tool for philip's analysis


% code below would work to remove some redundancy of server's but the orcale
% independent paths would still be needed
%
%    serverName=getServerNameFromID(ID)
%    getSubDirForServer(serverName)


switch ID
    case 1 %male room 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects';
    case 2 %female room
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects\';
    case 3 %female
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\subjects\';
    case 101 %rig1 eyetracking computer on right, 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\subjects'      
    case 103 %rig3 the room with the drill press
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig3TrialRecords\subjects'      
    otherwise
        ID
        error('bad requested ID')
end