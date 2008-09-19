function out=getCompiledDirForServer(server_name)
switch server_name
    case 'server2F-pmm' %rack2 server (old)
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled';
    case 'server1M-pmm' %rack1 server (pmm)
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords\';
    case 'server4F-edf' %rack3-edf
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    case 'test' %rig1 eyetracking computer on right, 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\compiled';
    case 'server3F-pr' %rack3-pr
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    otherwise
        error('bad')
end

