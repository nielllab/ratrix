close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62y3lt_001_000.sbx','behavSessionV2.mat','trialRecords_2702-2867_20160511T123527-20160511T130003.mat',psfile);
topo2pSession('g62y3lt_001_001.sbx','topoXsessionV2.mat',psfile);
topo2pSession('g62y3lt_001_002.sbx','topoYsessionV2.mat',psfile);
grating2pSession('g62y3lt_001_005.sbx','gratingSessionV2.mat',psfile);
passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientSessionV2.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav2sfSessionV2.mat','C:\behavStim2sfSmall3366.mat',psfile);
%behav2pSession('g62y3lt_001_001.sbx','behavSession_notgood.mat','trialRecords_4430-4501_20160411T153932-20160411T155102.mat',psfile);
% topo2pSession('g62y3lt_001_003.sbx','topoXsession2.mat',psfile);
% topo2pSession('g62y3lt_001_007.sbx','topoYsession2.mat',psfile);
%passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientSessionEffnoStimobj.mat ','C:\behavStim3sf4orient.mat',psfile);
%passiveBehav2pSession('g62y3lt_001_005.sbx','passiveBehav2sfSessionEffnoStimobj.mat','C:\behavStim2sfSmall3366.mat',psfile);

toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);

%getCellsBatch;
