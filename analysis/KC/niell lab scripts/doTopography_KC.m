%% choose FILE(S)

warning off

batchNEW_KC
cd(pathname)

%% select the fields that you want to filter on

alluse = find(strcmp({files.subj},'G6H277RT')...
      & strcmp({files.expt},'041121'))
   
% alluse = find(strcmp({files.virus},'CAV2-cre_cre-hM4Di')... 
%     & strcmp({files.inject},'CLOZ')... 
%     & strcmp({files.monitor},'land')...
%     & strcmp({files.timing},'post')...
%     & strcmp({files.area}, 'LP')...
%     & strcmp({files.genotype},'camk2 gc6')...
%     & strcmp({files.moviename4x3y},'C:\grating4x3y5sf3tf_short011315.mat'))
    
% files(n).moviename = 'C:\grating4x3y5sf3tf_short011315.mat'

%% save output VARS
%%% uncomment this for individual mouse
%savename = ['041121_277RT_anPass_Vars']

%%% uncomment this for group
% savename = ['203RT_cloz_post.mat']
% files(alluse(1)).subj '_' files(alluse(1)).timing '_' files(alluse(1)).virus '_' ...
% files(alluse(1)).genotype '_' files(alluse(1)).inject 

%% run doTopography 
% (use this one to average all sessions that meet criteria)

length(alluse)
allsubj = unique({files(alluse).subj})

% temp file needs to exist for some reason
psfilename = fullfile(pathname,'tempWF.ps'); 
if exist(psfilename,'file')==2;delete(psfilename);end   

% run doTopography on map file info (df/f) from dfOfMovie
% not sure why s = 1
for s=1:1
    
    use = alluse;
        allsubj{s}

    %%% calculate gradients and regions
    clear map merge

    x0=0; y0=0; sz=128;
    doTopography;
    
end

%% plot topox & topoy retino maps w/overlays

figure
suptitle(allsubj{s})
for m=1:2
    subplot(1,2,m);
    
    imshow(polarMap(meanpolar{m},95))
    
    hold on
    
    plot(ypts,xpts,'w.','Markersize',2)
    
end

%% show each of 2 images from above figures
% & use for picking points in later analyses
figure
imshow(polarMap(meanpolar{1},95))
figure
imshow(polarMap(meanpolar{2},95))

%% save 2 timages
% topoXYforOverlay{1} = polarMap(meanpolar{1});
% topoXYforOverlay{2} = polarMap(meanpolar{2});
% %save('041121_277RT_topoXYforOverlay.mat','topoXYforOverlay')

