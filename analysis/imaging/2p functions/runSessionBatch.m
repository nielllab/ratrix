close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

%makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62tx15lt_001_000.sbx','behavSessionV2.mat','trialRecords_5178-5383_20160608T124612-20160608T131300.mat',psfile);
topo2pSession('g62tx15lt_001_003.sbx','topoXsessionV2.mat',psfile);
topo2pSession('g62tx15lt_001_004.sbx','topoYsessionV2.mat',psfile);
grating2pSession('g62tx15lt_001_005.sbx','gratingSessionV2.mat',psfile);
passiveBehav2pSession('g62tx15lt_001_002.sbx','passiveBehav3x4orientSessionV2.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62tx15lt_001_001.sbx','passiveBehav2sfSessionV2.mat','C:\behavStim2sfSmall3366.mat',psfile);

%%behav2pSession('g62tx15lt_001_000.sbx','behavSessionNOTGOODV2.mat','trialRecords_3377-3408_20160525T150056-20160525T151722.mat',psfile);
% % topo2pSession('g62tx15lt_001_003.sbx','topoXsession2-V2.mat',psfile);
% % topo2pSession('g62tx15lt_001_004.sbx','topoYsession2-V2.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_003.sbx','passiveBehav3x4orientSessionV2noStimobj.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);
%grating2pSession('g62tx15lt_001_003.sbx','gratingSessionV2noStimobj.mat',psfile);

%%behav2pSession('naive_000_001.sbx','behavSessionnaiveV2.mat','trialRecords_25-36_20160601T111043-20160601T111151.mat',psfile);
% behav2pSession('naive_000_002.sbx','behavSessionhVvV2.mat','trialRecords_1219-1234_20160601T111252-20160601T111439.mat',psfile);

toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);
makeSbxMoviesBatch

%getCellsBatch;
