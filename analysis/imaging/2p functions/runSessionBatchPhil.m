close all
clear all
dbstop if error
% profile on

% [f p] = uiputfile('*.pdf','pdf file');
% newpdfFile = fullfile(p,f);

global S2P
S2P=0

% params to use: spatial 2, temporal 4, frmrate 25, yes to align
spatialBin = 2;
temporalBin = 4;
movierate = 25;
alignData = 1;
fullMovie = 1;

% %%%%for batch analysis
% 
% batchPhil2pSizeSelect22min
% cd(pathname)
% 
% for z=1:length(files)
%     
%     sprintf('analyzing %d of %d',z,length(files))
%     
% %     cd(fullfile(pathname,files(z).dir))
% 
% if S2P==0
%     sbxaligndir
% end
% 
% % makeSbxMoviesBatch
% 
% newpdfFile = [files(z).sizesession '.pdf']
% 
% psfilename = 'c:\tempPhil.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% tic
% 
% topo2pSession([files(z).topoxdata ',sbx'],[files(z).topoxsession '.mat'],psfilename);
% topo2pSession([files(z).topoydata ',sbx'],[files(z).topoysession '.mat'],psfilename);
% sizeSelect2pSession([files(z).sizedata ',sbx'],[files(z).sizesession '.mat'],files(z).sizestimObj,psfilename);


%%%%for manual analysis
[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfilename = 'c:\tempPhil.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

if S2P==0
    sbxaligndir
end

makeSbxMoviesBatch


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

%%%022017
% topo2pSession('G62BB6RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB6RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB6RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%022127
% topo2pSession('G62GG10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GG10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GG10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

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

% %%%060117 test
% topo2pSession('G62W9RT_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62W9RT_001_005.sbx','topoYsession_V2.mat',psfilename);
% sizeSelect2pSession('G62W9RT_001_006.sbx','sizeSession_PRE_V2.mat',psfilename);

%%%060117
% topo2pSession('G62GGG1LT_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG1LT_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG1LT_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_009.sbx','darkness_POST_V2.mat',psfilename);

%%%060117
% topo2pSession('G62GGG3LT_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG3LT_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG3LT_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_009.sbx','darkness_POST_V2.mat',psfilename);

%%%060617
% topo2pSession('G62GGG1LT_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG1LT_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG1LT_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG1LT_001_009.sbx','darkness_POST_V2.mat',psfilename);

% %%%060617
% topo2pSession('G62GGG3LT_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG3LT_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG3LT_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG3LT_001_009.sbx','darkness_POST_V2.mat',psfilename);

%%%060717
% topo2pSession('CG48LN_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('CG48LN_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('CG48LN_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('CG48LN_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('CG48LN_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('CG48LN_001_009.sbx','darkness_POST_V2.mat',psfilename);

%%%060917
% topo2pSession('CG48LN_001_004.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('CG48LN_001_005.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('CG48LN_001_006.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('CG48LN_001_007.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('CG48LN_001_008.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('CG48LN_001_009.sbx','darkness_POST_V2.mat',psfilename);

% %%%071017
% topo2pSession('G62FFF1RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FFF1RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FFF1RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071017
% topo2pSession('G62RR4LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071217
% topo2pSession('G62FFF1RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FFF1RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FFF1RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071317
% topo2pSession('G62RR4LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071317
% topo2pSession('G62JJ2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62JJ2RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62JJ2RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% % %%%071717
% topo2pSession('G62RR4LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62RR4LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62RR4LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071717
% topo2pSession('G62JJ2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62JJ2RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62JJ2RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%071717
% topo2pSession('G62TT1LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TT1LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TT1LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%091317
% topo2pSession('G62AAA11LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AAA11LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AAA11LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%091317
% topo2pSession('G62GGG6TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG6TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG6TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%091417
% topo2pSession('G62DDD3TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_006.sbx','darkness_POST_V2.mat',psfilename);
% 
% %%091517
% topo2pSession('G62GGG6TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG6TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62GGG6TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62GGG6TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%091517
% topo2pSession('G62ZZ9TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

%%%091817
% topo2pSession('G62DDD3TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%091917
% topo2pSession('G62ZZ9TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%092117
% topo2pSession('G62AAA11LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AAA11LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AAA11LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62AAA11LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%092217
% topo2pSession('G62ZZ9TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62ZZ9TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62ZZ9TT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%%092217
% topo2pSession('G62TT1LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TT1LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TT1LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62TT1LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%092417
% topo2pSession('G62DDD3TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62DDD3TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62DDD3TT_001_006.sbx','darkness_POST_V2.mat',psfilename);
% 
% %%092517
% topo2pSession('G62BB10LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB10LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62BB10LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%092617
% topo2pSession('G62QQ1RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ1RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ1RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%092717
% topo2pSession('G62QQ1RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ1RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62QQ1RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G62QQ1RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121217
% topo2pSession('G6H310RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H310RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H310RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121217
% topo2pSession('G6H39LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121217
% topo2pSession('G6H28LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H28LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H28LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121417
% topo2pSession('G6H39LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121517
% topo2pSession('G6H310RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H310RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H310RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H310RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121217
% topo2pSession('G6H28LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H28LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H28LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H28LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

% %%121817
% topo2pSession('G6H39LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G6H39LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% topo2pSession('G6H39LT_001_006.sbx','darkness_POST_V2.mat',psfilename);

%%121817
topo2pSession('G6H310RT_001_001.sbx','topoXsession_V2.mat',psfilename);
topo2pSession('G6H310RT_001_002.sbx','topoYsession_V2.mat',psfilename);
topo2pSession('G6H310RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
sizeSelect2pSession('G6H310RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
sizeSelect2pSession('G6H310RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
topo2pSession('G6H310RT_001_006.sbx','darkness_POST_V2.mat',psfilename);

%%%%%testing stuff

% % %%%071617
% topo2pSession('G62FFF1RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62FFF1RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% spot2pSession('G62FFF1RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62FFF1RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);

% %%%071617
% topo2pSession('G62JJ2RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62JJ2RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% spot2pSession('G62JJ2RT_001_003.sbx','darkness_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62JJ2RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);



%%%%%axon data

% %%061217
% topo2pSession('G62YY5RN_001_009.sbx','topoXsession_PRE_V2.mat',psfilename);
% topo2pSession('G62YY5RN_001_010.sbx','topoYsession_PRE_V2.mat',psfilename);
% topo2pSession('G62YY5RN_001_011.sbx','darkness_PRE_V2.mat',psfilename);
% topo2pSession('G62YY5RN_001_012.sbx','darkness_POST_V2.mat',psfilename);
% topo2pSession('G62YY5RN_001_013.sbx','topoYsession_POST_V2.mat',psfilename);
% topo2pSession('G62YY5RN_001_014.sbx','topoXsession_POST_V2.mat',psfilename);

% % %%070317
% axonSession('G62YY5RT_001_001.sbx','topoXsession_PRE_V2.mat',psfilename); %%topox
% axonSession('G62YY5RT_001_002.sbx','topoYsession_PRE_V2.mat',psfilename); %%topoy
% axonSession('G62YY5RT_001_003.sbx','darkness_PRE_V2.mat',psfilename); %%darkness
% axonSession('G62YY5RT_001_004.sbx','darkness_POST_V2.mat',psfilename); %%darkness DOI
% axonSession('G62YY5RT_001_005.sbx','topoYsession_POST_V2.mat',psfilename); %%topoy DOI
% axonSession('G62YY5RT_001_006.sbx','topoXsession_POST_V2.mat',psfilename); %%topox DOI

% %%070317
% axonSession('G62YY5RT_001_001.sbx','topoXsession_PRE_V2.mat',psfilename); %%topox
% axonSession('G62YY5RT_001_002.sbx','topoYsession_PRE_V2.mat',psfilename); %%topox
% axonSession('G62YY5RT_001_003.sbx','darkness_PRE_V2.mat',psfilename); %%size select (partial)

%%070317
% axonSession('G62YY5RN_001_001.sbx','topoXsession_PRE_V2.mat',psfilename); %%topox
% 
% %%070317
% axonSession('G62YY5LN_001_001.sbx','topoXsession_PRE_V2.mat',psfilename); %%topox


% %%%070517
% spot2pSession('CG49LT_001_001.sbx','bigSizeTest_V2.mat',psfilename);
% % sizeSelect2pSession('CG49LT_001_002.sbx','sizeSessionLongISI1_V2.mat',psfilename);
% sizeSelect2pSession('CG49LT_001_003.sbx','sizeSessionLongISI2_V2.mat',psfilename);



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
% else
%     try
%         ps2pdf('psfile', psfilename, 'pdffile', newpdfFile)
%         newpdfFile
%         display('generated pdf using builtin matlab ps2pdf')
%     catch
%         display('couldnt generate pdf');
%         keyboard
%     end

end

delete(psfilename);

% end

%getCellsBatch;
% profile viewer
