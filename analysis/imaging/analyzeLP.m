batchLP_DMN;


use = find(strcmp({files.monitor},'vert') & ~strcmp({files.site},'lgn') & ~strcmp({files.size},'8mm'));
%use = 1: length(files)
%%% calculate gradients and regions
clear map merge
for f = 1:length(use)
    f
    if ~isempty(files(f).topox) & ~isempty(files(f).topoy)
        [grad{f} amp{f} map_all{f} map{f} merge{f}]= getRegions(files(use(f)),pathname,outpathname);
    end
end


%%% align gradient maps to first file
for f = 1:length(use); %changed from 1:length(map)
    [imfit{f} allxshift(f) allyshift(f) allzoom(f)] = alignMaps(map([1 f]), merge([1 f]), [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
    xshift = allxshift(f); yshift = allyshift(f); zoom = allzoom(f);
    save( [outpathname files(use(f)).subj files(use(f)).expt '_topography.mat'],'xshift','yshift','zoom','-append');
end


avgmap=0;
for f= 1:length(use)

 m = shiftImage(merge{f},allxshift(f),allyshift(f),allzoom(f),80);
 sum(isnan(m(:)))
 
 sum(isnan(merge{f}(:)))
 figure
 imshow(m*3);
 avgmap = avgmap+m;
 title( [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
end
figure
imshow(3*avgmap/length(use));
    
for f = length(use):length(use)
    f
    %try
        fitSpeed([pathname files(use(f)).topox]);
        fitSpeed([pathname files(use(f)).topoy]);
        display('done')
   % catch
        display('couldnt')
    %end
end

%%% analyze 4-phase data (e.g. looming and grating)
for f = 1:length(use)
    loom_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'loom');
end

%fourPhaseAvg(loom_resp,allxshift-25,allyshift-25,zoom, 80, avgmap);

for f = 1:length(use)
 f
 grating_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'grating');
end
