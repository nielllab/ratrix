clear all

dt = 0.25;
framerate=1/dt;
twocolor = input('# of channels : ')
twocolor= (twocolor==2);
get2pBehavSession;

if ~exist('onsets','var')

    [bf bp] = uigetfile('*.mat','behav permanent trial record');
    [onsets starts trialRecs] = sync2pBehavior_sbx(fullfile(bp,bf) ,phasetimes);
    save(sessionName,'onsets','starts','trialRecs','-append');
end

display('aligning frames')
tic
if ~exist('mapalign','var')
    timepts = -1:0.25:2;
    mapalign = align2onsets(dfofInterp,onsets,dt,timepts);
    display('saving')
    save(sessionName,'timepts','mapalign','-append')
end
toc

%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
targ = sign([stim.target]);
for i = 1:length(trialRecs);
    orient(i) = trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
end



%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1;

figure
for t = 1:3
    if t==1
        dfmean = mean(mapalign(:,:,:,targ==-1),4);
    elseif t==2
        dfmean = mean(mapalign(:,:,:,targ==1),4);
    else
        dfmean = mean(mapalign(:,:,:,targ==-1),4) -mean(mapalign(:,:,:,targ==1),4) ;
    end
    %mn = mean(dfmean,3);
    mn = min(dfmean,[],3);
    figure
    for i = 1:13;
        subplot(4,4,i);
        if t<3
            imagesc(dfmean(:,:,i)-mn,[0 0.1]);
        else
            imagesc(dfmean(:,:,i),[-0.1 0.1]);
        end
        axis equal; axis off
    end
    
end


selectPts = input('select points for further analysis? 0/1 ')
if selectPts==1
    
    useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
    if useOld ==1
        [pts dF ptsfname icacorr cellImg usePts] = align2pPts(dfofInterp,greenframe);
    elseif useOld==2
        [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
    else
        ptsfname = uigetfile('*.mat','pts file');
        load(ptsfname);
    end
    
    
    dF(dF<0)=0;
    dF=deconvg6s(dF,0.25);
    
    edgepts = (pts(:,1)<18 | pts(:,1)>237 | pts(:,2)<18 | pts(:,2)>237);
    usenonzero= find(mean(dF,2)~=0 & ~edgepts);
    
    timepts = -1:0.25:2;
    dFalign = align2onsets(dF,onsets,dt,timepts);
    trialmean = mean(dFalign,3);
    for i = 1:size(trialmean,1);
        trialmean(i,:) = trialmean(i,:)- min(trialmean(i,:));
    end
    figure
    plot(trialmean');
    figure
    plot(timepts,mean(trialmean,1))
    
    
    
    
    %%% get left/right traces
    leftmean = mean(dFalign(:,:,targ==-1),3);
    rightmean = mean(dFalign(:,:,targ==1),3);
    for i = 1:length(leftmean)
        leftmean(i,:) = leftmean(i,:)-min(leftmean(i,3:4));
    end
    for i = 1:length(leftmean)
        rightmean(i,:) = rightmean(i,:)-min(rightmean(i,3:4));
    end
    
    figure
    plot(leftmean')
    
    figure
    plot(rightmean')
    
    figure
    draw2pSegs(usePts,leftmean(:,7),jet,256,usenonzero,[0 0.5])
    
    figure
    draw2pSegs(usePts,rightmean(:,7),jet,256,usenonzero,[0 0.5])
    
    figure
    plot(leftmean(:,9),rightmean(:,9),'o'); hold on
    axis equal; axis square; plot([0 1],[0 1],'g');
    
    results = [ sum(correct & targ==-1)  sum(~correct&targ==-1) sum(~correct & targ==1)  sum(correct & targ==1)];
    results = results/sum(results(:))
    figure
    pie(results); legend('left correct','left error','right error','right correct');
    
    correctmean = mean(dFalign(:,:,correct),3);
    wrongmean = mean(dFalign(:,:,~correct),3);
    figure
    plot(timepts,correctmean')
    figure
    plot(timepts,wrongmean');
    
    %%% get start/stop time
    resptime = starts(:,3)-starts(:,2); resptime = resptime*10^4;
    figure
    hist(resptime,0:0.1:5)
    stoptime = starts(:,2)-starts(:,1); stoptime  = stoptime*10^4;
    figure
    hist(stoptime);
    
    c = 'rgbcmk'
    figure
    hold on
    for i = 1:size(dF,1);
        plot(dF(i,:)/max(dF(i,:)) + i/2,c(mod(i,6)+1));
    end
    for i = 1:length(onsets);
        plot([onsets(i)/dt onsets(i)/dt],[1 size(dF,1)/2]);
    end
    
    save(ptsfname,'usenonzero','onsets','starts','trialRecs','correct','targ','orient','gratingPh','dFalign','-append')
    
    dF(dF<-0.1)=-0.1;
    dF(dF>5)=5;
    figure
    imagesc(corrcoef(dF(usenonzero,:)),[0 1])
    
    figure
    imagesc(corrcoef(dF(usenonzero,:)'),[0 1])
    
    figure
    imagesc(dF(usenonzero,:),[-1 5])
    
    startTimes = zeros(ceil(length(dF)*dt),1);
    startTimes(round(onsets))=1;
    x = [-60:60];
    filt = exp(-0.5*x.^2 / (20^2));
    filt = 60*filt/sum(filt);
    trialRate = conv(startTimes,filt,'same');
    
    for i = 1:size(dF,1)
        dFmin(i,:) = dF(i,:) - min(abs(dF(i,:)));
        dFstd(i,:) = dFmin(i,:)/std(dF(i,:));
    end
    
    
    
    
    % [Y e] = mdscale(dist,1);
    % [y sortind] = sort(Y);
    % figure
    % imagesc(dF(usenonzero(sortind),:),[-1 5])
    
    
    
    correctRate = conv(double(correct),ones(1,10),'same')/10;
    figure
    plot(correctRate);
    resprate = conv(resptime,ones(3,1),'same')/3;
    stoprate = conv(stoptime,ones(3,1),'same')/3;
    
    nclust=4;
    [idx] = kmeans(dFstd(usenonzero,:),nclust);
    [y sortind] = sort(idx);
    
    
    figure
    subplot(6,6,7:36);
    dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
    imagesc(dFlist(usenonzero(sortind),:),[-1 5]); ylabel('cell'); xlabel('frame')
    subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
    hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
    plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
    
    figure
    subplot(6,6,7:36);
    dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
    imagesc(corrcoef(dFlist(usenonzero,:)),[0 1]); xlabel('frame'); ylabel('frame')
    subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
    hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
    plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
    
    idxall = zeros(length(pts),1);
    idxall(usenonzero) = idx;
    
    figure
    draw2pSegs(usePts,idxall,jet,256,usenonzero,[1 4])
    
    orients = unique(orient);
    vert = find(orient==orients(1));
    horiz = find(orient==orients(2));
    vertresp= mean(dFalign(:,:,vert),3);
    horizresp = mean(dFalign(:,:,horiz),3);
    for i = 1:size(vertresp,1);
        mn = min([vertresp(i,3:4) horizresp(i,3:4)]);
        vertresp(i,:) = vertresp(i,:) - mn;
        horizresp(i,:) = horizresp(i,:) - mn;
    end
    
    leftmean = mean(dFalign(:,:,targ==-1),3);
    rightmean = mean(dFalign(:,:,targ==1),3);
    
    
    for i = 1:length(leftmean)
        mn =min([ leftmean(i,3:4) rightmean(i,3:4)]);
        leftmean(i,:) =  leftmean(i,:) - mn;
        rightmean(i,:) = rightmean(i,:)-mn;
    end
    
    
    t = find(timepts==0.5);
    leftright = leftmean(:,t)-rightmean(:,t) ;
    verthoriz = vertresp(:,t)-horizresp(:,t);
    figure
    plot(leftright,verthoriz,'o')
    
    figure
    plot(leftmean(:,t),rightmean(:,t),'o'); hold on; plot([0 2],[0 2],'g')
    
    figure
    plot(vertresp(:,t),horizresp(:,t),'o'); hold on; plot([0 2],[0 2],'g')
    
    
    dFalignfix = dFalign;
    for i=1:size(dFalign,1);
        for j = 1:size(dFalign,3);
            dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,3:5,j));
        end
    end
    %dFalignfix(dFalignfix>5)=5;
    
    usetrials = zeros(size(targ));
    usetrials(80:end)=1;
    usetrials=1;
    clear data err
    col = 'rmbc'
    allTrials = zeros(size(dFalign,2),4,size(dFalign,1));
    for i = 1:length(sortind)
        
        for j = 1:4
            if j==1
                use = targ==-1 & orient==0 & usetrials;
            elseif j==2
                use = targ==-1 & orient>0& usetrials;
            elseif j ==3
                use = targ==1 & orient==0& usetrials;
            else
                use = targ==1 & orient>0& usetrials;
            end
            d = mean(dFalignfix(usenonzero(sortind(i)),:,use),3);
            data(:,j) = d; %-mind(d);
            err(:,j) = std(dFalignfix(usenonzero(sortind(i)),:,use),[],3)/sqrt(sum(use));
            
        end
        data = data-min(data(:));
        allTrials(:,:,usenonzero(sortind(i))) = data;
        allTrialsErr(:,:,usenonzero(sortind(i))) = err;
        %           figure; hold on
        %           for j=1:4
        %             errorbar(timepts,data(:,j),err(:,j),col(j)); ylim([0 2])
        %         end
        %         title(sprintf('group %d cell %d',y(i),usenonzero(sortind(i))))
        %         legend('left vert','left horiz','right vert','right horiz')
    end
    
    
    save(ptsfname,'allTrials','allTrialsErr','vertresp','horizresp','leftmean', 'rightmean','timepts','-append');
    
    figure
    for t = 1:6
        subplot(2,3,t)
        plot(vertresp(:,2*t+1),horizresp(:,2*t+1),'o'); axis([0 1 0 1]); axis square
    end
    
    
    figure
    for t = 1:6
        subplot(2,3,t)
        plot(leftmean(:,2*t+1),rightmean(:,2*t+1),'o'); axis([0 1 0 1]); axis square
    end
    
    figure
    hold on
    for i = length(sortind):-1:1;
        plot(dF(usenonzero(sortind(i)),:)/max(abs(dF(usenonzero(sortind(i)),:))) + i,c(mod(i,6)+1));
        hold on
        plot([1 size(dF,2)], [i i],[c(mod(i,6)+1) ':'])
        
    end
    for i = 1:length(onsets);
        plot([onsets(i)/dt onsets(i)/dt],[1 length(sortind)]);
    end
    ylim([1 length(sortind)]); xlim([1 size(dF,2)])
    
    
    %%% plot each cluster
    col='rgbc'
    clear data
    for i =1:nclust
        figure; hold on
        useidx = find(idx==i);
        for j=1:length(useidx)
            d = mean(dFalign(usenonzero(useidx(j)),:,:),3);
            plot(timepts,d-min(d),col(i)); ylim([0 1.5])
            data(j,:) = d-min(d);
        end
        plot(timepts,median(data,1),'k','Linewidth',2);
    end
    
    
    %%% looks at stopping / resp times
    stoplength = 1.1;
    longstops = onsets(stoptime<stoplength);
    length(longstops)
    clear stopdF
    stopPts = -stoplength:0.25:2;
    stopalign = align2onsets(dF,longstops,dt,stopPts);
    for i = 1:size(dF,1);
        stopdF(i,:) = mean(stopalign(i,:,:),3);
        stopdF(i,:) = stopdF(i,:) - min(stopdF(i,:));
    end
    figure
    plot(stopPts,stopdF)
    hold on
    plot(stopPts,mean(stopdF,1),'g','Linewidth',2)
    
    figure
    imagesc(stopdF(usenonzero(sortind),:),[0 1.5])
    
    respDur = 0.5;
    longstops = onsets(correct) %+ resptime(resptime>respDur)';
    length(longstops)
    clear stopdF
    stopPts = -1:0.25:4;
    stopalign = align2onsets(dF,longstops,dt,stopPts);
    for i = 1:size(dF,1);
        stopdF(i,:) = mean(stopalign(i,:,:),3);
        stopdF(i,:) = stopdF(i,:) - min(stopdF(i,:));
    end
    figure
    plot(stopPts,stopdF)
    hold on
    plot(stopPts,mean(stopdF,1)*3,'g','Linewidth',2); ylim([0 2])
    
    figure
    imagesc(stopdF(usenonzero(sortind),:),[0 1.5])
    
end
