function [classified dims p]=states(phys,fs,freqs,numDims,numStates,binSecs,resamp)
% classifies a continuous recording into epochs of similar spectral content
%
% arguments ([arg] indicates optional arguments -- use defaults by omitting or specifying empty array []):
% phys        - vector of voltage measurements (arbitrary units)
% fs          - sampling frequency of phys in hz 
% [freqs]     - vector of frequencies to use for the classification (defaults is 1:50)
% [numDims]   - number of dimensions (principle components) to use for the classification (default is 2)
% [numStates] - number of states (estimate this by looking at the scatter plot) (default is 2)
% [binSecs]   - temporal granularity for the classification -- duration of each time slice in secs (default is 1)
% [resamp]    - first resample phys to this multiple of nyquist (2 x max(freqs)) (default is no resampling)
%
% return values:
% classified - vector of state classifications (btw 1 and numStates) for each time slice -- length is ceil(length(phys)/(fs*binSecs))
% dims       - the principle components found, the ith entry is the weight of the freqs(i) band -- size is numDims x length(freqs)
% p          - matrix of power spectra at freqs during each time slice (a spectrogram) -- size is length(freqs) x ceil(length(phys)/(fs*binSecs))

% parameters

useChronux = false; % http://chronux.org/ -- hip package for LFP/coherence analysis that gives you multi-taper based confidence intervals that matlab doesn't have built in
test       = true; % standalone test

%%%%%%%% input validation

if test
    phys=randn(1,1000000);
    fs=1000;
    freqs=1:50;
end

if ~isvector(phys) || ~isreal(fs)
    error('phys must be real vector')
end

if ~isscalar(fs) || fs<=0 || ~isreal(fs)
    error('fs must be real positive scalar')
end

if ~isvector(freqs) || ~all(freqs>0) || ~isreal(freqs) || 
    error('')
end
y = resample(x,p,q) resamples the sequence in vector x at p/q times the original sampling rate, using a polyphase filter implementation. p and q must be positive integers.

%%%%%%%%

if useChronux
    tic
    [S,t,f,Serr]=mtspecgramc(data,movingwin,params)
    toc
else
    tic
    [stft f t p]=spectrogram(phys-mean(phys),round(fs),[],freqs,fs); %1 sec res w/50% overlap? requires signal processing toolbox (octave has stft function http://www.gnu.org/software/octave/doc/interpreter/Signal-Processing.html#index-stft-1722)
    toc
end

p=p'-mean(p(:));
[u s]=pca(p);

%kmeans is in the statistics toolbox



end

function [u s]=pca(x)
done=false;
pct=1;

while ~done
    try
        [u s v]=svd(x(rand(1,size(x,1))<pct,:));
        done=true;
    catch ex
        if strcmp(ex.identifier, 'MATLAB:nomem')
            warning('too much data for svd -- choosing dims from %g%% subset',100*pct)
            pct=pct/2;
        else
            rethrow(ex);
        end
    end
end

s=diag(s);
end


function [P,Q]=getPQ(resampFreq,step)
if ~all(arrayfun(@isNearInteger,[resampFreq,1/step]))
    %         [resampFreq,1/step]
    %         warning('resample requires ints -- need to find ints P,Q, s.t. P/Q = ')
    %         resampFreq * step
    str = sprintf('%g',resampFreq*step);
    while str(end)=='0';
        str=str(1:end-1);
    end
    decstr=str;
    decCount=0;
    while length(decstr)>0 && decstr(end)~='.';
        decstr=decstr(1:end-1);
        decCount=decCount+1;
    end
    if isempty(decstr)
        P=resampFreq*step;
        Q=1;
        if ~isNearInteger(P)
            error('shouldn''t be possible')
        end
    else
        P=resampFreq*step*10^decCount;
        Q=10^decCount;
    end
    if (P/Q ~= resampFreq*step)
        error('fix didn''t work')
    end
else
    P=resampFreq;
    Q=1/step;
end
P=round(P);
Q=round(Q);
if ~almostEqual(resampFreq, P/Q/step)
    error('PQerr')
end
fprintf('resampling from %g to %g (P=%d, Q=%d)\n',1/step,resampFreq,P,Q);
end