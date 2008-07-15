function analysisDaemon()
clc

%settings
verbose=1;
checkFrequencySecs=10; %60
dailyCheckTime=6; % 24 hr, keep greater than 0.5hr
weeklyCheckDay='Mon';
weeklyResetDay='Tue';

%initialize
hasDoneDaily=0;
hasDoneWeekly=0;
keepRunnig=1;
checkNum=0;

startTime=now;
while keepRunnig
    %analysis if the right time
    if 24*(now-floor(now))>dailyCheckTime
        if ~hasDoneDaily
            doDaily(verbose);
            hasDoneDaily=1;
            if strcmp(datestr(now,'ddd'),weeklyCheckDay)
                doWeekly(verbose);
                hasDoneWeekly=1;
            end
        end
    end

    %reset to virgin
    if 24*(now+0.5-floor(now))>0 & 24*(now-floor(now))<2*(checkFrequencySecs/(60*60))
        hasDoneDaily=0;
        if strcmp(datestr(now,'ddd'),weeklyResetDay)
            hasDoneWeekly=0;
        end
    end

    WaitSecs(checkFrequencySecs);
    checkNum=checkNum+1;
    if verbose
        if rand<0.002
            disp(sprintf('check number %d, after %d hrs',checkNum,(now-startTime)*24))
        end
    end
end

function doDaily(verbose)
if verbose
    disp(sprintf('doing daily analysis at %s',datestr(now)))
end

subjects=getCurrentSubjects';
dateRange=[now-9999 now];
suppressUpdates=0;
forceSmallDataUpdate=0;


% dateRange=[now-8 now];
% suppressUpdates=1;
% forceSmallDataUpdate=0;
junk=allToSmall(subjects(:),dateRange,suppressUpdates,forceSmallDataUpdate);



function doWeekly(verbose)
if verbose
    disp(sprintf('doing weekly analysis at %s',datestr(now)))
end

subjects=getCurrentSubjects';
includeHeader=1;
saveToDesktop=1;
wholeReport=weeklyReport(subjects(:),includeHeader,saveToDesktop,'daemonReport-all male rats');
%email weekly report
