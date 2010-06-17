%nonGaussROCwork
%close all 
samps=20000;
K=0.2; %shape
noiseSigma=2;
signalSigma=1;
SIGMA=2;
w=2; h=2;
pGuess=0.3;
pYesGivenGuess=0.2;
%contrasts=[0 .1 .25 .5 1 2 3 4 5 7];
contrasts=[0 1 2 3 4 7];
sigmas=signalSigma*ones(1,length(contrasts));
sigmas([1])=noiseSigma; 

mu=repmat(contrasts,samps,1);
sigma=repmat(sigmas,samps,1);
response= gevrnd(K,sigma,mu); % get samps
ranked=sort(response);
ranked=[flipud(ranked(:,1)) ranked(:,2:end)]; %flip the noise ore for ease of comparison

figure;
subplot(h,w,1); hold on
numC=length(contrasts);
colors=jet(numC);
edges=linspace(0,15,100); %minmax(response(:)')
x=linspace(0,15,1000);
critSampling=ranked(round(linspace(1,samps,100)),1);% us percentiles of the noise for criterion spacing


for i=1:numC
    %subplot(numC,1,i); hist(response(:,i),200)
    n=histc(response(:,i),edges);
    %plot(edges,n/samps,'color',colors(i,:))% should be centers...% turned off for now
    
    ys(i,:)=gevpdf(x,K,sigmas(i),contrasts(i)); % find the boundary with a smoother pdf
    plot(x,ys(i,:),'color',colors(i,:))
    
    if i>2
        which=min(find(ys(1,:)<ys(i,:)));
        crit(i)=x(which);  %the criteria trade off for this contrast
        plot([crit(i) crit(i)],ylim,'k')
    end
    
end
for j=1:length(critSampling)
    %plot([critSampling(j) critSampling(j)],ylim,'k')
end
set(gca,'xlim',minmax(edges))
ylabel('probability')
xlabel('response')
%%
% subplot(h,w,3); hold on
% %
%
% plot(ranked)
% for i=1:length(crit)
%     plot([0 samps],[crit(i) crit(i)],'k')
% end
% axis([0 10000 -2 10])

%%
subplot(h,w,2); hold on
for i=1:numC
    for j=1:length(critSampling)
        hits(i,j)=sum(response(:,i)>critSampling(j))/samps;
        FAs(i,j)=sum(response(:,1)>critSampling(j))/samps;
        
    end
    plot(FAs(i,:),hits(i,:),'color',colors(i,:))
    
    if i>2
        %the optimum
        bestH(i)=sum(response(:,i)>crit(i))/samps;
        bestFA(i)=sum(response(:,1)>crit(i))/samps;
        plot(bestFA(i),bestH(i),'ok')
    end
end


%%
subplot(h,w,4); hold on
plot([0 1],[0 1],'k')
axis square
ylabel('hit rate')
xlabel('fa rate')

%guess adjusted
hitsG=(1-pGuess)*(hits)+pGuess*(pYesGivenGuess);
FAsG=(1-pGuess)*(FAs)+pGuess*(pYesGivenGuess);
bestHG=(1-pGuess)*(bestH)+pGuess*(pYesGivenGuess);
bestFAG=(1-pGuess)*(bestFA)+pGuess*(pYesGivenGuess);

gy=pGuess*(pYesGivenGuess);
gn=pGuess*(1-pYesGivenGuess);
fill([0 0 gy gy 1 1 ],[0 1 1 gy gy 0],[.8 .8 .8]);
text(.5,gy/2,'guess yes','HorizontalAlignment','center')

fill([0 1 1 1-gn 1-gn 0 ],[1 1 0 0 1-gn 1-gn],[.8 .8 .8]);
text(.5,1-gn/2,'guess no','HorizontalAlignment','center')

for i=1:numC
    plot(FAsG(i,:),hitsG(i,:),'color',colors(i,:));  %
    if i>2
        plot(bestFAG(i),bestHG(i),'ok'); %the optimum
    end
end


settings.MarkerSize=6;
settings.textObjectFontSize=10;
cleanUpFigure(gcf,settings)
