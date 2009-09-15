function [train test trainLabel testLabel whichTrain]=getBehavioralFeatures(d,window,features,labelType,holdout,doPrewhittening)
% F=getBehavioralFeatures(d);
% F=getBehavioralFeatures(d,[],{'responseTime'}),'correct',[],true;

if ~exist('window','var') || isempty(window)
    %window.Waveform='exponential'
    %window.Sizes=[1 1];  % window size one is a delta function
    %window.offset=[-1 -2]  % one before and two before
    %window.blockOut=[0]  % ignore self, redundant in this case  b/c offset
    %window.params.tau=[0 0]; %this is a boxcar / flat no decay


    window.Waveform='gaussian'
    window.Sizes=[1 10 100];
    window.offset=[0 0 0]; %dont include current trial, only those before
    window.blockOut=[0]  % ignore self, middle of gaussian
    window.params.std=[0 2 20];


    window.Waveform='exponential'
    window.Sizes=[1 10 100];
    window.offset=[1 1 1]; %dont include current trial, only those before
    window.blockOut=[0]  % ignore self, redundant in this case b/c offset
    window.params.tau=[0 4 40];
end

if ~exist('features','var') || isempty(features)
    %features={'correct','incorrect','rightward','leftward'}
    features={'correct','reward','rightward','switches','numRequestLicks','responseTime','ITI'}
end

if ~exist('labelType','var') || isempty(labelType)
    labelType='correct'; % 'side'
end

if ~exist('holdout','var') || isempty(holdout)
    holdout.type='randomDays'
    holdout.fraction=0.2;
    holdout.seed=[];

    holdout.type='last'
    holdout.fraction=0.1;
end

if ~exist('doPrewhittening','var') || isempty(doPrewhittening)
    doPrewhittening=false;
end

pad=max(window.Sizes)-1;
ln=length(d.date)-pad;
which=logical(zeros(size(d.date)));
which(pad+1:end)=1;
date=d.date(which);
data=zeros(ln ,length(window.Sizes)*length(features));
for i=1:length(window.Sizes)
    %which= ;% for this window size, not being used, try all
    for j=1:length(features)
        switch features{j}
            case {'correct','reward','numRequestLicks','responseTime'}
                value=double(d.(features{j}));
            case 'incorrect'
                value=double(d.correct==0);
            case 'rightward'
                value=double(d.response==3);
            case 'leftward'
                value=double(d.response==1);
            case 'switches'  % include in addYesResponse
                value=double([0 ~(diff(d.response==1)==0)]);
            case 'trialThisDay'  % include in addYesResponse
                counter=ones(size(d.date))
                dayEdge=logical(diff(floor(d.date)))
                counter(dayEdge)=-[min(find(dayEdge)) diff(find(dayEdge))] %reset counter after numTrials per day
                trialThisDay=cumsum(counter);
                plot(trialThisDay)
                keyboard
            case 'ITI'
                value=[0 diff(d.date)*24*60*60];
                value(value>10)=10;
            otherwise
                features{j}
                error('bad feature')
        end

        switch window.Waveform
            case 'exponential'
                kernal=zeros(1,max(window.Sizes));
                kernal(end+1-window.Sizes(i):end)=exp(([1:window.Sizes(i)])*window.tau(i));
                if ~isempty(window.blockOut) && ~isnan(window.blockOut(i))
                    kernal(end+window.blockOut(i))=0;
                end
                disp('check exp and delta w/ -inf.... normalize to 1 or not?')
                %add 'exponential' to calculateSmoothedPerformances
                %case 'deltaOffset' %might be irrelevant with -inf tau ... i mean w/ offset in exponential
                %    kernal=zeros(1,window.params.offset(i));
                %    kernal(1:window.Sizes(i))=1;
            case 'exponenentialTime'
                error('not yet')
                timeBefore=zeros()
            otherwise
                error('bad waveform')
        end
        kernal=kernal/sum(kernal)

        ind=(i-1)*length(features)+j;
        class(value)
        names{ind}=sprintf('%s-%d',features{j},window.Sizes(i))
        try
        data(:,ind)=conv2(value,kernal,'valid');

        catch ex 
             disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
            the_data=size(data(:,ind))
            the_conv=size(conv2(value,kernal,'valid'))
            the_values=size(value)
            the_kernal=size(kernal)
            error('conv2 failed')
        end

    end


    label=zeros(size(data,1),1);
    switch labelType
        case 'correct'
            label(d.correct(which)==1)=1;
            label(d.correct(which)==0)=-1;
        case 'side'
            label(d.response(which)==3)=1;
            label(d.response(which)==1)=-1;
        otherwise
            labelType
            error('bad labelType')
    end

end

switch class(holdout)
    case 'logical'
        if length(whichTrain)==ln
            whichTrain=holdout;
        else
            ln
            length(whichTrain)
            error('wrong size logical')
        end
    case 'struct'
switch holdout.type
    case 'last'
        ind=round(ln*(1-holdout.fraction));
        whichTrain=[1:ln]<ind;
    case 'randomDays'
        if ~isempty(holdout.seed)
            seed(holdout.seed)
        end

        days=unique(floor(date));
        randInds=randperm(length(days));
        ind=round(length(days)*(holdout.fraction));
        testDays=days(randInds(1:ind));
        whichTrain=~ismember(floor(date),testDays);
        testingFraction=mean(double(~whichTrain));
        sprintf('using %d of %d days for testing, which is %2.2g%% of the data (%d%% was requested)',...
            length(testDays), length(days),100*testingFraction,100*holdout.fraction)
        if (abs(testingFraction-holdout.fraction)/holdout.fraction)>1.1 % 110 percent!
            perDay=histc(floor(date), min(days):max(days))
            error('not the expected about of testing data.  this could be caused by uneven amounts of data per day')
        else
            disp('close enough amount of data')
        end
    case 'lastTen' 
       whichTrain=[1:ln]<ln-10;
    otherwise
        error('bad holdout method')
end
    otherwise
        class()
        error('bad hold out class')
end
train=data(find(whichTrain),:);
test=data(find(~whichTrain),:);
trainLabel=label(find(whichTrain));
testLabel=label(find(~whichTrain));

if doPrewhittening
    numF=size(train,2);
    
    %plot raw distribution
    numHists=5; n=1;
    statHist(train,n,numHists,trainLabel);
    subplot(numHists,numF,(numF*(n-1))+1); ylabel('raw')
    
    %%normalize each to gaussian
    n=n+1;
    train=normalize(train);
    test=normalize(test);
    statHist(train,n,numHists,trainLabel);
    subplot(numHists,numF,(numF*(n-1))+1); ylabel('normalized')
    
    %whiten
    n=n+1;
    train=real(prewhiten(train));
    test=real(prewhiten(test));
    statHist(train,n,numHists,trainLabel);
    subplot(numHists,numF,(numF*(n-1))+1); ylabel('whitened')
    
    %normalize again
    n=n+1;
    train=normalize(train);
    test=normalize(test);
    statHist(train,n,numHists,trainLabel);
    subplot(numHists,numF,(numF*(n-1))+1); ylabel('normalized')
        
    %whiten again
    %n=n+1;
    %train=real(prewhiten(train));
    %test=real(prewhiten(test));
    %statHist(train,n,numHists,trainLabel);
    %subplot(numHists,numF,(numF*(n-1))+1); ylabel('whitened')
    
    %label stat
    for i=1:size(train,2)
        subplot(numHists,numF,i)
        xlabel(names{i})
    end
    
end

function y=normalize(x)
%edf sez: this is a poor choice for a function name, but OK cuz local functions have precedence
%http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_prog/f7-58170.html#bresuvu-6    

%order the distribution, and force it to be gaussian, drawn from a normal distribution
%works on a vector [Nx1] or a matrix [Nsamples x Mfeatures]

%check input size

if any(isnan(x(:)))
    x
    amount_of_nans=sum(isnan(x(:)))
    error('contains nans!, offset might fight with window size=1...?')
end

numF=size(x,2);
numSamps=size(x,1); %samples
y=zeros(size(x));
for i=1:numF
    [sorted IDs ]=sort(x(:,i));
    [rank inverseID]=sort(IDs);
    [values count]=unique(sorted);
    repVals=values(count>1);
    for j=1:length(repVals)  %this counts all repeated values as their rank average
        these=find(sorted==repVals(j));
        rank(these)=mean(these);
    end
    %normalize to 1 and return values to rank order
    fractionalRank=2*(rank-(numSamps/2))./(numSamps+1); %example: [1 99]/100 is centered, so is [-49 49]/100;
    %max(fractionalRank) %about 1 
    %min(fractionalRank) % about -1
    y(:,i)=erfinv(fractionalRank(inverseID));

    confirmPlot=false;
    if confirmPlot
        figure(99)
        subplot(3,1,1); hist(x(:,i),20)
        subplot(3,1,2); hist(y(:,i),20)
        nn=15;
        dmean=x(1:nn,i)-mean(x(1:nn,i));
        scaledX=dmean./(max(dmean)-min(dmean));
        subplot(3,1,3); hold off; plot(scaledX,'g');
        hold on; plot(y(1:nn,i),'r')
        pause
    end
end

    function statHist(data,row,numRows,labels)
        numF=size(data,2);
        for i=1:numF
            feature=data(:,i);
            edges=linspace(min(feature),max(feature),20);
            count=histc(feature,edges);
            subplot(numRows,numF,numF*(row-1)+i);
            [mu sigma]=normfit(feature);
            fitted=normpdf(edges,mu,sigma);
            maxFit=max(fitted);
            maxCount=max(count);
            plot(edges,fitted/maxFit,'k');
            hold on
            plot(edges,count/maxCount,'k.')
            if exist('labels','var')
                %seperate distribution per category
                feature=data(find(labels==1),i);
                [mu sigma]=normfit(feature);
                fitted1=normpdf(edges,mu,sigma);
                count1=histc(feature,edges);

                feature=data(find(labels==-1),i);
                [mu sigma]=normfit(feature);
                fitted2=normpdf(edges,mu,sigma);
                count2=histc(feature,edges);

                %plot the conditional distributions,
                %still normalizing to the full distribution
                plot(edges,fitted1/maxFit,'r');
                plot(edges,fitted2/maxFit,'b');
                plot(edges,count1/maxCount,'r.');
                plot(edges,count2/maxCount,'b.');
            end

        end