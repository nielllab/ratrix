clear all
close all
opengl software
pathname = '\\langevin\backup\widefield\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';

n=1;

files(n).subj = 'g62Tx1-1';
files(n).expt = '010616';
files(n).windowsize = 'acrylic';
files(n).age = 17;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010615 G62Tx1-1 darkness\g62tx1-1_run2_darkness\g62tx1-1_run2_darkness_00maps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010615 G62Tx1-1 darkness\g62tx1-1_run2_darkness\g62tx1-1_run2_darkness_000001.tif';
files(n).flip = 1;
files(n).doi = 0;

n=n+1;
files(n).subj = 'g62Tx1-1';
files(n).expt = '010716';
files(n).windowsize = 'acrylic';
files(n).age = 18;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010715 G62Tx1-1 darkness\G62Tx1-1_run1_darkness_16min\G62Tx1-1_run1_darkness_16minmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010715 G62Tx1-1 darkness\G62Tx1-1_run1_darkness_16min\G62Tx1-1_run1_darkness_16min_000001.tif';
files(n).flip = 1;
files(n).doi = 0;

% 
n=n+1;
files(n).subj = 'G62Z-2';
files(n).expt = '010716';
files(n).windowsize = 'acrylic';
files(n).age = 18;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010715 G62Z-2 darkness\G62Z-2_run2_darkness_16min\G62Z-2_run2_darkness_16minmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010715 G62Z-2 darkness\G62Z-2_run2_darkness_16min\G62Z-2_run2_darkness_16min_000001.tif';
files(n).flip = 1;
files(n).doi = 0;

n=n+1;
files(n).subj = 'G62Z-3';
files(n).expt = '010716';
files(n).windowsize = 'acrylic';
files(n).age = 18;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010715 G62Z-3 darkness\G62Z-3_run3_darkness_16min\G62Z-3_run3_darkness_16minmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010715 G62Z-3 darkness\G62Z-3_run3_darkness_16min\G62Z-3_run3_darkness_16min_000001.tif';
files(n).flip = 1;
files(n).doi = 0;

n=n+1;
files(n).subj = 'G62Z-2';
files(n).expt = '010816';
files(n).windowsize = 'acrylic';
files(n).age = 18;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010815 G62TZ-2 darkness\G62Z-2_run1_darkness\G62Z-2_run1_darknessmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010815 G62TZ-2 darkness\G62Z-2_run1_darkness\G62Z-2_run1_darkness_000001.tif';
files(n).flip = 1;
files(n).doi = 0;

n=n+1;
files(n).subj = 'G62Z-3';
files(n).expt = '010816';
files(n).windowsize = 'acrylic';
files(n).age = 18;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'passive\juvenile connectivity\010815 G62TZ-3 darkness\G62Z-3_run1_darkness\G62Z-3_run1_darknessmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'passive\juvenile connectivity\010815 G62TZ-3 darkness\G62Z-3_run1_darkness\G62Z-3_run1_darkness_000001.tif';
files(n).flip = 1;
files(n).doi = 0;



n=n+1;
files(n).subj = 'g62l7rt';
files(n).expt = '091715';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\091715 G62L7-rt cleared skull both hemispheres\g62l7rt_run4_2monitors_landscape_Darkness5min\g62l7rt_run4_2monitors_landscape_Darkness5min_00maps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata ='Acrilic cleared skull headplate\091715 G62L7-rt cleared skull both hemispheres\g62l7rt_run4_2monitors_landscape_Darkness5min\g62l7rt_run4_2monitors_landscape_Darkness5min_000001.tif';
files(n).flip = 1;
files(n).doi = 0;
% 
n=n+1;
files(n).subj = 'g62l4lt';
files(n).expt = '091715';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\091715 G62L4-lt cleared skull both hemispheres\g62l4lt_run4_2monitors_landscape_Darkness5min\g62l4lt_run4_2monitors_landscape_Darkness5min_00maps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'Acrilic cleared skull headplate\091715 G62L4-lt cleared skull both hemispheres\g62l4lt_run4_2monitors_landscape_Darkness5min\g62l4lt_run4_2monitors_landscape_Darkness5min_000001.tif';
files(n).flip = 1;
files(n).doi = 0;


n=n+1;
files(n).subj = 'g62l7rt';
files(n).expt = '112015';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\112015_G62L7RT_RIG2_DOI\112015_G62L7RT_RIG2_DOI_PRE_DARKNESS\112015_G62L7RT_RIG2_DOI_PRE_DARKNESSmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'blurry  / low stdev'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata ='Acrilic cleared skull headplate\112015_G62L7RT_RIG2_DOI\112015_G62L7RT_RIG2_DOI_PRE_DARKNESS\112015_G62L7RT_RIG2_DOI_PRE_DARKNESS_000001.tif';
files(n).flip = 0;
files(n).doi = 0;

n=n+1;
files(n).subj = 'g62l7rt';
files(n).expt = '120115';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\120115_G62L7RT_RIG2_DOI\120115_G62L7RT_RIG2_DOI_PRE_DARKNESS\120115_G62L7RT_RIG2_DOI_PRE_DARKNESSmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata ='Acrilic cleared skull headplate\120115_G62L7RT_RIG2_DOI\120115_G62L7RT_RIG2_DOI_PRE_DARKNESS\120115_G62L7RT_RIG2_DOI_PRE_DARKNESS_000001.tif';
files(n).flip = 0;
files(n).doi = 0;
% 
n=n+1;
files(n).subj = 'g62l4lt';
files(n).expt = '120115';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\120115_G62L4LT_RIG2_DOI\120115_G62L4LT_RIG2_DOI_PRE_DARKNESS\120115_G62L4LT_RIG2_DOI_PRE_DARKNESSmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'Acrilic cleared skull headplate\120115_G62L4LT_RIG2_DOI\120115_G62L4LT_RIG2_DOI_PRE_DARKNESS\120115_G62L4LT_RIG2_DOI_PRE_DARKNESS_000001.tif';
files(n).flip = 0;
files(n).doi = 0;

n=n+1;
files(n).subj = 'g62l7rt';
files(n).expt = '120115';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\120115_G62L7RT_RIG2_DOI\120115_G62L7RT_RIG2_DOI_POST_DARKNESS\120115_G62L7RT_RIG2_DOI_POST_DARKNESSmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata ='Acrilic cleared skull headplate\120115_G62L7RT_RIG2_DOI\120115_G62L7RT_RIG2_DOI_POST_DARKNESS\120115_G62L7RT_RIG2_DOI_POST_DARKNESS_000001.tif';
files(n).flip = 0;
files(n).doi = 1;
% 
n=n+1;
files(n).subj = 'g62l4lt';
files(n).expt = '120115';
files(n).windowsize = 'acrylic';
files(n).age = NaN;
files(n).topox =  ''; %1 flipped (nasal to temporal)
files(n).topoy = '';
files(n).darkness = 'Acrilic cleared skull headplate\120115_G62L4LT_RIG2_DOI\120115_G62L4LT_RIG2_DOI_POST_DARKNESS\120115_G62L4LT_RIG2_DOI_POST_DARKNESSmaps.mat';
files(n).monitor = '2 screens land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; %also auditory and aud-vis stim this day 
files(n).topoxdata =  '';
files(n).topoydata = '';
files(n).darknessdata = 'Acrilic cleared skull headplate\120115_G62L4LT_RIG2_DOI\120115_G62L4LT_RIG2_DOI_POST_DARKNESS\120115_G62L4LT_RIG2_DOI_POST_DARKNESS_000001.tif';
files(n).flip = 0;
files(n).doi=1;


% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).windowsize = '8mm';
% files(n).step_binary = '';
% files(n).topox =  '';
% files(n).topoy = '';
% files(n).behav = '';
% files(n).grating = '';
% files(n).loom = '';
% files(n).whisker = '';
% files(n).darkness = '';
% files(n).monitor = '';
% files(n).task = '';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).step_binarydata = '';
% files(n).topoxdata =  '';
% files(n).topoydata = '';
% files(n).behavdata = '';
% files(n).gratingdata = '';
% files(n).loomdata = '';
% files(n).topoxreversedata = '';
% files(n).whiskerdata = '';


% 
% %%% batch dfofMovie
% errmsg= [];errRpt = [];
% nerr=0;
% 
% 
% %for f = 1:length(files)
% % for f = 1:1
% % 
% %     f
% %     tic
% %     
% %     try
% %         dfofMovie([datapathname files(f).topoxdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}= sprintf('couldnt do %s',files(f).topoxdata)
% %         errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).topoydata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).topoydata)
% %         errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).whiskerdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).whiskerdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).darknessdata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).darknessdata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).step_binarydata]);
% %     catch
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).step_binarydata)
% %         errRpt{nerr}= getReport(exc,'extended')
% %     end
% %     try
% %         dfofMovie([datapathname files(f).topoxreversedata]);
% %     catch exc
% %         nerr=nerr+1;
% %         errmsg{nerr}=sprintf('couldnt do %s',files(f).topoxreversedata)
% %          errRpt{nerr}=getReport(exc,'extended')
% %     end
% %     
% %     toc
% % end
% %  errRpt{:} 
%  outpathname = 'I:\compiled 8mm\8mm overlays\';
% % 
% %keyboard
% %use = find(strcmp({files.monitor},'vert') & strcmp({files.task},'HvV_center')& strcmp({files.notes},'good imaging session'))
% for i = 1:length(files);
%     if ~isempty(files(i).topox) & strcmp(files(i).notes,'good imaging session')
%         used(i)=1;
%     else
%        used(i)=0;
%     end
% end
% 
%     use = find(used)
% 
% 
% %%% calculate gradients and regions
% 
% 
% for i = 1:length(files);
%     if ~isempty(files(i).step_binary) & ~isempty(files(i).whisker) &  ~isempty(files(i).darkness) & strcmp(files(i).notes,'good imaging session')
%         used(i)=1;
%     else
%        used(i)=0;
%     end
% end
% 
%     use = find(used)
% 
% for f = 1:length(use)
% f
% load([pathname files(use(f)).darkness],'sp','dfof_bg');
% movemap =mean(dfof_bg(:,:,sp>400),3)- mean(dfof_bg(:,:,sp<400),3);
% figure
% imagesc(movemap);
% load([pathname files(use(f)).step_binary],'map');
% map1 = map;
% load([pathname files(use(f)).whisker],'map');
% map2= map;
% 
% mergeMaps(map1,map2,movemap, pathname, [files(use(f)).subj files(use(f)).expt files(use(f)).monitor])
% end
% 
% for f = 7:7
%     load([pathname files(f).step_binary],'sp','dfof_bg');
%     
% end
% 
% 
% 
