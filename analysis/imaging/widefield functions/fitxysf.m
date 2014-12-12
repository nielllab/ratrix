function [xfit yfit sffit gain ampfit basefit] = fitxysf(data,xpos,ypos,sf,sp);

xrange = unique(xpos); yrange=unique(ypos); sfrange = unique(sf);
params = zeros(length(data),11);
for tr = 1:length(data);
    xind = find(xrange==xpos(tr)); yind = find(yrange == ypos(tr)); sfind = find(sfrange==sf(tr)); run = sp(tr)>500;
    params(tr,xind)=1; params(tr,yind+5)=1; params(tr,sfind+8)=1; params(tr,11)=run;
end

for i = 1:10
    p0(i) = mean(data(params(:,i)==1));
end

p0(p0<0)=0;
p0(11)= mean(data(params(:,10)==1))./( mean(data(params(:,10)==0))+0.0001) - 1;
p0(12)=0;


p0(1:5) = p0(1:5)/max(p0(1:5)); p0(6:8) = p0(6:8)/max(p0(6:8)); p0(9:10)=p0(9:10)/max(p0(9:10));
p0(1:5) = p0(1:5)*prctile(data,95);

%p0 = [0.05 0.05 0.05 0.05 0.05 1 1 1 1 1 0.5 0];
lb = zeros(size(p0));lb(11)=-0.1; lb(12)=-0.02;
ub = ones(size(p0)); ub(11)=0.5; ub(12)=0.1;
ub(1:5)=0.3;

p0=max(p0,lb); p0 = min(p0,ub);
p0'
lb';
ub';
  
        f = @(x)computexysfTuningErr(x,params,data);
        fit = fmincon(f,p0,[],[],[],[],lb,ub);
       % fit = p0;
        xtuning = fit(1:5); ytuning=fit(6:8); sftuning = fit(9:10);
        [mx xfit] = max(xtuning); [my yfit] = max(ytuning); [msf sffit] = max(sftuning); gain=fit(11);
        
        xtuning=xtuning-min(xtuning); ytuning=ytuning-min(ytuning);
        xfit = sum(xtuning.*(1:5))/sum(xtuning); yfit = sum(ytuning.*(1:3))/sum(ytuning);
        sffit = (sftuning(1)+2*sftuning(2))/(sftuning(1)+sftuning(2));
        ampfit = mx*my*msf;
     basefit = fit(12);
