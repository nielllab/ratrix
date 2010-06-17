
%%
filter{1}.type='9.4';                   % use flanker present at contrast .4 with target at contratst 1.0, and no flanks mixed in to the nf analysis
conditionType='8flanks+';
dateRange=[0 pmmEvent('endToggle')];
goodTrialType='withoutAfterError';
%[stats CI names params]=getFlankerStats(subjects,conditionType,statTypes,filter,dateRange,[], numShuffle);

subjects={'228','227','230','233','234','139','138'}; %puts high-lighted rat (end) on the top
%subjects={'138','228'}; % quick for testing
chunkSize=500;
allTrialsAllRats=[];
for i=1:length(subjects)
    d=getSmalls(subjects{i},dateRange);
    d=filterFlankerData(d,filter);
    d=removeSomeSmalls(d,~getGoods(d,goodTrialType));
    allTrialsAllRats=[allTrialsAllRats d.correct];
    over=mod(length(d.date),chunkSize);
    fitsWell=ones(1,length(d.date));
    fitsWell(end+1-over:end)=0;
    d=removeSomeSmalls(d,~fitsWell);
    totalTrials=length(d.date);
    avg=sum(d.correct)/totalTrials;
    [junk ci]=binofit(round(avg*chunkSize),chunkSize);
    p=reshape(d.correct,chunkSize,[]);
    chunk=1:size(p,2);
    numOutliers=sum(mean(p)>ci(2) | mean(p)<ci(1));
    outlierFrac= numOutliers/length(chunk);
    [f,S] = polyfit(chunk,mean(p),1); % fit a line
    ranked=sort(mean(p));
    lb=ranked(ceil(length(chunk)*0.025));
    ub=ranked(ceil(length(chunk)*0.975));
    
    subplot(4,2,i); hold on
    fill([1 1 chunk([end end])],ci([1 2 2 1]),'c','FaceColor',[.8 .8 .8])
    plot(chunk,mean(p),'.')
    plot([1 max(chunk)],[lb lb],'k')
    plot([1 max(chunk)],[ub ub],'k')
    plot(chunk,chunk*f(1)+f(2),'b')
    
    title(sprintf('%s: %d of %d outliers (%2.2f%%) rise: %2.1f%% [%2.2f %2.2f]',...
        subjects{i},numOutliers,length(chunk),outlierFrac*100,f(1)*max(chunk)*100,ub,lb))
    axis([1 max(chunk) .5 .8]);
    

    bound(i,1)=lb;    
    bound(i,2)=ub;
    bound2(i,1)=min(mean(p));
    bound2(i,2)=max(mean(p));
    subplot(4,2,8); hold on
    plot([i i],[lb ub])
    axis([1 max(chunk) .5 .8])
end

bound
bound2
mean(allTrialsAllRats)