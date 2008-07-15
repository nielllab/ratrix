%this function anlayzes all trials to date in the ratrix and draws a
%"Matrix" -esq image of the trial and step numbers

clear all


    
%% get all the data
racks=[1,2];
D=[];

for i=racks
    %dir=getCompiledDirForRack(i) % could get ALL historical...

    subjects=getCurrentSubjects(i); % only the current ones
    subjects=unique(subjects);
    for j=1:length(subjects)
        d=getSmalls(subjects{j},[],i);

        %add ID
        id=str2num(subjects{j});
        if isempty(id) % all the letters and tests
            id=99;
        end
        d.subject=id*ones(size(d.date))

        %remove surplus fields for memory reasons
        surplus={'currentShapedValue','flankerPosAngle','stdGaussMask','redLUT','correctResponseIsLeft',...
            'targetContrast','targetOrientation','flankerContrast','flankerOrientation','deviation','targetPhase',...
            'flankerPhase','pixPerCycs'};
        d=rmfield(d,intersect(surplus,fields(d)));

        %put em all together
        D=combineTwoSmallDataFiles(D,d,Inf)
    end
end

%% remove bad trials and sort

[junk inds] = sort(D.date,2,'ascend');
D=sortSmallData(D,inds);
D=removeSomeSmalls(D,~(getGoods(D) | getGoods(D,'justCorrectionTrials'))); %keeps CTS
D=removeSomeSmalls(D,D.subject==99);



%% get events at an index ad draw them: example # trials at one million 
figure; hold on

eventFont=12;
bLen=2000; %block length for chuncked anlayis, 1 block = 1 number in matrix
maxTrialsViewed=100000; %to view an interesting range
bottom=maxTrials./bLen;


%function postEventVec=findTrialAfterEvent(D,eventInds)
eventInds=1000000;%*[1 2];
subjects=unique(D.subject);
postEventVec=nan(length(subjects),length(eventInds));
for j=1:length(eventInds)
    afterEvent=zeros(size(D.date));
    afterEvent(eventInds(j)+1:end)=1;
    for i=1:length(subjects)
        postEvent=min(find(D.subject==subjects(i) & afterEvent))
        if isempty(postEvent) || postEvent==min(find(D.subject==subjects(i)))
            %don't include it it if its the first trial for the subject
            %or if its not existing
        else
            postEventVec(i,j)=postEvent; %save history
            trailsByThen=(sum(   (D.subject==subjects(i) & ~afterEvent)  ))
            t=text(i,-trailsByThen/bLen,num2str(trailsByThen));
            set(t,'Color',[.6 .8 .6],'FontSize',eventFont);
        end
    end
end


%% draw it

for i=1:length(subjects)
    %this is a little silly
    d=removeSomeSmalls(D,D.subject~=subjects(i));
    numTrials=length(d.date);

    bEnd=min(numTrials-mod(numTrials,bLen),maxTrialsViewed);
    blockStarts=[1:bLen:bEnd];
    blockEnds=[bLen:bLen:bEnd];
    for j=1:length(blockStarts)
        step=max(d.step(blockStarts(j):blockEnds(j)));
        val=num2str(step);
        t=text(i,-j,val);
        disp([subjects(i) i j step])
        %green intensity coded by pct correct
        perf=mean(d.correct(blockStarts(j):blockEnds(j)));
        intensity=max([0 (perf-.5)*2]);
        set(t,'Color',[0 intensity 0]);
    end
end

axis([0 length(subjects)+1 -bottom 0])
set(gca,'Color',[0 0 0])
set(gcf,'Color',[0 0 0])
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])

%% add info box
infoFont=13;
infoFractionTop=.85;
infoFractionLeftMargin=3/4;
nextLineFraction=0.04;

t=text(length(subjects)*infoFractionLeftMargin,-bottom*(infoFractionTop+(0*nextLineFraction)),sprintf('# rats daily: %s',num2str(length(subjects))))
set(t,'Color',[.6 .8 .6],'FontSize',infoFont);

%last 2 weeks
numDays=14;
avgTrailsPerDay=sum((D.date(end)-D.date)<numDays)/numDays
t=text(length(subjects)*infoFractionLeftMargin,-bottom*(infoFractionTop+(1*nextLineFraction)),sprintf('trials/day:   %s kT',num2str(avgTrailsPerDay/1000,'%2.0f')))
set(t,'Color',[.6 .8 .6],'FontSize',infoFont);

t=text(length(subjects)*infoFractionLeftMargin,-bottom*(infoFractionTop+(2*nextLineFraction)),sprintf('total trials:   %s MT',num2str(length(D.date)/1000000,'%2.1f')))
set(t,'Color',[.6 .8 .6],'FontSize',infoFont);

%% save
m=getFrame(gcf);
path='C:\Documents and Settings\rlab\Desktop'
imwrite(m.cdata, fullfile(path,'megaLick.bmp'), 'bmp')