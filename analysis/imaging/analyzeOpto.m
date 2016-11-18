function [respAll timeAll] = analyzeOpto(filename, figtitle)%%% analyze behavior performance with laser stimulation
%%% 2AFC location-based task
%%% can analyze by orientation for orientation task (commented out)


%%% read in behav data
if ~exist('filename','var')
    [f p]= uigetfile('*.mat');
    filename = fullfile(p,f);
end

if ~exist('figtitle','var');
    figtitle = '';
end

load(filename,'trialRecords');

%%% parse out records
for i = 1:length(trialRecords)-1;
    rec = trialRecords(i);
    correct(i) = rec.trialDetails.correct;  %%% correct or not
    resptime(i) = rec.phaseRecords(3).responseDetails.startTime - rec.phaseRecords(2).responseDetails.startTime ;  %%% response time
    loc(i) = sign(rec.stimDetails.subDetails.xPosPcts - 0.5);  %%% stimulus location
    orient(i) =  rec.stimDetails.subDetails.orientations;  %%% stimulus orientation
    laser(i) = rec.stimDetails.subDetails.laserON;  %%% laser on?
    if correct(i)        %%% figure response (left vs right)
        resp(i) = loc(i);
    else
        resp(i) = -loc(i);
    end
end

%%% get percent rightward responses for each stim location, laser on off;
%%% use binofit to get binomial distribution 95% confidence intervals
[respAll(1,1) errAll(1,1,:)] = binofit(sum(resp(loc<0 & ~laser)==1),sum(loc<0 & ~laser));
[respAll(2,1) errAll(2,1,:)] = binofit(sum(resp(loc>0 & ~laser)==1),sum(loc>0 & ~laser));
[respAll(1,2) errAll(1,2,:)] = binofit(sum(resp(loc<0 & laser)==1),sum(loc<0 & laser));
[respAll(2,2) errAll(2,2,:)] = binofit(sum(resp(loc>0 & laser)==1),sum(loc>0 & laser));

%%% uncomment to analyze based on orientation
% [respAll(1,1) errAll(1,1,:)] = binofit(sum(resp(orient==0 & ~laser)==1),sum(orient==0 & ~laser));
% [respAll(2,1) errAll(2,1,:)] = binofit(sum(resp(orient>0 & ~laser)==1),sum(orient>0 & ~laser));
% [respAll(1,2) errAll(1,2,:)] = binofit(sum(resp(orient==0 & laser)==1),sum(orient==0 & laser));
% [respAll(2,2) errAll(2,2,:)] = binofit(sum(resp(orient>0 & laser)==1),sum(orient>0 & laser));


%%% convert confidence intervals to error bar size
errAll(:,:,1) = respAll-errAll(:,:,1);
errAll(:,:,2) = errAll(:,:,2)- respAll;

%%% plot psychometric curve
figure
errorbar([0.98 1.98], respAll(:,1),errAll(:,1,1),errAll(:,1,2),'ko-'); hold on;    errorbar([1.02 2.02], respAll(:,2),errAll(:,2,1),errAll(:,2,2),'bo-');
ylim([0 1]); plot([1 2],[0.5 0.5],'k:');
legend({'off','on'})
ylabel('fraction left'); set(gca,'Xtick',[1 2]); set(gca,'Xticklabel',{'top','bottom'}); title(figtitle);

%%% bar graph of response time
clear timeAll
timeAll(1) = median(resptime(~laser)); err(1) = std(resptime(~laser))/sqrt(sum(~laser));
timeAll(2) = median(resptime(laser));err(2) = std(resptime(laser))/sqrt(sum(laser));
figure
errorbar(1,timeAll(1),err(1),'ko'); hold on; errorbar(2,timeAll(2),err(2),'bo'); plot([1 2],timeAll);
ylabel('median resp time');set(gca,'Xtick',[1 2]); set(gca,'XtickLabel',{'off','on'}); ylim([ 0 1]);title(figtitle);

