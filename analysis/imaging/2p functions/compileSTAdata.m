%%% compiles data from sparse noise analysis in Octo data
%%% cmn 2019

close all
clear all

fullfigs = 0; %%% 0 - for abbreviated figures, 1 - full figures

%%% select files to analyze based on compile file

%%% select files to analyze based on compile file
stimlist = {'sparse noise 1','sparse noise 2'};  %%% add others here
for i = 1:length(stimlist)
    display(sprintf('%d) %s',i,stimlist{i}))
end
stimnum = input('which stim : ');
stimname = stimlist{stimnum};

xyswap = 1;  %%% swap x and y for retinotopy?

if strcmp(stimname,'sparse noise 2')
    nsz = 4;
else
    nsz = 3;
end

%batch_file = 'ForBatchFileAngeliquewregioned.xlsx';

[batch_fname batch_pname] = uigetfile('*.xlsx','.xls batch file');
batch_file = fullfile(batch_pname,batch_fname);

[sbx_fname acq_fname mat_fname quality regioned runBatch metadata] = compileFilenames(batch_file,stimname, '');

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigsSTAcomp.ps';

if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2;delete(psfile);end
end

% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = strcmp(quality{i},'Y');
end


useN = find(usefile); clear goodfile
n=0;
display(sprintf('%d recordings, %d labeled good',length(usefile),length(useN)));



%%% collect filenames and make sure the files are there
%for i = 1:length(useN)
for i = 1:6
    try
        base = mat_fname{useN(i)}(1:end-4);
        goodfile{n+1} = dir([base '*']).name;
        goodfileN(n+1) = useN(i);
        n= n+1;
    catch
        sprintf('cant do %s',mat_fname{useN(i)})
    end
end
mat_fname = goodfile;

nfiles = length(mat_fname);
display(sprintf('%d good files found',nfiles))

rLabels = {'OGL','Plex','IGL','Med'};

%%% threshold for good RF
zthresh = 5.5;

%%% threshold for # of units to include data
nthresh = 5;

figure
subplot(2,2,1)
plot(metadata.eyeSize,metadata.lobeSize,'o');
xlabel('eyeSize'); ylabel('lobeSize');
axis equal

subplot(2,2,2)
hist(metadata.lobeSize);
xlabel('lobe size mm')
xlim([0 1.1*max(metadata.lobeSize)]);

subplot(2,2,3)
hist(metadata.screenDist);
xlabel('screen distance mm')
xlim([0 1.1*max(metadata.screenDist)]);


brainScale = metadata.lobeSize.*metadata.screenDist;
subplot(2,2,4)
hist(brainScale);
xlabel('screenDist * lobeSize');
xlim([0 1.1*max(brainScale)]);
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

for f = 1:nfiles
    ['PungorCB_' mat_fname{f}(1:6) '_dataset.mat']
   
    load(mat_fname{f},'xpts','ypts','tuning','zscore','xb','yb','moviedata','stas','dF','stimFrames')
    save(['PungorCB_' mat_fname{f}(1:6) '_dataset.mat'],'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','moviedata','stas');
end
