%batch_session_Joe_S2P
%%run session analysis for all uncomented sessions in batch mode;  check all
%%info for paths and make sure it matches where your data is.  

dbstop if error

close all
clear all

%for suite 2p session analysis%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global S2P
S2P=1

% params to use: spatial 2, temporal 4, frmrate 12.5, yes to align
spatialBin = 2;
temporalBin = 4;
movierate = 12.5;
alignData = 1;
fullMovie = 1;

if S2P==0
    sbxaligndir
    %makeSbxMoviesBatch
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


n=0

 
%datadir = '\\langevin\backup\twophoton\Newton\data\'; %data backup
%datadir = 'C:\';  %SSD on Joze-Monster
datadir = 'F:\';  %Spinning disk on Joze-Monster


psfile = 'c:\tempJW.ps';
if exist(psfile,'file')==2;delete(psfile);end



% 
% 
% %GTS

% n=n+1 %g62y3lt 050316  %(re-run 4/24/17 _S2P)
%                 sessiondir{n}= '050316 g62y3lt GTS behavior\g62y3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '050316_g62y3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1853-2020_20160503T154535-20160503T160643.mat',psfile);
% topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62y3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 

%%may need to rerun the y3 sessions because passive behavStim was different
n=n+1 %g62y3lt 050516
                sessiondir{n}= '050516 g62y3lt GTS behavior\g62y3lt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '050516_g62y3lt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

%behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2261-2511_20160505T131650-20160505T135237.mat',psfile);
topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62y3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end
close all; 
% % % 
% n=n+1 %g62y3lt 050916
%                 sessiondir{n}= '050916 g62y3lt GTS behavior\g62y3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '050916_g62y3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2527-2680_20160509T124714-20160509T131922.mat',psfile);
% topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62y3lt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_005.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
%
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
%
%
% n=n+1 %g62tx15lt 060616
%                 sessiondir{n}= '060616 g62tx15lt GTS behavior\g62tx15lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '060616_g62tx15lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tx15lt_001_001.sbx','behavSessionS2P.mat','trialRecords_4907-5064_20160606T124008-20160606T131912.mat',psfile);
% topo2pSession('g62tx15lt_001_002.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tx15lt_001_003.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tx15lt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_004.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
% 
% 
% n=n+1 %g62tx15lt 060816
%                 sessiondir{n}= '060816 g62tx15lt GTS behavior\g62tx15lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '060816_g62tx15lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tx15lt_001_000.sbx','behavSessionS2P.mat','trialRecords_5178-5383_20160608T124612-20160608T131300.mat',psfile);
% topo2pSession('g62tx15lt_001_003.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tx15lt_001_004.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tx15lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_002.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_001.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% n=n+1 %g62bb10lt 063016
%                 sessiondir{n}= '063016 g62bb10lt GTS behavior\g62bb10lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '063016_g62bb10lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62bb10lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2044-2243_20160630T133628-20160630T140450.mat',psfile);
% topo2pSession('g62bb10lt_001_003.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62bb10lt_001_004.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62bb10lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62bb10lt_001_002.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62bb10lt_001_001.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
% 
% n=n+1 %g62bb10lt 072716
%                 sessiondir{n}= '072716 g62bb10lt gts behavior\g62bb10lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '072716_g62bb10lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62bb10lt_001_000.sbx','behavSessionS2P.mat','trialRecords_3756-3996_20160727T141438-20160727T143543.mat',psfile);
% topo2pSession('g62bb10lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62bb10lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62bb10lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62bb10lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62bb10lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;

% n=n+1 %g62gg5rt 080916
%                 sessiondir{n}= '080916 g62gg5rt GTS behavior\g62gg5rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '080916_g62gg5rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62gg5rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1295-1473_20160809T141013-20160809T142919.mat',psfile);
% topo2pSession('g62gg5rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62gg5rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62gg5rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62gg5rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62gg5rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
%                 
% n=n+1 %g62gg5rt 081216
%                 sessiondir{n}= '081216 g62gg5rt GTS behavior\g62gg5rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '081216_g62gg5rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62gg5rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1869-2059_20160812T121837-20160812T123821.mat',psfile);
% topo2pSession('g62gg5rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62gg5rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62gg5rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62gg5rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62gg5rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
%                 
%                 
%                 
%   n=n+1 %g62gg10lt 092216
%                 sessiondir{n}= '092216 g62gg10lt GTS behavior\g62gg10lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '092216_g62gg10lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62gg10lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1927-2132_20160922T112300-20160922T114229.mat',psfile);
% topo2pSession('g62gg10lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62gg10lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62gg10lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end
%close all;
% 
%   n=n+1 %g62gg10lt 092916
%                 sessiondir{n}= '092916 g62gg10lt GTS behavior\g62gg10lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '092916_g62gg10lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62gg10lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2618-2819_20160929T105655-20160929T111517.mat',psfile);
% topo2pSession('g62gg10lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62gg10lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62gg10lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                
%  close all;
%                 
%                 
%   n=n+1 %g62gg10lt 093016
%                 sessiondir{n}= '093016 g62gg10lt GTS behavior\g62gg10lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '093016_g62gg10lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62gg10lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2861-3082_20160930T110110-20160930T112043.mat',psfile);
% topo2pSession('g62gg10lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62gg10lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62gg10lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62gg10lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                
% close all;                                  
% 
%                 
                
% 
% %Naive

n=n+1 %g62ff8rt 072116
                sessiondir{n}= '072116 g62ff8rt Naive behavior\g62ff8rt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072116_g62ff8rt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62ff8rt_001_000.sbx','behavSessionS2P.mat','trialRecords_368-530_20160721T115149-20160721T121256.mat',psfile);
topo2pSession('g62ff8rt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62ff8rt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62ff8rt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
close all; 


n=n+1 %g62ff8rt 072216
                sessiondir{n}= '072216 g62ff8rt Naive behavior\g62ff8rt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072216_g62ff8rt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62ff8rt_001_000.sbx','behavSessionS2P.mat','trialRecords_532-708_20160722T132416-20160722T134234.mat',psfile);
topo2pSession('g62ff8rt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62ff8rt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62ff8rt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
close all; 


n=n+1 %g62ff8rt 072716
                sessiondir{n}= '072716 g62ff8rt Naive behavior\g62ff8rt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072716_g62ff8rt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62ff8rt_001_000.sbx','behavSessionS2P.mat','trialRecords_951-1134_20160727T115728-20160727T121918.mat',psfile);
topo2pSession('g62ff8rt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62ff8rt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62ff8rt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
close all; 

 
 n=n+1 %g62ff8rt 072816
                sessiondir{n}= '072816 g62ff8rt Naive behavior\g62ff8rt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072816_g62ff8rt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62ff8rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1146-1344_20160728T143556-20160728T145852.mat',psfile);
topo2pSession('g62ff8rt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62ff8rt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62ff8rt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62ff8rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
close all; 



n=n+1 %g62bb12lt 072116
                sessiondir{n}= '072116 g62bb12lt Naive behavior\g62bb12lt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072116_g62bb12lt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62bb12lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1065-1242_20160721T141522-20160721T143636.mat',psfile);
topo2pSession('g62bb12lt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62bb12lt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62bb12lt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62bb12lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62bb12lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
close all; 

n=n+1 %g62bb12lt 072216
                sessiondir{n}= '072216 g62bb12lt Naive behavior\g62bb12lt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '072216_g62bb12lt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62bb12lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1249-1409_20160722T105022-20160722T110905.mat',psfile);
topo2pSession('g62bb12lt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62bb12lt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62bb12lt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62bb12lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62bb12lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);

                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                
 close all; 

%   n=n+1 %g62qq2lt 101716
%                 sessiondir{n}= '101716 g62qq2lt Naive behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '101716_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1-156_20161017T133105-20161017T135049.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end 
%  close all;               
%                 
%                 
%                 
%   n=n+1 %g62qq2lt 101816
%                 sessiondir{n}= '101816 g62qq2lt Naive behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '101816_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_157-321_20161018T123255-20161018T125151.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end 
%  close all;               
%                 
% 
%   n=n+1 %g62qq2lt 101916
%                 sessiondir{n}= '101916 g62qq2lt Naive behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '101916_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_322-506_20161019T111945-20161019T113906.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                             
% close all;
%                 
% 
%   n=n+1 %g62qq2lt 102016
%                 sessiondir{n}= '102016 g62qq2lt Naive behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102016_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_001.sbx','behavSessionS2P.mat','trialRecords_603-683_20161020T111643-20161020T113450.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_003.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_005.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                  
%  close all;               
% 
%   n=n+1 %g62qq2lt 102116
%                 sessiondir{n}= '102116 g62qq2lt Naive behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102116_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_685-781_20161021T125257-20161021T131207.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%for langevin run

%   n=n+1 %g62tt1lt 101916
%                 sessiondir{n}= '101916 g62tt1lt Naive behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '101916_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1-169_20161019T130812-20161019T132921.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%   n=n+1 %g62tt1lt 102016
%                 sessiondir{n}= '102016 g62tt1lt Naive behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102016_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_170-345_20161020T133849-20161020T135842.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
% 
%   n=n+1 %g62tt1lt 102116
%                 sessiondir{n}= '102116 g62tt1lt Naive behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102116_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_346-513_20161021T110504-20161021T112425.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
% 
%   n=n+1 %g62tt1lt 102416
%                 sessiondir{n}= '102416 g62tt1lt Naive behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102416_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_514-636_20161024T120740-20161024T122512.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %


%   n=n+1 %g62tt1lt 102516  (accidentally ran as g62qq1rt)
%                 sessiondir{n}= '102516 g62qq1rt Naive behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102516_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1-123_20161025T125503-20161025T131425.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
%%%%%%%%%%%%%%%%%%%%%%%

%   n=n+1 %g62qq1rt 102716  
%                 sessiondir{n}= '102716 g62qq1rt Naive behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102716_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_124-313_20161027T104229-20161027T110319.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%   n=n+1 %g62qq1rt 102816  
%                 sessiondir{n}= '102816 g62qq1rt Naive behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '102816_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_314-465_20161028T105850-20161028T111905.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
%   n=n+1 %g62qq1rt 103116  
%                 sessiondir{n}= '103116 g62qq1rt Naive behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '103116_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_466-622_20161031T111645-20161031T113501.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
%   n=n+1 %g62qq1rt 110116  
%                 sessiondir{n}= '110116 g62qq1rt Naive behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '110116_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_624-790_20161101T104351-20161101T110328.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
% 
% %%%%%%%%%%%%
% (randreward) 
%%%%%%%%%%%%%%
%n=n+1 %g62qq2lt 120516  
%                 sessiondir{n}= '120516 g62qq2lt RandReward behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120516_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1261-1441_20161205T115150-20161205T120858.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62qq2lt 120616  
%                 sessiondir{n}= '120616 g62qq2lt RandReward behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120616_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1442-1618_20161206T124234-20161206T130006.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62qq2lt 120716  
%                 sessiondir{n}= '120716 g62qq2lt RandReward behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120716_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1619-1775_20161207T102058-20161207T104058.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62qq2lt 120816  
%                 sessiondir{n}= '120816 g62qq2lt RandReward behavior\g62qq2lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120816_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1776-1896_20161208T101746-20161208T103652.mat',psfile);
% topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62tt1lt 120616  
%                 sessiondir{n}= '120616 g62tt1lt RandReward behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120616_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1357-1519_20161206T103958-20161206T110059.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62tt1lt 120716  
%                 sessiondir{n}= '120716 g62tt1lt RandReward behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120716_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1520-1691_20161207T115847-20161207T122146.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62tt1lt 120816  
%                 sessiondir{n}= '120816 g62tt1lt RandReward behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120816_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1692-1836_20161208T140313-20161208T142355.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %

%n=n+1 %g62tt1lt 120916  
%                 sessiondir{n}= '120916 g62tt1lt RandReward behavior\g62tt1lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '120916_g62tt1lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62tt1lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1839-2000_20161209T120210-20161209T121941.mat',psfile);
% topo2pSession('g62tt1lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tt1lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tt1lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62tt1lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;                
% %
% 
%n=n+1 %g62qq1rt 121216  
%                 sessiondir{n}= '121216 g62qq1rt RandReward behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121216_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1023-1202_20161212T103556-20161212T105303.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
% 
%n=n+1 %g62qq1rt 121316  
%                 sessiondir{n}= '121316 g62qq1rt RandReward behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121316_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1213-1389_20161213T102404-20161213T104123.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
% 
%n=n+1 %g62qq1rt 121416  
%                 sessiondir{n}= '121416 g62qq1rt RandReward behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121416_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1577-1759_20161215T103837-20161215T105718.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
% 
%n=n+1 %g62qq1rt 121516  
%                 sessiondir{n}= '121516 g62qq1rt RandReward behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121516_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1577-1759_20161215T103837-20161215T105718.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
% 
%n=n+1 %g62qq1rt 121616  
%                 sessiondir{n}= '121616 g62qq1rt RandReward behavior\g62qq1rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121616_g62qq1rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62qq1rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1761-1935_20161216T125557-20161216T131438.mat',psfile);
% topo2pSession('g62qq1rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62qq1rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62qq1rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62qq1rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
% 
%n=n+1 %g62kk12rt 121316  
%                 sessiondir{n}= '121316 g62kk12rt RandReward behavior\g62kk12rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121316_g62kk12rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62kk12rt_001_000.sbx','behavSessionS2P.mat','trialRecords_842-1023_20161213T134739-20161213T140442.mat',psfile);
% topo2pSession('g62kk12rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62kk12rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62kk12rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62kk12rt 121416  
%                 sessiondir{n}= '121416 g62kk12rt RandReward behavior\g62kk12rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121416_g62kk12rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62kk12rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1024-1245_20161214T103345-20161214T105333.mat',psfile);
% topo2pSession('g62kk12rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62kk12rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62kk12rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62kk12rt 121516  
%                 sessiondir{n}= '121516 g62kk12rt RandReward behavior\g62kk12rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121516_g62kk12rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62kk12rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1246-1457_20161215T122324-20161215T124204.mat',psfile);
% topo2pSession('g62kk12rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62kk12rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62kk12rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62kk12rt 121516  
%                 sessiondir{n}= '121516 g62kk12rt RandReward behavior\g62kk12rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121516_g62kk12rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62kk12rt_001_000.sbx','behavSessionS2P.mat','trialRecords_1458-1664_20161216T111159-20161216T113228',psfile);
% topo2pSession('g62kk12rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62kk12rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62kk12rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62kk12rt 121616  
%                 sessiondir{n}= '121616 g62kk12rt RandReward behavior\g62kk12rt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '121616_g62kk12rt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62kk12rt_001_000.sbx','behavSessionS2P.mat','trialRecords_491-683_20161212T121840-20161212T123708.mat',psfile);
% topo2pSession('g62kk12rt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62kk12rt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62kk12rt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62kk12rt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62aaa3lt 040517  
%                 sessiondir{n}= '040517 g62aaa3lt RandReward behavior\g62aaa3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '040517_g62aaa3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62aaa3lt_001_002.sbx','behavSessionS2P.mat','trialRecords_203-334_20170405T141842-20170405T143405.mat',psfile);
% topo2pSession('g62aaa3lt_001_003.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62aaa3lt_001_004.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62aaa3lt_001_007.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_006.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_005.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62aaa3lt 040717  
%                 sessiondir{n}= '040717 g62aaa3lt RandReward behavior\g62aaa3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '040717_g62aaa3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62aaa3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_438-529_20170407T112300-20170407T114309.mat',psfile);
% topo2pSession('g62aaa3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62aaa3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62aaa3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62aaa3lt 041017  
%                 sessiondir{n}= '041017 g62aaa3lt RandReward behavior\g62aaa3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '041017_g62aaa3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62aaa3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_553-671_20170410T111110-20170410T112804.mat',psfile);
% topo2pSession('g62aaa3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62aaa3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62aaa3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%
%
% 
%n=n+1 %g62aaa3lt 041217  
%                 sessiondir{n}= '041217 g62aaa3lt RandReward behavior\g62aaa3lt\';
%                 p{n}= [datadir sessiondir{n}];
%                 f{n} = '041217_g62aaa3lt_session_summary_S2P.pdf';  %pdf file name
%                 newpdfFile{n} = fullfile(p{n},f{n});
%                 if exist(psfile,'file')==2;delete(psfile);end
%                 cd ([datadir sessiondir{n}])
% 
% behav2pSession('g62aaa3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_696-775_20170412T110811-20170412T112933.mat',psfile);
% topo2pSession('g62aaa3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62aaa3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62aaa3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62aaa3lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% 
%                 try
%                     dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )
% 
%                 catch
%                     display('couldnt generate pdf');
%                 end                   
% close all;
%%