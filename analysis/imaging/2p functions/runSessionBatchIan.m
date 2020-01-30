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
%  topo2pSession('G6H12p13LN_001_009.sbx','topoXsession_V3.mat',psfilename);
%  topo2pSession('G6H12p13LN_001_010.sbx','topoYsession_V2.mat',psfilename);
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
% topo2pSession('G6H17p5RT_001_001.sbx','topoXPREsession_V2.mat',psfilename);
% topo2pSession('G6H17p5RT_001_002.sbx','topoYPREsession_V2.mat',psfilename);
% topo2pSession('G6H17p5RT_001_003.sbx','darknessPREsession_V2.mat',psfilename);
% patchGrating2pSession('G6H17p5RT_001_004.sbx','patchGratingPREsession_V2.mat',psfilename);
% patchGrating2pSession('G6H17p5RT_001_005.sbx','patchGratingPOSTsession_V2.mat',psfilename);
% topo2pSession('G6H17p5RT_001_006.sbx','darknessPOSTsession_V2.mat',psfilename);
% topo2pSession('G6H17p5RT_001_007.sbx','topoYPOSTsession_V2.mat',psfilename);
% topo2pSession('G6H17p5RT_001_008.sbx','topoXPOSTsession_V2.mat',psfilename);

%% 071619
% topo2pSession('G6H15p5RT_001_001.sbx','darknessPREsession_V2.mat',psfilename);
% topo2pSession('G6H15p5RT_001_002.sbx','darknessPOSTsession_V2.mat',psfilename);

%% 072219
% topo2pSession('G6H12p13TT_001_001.sbx','topoX_pre.mat',psfilename);
% topo2pSession('G6H12p13TT_001_002.sbx','topoY_pre.mat',psfilename);
% %    topo2pSession('G6H12p13TT_001_003.sbx','003.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_004.sbx','004.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_005.sbx','005.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_006.sbx','006.mat',psfilename);
% topo2pSession('G6H12p13TT_001_007.sbx','topoY_post.mat',psfilename);
% topo2pSession('G6H12p13TT_001_008.sbx','topoX_post.mat',psfilename);

% %% 072619
% topo2pSession('G6H12p13TT_001_001.sbx','topoX_pre.mat',psfilename);
% topo2pSession('G6H12p13TT_001_002.sbx','topoY_pre.mat',psfilename);
% %    topo2pSession('G6H12p13TT_001_003.sbx','003.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_004.sbx','004.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_005.sbx','005.mat',psfilename);
% %   topo2pSession('G6H12p13TT_001_006.sbx','006.mat',psfilename);
% topo2pSession('G6H12p13TT_001_007.sbx','topoY_post.mat',psfilename);
% topo2pSession('G6H12p13TT_001_008.sbx','topoX_post.mat',psfilename);

%082719
% topo2pSession('G6H15P11RT_001_002.sbx','topoX_pre.mat',psfilename);
% topo2pSession('G6H15P11RT_001_003.sbx','topoY_pre.mat',psfilename);
% topo2pSession('G6H15P11RT_001_004.sbx','004.mat',psfilename);
% topo2pSession('G6H15P11RT_001_005.sbx','005.mat',psfilename);
% topo2pSession('G6H15P11RT_001_006.sbx','topoX_post.mat',psfilename);
% topo2pSession('G6H15P11RT_001_007.sbx','topoY_post.mat',psfilename);


%%% extract cell peaks (use values from first session, but could modify
[dF xpts ypts minF xrange yrange ] =  getCellsPeaks('topoX_pre.mat',psfilename,2);
getCellsPeaks('topoY_pre.mat',psfilename,2,minF,xrange,yrange);
getCellsPeaks('topoY_post.mat',psfilename,2,minF,xrange,yrange);
getCellsPeaks('topoX_post.mat',psfilename,2,minF,xrange,yrange);

%%% prepost comparison
prePost2p({'topoX_pre.mat','topoX_post.mat'},psfilename)
prePost2p({'topoY_pre.mat','topoY_post.mat'},psfilename)

%%
dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
if exist(newpdfFile,'file')
    display('generated pdf using dos ps2pdf')
    delete(psfilename);
end