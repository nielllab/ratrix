close all
clear all
dbstop if error
profile on

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

global S2P
S2P=1

% params to use: spatial 2, temporal 4, frmrate 25, yes to align
spatialBin = 2;
temporalBin = 4;
movierate = 25;
alignData = 1;
fullMovie = 1;

if S2P==0
    sbxaligndir
end

% makeSbxMoviesBatch

psfilename = 'c:\tempPhil.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

tic

% topo2pSession('G62BB6RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62BB6RT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62BB6RT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

% topo2pSession('G62TX210TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62TX210TT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62TX210TT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);


% topo2pSession('G62EE8TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62EE8TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62EE8TT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62EE8TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62EE8TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62EE8TT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

% topo2pSession('G62AA3TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62AA3TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62AA3TT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AA3TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AA3TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62AA3TT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);


% topo2pSession('G62BB8RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB8RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62BB8RT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62BB8RT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);
% 
% topo2pSession('G62TX210TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_002.sbx','topoYsession_V2.mat',psfilename);

% topo2pSession('G62Y9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62Y9RT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62Y9RT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);
% 
% topo2pSession('G62TX19LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX19LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62TX19LT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62TX19LT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);


% sizeSelect2pSession('g62tx1rt_001_007.sbx','sizeSessionPOST_V2.mat',psfile);
% 
% topo2pSession('g62tx1rt_001_000.sbx','topoXsessionPRE_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_001.sbx','topoYsessionPRE_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_008.sbx','topoXsessionPOST_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_009.sbx','topoYsessionPOST_V2.mat',psfile);

%%090816
% topo2pSession('G62TX210TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62TX210TT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62TX210TT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_008.sbx','darkness_POST_V2.mat',psfilename);

%%090916
% topo2pSession('G62BB6RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB6RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB6RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%091016
% topo2pSession('G62Y9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Y9RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62Y9RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62Y9RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62Y9RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%091016
% topo2pSession('G62BB8TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB8TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% patchGrating2pSession('G62BB8TT_001_003.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% topo2pSession('G62BB8TT_001_004.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8TT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8TT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB8TT_001_007.sbx','darkness_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB8TT_001_008.sbx','patchGratingsession_POST_V2.mat',psfilename);

% % %%091216
% topo2pSession('G62TX19LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX19LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62TX19LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62TX19LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62TX19LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62TX19LT_001_008.sbx','darkness_POST_V2.mat',psfilename);
% % 
% %%091216
% topo2pSession('G62MM3RN_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_008.sbx','darkness_POST_V2.mat',psfilename);

% % %%091516
% topo2pSession('G62BB7LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB7LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB7LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB7LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB7LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB7LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB7LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB7LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

%%%091616
% topo2pSession('G62FF2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62FF2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62FF2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62FF2RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FF2RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FF2RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62FF2RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62FF2RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% % %%%091616
% topo2pSession('G62Z5RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Z5RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Z5RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62Z5RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Z5RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Z5RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62Z5RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62Z5RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

%%%091716
% topo2pSession('G62MM3RN_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_008.sbx','darkness_POST_V2.mat',psfilename);

%%101216
% topo2pSession('G62TX210TT_001_005.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_004.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62TX210TT_001_007.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_008.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX210TT_001_009.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62TX210TT_001_010.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62TX210TT_001_011.sbx','darkness_POST_V2.mat',psfilename);

% %%101216
% topo2pSession('G62BB6RT_001_003.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_004.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_005.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB6RT_001_006.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB6RT_001_009.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_010.sbx','darkness_POST_V2.mat',psfilename);

% %%101516
% topo2pSession('G62BB2RT_001_005.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_004.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB2RT_001_007.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_008.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_009.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB2RT_001_010.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_011.sbx','darkness_POST_V2.mat',psfilename);

% %%101616
% topo2pSession('G62MM3RN_001_005.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_006.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_007.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_008.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_009.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_010.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_011.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_012.sbx','darkness_POST_V2.mat',psfilename);

% %%102816
% topo2pSession('G62MM3RN_001_006.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_007.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_008.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_009.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_010.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62MM3RN_001_011.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62MM3RN_001_012.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62MM3RN_001_013.sbx','darkness_POST_V2.mat',psfilename);

% %%111216
% topo2pSession('G62BB2RT_001_006.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_007.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_008.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB2RT_001_009.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_010.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_011.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB2RT_001_012.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_013.sbx','darkness_POST_V2.mat',psfilename);

% %%112316
% topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%112716
% topo2pSession('G62Y3LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62Y3LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62Y3LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%112916
% topo2pSession('G62BB10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB10LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB10LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011217
% topo2pSession('G62DD2LN_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62DD2LN_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DD2LN_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DD2LN_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62DD2LN_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011217
% topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011317
% topo2pSession('G62BB10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62BB10LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62BB10LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011517
% topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62GG10LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011617
% topo2pSession('G62DD2LN_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62DD2LN_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DD2LN_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DD2LN_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62DD2LN_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62DD2LN_001_008.sbx','darkness_POST_V2.mat',psfilename);

% % %011817
% topo2pSession('G62Y3LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62Y3LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62Y3LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011917
% topo2pSession('G62W9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62W9RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62W9RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%012317
% topo2pSession('G62W9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62W9RT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62W9RT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% %%011917
% topo2pSession('G62QQ2LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% patchGrating2pSession('G62QQ2LT_001_004.sbx','patchGratingsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_005.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_006.sbx','sizeSession_POST_V2.mat',psfilename);
% patchGrating2pSession('G62QQ2LT_001_007.sbx','patchGratingsession_POST_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_008.sbx','darkness_POST_V2.mat',psfilename);

% % %%020817
% topo2pSession('G62W9RT_001_001.sbx','topoXsession_PRE_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_002.sbx','topoYsession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_003.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_004.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_005.sbx','topoYsession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_006.sbx','topoXsession_POST_V2.mat',psfilename);

% %%%022017
% topo2pSession('G62BB6RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

%%%022127
topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
sizeSelect2pSession('G62GG10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
topo2pSession('G62GG10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%022317
% topo2pSession('G62BB6RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%022317
% topo2pSession('G62Y3LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%022817
% topo2pSession('G62W9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%030117
% topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0030217
% topo2pSession('G62Y3LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y3LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62Y3LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0030717
% topo2pSession('G62QQ2LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0030817
% topo2pSession('G62W9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0030917
% topo2pSession('G62QQ2LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ2LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62QQ2LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0031417
% topo2pSession('G62BB10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0031517
% topo2pSession('G62BB2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0031617
% topo2pSession('G62BB10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%0031717
% topo2pSession('G62BB2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB2RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB2RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

toc


% 
% try
%     dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )
% 
% catch
%     display('couldnt generate pdf');
% end
%delete(psfile);

dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
if exist(newpdfFile,'file')
%     ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"']
    display('generated pdf using dos ps2pdf')
else
    try
        ps2pdf('psfile', psfilename, 'pdffile', newpdfFile)
        newpdfFile
        display('generated pdf using builtin matlab ps2pdf')
    catch
        display('couldnt generate pdf');
        keyboard
    end
end

delete(psfilename);
%getCellsBatch;
profile viewer
