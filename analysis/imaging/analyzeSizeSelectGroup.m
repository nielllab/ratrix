%%%This code calculates group averages from individual size select data
%%%Then feeds the averages to doSizeSelectPlots for group plotting
dbstop if error
close all
clear all

path = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data'

%%choose dataset
batchPhilSizeSelect
cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained:')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'SalineNaiveSizeSelect'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'SalineTrainedSizeSelect'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'DOINaiveSizeSelect'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'DOITrainedSizeSelect'
else
    sprintf('please restart and choose a number 1-4')
end

redo = input('redo group averaging? 1=reanalyze, 0=load existing data:');

%%%dependencies and movie loading
numAni = length(use)/2;
load('C:\mapoverlay.mat');
moviename = 'C:\sizeSelect2sf8sz26min.mat';
load(moviename);
imagerate=10;
acqdurframes = imagerate*(isi+duration);
timepts = [1:acqdurframes+acqdurframes/2]*0.1;
areas = {'V1','P','LM','AL','RL','AM','PM','RSP'}; %list of all visual areas for points
behavState = {'stationary','running'};
ncut = 3;
trials = length(sf)-ncut;
sizeVals = [0 5 10 20 30 40 50 60];
sf=sf(1:trials);contrasts=contrasts(1:trials);phase=phase(1:trials);radius=radius(1:trials);
order=order(1:trials);tf=tf(1:trials);theta=theta(1:trials);xpos=xpos(1:trials);
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end


if redo
    cnt=1;
    alltrialcycavgpre = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(contrastRange),length(radiusRange),2,numAni);
    allpeakspre = zeros(length(sfrange),length(contrastRange),length(radiusRange),2,length(areas),numAni);
    alltracespre = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(contrastRange),length(radiusRange),2,numAni);
    allgauParamspre = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,5,numAni);
    allhalfMaxpre = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    allareameanspre = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    allareapeakspre = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    for i= 1:2:length(use) %collates all conditions (numbered above) 
        sprintf('loading %s out of %s files',num2str(cnt),num2str(length(use)))
        aniFile = sprintf('%s_%s_pre_%s',files(use(i)).expt,files(use(i)).subj,files(use(i)).inject)
        load(aniFile,'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax','areameans')
        alltrialcycavgpre(:,:,:,:,:,:,:,cnt) = trialcycavg;
        allpeakspre(:,:,:,:,:,cnt) = peaks;
        allmvpre(:,cnt) = mv;
        allgauParamspre(:,:,:,:,:,cnt) = gauParams;
        allhalfMaxpre(:,:,:,:,cnt) = halfMax;
        allareapeakspre(:,:,:,:,cnt) = areapeaks;
        allareameanspre(:,:,:,:,cnt) = areameans;
        load(files(use(i)).ptsfile);
        for j=1:length(x)
            alltracespre(j,:,:,:,:,:,cnt) = squeeze(nanmean(nanmean(trialcycavg(y(j)-1:y(j)+1,x(j)-1:x(j)+1,:,:,:,:,:),1),2));
        end
        cnt=cnt+1;
    end

%     avgtrialcycavgpre = nanmean(alltrialcycavgpre,9);%group mean frames by trial
%     setrialcycavgpre = nanstd(alltrialcycavgpre,9)/sqrt(length(datafiles));%group standard error
%     avgpeakspre = nanmean(allpeakspre,7);
%     sepeakspre = nanstd(allpeakspre,7)/sqrt(length(datafiles));
%     avgtracespre = nanmean(alltracespre,8);
%     setracespre = nanstd(alltracespre,8)/sqrt(length(datafiles));
%     avgmvpre = nanmean(allmvpre,2);
%     semvpre = nanstd(allmvpre,2)/sqrt(length(datafiles));
%     avggauParamspre = nanmean(allgauParamspre,6);
%     segauParamspre = nanstd(allgauParamspre,6)/sqrt(length(datafiles));
%     avghalfMaxpre = nanmean(allhalfMaxpre,5);
%     sehalfMaxpre = nanstd(allhalfMaxpre,5)/sqrt(length(datafiles));
%     avgareapeakspre = nanmean(allareapeakspre,5);
%     seareapeakspre = nanstd(allareapeakspre,5)/sqrt(length(datafiles));
    cnt=1;
    alltrialcycavgpost = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(contrastRange),length(radiusRange),2,numAni);
    allpeakspost = zeros(length(sfrange),length(contrastRange),length(radiusRange),2,length(areas),numAni);
    alltracespost = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(contrastRange),length(radiusRange),2,numAni);
    allgauParamspost = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,5,numAni);
    allhalfMaxpost = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    allareameanspost = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    allareapeakspost = zeros(length(contrastRange),length(radiusRange),2,length(areas)-1,numAni);
    for i= 2:2:length(use) %collates all conditions (numbered above) 
        sprintf('loading %s out of %s files',num2str(cnt+length(use)/2),num2str(length(use)))
        aniFile = sprintf('%s_%s_post_%s',files(use(i)).expt,files(use(i)).subj,files(use(i)).inject)
        load(aniFile,'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax','areameans')
        alltrialcycavgpost(:,:,:,:,:,:,:,cnt) = trialcycavg;
        allpeakspost(:,:,:,:,:,cnt) = peaks;
        allmvpost(:,cnt) = mv;
        allgauParamspost(:,:,:,:,:,cnt) = gauParams;
        allhalfMaxpost(:,:,:,:,cnt) = halfMax;
        allareapeakspost(:,:,:,:,cnt) = areapeaks;
        allareameanspost(:,:,:,:,cnt) = areameans;
        load(files(use(i)).ptsfile);
        for j=1:length(x)
            alltracespost(j,:,:,:,:,:,cnt) = squeeze(nanmean(nanmean(trialcycavg(y(j)-2:y(j)+2,x(j)-2:x(j)+2,:,:,:,:,:),1),2));
        end
        cnt=cnt+1;
    end

%     avgtrialcycavgpost = nanmean(alltrialcycavgpost,9);%group mean frames by trial
%     setrialcycavgpost = nanstd(alltrialcycavgpost,9)/sqrt(length(datafiles));%group standard error
%     avgpeakspost = nanmean(allpeakspost,7);
%     sepeakspost = nanstd(allpeakspost,7)/sqrt(length(datafiles));
%     avgtracespost = nanmean(alltracespost,8);
%     setracespost = nanstd(alltracespost,8)/sqrt(length(datafiles));
%     avgmvpost = nanmean(allmvpost,2);
%     semvpost = nanstd(allmvpost,2)/sqrt(length(datafiles));
%     avggauParamspost = nanmean(allgauParamspost,6);
%     segauParamspost = nanstd(allgauParamspost,6)/sqrt(length(datafiles));
%     avghalfMaxpost = nanmean(allhalfMaxpost,5);
%     sehalfMaxpost = nanstd(allhalfMaxpost,5)/sqrt(length(datafiles));
%     avgareapeakspost = nanmean(allareapeakspost,5);
%     seareapeakspost = nanstd(allareapeakspost,5)/sqrt(length(datafiles));

%     for i = 1:length(sfrange)
%         for j = 1:length(phaserange)
%             for k = 1:length(contrastRange)
%                 for l = 1:length(radiusRange)
%                     for m = 1:2
%                         for fr=1:size(avgtrialcycavgpre,3)
%                             avgtrialcycavgpre(:,:,fr,i,j,k,l,m) = avgtrialcycavgpre(:,:,fr,i,j,k,l,m) - nanmean(avgtrialcycavgpre(:,:,1:acqdurframes/2,i,j,k,l,m),3);
%                             avgtrialcycavgpost(:,:,fr,i,j,k,l,m) = avgtrialcycavgpost(:,:,fr,i,j,k,l,m) - nanmean(avgtrialcycavgpost(:,:,1:acqdurframes/2,i,j,k,l,m),3);
%                         end
%                     end
%                 end
%             end
%         end
%     end
    sprintf('saving...')
    save(filename,'alltrialcycavgpre','allpeakspre','alltracespre','allgauParamspre','allhalfMaxpre','allareameanspre','allareapeakspre',...
        'alltrialcycavgpost','allpeakspost','alltracespost','allgauParamspost','allhalfMaxpost','allareameanspost','allareapeakspost','-v7.3');
    sprintf('making plots')
    doSizeSelectPlots
else
    sprintf('loading data')
    load(filename)
    sprintf('making plots')
    doSizeSelectPlots
end
