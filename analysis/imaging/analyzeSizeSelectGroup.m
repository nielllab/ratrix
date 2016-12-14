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
    predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_Saline';
    postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_Saline';
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'SalineTrainedSizeSelect'
    predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_Saline';
    postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_Saline';
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'SalineNaiveSizeSelect'
    predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_DOI';
    postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_DOI';
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    filename = 'SalineTrainedSizeSelect'
    predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_DOI';
    postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_DOI';
else
    sprintf('please restart and choose a number 1-4')
end

redo = input('redo group averaging? 1=reanalyze, 0=load existing data:');

%%%dependencies and movie loading
load('C:\mapoverlay.mat');
moviename = 'C:\sizeSelect2sf8sz26min.mat';
load(moviename);
imagerate=10;
acqdurframes = imagerate*(isi+duration);
timepts = [1:acqdurframes+acqdurframes/2]*0.1;
areas = {'V1','P','LM','AL','RL','AM','PM'};
behavState = {'stationary','running'};
ncut = 2;
trials = length(sf)-ncut;
sizeVals = [0 5 10 20 30 40 50 60];
sf=sf(1:trials);contrasts=contrasts(1:trials);phase=phase(1:trials);radius=radius(1:trials);
order=order(1:trials);tf=tf(1:trials);theta=theta(1:trials);xpos=xpos(1:trials);
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end

if redo
    alltrialcycavgpre = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
    allpeakspre = zeros(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    alltracespre = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
    allgauParamspre = zeros(length(contrastRange),length(radiusRange),2,length(areas),5,length(datafiles));
    allhalfMaxpre = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    allareapeakspre = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    for i= 1:length(use) %collates all conditions (numbered above) 
        load(fullfile(predir,files(use(i)).datafile),'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax')
        alltrialcycavgpre(:,:,:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(trialcycavg,4),5));
        allpeakspre(:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(peaks,4),5));
        allmvpre(:,i) = mv;
        allgauParamspre(:,:,:,:,:,i) = gauParams;
        allhalfMaxpre(:,:,:,:,i) = halfMax;
        allareapeakspre(:,:,:,:,i) = areapeaks;
        load(files(use(i)).ptsfile);
        for j=1:length(x)
            alltracespre(j,:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(nanmean(nanmean(trialcycavg(y(j)-1:y(j)+1,x(j)-1:x(j)+1,:,:,:,:,:,:),4),5),1),2));
        end
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

    alltrialcycavgpost = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
    allpeakspost = zeros(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    alltracespost = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
    allgauParamspost = zeros(length(contrastRange),length(radiusRange),2,length(areas),5,length(datafiles));
    allhalfMaxpost = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    allareapeakspost = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
    for i= 1:length(use) %collates all conditions (numbered above) 
        load(fullfile(postdir,files(use(i)).datafile),'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax')
        alltrialcycavgpost(:,:,:,:,:,:,:,:,i) = trialcycavg;
        allpeakspost(:,:,:,:,:,:,i) = peaks;
        allmvpost(:,i) = mv;
        allgauParamspost(:,:,:,:,:,i) = gauParams;
        allhalfMaxpost(:,:,:,:,i) = halfMax;
        allareapeakspost(:,:,:,:,i) = areapeaks;
        load(files(use(i)).ptsfile);
        for j=1:length(x)
            alltracespost(j,:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(trialcycavg(y(j)-2:y(j)+2,x(j)-2:x(j)+2,:,:,:,:,:,:),1),2));
        end
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
    
    save(filename,'avgtrialcycavgpre','avgpeakspre','avgtracespre','avggauParamspre','avghalfMaxpre','avgareapeakspre','avgmvpre',...
        'setrialcycavgpre','sepeakspre','setracespre','segauParamspre','sehalfMaxpre','seareapeakspre','semvpre',...
        'avgtrialcycavgpost','avgpeakspost','avgtracespost','avggauParamspost','avghalfMaxpost','avgareapeakspost','avgmvpost',...
        'setrialcycavgpost','sepeakspost','setracespost','segauParamspost','sehalfMaxpost','seareapeakspost','semvpost','-v7.3');
    doSizeSelectPlots
else
    load(filename)
    doSizeSelectPlots
end
