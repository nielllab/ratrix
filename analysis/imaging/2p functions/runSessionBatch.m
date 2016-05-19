close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

%makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62dd2ln_001_003.sbx','behavSessionV2.mat','trialRecords_2298-2611_20160329T130445-20160329T134519.mat',psfile);
topo2pSession('g62dd2ln_001_004.sbx','topoXsessionV2.mat',psfile);
topo2pSession('g62dd2ln_001_005.sbx','topoYsessionV2.mat',psfile);
grating2pSession('g62dd2ln_001_006.sbx','gratingSessionV2.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_007.sbx','passiveBehav3x4orientSessionV2.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_008.sbx','passiveBehav2sfSessionV2.mat','C:\behavStim2sfSmall3366.mat',psfile);
%behav2pSession('g62dd2ln_001_001.sbx','behavSession_notgood.mat','trialRecords_4430-4501_20160411T153932-20160411T155102.mat',psfile);
% topo2pSession('g62dd2ln_001_003.sbx','topoXsession2-V2.mat',psfile);
% topo2pSession('g62dd2ln_001_006.sbx','topoYsession2-V2.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_003.sbx','passiveBehav3x4orientSessionV2noStimobj.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav2sfSessionEffV2noStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);
%grating2pSession('g62dd2ln_001_003.sbx','gratingSessionV2noStimobj.mat',psfile);

toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);

%getCellsBatch;
