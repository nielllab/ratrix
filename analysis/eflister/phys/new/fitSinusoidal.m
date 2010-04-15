function [newout out]=fitSinusoidal(in,freqs,numContrasts,f,S,t)
numConds=(length(freqs)*numContrasts);
out=medianChunk(in,numConds);

[junk freqOrd]=sort(out(1,:),'descend');

freqs=sort(freqs(:),1,'descend');
if length(unique(freqs))~=length(freqs) || ~all(freqs>0) || ~all(isreal(freqs))
    error('freqs must all be unique, real, strictly positive')
end

%142/87
%148/84

numnans=(size(in,2)-size(S,2))/2;
cs=1:numContrasts;
amps=nan(length(freqs),size(S,2));
amp=nan(length(freqs),numConds);
for i=1:length(freqs)
    inds=freqOrd(1:numContrasts);
    
    out(1,inds)=freqs(i);
    
    if true
        %using the fitted gaussian amplitudes isn't working cuz of baseline offsets
        
        if inRange(freqs(i),minmax(f))
            thisf=freqs(i);
        elseif freqs(i)>max(f) && ((freqs(i)/max(f)) - 1) < .01 %cuz interp2 don't extrap
            thisf=max(f);
        else
            error('huh?')
        end
        amps(i,:)=[nan(1,floor(numnans)) interp2(1:size(S,2),f,S,1:size(S,2),thisf) nan(1,ceil(numnans))];
        amp(i,:)=medianChunk(amps(i,:),numConds);
        amp(i,setdiff(1:size(amp,2),inds))=min(amp(i,:));
        out(2,inds)=amp(i,inds);
    end
    [junk ampOrd]=sort(out(2,inds),'ascend');
    out(2,inds(ampOrd))=cs;
    
    freqOrd=freqOrd(numContrasts+1:end);
end
offsets=repmat((0:length(freqs)-1)*10,size(S,2),1);
plot(t,offsets+amps')
hold on
plot(t,offsets+expand(amp,amps)')
plot(t,offsets+repmat(min(amp'),size(offsets,1),1),'k')

newout=expand(out,in);
end

function out=medianChunk(in,numConds)
chunkLen=size(in,2)/numConds;
out=nan(size(in,1),numConds);
for j=1:size(in,1)
    for i=1:size(out,2)
        thisChunk=in(j, (1:round(chunkLen))+round((i-1)*chunkLen) );
        out(j,i)=median(thisChunk(~isnan(thisChunk)));
    end
end
end

function newout=expand(out,in)
newout=nan(2,size(in,2));
for j=1:size(in,1)
    newout(j,:)=interp1(1:size(out,2),out(j,:),linspace(.5,size(out,2)+.5,size(in,2)),'nearest','extrap');
end
end