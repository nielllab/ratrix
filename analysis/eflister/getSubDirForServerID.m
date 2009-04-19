function out=getSubDirForServerID(serverID)

switch serverID 
    case 1
       server_name='server-01-male-pmm-154';
    case 2 
        server_name='server-02-female-pmm-156';
    case 3 
        server_name='server-03-female-edf-157';
    case 4 
        server_name='server-04-female-pr-155';
    case 101 %rig1 eyetracking computer on right 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\subjects'      
    case 103 %rig3 the room with the drill press
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig3TrialRecords\subjects'      
    otherwise
        rackNum
        error('bad requested rackNum')
end

if serverID<100
    out=getSubDirForServer(server_name);
end