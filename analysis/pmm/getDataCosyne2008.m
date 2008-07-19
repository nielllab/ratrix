function getDataCosyne2008()

%%

if 0
%%
subject={'rat_117'};
dateRange=datenum({'Nov.15,2007','13-Feb-2008'}); % good bounds
%dateRange=datenum({'June.10,2007','Aug.1,2007'}); % too broad to find bounds
d=allToSmall(subject,dateRange,1,0);

%checks
trialsPerDay=makeDailyRaster(d.correct,d.date);
find(trialsPerDay>1000) 
datestr(floor(min(d.date))+30)
badDay='29-Dec-2007 05:31:07';  %this is actually the sessionID
%why bad?  wrong rat?  9 dual responses in 847 trials, possibly no water?
%seems to be a multi day effect.. i don't think we are justified in removing it
%bar(trialsPerDay)
%d=removeSomeSmalls(d,floor(d.date)==floor(datenum(badDay)));
d=removeSomeSmalls(d,(d.step~=6));
sum(d.step==6)
sum(d.step~=6)
length(trialsPerDay)



    m=0; whichPlots= [1 1 0 m 0 m m 1 0 0 0 0 0 0 1 0 1 m]; handles=[1:length(whichPlots)];
    inspectRatResponses(char(subject),'noPathUsed',whichPlots,handles,[],d);
    
    savePath='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\cosyneXfer\';
    save(fullfile(savePath,'117_90_stable_days.mat'),'d')
    %inspect it
    f=fields(d);
    f(strcmp(f,'info') | strcmp(f,'date')  |  strcmp(f,'date') |  strcmp(f,'totalFrames')   | strcmp(f,'startTime')  | strcmp(f,'numMisses') | strcmp(f,'actualRewardDuration') | strcmp(f,'responseTime'))=[]
    %temp=rmfield(d,'info'); unique([struct2cell(d)])
    for i=1:length(f)
        command=sprintf('du.%s=unique(d.%s(~isnan(d.%s)));',f{i},f{i},f{i})
        disp(f{i})
        eval(command);
    end
    du
    datestr([min(d.date) max(d.date)])
    
subject={'rat_135'};
dateRange=datenum({'Dec.9,2007','16-Dec-2007'}) % where he fails on step 12
d=allToSmall(subject,dateRange,1,0);


if 0
    dateRange=datenum({'Dec.2,2007','13-Dec-2007'}) % step 12 good
    d=allToSmall(subject,dateRange,1,0);
    smallData=d
    stepUsed=12
    peekAtData
    d=removeSomeSmalls(d,(d.step~=12));
    savePath='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\cosyneXfer\';
    save(fullfile(savePath,'135_goodAtStep12.mat'),'d')
end


dateRange=datenum({'Sep.9,2007','16-Feb-2008'}) % all
d=allToSmall(subject,dateRange,1,0);
savePath='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\cosyneXfer\';
save(fullfile(savePath,'135_lifeLog.mat'),'d')
    
    
    m=0; whichPlots= [1 1 0 m 0 m m 1 0 0 0 0 0 0 1 0 1 m]; handles=[1:length(whichPlots)];
    inspectRatResponses(char(subject),'noPathUsed',whichPlots,handles,[],d);
    
    %why is he so good at step 12 at first?  and then why does he give
    %up!?!?! what happened on dec 13th?  it gets all the rats in the lower
    %left box, except the one who is at 90% already... all rats drop
    %performance
    
    %the good rat (137 )licks less per trial on that day, and the oter rats
    %lick MORE
    
    %also see 129 and 130 who 
    
   
    
    
%%

end


%%
if 0
    length(d.info.sessionIDs)
    sessionNum=21;
    type='smallData';
    pathAndName=fullfile(fullfile(getDataStorageIPAndPath, char(subject)),type,['Data.' datestr(d.info.sessionIDs(sessionNum),30) '.mat']);
    x=load(pathAndName, type)
    type='largeData';
    pathAndName=fullfile(getDataStorageIPAndPath, char(subject),type,['Data.' datestr(d.info.sessionIDs(sessionNum),30)],'trialRecords.mat')
    y=load(pathAndName,'trialRecords')

    stimDetails=[y.trialRecords.stimDetails];
    tc=[stimDetails.targetContrast];
    unique(tc)
end
%%


subject={'rat_106'};
dateRange=datenum({'Jun.30,2007','Jul.22,2007'}); % good bounds
%dateRange=datenum({'June.10,2007','Aug.1,2007'}); % too broad to find bounds
d=allToSmall(subject,dateRange,1,0);

%checks
firstDim=datestr(min(d.date(d.targetContrast==.125))) %29-Jun-2007 20:06:40
firstFlankerOffset=datestr(min(d.date(d.deviation==0.0625))) %21-Jul-2007 17:44:47 %should be after
firstFlankerContrast=datestr(min(d.date(d.flankerContrast~=0))) %21-Jul-2007 17:44:27

startID=find(abs(d.date-datenum('29-Jun-2007 20:06:01'))<0.00001);
endID=find(abs(d.date-datenum('21-Jul-2007 17:30:48'))<0.00001);

savePath='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\cosyneXfer\forMCMC';

close all
figure
if startID==1 & endID==length(d.date)
    
    
    goods=getGoods(d);
    dayInd=[1+floor(d.date)-floor(d.date(1))];
    uniqueDays=unique(dayInd);
    values=d.targetContrast;
    uniqueValues=unique(values);
    uniqueValues(uniqueValues==0)=[];
    [conditionInds names]=getFlankerConditionInds(d,[],'onlyTarget');
    colors=jet(size(conditionInds,1))
    format long g
    for day=1:length(uniqueDays)
        for cond=1:size(conditionInds,1)
            attempts=zeros(1,length(uniqueValues));
            pctCorrect=zeros(1,length(uniqueValues));
            which=( values==0) & (dayInd==uniqueDays(day)) & (conditionInds(cond,:) & goods);
            noSigAttemptsPerCondition=max([1 floor(sum(which)/length(uniqueValues))]); %this avoids nans when no noSigs
            crRate=sum(d.correct(which))/sum(which);
            for v=1:length(uniqueValues)
                which=( values==uniqueValues(v)) & (dayInd==uniqueDays(day)) & (conditionInds(cond,:) & goods);
                attempts(v)=sum(which);
                hitRate=(sum(d.correct(which))/sum(which));
                fracSig=attempts(v)/(attempts(v)+noSigAttemptsPerCondition);
                fracNoSig=noSigAttemptsPerCondition/(attempts(v)+noSigAttemptsPerCondition);
                pctCorrect(v)=(fracSig*hitRate)+(fracNoSig*crRate);
                allAttempts(day,cond,v)=attempts(v);
                allPctCorrect(day,cond,v)=pctCorrect(v);
            end
            format long g
            out=[uniqueValues; pctCorrect; attempts]';
            save(fullfile(savePath,sprintf('%s_%d_%s.dat',char(subject),day,names{cond})),'out','-ASCII')
            string='';
            for i=1:length(uniqueValues)
                string=[string sprintf('%s\n',sprintf('%2.3g  \t',out(i,:)))];
            end
            
            %save(fullfile(savePath,sprintf('%s_%d_%s.dat',char(subject),day,names{cond})),'string','-nounicode')
            
            disp(sprintf('******day %d\t cond: %s',uniqueDays(day),names{cond}))
            disp(string)

            %plot(allPctCorrect(day,cond,v))
            [P, PCI] = binofit(pctCorrect.*attempts,attempts);
            subplot(5,5,day)
            h=errorbar(uniqueValues, P, P-PCI(:,1)', PCI(:,2)'-P);
            hold on
            axis([0 1.1 0 1.1])
        end
        set(h,'color',colors(cond,:))
    end
    
    figure
    hold on
    %all vertical
    vAttempt=reshape(sum(allAttempts(:,1,:)),1,length(uniqueValues));
    vNumCorrect=reshape(sum(allAttempts(:,1,:).*allPctCorrect(:,1,:)),1,length(uniqueValues));
    [P, PCI] = binofit(vNumCorrect,vAttempt);
    h=errorbar(uniqueValues, P, P-PCI(:,1)', PCI(:,1)'-P)
    set(h,'color',colors(1,:));
    
    %all horizonal
    hAttempt=reshape(sum(allAttempts(:,2,:)),1,length(uniqueValues));
    hNumCorrect=reshape(sum(allAttempts(:,2,:).*allPctCorrect(:,2,:)),1,length(uniqueValues));
    [P, PCI] = binofit(hNumCorrect,hAttempt);
    h=errorbar(uniqueValues, P, P-PCI(:,1)', PCI(:,1)'-P);
    set(h,'color',colors(2,:))
    
    axis([0 1.1 0 1.1])
    
    
else
    error('wrong bounds')
end


%save test



