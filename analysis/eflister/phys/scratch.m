function scratch
clc
close all
format long g
format compact
addpath(genpath('/Users/eflister/Desktop/chronux'));

mins = 5;
hz = 40000;
freq = 40;
amp = .3;
p = .95;
phaseRes = [3 freq]; %[numBins freq] -- calculate windows s.t. there will be numBins phase bins at freq

durSec = mins*60;
samps = round(durSec*hz/3);
noise = [randn(round(2.5*samps),1); zeros(round(samps/2),1)];

phases = rem([...
    zeros(samps,1); ...
    2*pi*freq*(1:samps)'/hz; ...
    zeros(samps,1)],...
    2*pi);

lenDiff=length(phases)-length(noise);
if abs(lenDiff)==1
    if lenDiff>0
        phases=phases(1:end-1);
    else
        phases(end+1)=0;
    end
end

data = noise + amp*sin(phases);

downSample=true;
if downSample
    oldHz = hz;
    hz = 1000;
    
    samps = round(durSec*hz/3);
    
    fprintf('resample: \t')
    tic
    data = resample(data,hz,oldHz); %fast
    phases = resample(phases,hz,oldHz);
    toc
    
    if false
        x=(1:length(data))/oldHz;
        xi=(1:round(length(data)*hz/oldHz))/hz;
        
        fprintf('linear: \t')
        tic
        data2 = interp1(x,data,xi); %2x resample
        toc
        
        fprintf('spline: \t')
        tic
        data2 = interp1(x,data,xi,'spline'); %runs out of memory, takes 5 secs for 1 min @ 40kHz->1kHz
        toc
        
        fprintf('pchip: \t')
        tic
        data2 = interp1(x,data,xi,'pchip'); %2 secs for 1 min @ 40kHz->1kHz
        toc
        
        data=data2;
    end
end

spkPhase = pi/2;
spkNoise = .1;
phasePct = .8;
pctPhase = .8;
times = (1:length(data))/hz;
spkTimes = times([false; diff(phases>spkPhase)==1]);
spkTimes = spkTimes + spkNoise*(1/freq)*randn(1,length(spkTimes));
spkTimes = spkTimes(rand(1,length(spkTimes))<phasePct);
spkPct = (freq*phasePct)/hz/pctPhase;
spkTimes = sort([spkTimes times(rand(1,length(times))<spkPct)]);
spks(1).times = spkTimes'; %not documented, but required to be column

figure
plotSecs = .2;
plotSamps = round(plotSecs*hz);
plotRange = samps-round(plotSamps/2)+(1:plotSamps);
plot(times(plotRange),[data(plotRange) phases(plotRange)]);
hold on
plottedSpkTimes=spkTimes(spkTimes>times(plotRange(1)) & spkTimes<times(plotRange(end)));
plot(plottedSpkTimes,spkPhase*ones(1,length(plottedSpkTimes)),'kx')

params.Fs=hz;
params.err=[2 p]; %0 for none, [1 p] for theoretical(?), [2 p] for jackknife
[garbage,garbage,garbage,garbage,garbage,garbage,params]=getparams(params);
params

winDur = .1; %1/prod(phaseRes); %default nw can handle .01, but not .0025 (a typical value needed for phaseRes)
movingwin=[winDur winDur]; %[window winstep] (in secs)

if false
    figure
    subplot(4,1,1)
    fprintf('chronux coh w/err:')
    tic
    [C,phi,S12,S1,S2,t,f,zerosp,confC,phistd,Cerr]=cohgramcpt(data,spks,movingwin,params,0);
    toc
    
    C(repmat(logical(zerosp),1,size(C,2)))=0;
    gram(C',t,f,'lin');
    title('coherence')
    
    subplot(4,1,2)
    gram(squeeze(Cerr(1,:,:))',t,f,'lin');
    title('chronux bottom err')
    subplot(4,1,3)
    gram(squeeze(Cerr(2,:,:))',t,f,'lin');
    title('chronux top err')
    
    subplot(4,1,4)
    gram(phi',t,f,'lin');
    title('chronux phase') 
end

if false
    fprintf('chronux w/err: \t')
    tic
    [S,t,f,Serr]=mtspecgramc(data,movingwin,params); %takes 180 sec for 5 mins @ 40kHz
    toc
    
    figure
    subplot(2,1,1)
    plotSpecGram(squeeze(Serr(1,:,:))',t,f,'log');
    title('chronux bottom err')
    subplot(2,1,2)
    plotSpecGram(squeeze(Serr(2,:,:))',t,f,'log');
    title('chronux top err')
    
    figure
    subplot(3,1,1)
    plotSpecGram(S',t,f,'log');
    title('chronux w/err')
else
    figure
end

params.err=0;

fprintf('chronux w/o err:')
tic
[S,t,f]=mtspecgramc(data,movingwin,params); %takes ? sec for 5 mins @ 40kHz
toc
t2=t;

subplot(3,1,2)
plotSpecGram(S',t,f,'log');
title('chronux w/o err')

% spectrogram lets us specify f's we want, but isn't mtm
% we should rewrite to use mtm, but windowing requires some thinking (could copy from chronux)
% also consider wavelet analyis as a general spectrogram alternative w/variable window sizes

% defaults to hamming windows
% f is a vector of frequencies in Hz (with 2 or more elements) computes the spectrogram at those frequencies using the Goertzel algorithm.
%   if scalar, specifies number of freq points
usePhaseRes = false;
if usePhaseRes
    %this doesn't work well for doing our phase estimates -- horrible frequency resolution and takes forever.
    %instead, to corroborate chronux SFC, use spike-triggered-average-LFP...
    %then take power spectrum and normalize by average power spectrum of the individual triggered LFPs
    %(this is from reynold's 2001 paper)
    %http://www.sciencemag.org/cgi/content/full/sci;291/5508/1560/DC1
    
    %see methods of this paper for new sophisticated hilbert method:
    %http://www.sciencemag.org/cgi/data/324/5931/1207/DC1/1
    %especially detailed in
    %http://research.yerkes.emory.edu/Buffalo/downloads/Empirical%20mode%20decomposition%20of%20field%20potentials%20from%20macaque.pdf
    %(compare it favorably against wavelet)
    winDur = 1/prod(phaseRes);
    movingwin=[winDur winDur];
    f=linspace(0,2*phaseRes(2),6);
end

fprintf('spectrogram: \t')
tic
[stft,f2,t,S] = spectrogram(data,round(movingwin(1)*hz),round(hz*(movingwin(1)-movingwin(2))),f,hz); % takes ? sec for 5 mins @ 40kHz
toc

if ~all(f2(:)==f(:))
    error('f error')
end

subplot(3,1,3)
plotSpecGram(S,t,f,'log');
title('spectrogram')

if ~usePhaseRes && any(abs(t2-t)>.01)
    figure
    plot(t)
    hold on
    plot(t2)
end

figure
fprintf('chronux coh w/o err:')
tic
[C,phi,S12,S1,S2,t,f,zerosp]=cohgramcpt(data,spks,movingwin,params,0);
toc
gram(C',t,f,'lin');
title('coherence')

if false
    %sucked out of spectrogram.m -- do i need to do anything (like correct for windowing) to stft to make a phaseogram?
    %pretty sure answer is no...
    % [garbage,garbage,garbage,garbage,garbage,win] = welchparse(data,'psd',varargin{:});
    % U = win'*win;     % Compensates for the power of the window.
    % Sxx = y.*conj(y)/U; % Auto spectrum.
    
    if ~all(size(stft)==size(S))
        error('size problem')
    end
    
    figure
    gram(angle(stft),t,f,'lin');
    title('phaseogram')
end

if false
    nw=[]; %the time-bandwidth product for the discrete prolate spheroidal sequences. default=4. Other typical choices are 2, 5/2, 3, or 7/2.
    %note that chronux defaults tapers = [3 5], so not clear how to translate this (and relative time penalty)
    fprintf('pmtm: \t')
    tic
    [Pxx,Pxxc,f2] = pmtm(data,nw,f,hz,p);
    toc
    
    if ~all(f2(:)==f(:))
        error('f error')
    end
    
    figure
    plot(f,[Pxx; Pxxc]');
    title('mtm');
    xlabel('f')
    ylabel('psd')
end

end

function gram(S,t,f,type)
imagesc(t,f,S);
axis xy;
xlabel('time (s)');
ylabel('freq (hz)');
colorbar;
end

function plotSpecGram(S,t,f,type)
if any(S(:)<0)
    error('not expecting negative S')
end
gram(10*log10(abs(S)+eps),t,f,type); %this code for plotting log psd is from matlab's spectrogram, chronux's plot_matrix uses similar, but without abs or eps

%    set(gca,'XTick',-pi:pi/2:pi)
%    set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})

%    ytick
end