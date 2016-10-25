% display('info about parallel pool')
% myCluster=parcluster('local')
% gcp('nocreate')
close all
clear all
%batchBehavNew;
batchLearningBehav;
%batchBehavNN;
%batchTopography;
close all

%need to have behavior file for each one, what about pre-behavior?
%alluse = find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session')  &  strcmp({files.label},'camk2 gc6') & ~strcmp({files.behav},'') & strcmp({files.task},'GTS') & strcmp({files.subj},'g62m9tt')); %
alluse = find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session')  &  strcmp({files.label},'camk2 gc6') & strcmp({files.task},'GTS') & ~strcmp({files.behav},'') ); % for all files including ones without behavior
% nouse =  1:length(files) & find(strcmp({files.monitor},'vert') &  strcmp({files.notes},'good imaging session')  & ~strcmp({files.topox},'') & ~strcmp({files.topoy},'')& strcmp({files.subj},'g62l10rt'
%alluse = 1:length(files) & ~strcmp({files.topox},'') & ~strcmp({files.topoy},'')  & ~strcmp({files.subj},'g62j8lt') & ~strcmp({files.subj},'g62l1lt') & ~strcmp({files.subj},'g62m1lt') & strcmp({files.task},'naive');
%     & strcmp({files.task},'HvV') & ~strcmp({files.subj},'g62l10rt') &  ~strcmp({files.subj},'g62n1ln') & ~strcmp({files.subj},'g62m9tt')

%  batchBehavFrontiers;
%  alluse = find(strcmp({files.monitor},'vert') & strcmp({files.notes},'good imaging session')  &  strcmp({files.label},'camk2 gc6') & strcmp({files.task},'HvV_center') ); %
%


length(alluse)
allsubj = unique({files(alluse).subj})
alltask = unique({files(alluse).task})




%% use this one for subject by subject averaging
% for s = 1:length(allsubj)
% use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))

%% use this one to average all sessions that meet criteria
for s=1:1
    use = alluse;
    
    allsubj{s}
    
    %%% calculate gradients and regions
    clear map merge
    x0 =10; y0=30; sz = 120;
    x0 =0; y0=0; sz = 128;
    doTopography;
    
    
    %save('D:/referenceMap.mat','avgmap4d','avgmap','files');
    
    
    %% overlay behavior on top of topomaps
    doBehavior;
    alldata{s} = avgbehavCond;
    
    % %%% analyze looming
    % for f = 1:length(use)
    %     loom_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'loom');
    % end
    % fourPhaseAvg(loom_resp,allxshift+x0,allyshift+y0,allthetashift,zoom, sz, avgmap);
    
    
    %%% analyze grating
    % for f = 1:length(use)
    %  f
    %  grating_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'grating');
    % end
    % fourPhaseAvg(grating_resp,allxshift+x0,allyshift+y0, allthetashift,zoom*0.57, sz, avgmap);
    
    
    
end


for f= 1:length(behav);
    for cond =3:4
        figure
        if ~isempty (behav{f}{cond})
            for t= 1:6
                subplot(2,3,t)
                imagesc(shiftBehav{f}{cond}(:,:,t+7),[0 0.15]);
                hold on
                plot(ypts,xpts,'w.','Markersize',1);
                axis off
            end
            title(sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt))
            subplot(2,3,2); title([ files(use(f)).learned ' ' num2str(days(f));
            subplot(2,3,1); if cond ==4,  title('avg top correct')
            else title('avg bottom correct'); end
        elseif isempty (behav{f}{cond})
            sprintf('no correct trials')
            sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt)
        end
    end
end
    
 
clear learn days
for i = 1:length(alluse)
    if strcmp(files(alluse(i)).learned,'mid')
        learn(i)=1;
    elseif strcmp(files(alluse(i)).learned,'post')
        learn(i)=2;
    end
    if ~isempty(files(alluse(i)).learningDay)
        days(i) = str2num(files(alluse(i)).learningDay);
    else
        days(i) = 100;
    end
end

clear data
for i = 1:length(behav)
    for c = 1:4
        if ~isempty(shiftBehav{i}{c})
            data(:,:,:,c,i) = shiftBehav{i}{c}(:,:,:);
        else
            data(:,:,:,c,i) = NaN;
        end
    end
end

clear avgLearned

avgLearned(:,:,:,:,1) = nanmean(data(:,:,:,:,learn==1 & days<10),5);
avgLearned(:,:,:,:,2) = nanmean(data(:,:,:,:,learn==2),5);

errLearned(:,:,:,:,1) = nanstd(data(:,:,:,:,learn==1 & days<10),[],5)/sqrt(sum(learn==1 & days<10));
errLearned(:,:,:,:,2) = nanstd(data(:,:,:,:,learn==2),[],5)/sqrt(sum(learn==2));



learnTitle = {'pre','post'};
condTitle = {'correct','incorrect','top','bottom'};
for i = 1:2
    for cond=1:4
        figure
        for t = 1:6
            subplot(2,3,t)
            imagesc(avgLearned(:,:,t+7,cond,i) - mean(mean(avgLearned(200:210,200:210,t+7,cond,i))),[ 0 0.15]); colormap jet
           hold on
              plot(ypts,xpts,'w.','Markersize',1);
              axis off
        end
        subplot(2,3,1); title(learnTitle{i});
        subplot(2,3,2); title(condTitle{cond});
    end
end

figure
imagesc(avgLearned(:,:,9,3,1));
hold on;  plot(ypts,xpts,'w.','Markersize',1);
for i = 1:12
    [y(i) x(i)] = ginput(1);  plot(y(i),x(i),'g*');
end
x= round(x); y= round(y); npts=12;
nullPt = [205 205];    
        


[f p] = uiputfile('*.mat','save data?');
if f~=0
    save(fullfile(p,f),'allsubj','alldata', 'shiftBehav', 'numTrialsPercond');
end


