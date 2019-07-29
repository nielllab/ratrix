%% runSessionBatchIan
close all
clear all
dbstop if error

% params to use: spatial 2, temporal 4, frmrate 25, yes to align
spatialBin = 2;
temporalBin = 4;
movierate = 25;
alignData = 1;
fullMovie = 1;

%%%%for manual analysis
[f p] = uiputfile('*.pdf','name your experiment pdf file');
newpdfFile = fullfile(p,f);

psfilename = 'c:\tempIan.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

makeSbxMoviesBatch

%% 060219
% topo2pSession('G6H12p13LN_001_009.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_010.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_001.sbx','topo1session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_002.sbx','topo2session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_003.sbx','topo3session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_004.sbx','topo4session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_005.sbx','topo5session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_006.sbx','topo6session_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_008.sbx','topo8session_V2.mat',psfilename);

%% 060319
% topo2pSession('G6H12p13LN_001_001.sbx','topoXPREsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_002.sbx','topoYPREsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_003.sbx','darknessPREsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_004.sbx','darknessPOSTsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_005.sbx','topoYPOSTsession_V2.mat',psfilename);
% topo2pSession('G6H12p13LN_001_006.sbx','topoXPOSTsession_V2.mat',psfilename);

%% 070219
topo2pSession('G6H17p5RT_001_001.sbx','topoXPREsession_V2.mat',psfilename);
topo2pSession('G6H17p5RT_001_002.sbx','topoYPREsession_V2.mat',psfilename);
topo2pSession('G6H17p5RT_001_003.sbx','darknessPREsession_V2.mat',psfilename);
patchGrating2pSession('G6H17p5RT_001_004.sbx','patchGratingPREsession_V2.mat',psfilename);
patchGrating2pSession('G6H17p5RT_001_005.sbx','patchGratingPOSTsession_V2.mat',psfilename);
topo2pSession('G6H17p5RT_001_006.sbx','darknessPOSTsession_V2.mat',psfilename);
topo2pSession('G6H17p5RT_001_007.sbx','topoYPOSTsession_V2.mat',psfilename);
topo2pSession('G6H17p5RT_001_008.sbx','topoXPOSTsession_V2.mat',psfilename);

%% 071619
% topo2pSession('G6H15p5RT_001_001.sbx','darknessPREsession_V2.mat',psfilename);
% topo2pSession('G6H15p5RT_001_002.sbx','darknessPOSTsession_V2.mat',psfilename);

%%
dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
if exist(newpdfFile,'file')
    display('generated pdf using dos ps2pdf')
    delete(psfilename);
end