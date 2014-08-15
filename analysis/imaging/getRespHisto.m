batchBehavNew;
close all
alluse = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6') &  strcmp({files.task},'HvV_center') &strcmp({files.spatialfreq},'100') & strcmp({files.subj},'g62b7lt'))
subj=unique({files(alluse).subj})
for f= 1:length(alluse)
  f
  if ~isempty(files(alluse(f)).behav) & exist([pathname files(alluse(f)).behav],'file')
         load([pathname files(alluse(f)).behav],'starts','correct');

         correct = double(correct);
resp_time = starts(3,:)-starts(2,:);
    stop_time = starts(2,:)-starts(1,:);

    figure
    plot(resp_time);ylim([0 1]);
    hold on
    plot(conv(correct,ones(50,1)/50,'same'),'g');
    
    
    percentCorrect(f) = mean(correct);

    
    clear histcorrect histresp
    for d = 1:15;
        histcorrect(d) = mean(correct(resp_time>(d-1)/10 & resp_time<d/10));
        histresp(d) = length(correct(resp_time>(d-1)/10 & resp_time<d/10));
    end
    histcorrect(d+1) = mean(correct(resp_time>d/10 & resp_time<5)); %%% <5 to eliminate timeouts
    histresp(d+1) = sum(resp_time>d/10);
    ntrials(f) = sum(histresp);
    histresp = histresp/sum(histresp);
    
    respall(f,:) = histresp;
    correctall(f,:) = histcorrect;
     else
     end
end

figure
hbins = 25:50:500;
h = hist(ntrials,hbins)
bar(hbins,h)
set(gca,'Xtick',0:100:500)
ylim([0 max(h)+1]);
xlabel('# of trials / session')

figure
plot((1:length(histresp))/10 -0.05,respall');
ylabel('% of trials');
hold on
plot((1:length(histresp))/10 -0.05,mean(respall),'g', 'Linewidth',2);

figure
errorbar((1:length(histresp)-1)/10 -0.05,mean(respall(:,1:end-1)),std(respall(:,1:end-1))/sqrt(length(alluse)),'-o');
ylabel('% of trials');
hold on
errorbar((length(histresp))/10 -0.05,mean(respall(:,end)),std(respall(:,end))/sqrt(length(alluse)),'-o')

figure
plot((1:length(histresp))/10 -0.05,correctall');
ylabel('% of trials');
hold on
plot((1:length(histresp))/10 -0.05,nanmean(correctall),'g', 'Linewidth',2);

correctallnonan = correctall; correctallnonan(isnan(correctallnonan))=0.5;
figure
errorbar((1:length(histresp)-1)/10 -0.05,nanmean(correctall(:,1:end-1)),std(correctallnonan(:,1:end-1))/sqrt(length(alluse)),'-o');
ylabel('% correct');
hold on
errorbar((length(histresp))/10 -0.05,mean(correctall(:,end)),std(correctallnonan(:,end))/sqrt(length(alluse)),'-o')
plot([0 1.6],[0.5 0.5],'--')
    