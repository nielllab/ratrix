clear all
close all

pathname = 'C:\data\imaging\';

n=1;

files(n).subj = 'g2b7lt';
files(n).expt = '022514';
files(n).topox =  '022514 G62B.7-LT HvV_center Behavior\topoXmaps.mat'; 
files(n).topoy = '022514 G62B.7-LT HvV_center Behavior\topoYmaps.mat';
files(n).behav = '022514 G62B.7-LT HvV_center Behavior\022514 g62b7lt behav data.mat';
files(n).grating = '';
files(n).loom = '';
files(n).monitor = 'vert';
files(n).task = 'HvV_center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

n=n+1;
files(n).subj = 'g62b7lt';
files(n).expt = '022314';
files(n).topox =  '022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run2_topoX_15ms\topox_dfofmaps.mat'; 
files(n).topoy = '022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run3_topoY_15ms\g62b4ln_topoymaps.mat';
files(n).behav = '';
files(n).grating = '';
files(n).loom = '';
files(n).monitor = 'vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

n=n+1;
files(n).subj = 'g62hltt';
files(n).expt = '042414';
files(n).topox =  '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run1_topox_fstop5.6_exp50msmaps.mat'; 
files(n).topoy = '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run2_topoy_fstop5.6_exp50msmaps.mat';
files(n).behav = '';
files(n).grating = '042414g62h1tt passive mapping\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50ms\G62H1TT_run3_gratingsSFTF_fstop5.6_exp50msmaps.mat';
files(n).loom = '042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run4_looming_fstop5.6_exp50msmaps.mat';
files(n).monitor = 'vert';
files(n).task = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';



% %%% batch dfofMovie
% datapathname = '...';
% for f = 1:length(files);
%     try
%         dfofMovie([datapathname files(f).topox]);
%     catch
%         sprintf('could do %s',file(f).topox)
%     end
%     try
%         dfofMovie([datapathname files(f).topoy]);
%     catch
%         sprintf('could do %s',file(f).topoy)
%     end
%     try
%         dfofMovie([datapathname files(f).grating]);
%     catch
%         sprintf('could do %s',file(f).grating)
%     end
%     try
%         dfofMovie([datapathname files(f).loom]);
%     catch
%         sprintf('could do %s',file(f).loom)
%     end
% end
    
outpathname = 'C:\data\imaging\widefield compilation\'

%%% calculate gradients and regions
for f = 1:length(files)
[map{f} merge{f}]= getRegions(files(f),pathname,outpathname);
end

%%% align gradient maps to first file
for f = 1:length(map);
    [imfit{f} allxshift(f) allyshift(f) allzoom(f)] = alignMaps(map([1 f]));
    xshift = allxshift(f); yshift = allyshift(f); zoom = allzoom(f);
    save( [outpathname files(f).subj files(f).expt '_topography.mat'],'xshift','yshift','zoom','-append');
end

avgmap=0;
for f= 1:length(files)

 m = shiftImage(merge{f},allxshift(f),allyshift(f),allzoom(f),80);
 figure
 imshow(m);
 avgmap = avgmap+m;
end
figure
imshow(avgmap/length(files));
    

% %%% overlay behavior on top of topomaps
nb=0; avgbehav=0;
for f = 1:length(files)
try
    behav{f} = overlayMaps(files(f),pathname,outpathname);
    if ~isempty(behav(f));
        b = shiftdim(behav{f},1);
        b = shiftImage(b,allxshift(f),allyshift(f),allzoom(f),80);
        avgbehav = avgbehav+b;
        nb= nb+1;
    end
catch
sprintf('couldnt do behav on %d',f)
end
end

% %%% analyze 4-phase data (e.g. looming and grating)
% for f = 1:length(files)
% fourPhaseOverlay(files(f),pathname,outpathname,'loom');
% end
% for f = 1:length(files)
% fourPhaseOverlay(files(f),pathname,outpathname,'grating');
% end