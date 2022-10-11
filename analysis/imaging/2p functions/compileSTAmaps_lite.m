%%% compiles data from sparse noise analysis in Octo data
%%% cmn 2019

close all
clear all

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

[sbx_fname acq_fname mat_fname quality] = compileFilenames(batch_file,stimname);

Opt.SaveFigs = 1;
Opt.psfile = 'C:\temp\TempFigs.ps';

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

nfiles = length(mat_fname);
display(sprintf('%d good files found',nfiles))

rLabels = {'OGL','Plex','IGL','Med'};

for f = 1:nfiles
    
    fname_clean = strrep(mat_fname{f},'_',' '); %%% underscores mess up titles so this is a better filename to use
    fname_clean = fname_clean(1:30);
    %%% load data
    mat_fname{f}
    clear xb yb
    load(mat_fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg')
    
    %%% threshold for good RF
    zthresh = 5.0;
    
    %%% select RFs that have zscore(ON, OFF) greater than zthresh
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    useOnOff = intersect(useOn,useOff);
    notOn = find(zscore(:,1)<zthresh); notOff = find(zscore(:,2)>-zthresh);
    
    fractionResponsive(f)=length(use)/length(zscore);
    
    %%% calculate amplitude of response based on size response tuning(cells,on/off,size, time)
    %%% average over 3 spot sizes and response time window
    amp = nanmean(nanmean(tuning(:,:,1:end-1,8:15),4),3);
    
    %%% positive rectify amp, to calculate preference index for ON/OFF
    ampPos = amp; ampPos(ampPos<0)=0;
    onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
    onOff(notOn)=-1; onOff(notOff)=1;
    
    
    %%% retinotopy
    if xyswap ==1
        xptsnew = ypts;
        yptsnew = xpts;
    else
        xptsnew = xpts;
        yptsnew = ypts;
    end
    %%% center RF positions
    
    rfxs = [rfx(useOn,1); rfx(useOff,2)];
    rfys = [rfy(useOn,1); rfy(useOff,2)];
    x0 = nanmedian(rfxs);
    y0 = nanmedian(rfys);
    
    %%% do topographic maps for X and Y, for both On and Off responses
    axLabel = {'X','Y'};
    onoffLabel = {'On','Off'};
    figure
    for ax = 1:2
        for rep = 1:2;
            subplot(2,2,2*(rep-1)+ax)
            
            imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
            hold on
            if rep==1
                data = useOn;
            else data = useOff;
            end
            
            for i = 1:length(data)
                if ax ==1
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfx(data(i),rep)-x0,-25, 25, jet));
                else
                    plot(xpts(data(i)),ypts(data(i)),'o','Color',cmapVar(rfy(data(i),rep)-y0,-25, 25, jet));
                end
            end
            if ax ==1 & rep==1
                title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
            else
                title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
            end
            
        end
    end
    
    sgtitle(fname_clean)
    
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% map of On/Off ratio
    figure
    imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
    hold on
    for i = 1:length(use)
        plot(xpts(use(i)),ypts(use(i)),'o','Color',cmapVar(onOff(use(i)),-0.5, 0.5, jet));
    end
    title('on off ratio')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

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

close all