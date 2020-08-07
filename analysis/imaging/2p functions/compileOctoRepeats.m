%%% load multiple sessions and compare mean responses
%%% ideal for comparing effect of varying a parameter
%%% cmn 2020

clear all

done = 0;
n=0;  %%% #number of files loaded

%%% prepare for pdf
psfile = 'C:\temp\TempFigs.ps';
if exist(psfile,'file')==2;delete(psfile);end


%%% load sessions
while ~done
    
    %%% get filename
    [f p] = uigetfile('*.mat','data file');
    
    if f==0  %% done when you hit cancel
        done=1;
    else
        load(fullfile(p,f),'dFrepeats','stimOrder','stdImg','trialTcourse');
        
        %%% get # of stim and length of stim, to check consistency
        if n==0
            nstim = length(unique(stimOrder));
            stimLength = size(dFrepeats,2);
            stimDur = stimLength/nstim; %%% frames per cycle
        end
        
        %%% check consistency
        if length(unique(stimOrder))~=nstim
            display('wrong # of stimuli');
        elseif size(dFrepeats,2) ~=stimLength
            display('wrong stim length');
            
            %%% if all is good, then add on the data
        else
            n=n+1;
            dF(:,n) = squeeze(median(nanmedian(dFrepeats,3),1));
            for i = 1:nstim
                tc((i-1)*30 + (1:30),n) = nanmedian(trialTcourse(:,stimOrder==i),2);
                pixResp(i,n) = nanmean(tc((i-1)*30 + (1:30),n),1);
                cellResp(i,n) = nanmean(dF((i-1)*stimDur + (1:stimDur),n),1);
            end
            labels{n} = input('data label : ','s');
        end
    end
end


%%% plot cell averages
figure; hold on
cmap = jet(n);
for i = 1:n
    plot(dF(:,i),'Color',cmap(i,:))
end
ylim([-0.05 0.15]); hold on
for i = 1:nstim
    plot([stimDur*i stimDur*i], [-0.1 0.2],'k:')
end
legend(labels); title('cell average')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

% for i = 1:nstim
%     tuning(i,:) = mean(dF((i-1)*stimDur + (1:20),:),1);
% end
% figure
% hold on
% for i = 1:n
%     plot(tuning(:,i),'Color',cmap(i,:))
% end
% ylim([-0.01 0.05]); 
%     
figure
bar(mean(dF,1))
set(gca,'XtickLabel',labels); ylabel('mean dF/F')
title('average over all stim, cells');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% analyze 6x4 spots - separate into on and off and only include 
%%% top 3 stim conditions (to avoid stim locations outside visual field)
if  nstim == 48;
    for i = 1:n
        off = sort(cellResp(1:24,i),'descend');
        meanCellResp(1,i) = nanmean(off(1:3));
        on = sort(cellResp(25:48,i),'descend');
        meanCellResp(2,i) = nanmean(on(1:3));
    end
    figure
    bar(meanCellResp');
    set(gca,'XtickLabels',labels);
    legend({'off','on'}); title('mean cell responses (top 3 stim)')
    xlabel('condition'); ylabel('df/f')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

end


%%% plot pixel averages
figure; hold on
for i = 1:n
    plot(tc(:,i),'Color',cmap(i,:))
end
ylim([-0.05 0.15]); hold on
for i = 1:nstim
    plot([30*i 30*i], [-0.1 0.2],'k:')
end
legend(labels); title('non-weighted pixel average')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

figure
bar(mean(tc,1))
set(gca,'XtickLabel',labels); ylabel('mean dF/F')
title('average over all stim, pixels');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% analyze 6x4 spots - separate into on and off and only include 
%%% top 3 stim conditions (to avoid stim locations outside visual field)
if  nstim == 48;
    for i = 1:n
        off = sort(pixResp(1:24,i),'descend');
        meanPixResp(1,i) = nanmean(off(1:3));
        on = sort(pixResp(25:48,i),'descend');
        meanPixResp(2,i) = nanmean(on(1:3));
    end
    figure
    bar(meanPixResp');
    set(gca,'XtickLabels',labels);
    legend({'off','on'}); title('mean pixel responses (top 3 stim)')
    xlabel('condition'); ylabel('df/f')
   if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
 
end


%%% save pdf
display('saving pdf')
[fPDF, pPDF] = uiputfile('*.pdf','save pdf file');
newpdfFile = fullfile(pPDF,fPDF);
try
    dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
    
catch
    display('couldnt generate pdf');
end

matfile = newpdfFile(1:end-4);
save(matfile,'dF','tc','nstim','stimDur','labels');


