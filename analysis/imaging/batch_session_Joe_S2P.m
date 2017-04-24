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



%may need to rerun the y3 sessions because passive behavStim was different
% n=n+1 %g62y3lt 050316
% sessiondir{n}= '050316 g62y3lt GTS behavior\g62y3lt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_1853-2020_20160503T154535-20160503T160643.mat',psfile);
% topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62y3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
% n=n+1 %g62y3lt 050516
% sessiondir{n}= '050516 g62y3lt GTS behavior\g62y3lt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2261-2511_20160505T131650-20160505T135237.mat',psfile);
% topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62y3lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_003.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
% 
% n=n+1 %g62y3lt 050916
% sessiondir{n}= '050916 g62y3lt GTS behavior\g62y3lt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62y3lt_001_000.sbx','behavSessionS2P.mat','trialRecords_2527-2680_20160509T124714-20160509T131922.mat',psfile);
% topo2pSession('g62y3lt_001_001.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62y3lt_001_002.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62y3lt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_004.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62y3lt_001_005.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
% n=n+1 %g62tx15lt 060616
% sessiondir{n}= '060616 g62tx15lt GTS behavior\g62tx15lt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62tx15lt_001_001.sbx','behavSessionS2P.mat','trialRecords_4907-5064_20160606T124008-20160606T131912.mat',psfile);
% topo2pSession('g62tx15lt_001_002.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tx15lt_001_003.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tx15lt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_004.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_005.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
% 
% n=n+1 %g62tx15lt 060816
% sessiondir{n}= '060816 g62tx15lt GTS behavior\g62tx15lt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62tx15lt_001_000.sbx','behavSessionS2P.mat','trialRecords_5178-5383_20160608T124612-20160608T131300.mat',psfile);
% topo2pSession('g62tx15lt_001_003.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62tx15lt_001_004.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62tx15lt_001_005.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_002.sbx','passiveBehav3x4orientS2P.mat ','C:\behavStim3sf4orient.mat',psfile);
% passiveBehav2pSession('g62tx15lt_001_001.sbx','passiveBehav2sfSessionS2P.mat','C:\behavStim2sfSmall3366.mat',psfile);
% 
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
% close all;
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
% close all;
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
% close all;
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
%   close all;
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
%  close all;                                  
% 
%                 
                
% 
% %Naive
% 
% n=n+1 %g62ff8rt 072116
% sessiondir{n}= '072116 g62ff8rt Naive behavior\g62ff8rt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62ff8rt_001_001.sbx','behavSessionS2P.mat','trialRecords_368-530_20160721T115149-20160721T121256.mat',psfile);
% topo2pSession('g62ff8rt_001_002.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62ff8rt_001_003.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62ff8rt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62ff8rt_001_005.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
% n=n+1 %g62ff8rt 072216
% sessiondir{n}= '072216 g62ff8rt Naive behavior\g62ff8rt\';
% cd [datadir sessiondir{n}]
% 
% behav2pSession('g62ff8rt_001_001.sbx','behavSessionS2P.mat','trialRecords_532-708_20160722T132416-20160722T134234.mat',psfile);
% topo2pSession('g62ff8rt_001_002.sbx','topoXsessionS2P.mat',psfile);
% topo2pSession('g62ff8rt_001_003.sbx','topoYsessionS2P.mat',psfile);
% grating2pSession('g62ff8rt_001_006.sbx','gratingSessionS2P.mat',psfile);
% passiveBehav2pSession('g62ff8rt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
% passiveBehav2pSession('g62ff8rt_001_005.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);
% 
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

  n=n+1 %g62qq2lt 102016
                sessiondir{n}= '102016 g62qq2lt Naive behavior\g62qq2lt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '102016_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62qq2lt_001_001.sbx','behavSessionS2P.mat','trialRecords_603-683_20161020T111643-20161020T113450.mat',psfile);
topo2pSession('g62qq2lt_001_002.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62qq2lt_001_003.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62qq2lt_001_006.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62qq2lt_001_005.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);


                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                  
 close all;               

  n=n+1 %g62qq2lt 102116
                sessiondir{n}= '102116 g62qq2lt Naive behavior\g62qq2lt\';
                p{n}= [datadir sessiondir{n}];
                f{n} = '102116_g62qq2lt_session_summary_S2P.pdf';  %pdf file name
                newpdfFile{n} = fullfile(p{n},f{n});
                if exist(psfile,'file')==2;delete(psfile);end
                cd ([datadir sessiondir{n}])

behav2pSession('g62qq2lt_001_000.sbx','behavSessionS2P.mat','trialRecords_685-781_20161021T125257-20161021T131207.mat',psfile);
topo2pSession('g62qq2lt_001_001.sbx','topoXsessionS2P.mat',psfile);
topo2pSession('g62qq2lt_001_002.sbx','topoYsessionS2P.mat',psfile);
grating2pSession('g62qq2lt_001_005.sbx','gratingSessionS2P.mat',psfile);
passiveBehav2pSession('g62qq2lt_001_004.sbx','passiveBehav3x8minS2P.mat ','C:\behavStim3x8min.mat',psfile);
passiveBehav2pSession('g62qq2lt_001_003.sbx','passiveBehav2sf8minSessionS2P.mat','C:\behavStim2sf8min.mat',psfile);


                try
                    dos(['ps2pdf ' 'c:\tempJW.ps "' newpdfFile{n} '"'] )

                catch
                    display('couldnt generate pdf');
                end                   
close all;                
                
                
