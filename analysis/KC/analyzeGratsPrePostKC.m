%% analyzeGratsPrePostKC
close all
clear all
dbstop if error
warning off

savename = 'calb2ck2g6h47RT_DiffPeaksSpatial' %pdf file name
pathname = 'F:\Kristen\Widefield' %location you want PDF saved

%create a temp file for pdf generation
psfilename = fullfile(pathname,'tempWF.ps'); 
if exist(psfilename,'file')==2;delete(psfilename);end

[prefile p] = uigetfile('*.mat','select PRE file');
cd(p)
[postfile p] = uigetfile('*.mat','select POST file');
fnames = {prefile,postfile}; % why need this?
mycol = {'k','r'}; %colors for plotting
areas = {'V1','LM','AL','RL','AM','PM','MM'}; %labels for the different areas
pltrange = [0 0.01]; %colormap range for plotting images
pplabel = {'pre','post'}; %label for pre/post for graphing

load('F:\Kristen\CrisPts.mat') %selected points for looking at cycle averages for each area
load('C:\mapOverlay5mm.mat') %borders of visual areas for plotting <-- where is this stored?
ptsrange = 2; %number of points to average over around points for each area
dt=0.1; %time between imaging frames
f1 = figure;f2 = figure; %initialize figures
cnt=1; %counter to plot pixel-wise responses
for f = 1:length(fnames) % for both files/2 times
    clear cycavg tuningall % clear existing versions of these variables
    load(fullfile(p,fnames{f}),'cycavg','tuningall') %building a full file name from parts & loading in variables from that file
    if length(size(cycavg))==4 % case with a group (if there's a group, the last dimension is #animals)
        semcycavg = std(cycavg,[],4)/sqrt(size(cycavg,4)); % <-- KC: why the brackets? why 4? 
        cycavg = mean(cycavg,4);
    else %case with an individual animal
        semcycavg = zeros(size(cycavg));
    end
    
    if ~exist('spatials','var') %use this to store responses per spatial location pre/post
        spatials = zeros(size(tuningall,1),size(tuningall,2),size(tuningall,3),size(tuningall,4),2);
    end
    
    cycavg = circshift(cycavg,5,3); %not sure why this was here...
    figure(f1)
    for i = 1:length(x) %loop through all the visual areas
        subplot(2,round(length(x)/2)+1,i)
        hold on
        im = cycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:); %calculate trace for that vis area
        im = squeeze(mean(mean(im,2),1)); %average and squeeze it so it's 2D
        im = im-(mean(im(1:2)));
        sim = semcycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);%calc standard error of the trace
        sim = squeeze(mean(mean(sim,2),1));
        sim = sim-(mean(sim(1:2)));
        shadedErrorBar(0:dt:length(im)*dt-dt,im,sim,mycol{f},1)%plot mean and sem
        axis([0 length(im)*dt-dt -0.05 0.05])
        ylabel(sprintf('%s dfof',areas{i})) %label which area it is
        xlabel('time (s)')
        axis square
    end
    subplot(2,round(length(x)/2)+1,length(x)+f)
    colormap jet
    im = mean(cycavg(:,:,6:8),3)-mean(cycavg(:,:,1:2),3);
    imagesc(im,pltrange)
    hold on; plot(ypts,xpts,'w.','Markersize',2);
    for i = 1:length(x)
        plot(y(i),x(i),'g.','MarkerSize',5)
    end
    axis image
    axis off
    title(pplabel{f})
    
    figure(f2)
    colormap jet
    for i = 4:10
        subplot(2,7,cnt)
        im = squeeze(cycavg(:,:,i));
        imagesc(im,pltrange)
        hold on; plot(ypts,xpts,'w.','Markersize',2);
        axis image
        axis off
        cnt=cnt+1;
    end
    
    
    figure; %show peak response/spatial location
    load(fullfile(p,fnames{f}),'cycavg','tuningall') % KC added this 2-14-20
    for i = 1:size(tuningall,3)
        for j=1:size(tuningall,4)
            subplot(size(tuningall,4),size(tuningall,3),size(tuningall,3)*(j-1)+i)
            im = squeeze(mean(mean(mean(tuningall(:,:,i,j,:,:,:),6),5),7));
            spatials(:,:,i,j,f) = im;
            imagesc(im,[0 0.08]); colormap jet
%             title(sprintf('%0.2f %0.2f',xrange(i),yrange(j)))
            %axis off; 
            axis equal  %%% axis equal is cropping?!
            hold on; plot(ypts/4,xpts/4,'k.','Markersize',2)
            set(gca,'LooseInset',get(gca,'TightInset'))
            axis off
        end
    end
    mtit(sprintf('%s peak response/spatial location',pplabel{f}))
    %append plot pdf temp file
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
end
figure(f2)
mtit('pre (top) vs. post (bottom) cycle average')
%append plot pdf temp file
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end
figure(f1)
%legend('pre','post')
mtit('cycle averages for each visual area')
%append plot pdf temp file
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

figure
for i = 1:size(tuningall,3)
    for j=1:size(tuningall,4)
        subplot(size(tuningall,4),size(tuningall,3),size(tuningall,3)*(j-1)+i)
        im = spatials(:,:,i,j,2)-spatials(:,:,i,j,1);
        imagesc(im,[-0.025 0.025]); colormap jet
%             title(sprintf('%0.2f %0.2f',xrange(i),yrange(j)))
        %axis off; 
        axis equal  %%% axis equal is cropping?!
        hold on; plot(ypts/4,xpts/4,'k.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
        axis off
    end
end
colorbar
mtit('post-pre response/spatial location')
%append plot pdf temp file
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

%save the pdf
try
    dos(['ps2pdf ' psfilename ' "' savename '.pdf' '"'])
    delete(psfilename);
catch
    disp('couldnt generate pdf');
    keyboard
end