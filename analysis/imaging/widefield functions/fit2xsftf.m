function [xfit  sffit tffit gain ampfit basefit] = fitxysf(data,xpos,sf,tf, sp);

xrange = unique(xpos); sfrange = unique(sf); tfrange = unique(tf);
params = zeros(length(data),13);
for tr = 1:length(data);
    xind = find(xrange==xpos(tr)); tfind=find(tfrange==tf(tr)); sfind = find(sfrange==sf(tr)); run = sp(tr)>500;
    params(tr,xind)=1; params(tr,sfind+2)=1; params(tr,tfind+8)=1; params(tr,12)=run;
end

for i = 1:11
    p0(i) = mean(data(params(:,i)==1));
end

p0(p0<0)=0;
p0(12)= mean(data(params(:,12)==1))./( mean(data(params(:,12)==0))+0.0001) - 1;
p0(13)=0;


p0(1:2) = p0(1:2)/max(p0(1:2)); p0(3:8) = p0(3:8)/max(p0(3:8)); p0(9:11)=p0(9:11)/max(p0(9:11)); 
p0(1:2) = p0(1:2)*prctile(data,95);

%p0 = [0.05 0.05 0.05 0.05 0.05 1 1 1 1 1 0.5 0];
lb = zeros(size(p0));lb(12)=-0.1; lb(13)=-0.05;
ub = ones(size(p0)); ub(12)=0.5; ub(13)=0.1;
ub(1:2)=0.5;

p0=max(p0,lb); p0 = min(p0,ub);
p0'
lb';
ub';
  
        f = @(x)compute2xsftfTuningErr(x,params,data);
        fit = fmincon(f,p0,[],[],[],[],lb,ub);
       % fit = p0;
        xtuning = fit(1:2);  sftuning = fit(3:8); tftuning= fit(9:11);
        [mx xfit] = max(xtuning); [msf sffit] = max(sftuning); [mtf] = max(tftuning); gain=fit(12);
        
        sftuning=sftuning-min(sftuning);sftuning=sftuning-min(sftuning); 
        xfit = sum(xtuning.*(1:2))/sum(xtuning);  tffit = sum(tftuning.*(1:3))/sum(tftuning);
         sffit = sum(sftuning.*(1:6))/sum(sftuning);
        ampfit = mx*msf*mtf;
     basefit = fit(13);
