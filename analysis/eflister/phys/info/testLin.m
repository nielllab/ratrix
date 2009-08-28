function testLin
len=10;
dur=20;
tau=0.1;
decay=exp(linspace(0,-1,dur)/tau);
stim1=getStim(len);
stim2=getStim(len);
out1=doMonitor(stim1,decay);
hold on
out2=doMonitor(stim2,decay);
outSum=doMonitor(stim1+stim2,decay);
sumOut=out1+out2;
plot(sumOut)
plot(sumOut-outSum)

function stim=getStim(len)
stim=randn(1,len);
stim=stim-min(stim);

function out=doMonitor(stim,decay)
len=length(stim);
dur=length(decay);
out=reshape(repmat(stim,dur,1),1,[]).*repmat(decay,1,len);
plot(out)