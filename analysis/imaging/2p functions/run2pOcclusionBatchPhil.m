%% run2pOcclusionBatchPhil

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


%%%%for manual analysis
[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfilename = 'c:\tempPhil.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

if S2P==0
    sbxaligndir
end

% makeSbxMoviesBatch

%% experiments

%110918
topo2pSession('G6H79LT_001_001.sbx','topoXsession_V2.mat',psfilename);
topo2pSession('G6H79LT_001_002.sbx','topoYsession_V2.mat',psfilename);
spot2pSession('G6H79LT_001_003.sbx','spotTest_V2.mat',psfilename);
occlusion2pSession('G6H79LT_001_004.sbx','occlusion6min4rpt_V2.mat',psfilename);


%% make pdf

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