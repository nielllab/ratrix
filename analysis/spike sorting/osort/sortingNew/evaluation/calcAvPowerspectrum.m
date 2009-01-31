function [pxxAv,w] = calcAvPowerspectrum( traces, Fs, till )

if till>size(traces,1)
    till=size(traces,1);
end


pxxAv=[];
for i=1:till

%[pxx,w]=periodogram( traces(i,:),[],'oneSided',1024,Fs);
%[pxx,w]=periodogram( noiseTraces(i,2:65),[],'oneSided',1024,25000);
[pxx,w]=pwelch( traces(i,2:65),[],[],[],Fs,'oneSided');
if i==1
    pxxAv=pxx;
else
    pxxAv=pxxAv+pxx;
end

end

pxxAv=pxxAv/till;