function out=makeSinusoid(samplingRate,freq,secsDur,type)
out=cos(linspace(0,2*pi*freq*(secsDur-1/samplingRate),secsDur*samplingRate)); %cos instead of sin, so that at least first value will be at an extreme (using sin, eg 50Hz flicker at 100Hz would be all zeros)
switch type
    case 'squareFlicker'
        out=double(out>0)*2-1;
        warning('careful, this will alias -- needs fixing')
    case 'sinusoidalFlicker'
        %pass
    otherwise
        type
        error('unsupported type')
end