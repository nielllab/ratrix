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
S2P=1
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




behav2pSession('g62tx15lt_001_001.sbx','behavSessionS2P.mat','trialRecords_4907-5064_20160606T124008-20160606T131912.mat',psfile);
topo2pSession('g62tx15lt_001_002.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62tx15lt_001_003.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62tx15lt_001_006.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62tx15lt_001_004.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);

%%behav2pSession('g62tx15lt_001_000.sbx','behavSessionNOTGOODV2.mat','trialRecords_3377-3408_20160525T150056-20160525T151722.mat',psfile);
%%topo2pSession('g62tx15lt_001_002.sbx','topoXsession2-V2.mat',psfile);
%%topo2pSession('g62tx15lt_001_002.sbx','topoYsession2short-V2.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav3x8minSessionV2_2.mat ','C:\behavStim3x8min.mat',psfile);
%passiveBehav2pSession('g62tx15lt_001_003.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sf8min.mat',psfile);
%grating2pSession('g62tx15lt_001_003.sbx','gratingSessionV2noStimobj.mat',psfile);

%%behav2pSession('naive_000_001.sbx','behavSessionnaiveV2.mat','trialRecords_25-36_20160601T111043-20160601T111151.mat',psfile);
% behav2pSession('naive_000_002.sbx','behavSessionhVvV2.mat','trialRecords_1219-1234_20160601T111252-20160601T111439.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);
%makeSbxMoviesBatch

%getCellsBatch;
