uiparams.remotePath = 'C\pmeier\Ratrix\Boxes\box1\';
uiparams.heats{1}.name = 'Overnight';
uiparams.heats{1}.subjects = {'rat_113','rat_102','rat_106'; 
                              'rat_114','rat_116','rat_117';}';
uiparams.heats{2}.name = 'Morning';
uiparams.heats{2}.subjects = {'rat_126','rat_127','rat_128';
                                'rat_129','rat_130','rat_131'}';
uiparams.heats{3}.name = 'Afternoon';
uiparams.heats{3}.subjects = {'rat_112','','';
                              'rat_115','rat_118','rat_119';}';


uiparams.subjects = {};
uiparams.stationIds = [3 1 2; 11 9 4];     

uiparams.desktopPath='C:\Documents and Settings\rlab\Desktop';
uiparams.weeklyLogPath='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixLogs';

for i=1:size(uiparams.heats,2)
    tmp = {uiparams.heats{i}.subjects{:}};
    uiparams.subjects = [ uiparams.subjects tmp ];
end
uiparams.subjects = unique({uiparams.subjects{:}});
if strcmp(uiparams.subjects{1},'') == 1
    uiparams.subjects{1} = [];
end
uiparams.loadMethod = 'betweenDates';
%uiparams.loadMethodParams = []; % Determined by date range in UI
uiparams.saveSmallData = 1;
uiparams.saveLargeData = 0;
%uiparams.data = ; % Note used

uiparams.whichPlots= [1 1 1 1 0 1 1 1 1 1 1 1 1]; %see a lot ; 
uiparams.whichPlots=[1 1 0 0 0 0 0 0 0 0 0 0 0]; %see basics
uiparams.savePlots = uiparams.whichPlots;
uiparams.plotHandles = [ 1:13 ];
stationIP{1}='192.168.0.101';
stationIP{2}='192.168.0.102';
stationIP{3}='192.168.0.103';
stationIP{4}='192.168.0.104';
stationIP{9}='192.168.0.109';
stationIP{10}='192.168.0.110';
stationIP{11}='192.168.0.111';
uiparams.stationIP = stationIP;
sP.index = 1;
sP.x = 1;
sP.y = 1;
uiparams.subplotParams = sP;