function out=getCompiledDirForServer(server_name)
switch server_name
    case 'server-02-female-pmm-156' %rack2 server (old)
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\compiledRecords';
    case 'server-01-male-pmm-154' %rack1 server (pmm)
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\compiled';
    case 'server-03-female-edf-157' %rack3-edf
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    case 'test' %rig1 eyetracking computer on right, 
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rig1TrialRecords\compiled';
    case 'server-04-female-pr-155' %rack3-pr
        out='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\rack3\compiledTrialRecords\';
    otherwise
        error('bad')
end

