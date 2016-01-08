function [ph amp alldata fit cycavg tuning sftcourse trialcycavg trialcycavgRun trialcycavgSit] = analyzeGratingPatch(dfof_bg,sp,moviename,useframes,base,xpts,ypts, label,stimRec,psfilename,frameT);
%load(fname,'dfof_bg');
%close all


timingfig = figure;
subplot(2,2,1)
plot(diff(stimRec.ts));
xlabel('frame')
title('stim frames')

subplot(2,2,2)
plot(diff(frameT));
xlabel('frame')
title('acq frames')

subplot(2,2,3)
plot((stimRec.ts-stimRec.ts(1))/60,(stimRec.ts' - stimRec.ts(1)) - (1/60)*(0:length(stimRec.ts)-1));
hold on
plot((frameT-frameT(1))/60,(frameT' - frameT(1)) - 0.1*(0:length(frameT)-1),'g');
legend('stim','acq')
ylabel('slippage (secs)')
xlabel('mins')

sf=0; tf=0; isi=0; duration=0;

load(moviename)

imagerate=10;

imageT=(1:size(dfof_bg,3))/imagerate;
img = imresize(double(dfof_bg),1,'method','box');

trials = length(sf)-1;
trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1)
xpos=xpos(1:trials); ypos=ypos(1:trials); sf=sf(1:trials); tf=tf(1:trials);
% tic
% img=deconvg6s(dfof_bg,1/imagerate);
% toc
% trials=trials-1;

acqdurframes = (duration+isi)*imagerate; %%% length of each cycle in frames;
nx=ceil(sqrt(acqdurframes+1)); %%% how many rows in figure subplot

%%% mean amplitude map across cycle
figure
map=0;
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,(f+trials*acqdurframes/2):acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.02 0.02])
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    map = map+squeeze(cycavg(:,:,f))*exp(2*pi*sqrt(-1)*(0.5 +f/acqdurframes));
end

%%% add timecourse
subplot(nx,nx,f+1)
plot(squeeze(mean(mean(cycavg,2),1)))
axis off
set(gca,'LooseInset',get(gca,'TightInset'))


if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%% calculate phase of cycle response
%%% good for detectime framedrops or other problems
tcourse = squeeze(mean(mean(img,2),1));

fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(10*duration + 10*isi));
figure(timingfig)
subplot(2,2,4)
plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
ylim([-pi pi])
ylabel('phase'); xlabel('mins')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

meandf = squeeze(mean(mean(img,2),1));

%%% separate responses by trieals
speedcut = 500;
trialdata = zeros(size(img,1),size(img,2),trials+2);
trialspeed = zeros(trials+2,1);
shift = (duration+isi)*imagerate;
trialcyc = zeros(size(img,1),size(img,2),shift-10,trials+2);
for tr=1:trials;
    t0 = round((tr-1)*(duration+isi)*imagerate);
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
    try
        trialspeed(tr) = mean(sp(useframes+t0));
    catch
        trialspeed(tr)=500;
    end
    trialcourse(tr,:) = squeeze(mean(mean(img(:,:,t0+(1:18)),2),1));
    trialcyc(:,:,:,tr) = img(:,:,t0+10+(1:15));  
end

%%% get responses by averaging (this is simple method)
figure
set(gcf,'Name',label);
if length(unique(xpos))>1
    subplot(2,2,1)
    [ph(:,:,1) amp(:,:,1) xtuning] = getPixelTuning(trialdata,xpos,'X',[1 length(unique(xpos))],hsv);
end
if length(unique(ypos))>1
    subplot(2,2,2)
    [ph(:,:,2) amp(:,:,2) ytuning] = getPixelTuning(trialdata,ypos,'Y',[1 3],hsv);
end
if length(unique(sf))>1
    subplot(2,2,3)
    [ph(:,:,3) amp(:,:,3) sftuning] = getPixelTuning(trialdata,sf,'SF', [1 length(unique(sf))],jet);
end
if length(unique(tf))>1
    subplot(2,2,4)
    [ph(:,:,4) amp(:,:,4) tftuning] = getPixelTuning(trialdata,tf,'TF',[1 length(unique(tf))],jet);
end

if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end


spd = tf./sf;
spd(tf==0)=0;
spd(sf==0)=0;
unique(spd)
spd(spd==0)=1.6;
spd=log(spd);
figure
if length(unique(spd))>1
    [ph(:,:,5) amp(:,:,5) tftuning] = getPixelTuning(trialdata,spd,'speed',[3 7],jet);
end
close (gcf)

xrange = unique(xpos); yrange=unique(ypos); sfrange=unique(sf); tfrange=unique(tf);
tuning=zeros(size(trialdata,1),size(trialdata,2),length(xrange),length(yrange),length(sfrange),length(tfrange));
cond = 0;

if length(xrange)==4 && length(tfrange)==1;
    bkgrat =1;
else
    bkgrat=0;
end

bkgrat

if bkgrat
    for i = 1:2
        blank = find(xpos==xrange(end) & sf == sfrange(i) );
        patch = find(xpos==xrange(2) & sf == sfrange(i));
        blankstart = floor((blank-1)*(duration+isi)*imagerate + isi*imagerate -1);
        patchstart = floor((patch-1)*(duration+isi)*imagerate +isi*imagerate-1);
        for f = 1:acqdurframes
            blankcyc(:,:,f) = mean(img(:,:,blankstart+f),3);
            patchcyc(:,:,f) =  mean(img(:,:,patchstart+f),3);
        end
        cycavg(:,:,(1:acqdurframes)+ (i-1)*2*acqdurframes) = blankcyc;
        cycavg(:,:,((acqdurframes+1):2*acqdurframes) + (i-1)*2*acqdurframes) = patchcyc;
        
    end
end


%%% show blank stim for bkgrat
if bkgrat
    figure
    for k=1:length(sfrange);
        blankMap(:,:,k) =squeeze(median(trialdata(:,:,find(xpos==xrange(4)& sf==sfrange(k))),3));
        subplot(1,2,k);
        imagesc(blankMap(:,:,k));axis equal
        title(sprintf('blank stim sf = %0.2f',sfrange(k)));
    end
    
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    
end

%%% separate out responses by stim parameter
run = find(trialspeed>=speedcut);
sit = find(trialspeed<speedcut);
cond=0;
trialcycavg=zeros(size(img,1),size(img,2),shift-10,length(xrange),length(yrange),length(sfrange),length(tfrange));
trialcycavgRun=zeros(size(img,1),size(img,2),shift-10,length(xrange),length(yrange),length(sfrange),length(tfrange));
trialcycavgSit=zeros(size(img,1),size(img,2),shift-10,length(xrange),length(yrange),length(sfrange),length(tfrange));
for i = 1:length(xrange)
    i
    for j= 1:length(yrange)
        for k = 1:length(sfrange)
            for l=1:length(tfrange)
                cond = cond+1;
                inds = find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l));
                avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l))),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
                if bkgrat  %%% subract blank for bkgrat
                    avgtrialdata(:,:,cond)=avgtrialdata(:,:,cond)-blankMap(:,:,k);
                end
                avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)),:),1));
                avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
                avgspeed(cond)=0;
                avgx(cond) = xrange(i); avgy(cond)=yrange(j); avgsf(cond)=sfrange(k); avgtf(cond)=tfrange(l);
                tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
                meanspd(i,j,k,l) = squeeze(mean(trialspeed(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))>500));
                trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
                trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
                trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
            end
        end
    end
end

%%% plot response based on previous trial's response
%%% this is a check for whether return to baseline is an issue
figure
plot(avgcondtrialcourse(:,1)-avgcondtrialcourse(:,10),avgcondtrialcourse(:,15)-avgcondtrialcourse(:,10),'o');
xlabel('pre dfof'); ylabel('post dfof')

%tdata = imresize(trialdata,0.25);
tdata = imresize(avgtrialdata,1);
%gcp

tic
for i = 1:size(tdata,1);
    i
    if length(tfrange)==4
        for j = 1:size(tdata,2);
            [xfit(i,j)  yfit(i,j) sffit(i,j) tffit(i,j) gainfit(i,j) ampfit(i,j) basefit(i,j) fit(i,j,:)] = fit3x2ysftf(squeeze(tdata(i,j,1:length(avgx))),avgx,avgy,avgsf,avgtf,avgspeed);
        end
    elseif bkgrat
        for j = 1:size(tdata,2);
            [xfit(i,j)  yfit(i,j) sffit(i,j) tffit(i,j) gainfit(i,j) ampfit(i,j) basefit(i,j) fit(i,j,:)] = fitbackground(squeeze(tdata(i,j,1:length(avgx))),avgx,avgy,avgsf,avgtf,avgspeed);
        end
    elseif length(xrange)==4
        for j = 1:size(tdata,2);
            % [xfit(i,j)  yfit(i,j) sffit(i,j) tffit(i,j) gainfit(i,j) ampfit(i,j) basefit(i,j) fit(i,j,:)] = fitxysftf(squeeze(tdata(i,j,1:length(xpos))),xpos,ypos,sf,tf,trialspeed);
            [xfit(i,j)  yfit(i,j) sffit(i,j) tffit(i,j) gainfit(i,j) ampfit(i,j) basefit(i,j) fit(i,j,:)] = fitxysftf(squeeze(tdata(i,j,1:length(avgx))),avgx,avgy,avgsf,avgtf,avgspeed);
        end
    end
end
toc

%     figure
%     imagesc(xfit); title('X');
%
%       figure
%     imagesc(yfit); title('Y');
%
%     figure
%     imagesc(sffit,[2 4]); title('SF');
%
%     figure
%     imagesc(tffit,[1 3]); title('TF');
%     figure
%     imagesc(ampfit+basefit); title('amp + base');
%     figure
%     imagesc(ampfit); title('amp')
%     figure
%     imagesc(basefit); title('base')
%     figure
%     imagesc(gainfit,[0 1]); title('gain');
if exist('xfit','var')
    alldata(:,:,1) = xfit; alldata(:,:,2) = yfit; alldata(:,:,3)=sffit; alldata(:,:,4)=tffit; alldata(:,:,5)=ampfit;
    alldata(:,:,6)=basefit; alldata(:,:,7) = gainfit;
else
    alldata=[]; fit =[];
end


% baseimg=figure
% imagesc(xfit);
% for i = 1:10
%     figure(baseimg)
%     [y x]=ginput(1); x=4*round(x); y=4*round(y);
%     figure
%     subplot(1,2,1)
%     imagesc(squeeze(tuning(x,y,:,:,1,1)),[-0.025 0.025]);
%     subplot(1,2,2);
%     imagesc(squeeze(tuning(x,y,:,:,2,1)),[-0.025 0.025]);
% end
%
if length(xrange)==4 & length(yrange)==3
    figure
    for i = 1:length(sfrange)
        for j=1:length(tfrange)
            subplot(length(tfrange),length(sfrange),length(sfrange)*(j-1)+i)
            d=squeeze(mean(mean(avgtrialcourse(:,:,i,j,:),2),1));
            sftcourse(i,j,:) = d-min(d);
            plot(d-min(d)); axis([1 18 0 0.015]);
            set(gca,'Xticklabel',[]); set(gca,'Yticklabel',[]);
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
    end
end


%%% plot sf and tf responses
figure
for i = 1:length(sfrange)
    for j=1:length(tfrange)
        subplot(length(tfrange),length(sfrange),length(sfrange)*(j-1)+i)
        imagesc(squeeze(mean(mean(tuning(:,:,:,:,i,j),4),3)),[ -0.005 0.05]); colormap jet;
        title(sprintf('%0.2fcpd %0.0fhz',sfrange(i),tfrange(j)))
        axis off; axis equal
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
end
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end  

if bkgrat
    range = [-0.005 0.035];
else
    range= [0 0.075];
end

%%get percent time running
sp = conv(sp,ones(50,1),'same')/50;
mv = sum(sp>500)/length(sp);
figure
subplot(1,2,1)
bar(mv);
xlabel('subject')
ylabel('fraction running')
subplot(1,2,2)
bar([mean(trialspeed(run)) mean(trialspeed(sit))])
set(gca,'xticklabel',{'run','sit'})
ylabel('speed')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end


% figure
% for i = 1:length(xrange)
%     for j=1:length(yrange)
%         subplot(length(yrange),length(xrange),length(xrange)*(j-1)+i)
%         d=squeeze(mean(mean(avgtrialcourse(i,j,:,:,:),4),3));
%         plot(d-min(d)); axis([1 18 0 0.015])
%         set(gca,'Xticklabel',[]); set(gca,'Yticklabel',[]);
%         set(gca,'LooseInset',get(gca,'TightInset'))
%     end
% end

%%% plot x/y maps
% if ~bkgrat
%     figure
%     for i = 1:length(xrange)
%         for j=1:length(yrange)
%             subplot(length(yrange),length(xrange),length(xrange)*(j-1)+i)
%             imagesc(squeeze(mean(mean(tuning(:,:,i,j,:,:),6),5)),range); colormap jet
%             % title(sprintf('%0.2f %0.2f',xrange(i),yrange(j)))
%             axis off; axis equal
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
%             set(gca,'LooseInset',get(gca,'TightInset'))
%         end
%     end
% else
%     for k = 1:2
%         figure
%         for i = 1:length(xrange)
%             for j=1:length(yrange)
%                 subplot(length(yrange),length(xrange),length(xrange)*(j-1)+i)
%                 imagesc(squeeze(mean(mean(tuning(:,:,i,j,k,:),6),5)),range);
%                 % title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
%                 axis off; axis equal
%                 hold on; plot(ypts,xpts,'w.','Markersize',2)
%                 set(gca,'LooseInset',get(gca,'TightInset'))
%             end
%         end
%         title(sprintf('sf = %d',k));
%     end
% end
% 
% if exist('psfilename','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
% end


    


%    for x = 1:length(xrange)
%        for y = 1:length(yrange)
%            h = figure;
%            set(h,'Name',sprintf('x=%d y=%d',x,y))
%            for i = 1:length(sfrange)
%         for j=1:length(tfrange)
%             subplot(length(sfrange),length(tfrange),length(tfrange)*(i-1)+j)
%             imagesc(squeeze(tuning(:,:,x,y,i,j)),[ -0.05 0.05]);
%            % title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
%             axis off; axis equal
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
%              set(gca,'LooseInset',get(gca,'TightInset'))
%         end
%            end
%        end
%    end
%

%
% if length(xrange)>1 & length(xrange)<=3
% merge = zeros(size(tuning,1),size(tuning,2),3);
% figure
% for i = 1:length(xrange)
%     for j=1:length(yrange)
%         subplot(length(xrange),length(yrange),length(yrange)*(i-1)+j)
%         imagesc(squeeze(mean(tuning(:,:,i,j,:,1),5)),[ 0 0.05]);
%         merge(:,:,i) = squeeze(mean(tuning(:,:,i,j,:,1),5))/0.03;
%         title(sprintf('%0.2fx %0.2fy',xrange(i),xrange(j)))
%         axis off; axis equal
%     end
% end

% merge(merge<0)=0; merge(merge>1)=1;
% figure
% imshow(merge);
%end

% for doResolutionTest=1:1
%     figure
%     for i = 1:2
%         for j=1:length(xrange)
%             
%             spotimg = squeeze(mean(tuning(:,:,i,j,:,1),5));
%             imagesc(spotimg,[0 0.03]);
%             title(sprintf('%0.2fx %0.2fy',i,j))
%             axis off; axis equal
%         end
%     end
%     
%     
%     
%     [y x] = ginput(1);
%     crossSection = spotimg(:,round(y));
%     figure
%     plot(crossSection);
%     crossSection = mean(spotimg(round(x)+(-1:1),:),1);
%     figure
%     plot(crossSection);
%     crossSection = crossSection(100:199);
%     baseline_est=median(crossSection);
%     [peak_est x0_est] = max(crossSection);
%     sigma_est=5;
%     x=1:length(crossSection);
%     y=crossSection;
%     fit_coeff = nlinfit(x,y,@gauss_fit,[ baseline_est peak_est x0_est sigma_est])
%     
%     %%% parse out results
%     baseline = fit_coeff(1)
%     peak = fit_coeff(2)
%     x0=fit_coeff(3)
%     sigma_est=fit_coeff(4)
%     
%     %%% plot raw data and fit
%     figure
%     plot(x,y)
%     hold on
%     plot(x,gauss_fit(fit_coeff,x),'g')
%     
%     fwhm = 2*sigma_est*1.17*32.5
%     
%     keyboard
% end


% for tr = 1:trials;
%     data=zeros(length(sfrange),length(tfrange));
%     data(find(sfrange==sf(tr)),find(tfrange==tf(tr)))=1;
%     data=data(:);
%     data(end+1)=trialspeed(tr)>500;
%     alldata(tr,:)=data;
% end
%
% keyboard
% %alldata(alldata<0)=0;
% clear p0
% for i = 1:size(img,1);
%     i
%     for j=1:size(img,2);
%         d= squeeze(tuning(i,j,1,1,:,:));
%       p0= d(:);
%       p0(end+1)=1;
%       p = nlinfit(alldata,squeeze(trialdata(i,j,1:length(alldata))),@visualGain,p0);
%       fittuning(i,j,:,:) = reshape(p(1:end-1),length(sfrange),length(tfrange));
%       gain(i,j)=p(end);
%     end
%
% end
%
% figure
% imagesc(gain,[-1 1])
%
% figure
% for i = 1:length(sfrange)
%     for j=1:length(tfrange)
%         subplot(length(sfrange),length(tfrange),length(tfrange)*(i-1)+j)
%         imagesc(squeeze(fittuning(:,:,i,j)),[ 0 0.05]);
%         title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
%         axis off
%     end
% end
%
% sftuning = squeeze(mean(fittuning,4)); tftuning=squeeze(mean(fittuning,3));
%
% showTuning(sftuning,[1 5],jet,'SF');
% showTuning(tftuning,[1 4],jet,'TF');
%
%
% %
% %
% % for i = 1:size(trialdata,1)
% %     for j=1:size(trialdata,2)
% %         [data xmax] = max(xtuning(i,j,:));
% %         [data ymax] = max(ytuning(i,j,:));
% %
% %         freqtuning(i,j,:,:)=squeeze(tuning(i,j,xmax,ymax,:,:));
% %     end
% % end
% %
% % tic
% % for x=1:size(img,1);
% %     x
% %     for y= 1:size(img,2);
% %         curve= squeeze(tuning(x,y,:,:,:,:));
% %             curve = reshape(curve,size(curve,1)*size(curve,2),size(curve,3)*size(curve,4));
% %        curve(curve<0)=0;
% %        [u v] = nnmf(curve,1);
% %         spatial = reshape(u(:,1),size(tuning,3),size(tuning,4));
% %         freq = reshape(v(1,:),size(tuning,5),size(tuning,6));
% %         xtuning(x,y,:) = mean(spatial,2);
% %         ytuning(x,y,:) = mean(spatial,1);
% %         sftuning(x,y,:) = mean(freq,2);
% %         tftuning(x,y,:) = mean(freq,1);
% %     end
% % end
% % toc
% %
% % showTuning(xtuning,[2 4],hsv,'X')
% % showTuning(ytuning,[1.5 2.5],hsv,'Y');
%
% %
% %
% % map=figure
% % imagesc(mean(mean(mean(mean(tuning,3),4),5),6))
% % for i =1:100;
% %     figure(map);
% %
% % [y x] = ginput(1); x= round(x);y=round(y);
% %     figure
% %     imagesc(squeeze(tuning(x,y,:,:,:,:)));
% %     axis xy
% % %     subplot(2,3,1)
% % %     imagesc(squeeze(mean(mean(tuning(x,y,:,:,:,:),6),5))); axis equal; axis xy
% % %     subplot(2,3,4);
% % %     imagesc(squeeze(mean(mean(tuning(x,y,:,:,:,:),4),3))); axis equal; axis xy
% % %     curve = squeeze(tuning(x,y,:,:,:,:));
% % %     curve = reshape(curve,size(curve,1)*size(curve,2),size(curve,3)*size(curve,4));
% % %     curve(curve<0)=0;
% % %     [u v] = nnmf(curve,1);
% % %
% % %     subplot(2,3,6)
% % %     plot(s(1:5));
% % %     subplot(2,3,2)
% % %     imagesc(reshape(u(:,1),5,3)); axis xy
% % %     subplot(2,3,5);
% % %     imagesc(reshape(v(1,:),3,3)); axis xy
% % %     weights = mean(curve,2);
% % %     weights(weights<0)=0;
% % %    weighted = curve.*repmat(weights,[1 size(curve,2)]);
% % %    freq = mean(weighted,1);
% % %    subplot(2,3,3)
% % %    imagesc(reshape(freq,3,3)); axis xy
%
% % %end
%
