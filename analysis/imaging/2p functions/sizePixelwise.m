load sizeSession_PRE_V2_sm

dFout = dFsm; clear dFsm

%%% calculate timecourse of pixelwise map for each size, sf
clear tcourse
nostim = mean(dFout(:,:,:,radius==1),4);
freqs = [0.04 0.16];
for f = 1:2
    for r = 1:7
        figure
        tcourse(:,:,:,r) = mean(dFout(:,:,:,radius==r & sf==freqs(f)),4)-nostim;
        tcAll(:,:,:,r,f) = tcourse(:,:,:,r);
        for t = 1:15;
            subplot(3,5,t);
            imagesc(tcourse(:,:,t,r)- tcourse(:,:,5,r),[-0.1 0.2]); colormap jet
            axis equal
            axis off
        end
        drawnow
        set(gcf,'Name',sprintf('sz=%d sf=%0.2f',r,freqs(f)));
    end
end

%%% mean timecourse across image for each sf
for f = 1:2;
    figure
    plot(squeeze(mean(mean(tcAll(:,:,:,:,f),2),1)));
    title(sprintf('image mean sf = %0.2f',freqs(f)));
    ylim([-0.02 0.15])
    legend
end

    

%%% plot overlay of vert and horiz (red vs green) as a funciton of size
%%% separately for each sf
t=10;
for f = 1:2
    figure
    for r = 2:7
        subplot(2,3,r-1);
        im = zeros(size(dFout,1),size(dFout,2),3);
        tc = mean(dFout(:,:,t,radius==r & sf==freqs(f) &(theta==0 | theta ==pi) ),4)- nostim(:,:,t);
        im(:,:,1) = (tc + 0.05)/0.3;
        tc = mean(dFout(:,:,t,radius==r & sf==freqs(f)& (theta==pi/2 | theta == 3*pi/2) ),4)- nostim(:,:,t);
        im(:,:,2) = (tc + 0.05)/0.3;
        imshow(im);
        %imagesc(tcourse(:,:,t,r),[-0.1 0.2]); colormap jet
        axis equal; axis off
        set(gcf,'Name',sprintf('ori overlay sf=%0.2f',freqs(f)))
        drawnow
    end
end

%%% overlay low sf and high sf (red and green) for each size
t=10;
figure
for r = 2:7
    subplot(2,3,r-1);
    im = zeros(size(dFout,1),size(dFout,2),3);
    tc = mean(dFout(:,:,t,radius==r & sf==0.04),4)- nostim(:,:,t);
    im(:,:,1) = (tc + 0.05)/0.3;
    tc = mean(dFout(:,:,t,radius==r & sf==0.16),4)- nostim(:,:,t);
    im(:,:,2) = (tc + 0.05)/0.3;
    imshow(im);
    %imagesc(tcourse(:,:,t,r),[-0.1 0.2]); colormap jet
    axis equal; axis off
    set(gcf,'Name','SF overlay')
    drawnow
end



%%% plot timecourse trace centered on stim
xrange = 30:50; yrange = 60:80;
trace = squeeze(mean(mean(tcourse(yrange,xrange,:,:),2),1));
figure
plot(trace)
legend

%%% calculate peak response within a window centered on stim
stimpeak=9; prestim=5;
peak = squeeze(mean(mean(dFout(yrange,xrange,stimpeak,:),2),1))  - squeeze(mean(mean(dFout(yrange,xrange,prestim,:),2),1));
%%% loop over running and radius
for run = 0:1
    for r = 1:7;
        lowsf = peak(radius==r & sf==0.04 & running == run);
        sz(r,1) = mean(lowsf); err(r,1) = std(lowsf)/sqrt(length(lowsf));
        hisf  = peak(radius==r & sf==0.16 & running == run);
        sz(r,2) = mean(hisf); err(r,2) = std(hisf)/sqrt(length(hisf));
    end
    sz = sz-mean(sz(1,:));
    figure
    errorbar(sz,err); legend('0.04cpd','0.16cpd'); xlabel('radius'); title('center pixels');
end

%%% plot response amplitude across the session for small and large stim
%%% to check whether one or the other is adapting over time
figure
hold on
for i = [ 3 6]
    plot(peak(radius==i)-mean(peak(radius==1)));
    ylim([-0.1 0.4])
end
legend('10deg','40deg');xlabel('trial #');
