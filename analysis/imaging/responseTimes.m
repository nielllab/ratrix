clear all
files = dir;
dates = [files(3:end).datenum]
[d ind] = sort(dates);


trialCorrect(1:1000) = 0; trialResp(1:1000)=0; trialLapse(1:1000) = 0; nTrials(1:1000)=0;
for i = 1:length(files)-2;
%    for i = 1:10
    i
    load(files(ind(i)+2).name);
    for t = 1:length(trialRecords)-1;
        correct{i}(t) = trialRecords(t).trialDetails.correct;
        for j = 1:3
            phaseTimes(j) = [trialRecords(t).phaseRecords(j).responseDetails.startTime];
        end
        stopTime{i}(t) = phaseTimes(2)-phaseTimes(1);
        respTime{i}(t) = phaseTimes(3)-phaseTimes(2);
        
        if stopTime{i}(t)>60, stopTime{i}(t)=60, end;  %%% place ceiling on dramatic outliers
        if respTime{i}(t)>60, respTime{i}(t)=60, end;
        
        trialCorrect(t) = trialCorrect(t) + correct{i}(t);
        trialResp(t) = trialResp(t) + respTime{i}(t);
        trialLapse(t) = trialLapse(t) + double(respTime{i}(t)>1);
        nTrials(t) = nTrials(t)+1;
        
    end
    
    duration(i) = t;
    allCorrect(i) = mean(correct{i});
    allStop(i) = mean(stopTime{i});
    allResp(i) = mean(respTime{i});
    lapse(i) = sum(respTime{i}>1)/length(respTime{i});
    date(i) = dates(ind(i));
    
    for j = 1:10;
        range = round(((j-1)*t/10 + 1) : j*t/10);
        normCorrect(i,j) = mean(correct{i}(range));
        normResp(i,j) = mean(respTime{i}(range));
        normStop(i,j) = mean(stopTime{i}(range));
        normLapse(i,j) = mean(respTime{i}(range)>1);

    end
    
    
end

day = 1;
dayCorrect(1) = allCorrect(1); dayStop(1) = allStop(1); dayResp(1) = allResp(1); dayLapse(1) = lapse(1);
for i = 2:length(date)
    if date(i)-date(i-1)>0.5
        day = day+1;
        dayCorrect(day) = allCorrect(i); dayStop(day) = allStop(i); dayResp(day) = allResp(i); dayLapse(day) = lapse(i);
    else
        dayCorrect(day) = 0.5*(dayCorrect(day) + allCorrect(i)); dayStop(day) = 0.5*(dayStop(day) + allStop(i)); 
        dayResp(day) = 0.5*(dayResp(day) + allResp(i)); dayLapse(day) = 0.5*(dayLapse(day) + lapse(i));
    end
end

figure
plot(mean(normCorrect,1)); xlabel('session duration'); ylabel('% correct'); ylim([0 1]);

figure
plot(median(normResp,1));xlabel('session duration'); ylabel('response time');

figure
plot(mean(normStop,1));xlabel('session duration'); ylabel('stop time');


figure
plot(median(normLapse,1)); xlabel('session duration'); ylabel('lapse rate');


figure
plot(allCorrect); ylabel('% correct'); xlabel('session');
figure
plot(allStop); ylabel('stopping time'); xlabel('session');
figure
plot(allResp); ylabel('response time'); xlabel('session');
figure
loglog(allResp); ylabel('response time'); xlabel('session');
figure
plot(lapse); ylabel('% lapse trials'); xlabel('session');


figure
plot(dayCorrect); ylabel('% correct'); xlabel('day');
figure
plot(dayStop); ylabel('stopping time'); xlabel('day');
figure
plot(dayResp); ylabel('response time'); xlabel('day');
figure
plot(dayLapse); ylabel('% lapse trials'); xlabel('day');

figure
loglog(dayResp); ylabel('response time'); xlabel('day');


        trialCorrectMn = trialCorrect./nTrials
        trialRespMn = trialResp./nTrials;
        trialLapseMn = trialLapse./nTrials;
        
        figure
        plot(trialCorrectMn); xlabel('trial'); ylabel('correct');
        
        figure
        plot(trialRespMn); xlabel('trial'); ylabel('resp time');
        
         figure
        plot(trialLapseMn); xlabel('trial'); ylabel('lapse rate');

figure


for i = 1:length(ind);
    medianResp(i) = median(respTime{i});
    medianStop(i) = median(stopTime{i});
end

figure
loglog(medianResp); ylabel('median resp time')


