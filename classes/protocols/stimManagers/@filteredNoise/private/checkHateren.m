function checkHateren

fileName='ts001.txt';
hz=1200;
newHz=100;

durs=[8 33*8 45*60];
cols={'r' 'g' 'b'};

cut=12800;% of 32767 =  intmax('int16')
bottom=1/3;

binSize=30;

norm=true;

clc
close all

x=load(fileName);

if norm
    x=normalize(x);
    cut=cut/double(intmax('int16'));
    binSize=binSize/double(intmax('int16'));
end

bins=(0:binSize:max(x));
times=(0:(length(x)-1))/hz;

newX=resample(x,newHz,hz);
newX(newX<0)=0;
if norm
    %newX=normalize(newX); %DO NOT NORMALIZE!  resampling has added some (negative) artifacts that will cause normalization to dramatically reduce contrast! 
    newX(newX>1)=1;
else
    newX(newX>intmax('int16'))=intmax('int16');
end
newTimes=(0:(length(newX)-1))/newHz;

for i=1:length(durs)
    subplot(length(durs)+1,1,i)
    
    inds=1:durs(i)*hz;
    y=x(inds);
    theseTimes=times(inds);
    plot(theseTimes,y,cols{i})
    
    hold on
    inds=1:durs(i)*newHz;
    newY=newX(inds);
    plot(newTimes(inds),newY,'k')
    
    plot([0 max(theseTimes)],cut*ones(1,2),'k')
    plot([0 max(theseTimes)],bottom*cut*ones(1,2),'k')
    
    h{i}=hist(y,bins);
    newH{i}=hist(newY,bins);
    
    strs{i}=sprintf('first %g secs - %g%%/%g%% are above %g, %g%%/%g%% are below %g',durs(i),pct(sum(y>cut)/length(y),1),pct(sum(newY>cut)/length(newY),1),cut,pct(sum(y<cut*bottom)/length(y),1),pct(sum(newY<cut*bottom)/length(newY),1),bottom);
    title(strs{i})
end

maxH=0;
subplot(length(durs)+1,1,length(durs)+1)
for i=1:length(h)
    normalized=h{i}/sum(h{i});
    if max(normalized)>maxH
        maxH=max(normalized);
    end
    semilogy(bins,normalized,cols{i})
    hold on
    
    normalized=newH{i}/sum(newH{i});
    semilogy(bins,normalized,'k')
end
semilogy(cut*ones(1,2),[10^-10 maxH],'k')
semilogy(bottom*cut*ones(1,2),[10^-10 maxH],'k')

function out=pct(val,decs)
out=round(100*10^decs*val)/10^decs;

%can use ratrix\classes\util\matlaby\normalize if don't mind doubleified output
function x=normalize(x)
x=x-min(x(:));
x=x/max(x(:));