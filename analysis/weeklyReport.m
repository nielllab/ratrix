function wholeReport=weeklyReport(subjectsOrRack,includeHeader,saveToDesktop,heatName)
%generates useful text summary of performance for a list of rats
%
%initially created to be used by holly, july 2007, pmm
%modified for use by daniel, june 2008, pmm
%weeklyReport(1)
%weeklyReport({'rat_118'})
%chuckOfReport=weeklyReport(heat,0,0,name)
%afternoon=weeklyReport(uiparams.heats{1}.subjects,1,0,{uiparams.heats{1}.name});


if ~exist('subjectsOrRack','var')
    subjectsOrRack=1;
end

if isnumeric(subjectsOrRack)
    rackID=subjectsOrRack;
    [subjects heatName]=getCurrentSubjects(subjectsOrRack);
else
    subjects=subjectsOrRack;
end

if ~exist('includeHeader','var')
    includeHeader = 1;
end

if ~exist('saveToDesktop','var')
    saveToDesktop = 1;
end

if ~exist('heatName','var')
    heatName = repmat({''},1,size(subjects,2));
end


smoothingWidth=500;

desktopPath=fileparts(fileparts(getRatrixPath));
if exist('rackID','var')
    archivePath=fullfile(  fileparts(getSubDirForRack(rackID)) ,'weeklyReports')
end

wholeReport='';
for j=1:size(subjects,2)
    if includeHeader
        title=sprintf('weeklyReport generated %s',datestr(now,22));
        header1=      '         kT d   h20     trialsPerDay   step-shn     crct        observations';
        header2=      '                        (min/mean/max)  p day(this) (mean/max)    ';
        heatNameLine=['***' heatName{j} '***'];
        %rat_112	 2  5	149	 232/ 360/ 475	p-day(this)	NaN/0.54

        disp(title)
        disp(header1)
        disp(header2)
        disp(heatNameLine)
        wholeReport=[wholeReport title '\n\n' header1 '\n' header2 '\n\n' heatNameLine];
    else
        heatNameLine=['***' heatName{j} '***'];

        disp(heatNameLine)
        wholeReport=[ wholeReport '\n' heatNameLine];
    end

    numSubjects=size([subjects],1);%*size([subjects],2);
    for i=1:numSubjects %perHeat
        subject=subjects{i,j};
        if ~isempty(subject) %make sure a subject was running in that heat in that box
            %get data:
            %OLD:
            %filePathAndName=fullfile(dataStoragePath,subject,'smallData'); load(filePathAndName,'smallData'); d=smallData;

            d=getSmalls(subject,[now-7 now],[],0);
            
            if ~isempty(d) && ismember('date',fields(d)) 
                %choose good trials:
                goods=getGoods(d);
                %get trialsPerDay:
                [trialsPerDay correctPerDay]=makeDailyRaster(d.correct(goods),d.date(goods));
                %getBodyWeights
                %[weights BWdates] = getBodyWeightHistory(subject);

                if  length(trialsPerDay)>4
                    useTrialsPerDay=trialsPerDay(2:end-1); %so that partial days  don't mess with min / mean / max stats
                else
                    useTrialsPerDay=trialsPerDay;
                end
                %get performance:
                smoothingWidthUsed=min([smoothingWidth sum(goods)]);
                [performance colors]=calculateSmoothedPerformances(d.correct(goods)',smoothingWidthUsed,'boxcar','powerlawBW');
                performance=performance(~isnan(performance));
                %get h20 consumption:
                if ismember('actualRewardDuration',fields(d))
                    secondsH20=round(sum(d.actualRewardDuration( ~isnan(d.actualRewardDuration))));
                else
                    secondsH20=nan;
                end
                %get step
                step=max(d.step); stepStr=num2str(step,'%0.2d');
                daysThisStep=num2str(ceil(now)-ceil(min(d.date(d.step==step))));
                if d.step(1)==step
                    daysThisStep=[daysThisStep '+'];
                else
                    daysThisStep=[daysThisStep ' '];
                end
                totalDays=num2str(ceil(now)-ceil(min(d.date)));
                if d.step(1)==1
                    totalDays=[totalDays '+'];
                end
                %write it:
                ratReport=sprintf('%s\t%2.0d %2.0d\t%2.0d\t%4.0d/%4.0d/%4.0d\t%s %s(%s)\t%2.2g/%2.2g\t :',char(subject),round(sum(goods)/1000),length(trialsPerDay),secondsH20,...
                    min(useTrialsPerDay),round(mean(useTrialsPerDay)),max(useTrialsPerDay),...
                    stepStr, daysThisStep, totalDays,...
                    mean(performance),max(performance));
                disp(ratReport)
                wholeReport=[wholeReport '\n' ratReport];
            end % if data
        end %if subject
    end
    includeHeader=0; %turn off header for each heat
end%heat


if saveToDesktop
    reportName='lastWeeklyReport.txt';
    fid = fopen([desktopPath '\' reportName],'wt');
    fprintf(fid,'%s',sprintf (wholeReport));
    fclose(fid);
end

saveForPosterity=1;
if saveForPosterity & exist('rackID','var')
    reportName=sprintf('%s_weeklyReport.txt',datestr(now,30));
    fid = fopen([archivePath '\' reportName],'wt');
    fprintf(fid,'%s',sprintf (wholeReport));
    fclose(fid);
end
