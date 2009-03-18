function  analyzeGaze(subjectID,dateRange,downSampleBy)
%check analyzeLastGaze to improve this function
%toDo: check assumptions, add histograms

if ~exist('subjectID','var')
    subjectID='test_rig1b';
end

if ~exist('dateRange','var')
    dateRange=[now-2 now];
end

if ~exist('downSampleBy','var')
    downSampleBy=5;
end

rackID=101; %the only rack with eyeTracking currently
compileTrialRecords(rackID);
d=getSmalls(subjectID,dateRange,rackID);
%d=removeSomeSmalls(d,~getGoods(d));  %turn on for rat data, turn off for human tests
[desiredFiles eyeDataPath]=getEyeDataFiles(subjectID,d.trialNumber);

figure; hold on
title(sprintf('gaze for %s trial %d-%d',subjectID,min(d.trialNumber),max(d.trialNumber)))
numIncorrectPlotted=0;
numCorrectPlotted=0;

%plot incorrects
for trialInd=(find(d.correct==0))
    if ~isempty(desiredFiles{trialInd})

        e=load(fullfile(eyeDataPath,desiredFiles{trialInd}));
        [px py crx cry x y]=getPxyCRxy(e,downSampleBy);
        plot(x,y,'r.');% plot(px-crx,py-cry,'r.');
        disp(sprintf('doing %d of %d',d.trialNumber(trialInd), max(d.trialNumber)));
        %[correctCount] = hist3([(px-crx)' (py-cry)'],'ctrs',{Xs,Ys})
        %totalCorrectCount=totalCorrectCount+correctCount;
        numIncorrectPlotted=numIncorrectPlotted+1;
    end
end

%plots corrects
for trialInd=(find(d.correct==1))
    if ~isempty(desiredFiles{trialInd})

        e=load(fullfile(eyeDataPath,desiredFiles{trialInd}));
        [px py crx cry x y]=getPxyCRxy(e,downSampleBy);
        plot(x,y,'g.');% plot(px-crx,py-cry,'g.')
        disp(sprintf('doing %d of %d',d.trialNumber(trialInd), max(d.trialNumber)));
        %[incorrectCount] = hist3([(px-crx)' (py-cry)'],'ctrs',{Xs,Ys})
        %totalIncorrectCount=totalIncorrectCount+incorrectCount;
        numCorrectPlotted=numCorrectPlotted+1;
    end

end

%correctPDF=totalCorrectCount/sum(totalCorrectCount(:))
%incorrectPDF=totalIncorrectCount/sum(totalIncorrectCount(:))
%imagesc(correctPDF-incorrectPDF)

legend({sprintf('%d trials',numIncorrectPlotted),sprintf('%d trials',numCorrectPlotted)})

function [desiredFiles eyeDataPath]=getEyeDataFiles(subjectID,trialNumbers)

eyeDataPath= fullfile(fileParts(fileParts(getRatrixPath)),'ratrixData','eyeData',subjectID);

d=dir(eyeDataPath);
desiredFiles=repmat({[]},length(trialNumbers),1);

for i=1:length(d)
    if ~ismember(d(i).name,{'.','..'})
        [scanned,COUNT,ERRMSG,NEXTINDEX] = sscanf(d(i).name,'eyeRecords_%d_%dT%d.mat',3);
        if length(scanned)<1
            %             d(i).name
            %             scanned=scanned
            %             COUNT=COUNT
            %             ERRMSG=ERRMSG
            %             NEXTINDEX=NEXTINDEX
            warning(sprintf('skipped %s b/c its not a .mat',d(i).name) )
        end

        if ~d(i).isdir %avoid folders
            if length(scanned)>=1 %avoid things that don't match like 'eyeSessionData_108_20080701T032530.edf'
                thisTrial=scanned(1); %set trial
                if ismember(thisTrial,trialNumbers)

                    desiredFiles{find(thisTrial==trialNumbers)}=d(i).name;
                    %             startLoad=getSecs;
                    %             e=load(fullfile(getEyeDataPath(eyeTracker),desiredFiles{end}));
                    %             loadTimes(end+1)=getSecs-startLoad;
                    %
                    %             startLoad=getSecs;
                    %             e2=load(fullfile(getEyeDataPath(eyeTracker),desiredFiles{end}),'gaze');
                    %             loadMiniTimes(end+1)=getSecs-startLoad;
                    %
                end
            end
        end
    end
end




