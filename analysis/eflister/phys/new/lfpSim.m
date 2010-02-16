function lfpSim
%coupleLFP  doKernel (fact=1)
%false      false  ->  strong autocorr, no STA
%true       false  ->  strong autocorr, acausal STA, corrected is mainly fixed but still has acausal freq features
%false      true   ->  strong autocorr, STA recovers kernel, no acausal problems, corrected flips kernel and copies it acausally!
%true       true   ->  strong autocorr, STA contains kernel and acausal ring, corrected mainly fixes it but still has acausal freq features and mostly destroys kernel

close all
clc

durMins=30;
frameRate=100;

numFrames=1+durMins*60*frameRate;
stim=[normalize(randn(1,numFrames));0:1/frameRate:durMins*60];

    function in=normalize(in)
        in=in-min(in);
        in=in/max(in);
    end

lfpBand=[9 10];
coupleLFP=true;
if coupleLFP
    nyquist=frameRate/2;
    b=fir1(300,lfpBand/nyquist,'high');
    lfp=filtfilt(b,1,stim(1,:));
else
    lfp=sin(stim(2,:)*2*pi*mean(lfpBand));
end
lfp=normalize(lfp);

subplot(3,1,1)
xcDur=2;
frames=(0:2*xcDur*frameRate)+round(size(stim,2)/2);
plot(stim(2,frames),stim(1,frames))
hold on
plot(stim(2,frames),lfp(1,frames),'r')

kernel=zeros(1,xcDur*2*frameRate+1);
lims=ceil(length(kernel)*[1 2]/5);
kernel(lims(1):lims(2))=sin(linspace(0,2*pi,lims(2)-lims(1)+1));

g=normalize(conv(stim(1,:),fliplr(kernel),'same'));

subthresh=lfp;

doKernel=true;
if doKernel
    fact=1;
    subthresh=subthresh+fact*g;
end

[dist bins]=hist(subthresh,100);
spikeRate=20;
nonlin=(cumsum(dist)/length(subthresh) > 1-spikeRate/frameRate);

spks=stim(2,rand(1,size(stim,2)) < interp1(bins,nonlin,subthresh));

spks=spks(spks>xcDur & spks<max(stim(2,:))-xcDur);

plotSpks=spks(spks<=max(stim(2,frames)) & spks>=min(stim(2,frames)));
plot(plotSpks,.5*ones(1,length(plotSpks)),'kx')

exSpks=zeros(1,size(stim,2));
exSpks(interp1(stim(2,:),1:size(stim,2),spks,'nearest'))=1;

exSpksM=hist(spks,stim(2,:));

if ~doKernel || true
    if any(exSpksM~=exSpks)
        error('hist/interp err')
    end
end

if true    
    tmp=1+floor((spks-stim(2,1))*frameRate);
    exSpks=hist(tmp,1:length(stim(2,:)));
end

plot(stim(2,frames),exSpks(frames),'k')

subplot(3,1,2)
numFrames=ceil(xcDur*frameRate);

norm='biased';

[x lags]=xcorr(exSpks,numFrames,norm);
plotx=x;
plotx(ceil(length(plotx)/2))=0;
plot(lags/frameRate,plotx)
title(sprintf('spike rate: %g', length(spks)/(durMins*60)))

theseSpks=find(exSpks);

frameInds=-numFrames:numFrames;
inds=repmat(frameInds,length(theseSpks),1)+repmat(theseSpks',1,length(frameInds));

%sta=mean(stim(1,inds)); wha?  doesn't preserve shape?
tmp=stim(1,:); %shouldn't be necessary?
sta=mean(tmp(inds));
sta=(sta-mean(tmp))/std(tmp);

subplot(3,1,3)
xs=frameInds/frameRate;
plot(xs,sta,'k','LineWidth',3);
hold on
plot(zeros(1,2),[min(sta) max(sta)],'k')
plot([min(xs) max(xs)],zeros(1,2),'k')

[staX staLags]=xcorr((stim(1,:)-10^3)/10^9,exSpks,numFrames,norm);

if any(staLags~=lags)
    error('lag err')
end

plot(xs,cNorm(staX),'g');

corrected=fftshift(ifft(fft(staX)./fft(x))); 
%ok -- this might not be doing much cuz of relative scaling btw xcorr and autocorr!
%eg, shouldn't relative size of stim units compared to spike rate units matter?  maybe not w/coeff?
%but above moving of stim has no effect, so this must be accounted for, but i don't see how in the def of xcorr.
%i'm not clear why we don't want the crosscovariance, which would first remove the means
%according to matlab doc, crosscov = crosscor - prod(means), but i don't know what happend to the cross terms

if any(~isreal(corrected))
    error('complex err')
end

plot(xs,cNorm(corrected),'r')

if doKernel
    plot(xs,cNorm(kernel),'b')
end

xlim([min(xs) max(xs)])

    function in=cNorm(in)
        in=in-min(in);
        in=in/max(in);
        in=in*range(sta);
        in=in+min(sta);
    end

end