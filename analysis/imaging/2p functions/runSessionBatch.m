close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62dd2ln_001_000.sbx','behavSessionEff.mat','trialRecords_2612-2984_20160330T131438-20160330T135750.mat',psfile);
topo2pSession('g62dd2ln_001_001.sbx','topoXsessionEff.mat',psfile);
topo2pSession('g62dd2ln_001_002.sbx','topoYsessionEff.mat',psfile);
grating2pSession('g62dd2ln_001_003.sbx','gratingSessionEff.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav3x4orientSessionEff.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_006.sbx','passiveBehav2sfSessionEff.mat','C:\behavStim2sfSmall3366.mat',psfile);
%behav2pSession('g62dd2ln_001_001.sbx','behavSession_notgood.mat','trialRecords_4430-4501_20160411T153932-20160411T155102.mat',psfile);
% topo2pSession('g62dd2ln_001_003.sbx','topoXsession2.mat',psfile);
%topo2pSession('g62dd2ln_001_006.sbx','topoYsession2.mat',psfile);
toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);

%getCellsBatch;
