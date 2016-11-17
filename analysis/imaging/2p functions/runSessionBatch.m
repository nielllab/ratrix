close all
clear all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

%makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62QQ2LT_001_000.sbx','behavSessionV2.mat','trialRecords_1-156_20161017T133105-20161017T135049.mat',psfile);
topo2pSession('g62QQ2LT_001_001.sbx','topoXsessionV2.mat',psfile);
topo2pSession('g62QQ2LT_001_002.sbx','topoYsessionV2.mat',psfile);
grating2pSession('g62QQ2LT_001_003.sbx','gratingSessionV2.mat',psfile);
% passiveBehav2pSession('g62QQ2LT_001_004.sbx','passiveBehav3x8minV2.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62QQ2LT_001_003.sbx','passiveBehav2sf8minSessionV2.mat','C:\behavStim2sf8min.mat',psfile);

%%behav2pSession('g62QQ2LT_001_000.sbx','behavSessionNOTGOODV2.mat','trialRecords_3377-3408_20160525T150056-20160525T151722.mat',psfile);
%%topo2pSession('g62QQ2LT_001_002.sbx','topoXsession2-V2.mat',psfile);
%%topo2pSession('g62QQ2LT_001_002.sbx','topoYsession2short-V2.mat',psfile);
% passiveBehav2pSession('g62QQ2LT_001_005.sbx','passiveBehav3x8minSessionV2_2.mat ','C:\behavStim3x8min.mat',psfile);
%passiveBehav2pSession('g62QQ2LT_001_006.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sf8min.mat',psfile);
%grating2pSession('g62QQ2LT_001_003.sbx','gratingSessionV2noStimobj.mat',psfile);

%%behav2pSession('naive_000_001.sbx','behavSessionnaiveV2.mat','trialRecords_25-36_20160601T111043-20160601T111151.mat',psfile);
% behav2pSession('naive_000_002.sbx','behavSessionhVvV2.mat','trialRecords_1219-1234_20160601T111252-20160601T111439.mat',psfile);
% passiveBehav2pSession('g62QQ2LT_001_005.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);

toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);
makeSbxMoviesBatch

%getCellsBatch;
