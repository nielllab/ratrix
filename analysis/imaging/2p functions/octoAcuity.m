%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all; clear all

%%% select files to analyze based on compile file
stimname = 'sin gratings';
[sbx_fname acq_fname mat_fname] = compileFilenames('For Batch File.xlsx',stimname);

% %%% selectall files in directory
% files = dir('*.mat');
% for i = 1:nfiles
%     mat_fname{i} = files(i).name;
% end


nfiles = length(mat_fname);

for f = 1:nfiles
    
    %%% read in weighted timecourse (from pixelmap, weighted by baseline fluorescence
    load(mat_fname{f},'stimOrder','weightTcourse')

    for c = 1:17;  %%% loop over conditions
        %%% timecourse of response
        resp(c,:) = nanmedian(weightTcourse(:,stimOrder==c),2);
        %%% amplitude of response over timewindow
        amp(c,f) = nanmean(resp(c,9:20),2);
    end

    %%%% average across orientations (4) for each sf
    for sf = 1:4;
        tuning(sf+1,f) = nanmean(amp(sf:4:end,f));
        sfResp(sf+1,:,f) = nanmean(resp(sf:4:end,:),1);
    end
    
    %%% get fullfield flicker (last stim cond)
    tuning(1,f) = amp(end);
    sfResp(1,:,f) = resp(end,:);
%    
%     figure
%     plot(sfResp(:,:,f)'); title(mat_fname{f});
    figure
    plot(tuning(:,f))
    title(mat_fname{f}); ylim([0 0.05])
    xlabel('SF'); ylabel('resp')
end


figure
plot(mean(resp,3)')
figure
plot(1:5,tuning);

figure
plot(mean(sfResp,3)'); title('resp vs SF')

figure
hold on
plot(2:5,mean(tuning(2:end,:),2),'bo')
errorbar(2:5,mean(tuning(2:end,:),2), std(tuning(2:end,:),[],2)/sqrt(nfiles),'k');
plot(1.5,mean(tuning(1,:),2),'bo')
errorbar(1.5,mean(tuning(1,:),2), std(tuning(1,:),[],2)/sqrt(nfiles),'k');

ylabel('mean dF/F');xlabel('cyc / deg'); title('SF tuning')
set(gca,'Xtick',[ 1.5 2:5]);
set(gca,'XtickLabel',{'0','0.005','0.02','0.08','0.32'});
xlim([1 5.5])