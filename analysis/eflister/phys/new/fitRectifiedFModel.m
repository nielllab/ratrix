function cfun=fitRectifiedFModel(numHarmonics,data,fs,f1)
test=false;
if test
    clc
    close all
    
    fs = 1000;
    f1 = 10;
    f0 = 25;
    
    amp1=30;
    phase1 = pi/4;
    amp2=10;
    phase2 = 3*pi/2;
    data=3*randn(1,10*fs)+f0; %any more noise than this and it fails pretty badly
    
    if true
        amp1=5;
        amp2=0;
        data=zeros(1,10*fs)+f0;
    end
    
    
else
    if numHarmonics~=2
        error('2 harmonics hardcoded right now')
    end
end

dur=length(data)/fs;
ts=(0:(length(data)-1))/fs;

if test
    data = data + amp1*sin(ts*f1*2*pi  + phase1) + amp2*sin(ts*2*f1*2*pi  + phase2) ;
    data(data<0)=0;
    
    aFit=rectifiedFModel(ts,f0,f1,[amp1 phase1;amp2 phase2]);
    
    plot(ts,aFit,'r')
    hold on
end

model=fittype(sprintf('rectifiedFModel(x,thisf0,%g,[a1 p1;a2 p2])',f1));

if ~all(cellfun(@strcmp,coeffnames(model),{'a1','a2','p1','p2','thisf0'}'))
    coeffnames(model)
    error('coeff name error')
end

lower=[0 0 -2*pi -2*pi 0]; %if use zeros, the gradient can be pointed the wrong way and wind up jamming you on the bound
upper=[Inf Inf 2*pi 2*pi Inf];
options=fitoptions(model);
options=fitoptions(options,'Lower',lower,'Upper',upper);

cfun = fit(ts',data',model,options);

if test
    plot(cfun,'g',ts,data,'k')
end
end