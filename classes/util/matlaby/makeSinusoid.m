function out=makeSinusoid(samplingRate,freq,secsDur)
out=sin(linspace(0,2*pi*freq*secsDur,secsDur*samplingRate));