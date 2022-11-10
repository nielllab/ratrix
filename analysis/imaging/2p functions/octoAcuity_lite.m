%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all; clear all

%%% select files to analyze based on compile file
stimlist = {'8 way gratings 2ISI','sin gratings 7 steps'};  %%% add others here
for i = 1:length(stimlist)
    display(sprintf('%d) %s',i,stimlist{i}))
end
stimnum = input('which stim : ');
stimname = stimlist{stimnum}

%%% read sessions from batch file
%batch_file = 'ForBatchFileAngeliquewregioned.xlsx';
[batch_fname batch_pname] = uigetfile('*.xlsx','.xls batch file');
batch_file = fullfile(batch_pname,batch_fname);

[sbx_fname acq_fname mat_fname quality] = compileFilenames(batch_file,stimname,'');
Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';
if Opt.SaveFigs
    psfile = Opt.psfile
    if exist(psfile,'file')==2;delete(psfile);end
end

%%% select files to use based on quality
for i = 1: length(quality);
    usefile(i) = strcmp(quality{i},'Y');
end

useN = find(usefile); clear goodfile
display(sprintf('%d recordings, %d labeled good',length(usefile),length(useN)));

n=0;
%%% collect filenames and make sure the files are there
for i = 1:length(useN)
    try
        base = mat_fname{useN(i)}(1:end-4);
        goodfile{n+1} = dir([base '*']).name;
        n= n+1;
    catch
        sprintf('cant do %s',mat_fname{useN(i)})
    end
end
mat_fname = goodfile;


% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end

rLabels = {'OGL','Plex','IGL','Med'};
nfiles = length(mat_fname);
display(sprintf('%d good files found',nfiles))


ncond = 17;
cycDur=20;
if strcmp(stimname,'sin gratings smaller 2ISI') | strcmp(stimname,'8 way gratings 2ISI') | strcmp(stimname,'sin gratings 7 steps 2ISI');
    cycDur = 30;
end

if strcmp(stimname,'8 way gratings') || strcmp(stimname,'8 way gratings 2ISI')
    nOri = 8;
    nSF = 2;
    sfs = zeros(16,1);
    thetas = zeros(16,1);
    sfs(1:2:end) = 0.01; sfs(2:2:end) = 0.16;

    nOri = 4;
    nSF = 4;
    sfs = zeros(16,1);
    thetas = zeros(16,1);
    sfs(1:4:end) = 0.01; sfs(2:4:end) = 0.04; sfs(3:4:end) = 0.16; sfs(4:4:end) = 0.64;
    thetas(1:4) = 0; thetas(5:8) = 90; thetas(9:12) = 180; thetas(13:16) = 270;
end

if strcmp(stimname,'sin gratings 7 steps 2ISI') || strcmp(stimname,'sin gratings 7 steps')
    ncond = 29;
    nSF = 7;
    nOri = 4;
    sfs = zeros(28,1);
    thetas = zeros(28,1);
    for i = 1:7
        sfs(i:7:end) = 0.01*2^(i-1);
    end
    thetas(1:7) = 0; thetas(8:14) = 90; thetas(15:21) = 180; thetas(22:28) = 270;
end

th = unique(thetas);
for i = 1:length(th); oriLabels{i} = sprintf('%0.0f',th(i)); end

sf = unique(sfs);
for i = 1:length(sf); sfLabels{i} = sprintf('%0.02f',sf(i)); end

f = 0; %%% counter for number of sessions included
for nf = 1:nfiles
    
    fname_clean = strrep(mat_fname{nf},'_',' '); %%% underscores mess up titles so this is a better filename to use
    fname_clean = fname_clean(1:30);
    
    %%% read in weighted timecourse (from pixelmap, weighted by baseline fluorescence
    clear xb yb stimOrder weightTcourse
    warning('off','MATLAB:load:variableNotFound')
    load(mat_fname{nf},'stimOrder','weightTcourse','dFrepeats','xpts','ypts','xb','yb','meanGreenImg','stdImg','trialmean','cycPolarImg')
    warning('on','MATLAB:load:variableNotFound')
    if ~exist('xb','var')
        display(sprintf('%s does not appear to be regioned',mat_fname{nf}))
    end
    
    figure
    subplot(1,2,1)
    imshow(cycPolarImg); title('timecourse polar img');
    subplot(1,2,2);
    imagesc(meanGreenImg); axis equal; axis off; title(fname_clean);
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        dFmean = nanmean(dFrepeats,3);
    
    figure
    imagesc(dFmean,[-0.1 0.1]); title(['response of all cells ' fname_clean]); colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


end

close all

display('saving pdf')
if Opt.SaveFigs
    if ~isfield(Opt,'pPDF')
        [Opt.fPDF, Opt.pPDF] = uiputfile('*.pdf','save pdf file');
    end
    
    newpdfFile = fullfile(Opt.pPDF,Opt.fPDF);
    try
        dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end

