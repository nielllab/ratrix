close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir

makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic
behav2pSession('g62dd2ln_001_001.sbx','behavSessionNEW.mat','trialRecords_5508-5754_20160418T122637-20160418T130556.mat',psfile);
topo2pSession('g62dd2ln_001_002.sbx','topoXsessionNEW.mat',psfile);
topo2pSession('g62dd2ln_001_003.sbx','topoYsessionNEW.mat',psfile);
grating2pSession('g62dd2ln_001_004.sbx','gratingSessionNEW.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_005.sbx','passiveBehav3x4orientSessionNEW.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62dd2ln_001_008.sbx','passiveBehav2sfSessionNEW.mat','C:\behavStim2sfSmall3366.mat',psfile);
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

getCellsBatch;
