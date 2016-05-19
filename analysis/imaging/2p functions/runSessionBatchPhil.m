close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

%makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
%behav2pSession('g62dd2ln_001_000.sbx','behavSessionV2.mat','trialRecords_4502-4638_20160412T135714-20160412T141357.mat',psfile);

sizeSelect2pSession('g62tx1rt_001_005.sbx','sizeSessionPRE_V2.mat',psfile);
sizeSelect2pSession('g62tx1rt_001_007.sbx','sizeSessionPOST_V2.mat',psfile);

topo2pSession('g62tx1rt_001_000.sbx','topoXsessionPRE_V2.mat',psfile);
topo2pSession('g62tx1rt_001_001.sbx','topoYsessionPRE_V2.mat',psfile);
topo2pSession('g62tx1rt_001_008.sbx','topoXsessionPOST_V2.mat',psfile);
topo2pSession('g62tx1rt_001_009.sbx','topoYsessionPOST_V2.mat',psfile);


% 
% grating2pSession('g62dd2ln_001_003.sbx','gratingSessionV2.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_004.sbx','passiveBehav3x4orientSessionV2.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav2sfSessionV2.mat','C:\behavStim2sfSmall3366.mat',psfile);
%behav2pSession('g62dd2ln_001_001.sbx','behavSession_notgood.mat','trialRecords_4430-4501_20160411T153932-20160411T155102.mat',psfile);
% topo2pSession('g62dd2ln_001_003.sbx','topoXsession2-V2.mat',psfile);
% topo2pSession('g62dd2ln_001_006.sbx','topoYsession2-V2.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_003.sbx','passiveBehav3x4orientSessionV2noStimobj.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);

toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);

%getCellsBatch;
