clear all
files = dir;
for i = 1:length(files)-2;
   % for i = 1:3
    i
    load(files(i+2).name);
    for t = 1:length(trialRecords)-1;
        correct{i}(t) = trialRecords(t).trialDetails.correct;
        for j = 1:3
            phaseTimes(j) = [trialRecords(t).phaseRecords(j).responseDetails.startTime];
        end
        stopTime{i}(t) = phaseTimes(2)-phaseTimes(1);
        respTime{i}(t) = phaseTimes(3)-phaseTimes(2);
    end
    allCorrect(i) = mean(correct{i});
    allStop(i) = mean(stopTime{i});
    allResp(i) = mean(respTime{i});
    lapse(i) = sum(respTime{i}>1)/length(respTime{i});
    
end
dates = [files(3:end).datenum]
[d ind] = sort(dates);

figure
plot(allCorrect(ind)); ylabel('% correct'); xlabel('day');
figure
plot(allStop(ind)); ylabel('stopping time'); xlabel('day');
figure
plot(allResp(ind)); ylabel('response time'); xlabel('day');

figure
loglog(allResp(ind)); ylabel('response time'); xlabel('day');

figure

for i = 1:length(ind);
    loglog(ind(i)*ones(size(respTime{i})),respTime{i},'.');
    hold on
end


figure
plot(lapse(ind)); ylabel('% lapse trials'); xlabel('day');

for i = 1:length(ind);
    noLapse(i) = mean(respTime{i}(respTime{i}<1));
end
figure
loglog(noLapse(ind)); ylabel('response time'); xlabel('day');
