close all
clear all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

%makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


%for suite 2p analysis%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S2P=0
global S2P

% params to use: spatial 2, temporal 4, frmrate 25, yes to align
spatialBin = 2;
temporalBin = 4;
movierate = 12.5;
alignData = 1;
fullMovie = 1;

if S2P==0
    sbxaligndir
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




behav2pSession('g62zz9tt_001_000.sbx','behavSessionV2.mat','trialRecords_1849-1993_20170904T104006-20170904T105914.mat',psfile);
topo2pSession('g62zz9tt_001_001.sbx','topoXsessionV2.mat',psfile);
topo2pSession('g62zz9tt_001_002.sbx','topoYsessionV2.mat',psfile);
grating2pSession('g62zz9tt_001_005.sbx','gratingSessionV2.mat',psfile);
passiveBehav2pSession('g62zz9tt_001_004.sbx','passiveBehav3x8minV2.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62zz9tt_001_003.sbx','passiveBehav2sf8minSessionV2.mat','C:\behavStim2sf8min.mat',psfile);

% passiveBehav2pSession('g62zz9tt_001_002.sbx','passiveBehav3x4orientV2.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62zz9tt_001_001.sbx','passiveBehav2sfSessionV2.mat','C:\behavStim2sfSmall3366.mat',psfile);



try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);
makeSbxMoviesBatch

%getCellsBatch;
