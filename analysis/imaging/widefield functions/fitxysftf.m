function [xfit yfit sffit tffit gain ampfit basefit fit] = fitxysf(data,xpos,ypos,sf,tf, sp);

xrange = unique(xpos); yrange=unique(ypos); sfrange = unique(sf); tfrange = unique(tf);
params = zeros(length(data),18);
for tr = 1:length(data);
    xind = find(xrange==xpos(tr)); yind = find(yrange == ypos(tr)); sfind = find(sfrange==sf(tr)); tfind = find(tfrange==tf(tr)); run = sp(tr)>500;
    params(tr,xind)=1; params(tr,yind+4)=1; params(tr,sfind+7)=1; params(tr,tfind+13)=1; params(tr,17)=run;
end


for i = 1:16
    p0(i) = mean(data(params(:,i)==1));
end

ampfit = mean(p0(1:4));

%p0(p0<0)=0;
p0(17)= mean(data(params(:,17)==1))./( mean(data(params(:,17)==0))+0.0001) - 1;
p0(18)=0;


%p0(1:4) = p0(1:4)*prctile(data,95)/max(p0(1:4));
p0(5:7) = p0(5:7)/max(p0(5:7)); p0(8:13)=p0(8:13)/max(p0(8:13)); p0(14:16)= p0(14:16)/max(p0(14:16));


%p0 = [0.05 0.05 0.05 0.05 0.05 1 1 1 1 1 0.5 0];
lb = zeros(size(p0));lb(17)=-0.1; lb(18)=-0.005;
ub = ones(size(p0)); ub(17)=0.5; ub(18)=0.1;
ub(1:4)=0.3;

%p0=max(p0,lb); p0 = min(p0,ub);
p0';
lb';
ub';
  
        f = @(x)computexysftfTuningErr(x,params,data);
       % fit = fmincon(f,p0,[],[],[],[],lb,ub);
       fit = p0;
        xtuning = fit(1:4); ytuning=fit(5:7); sftuning = fit(9:13); tftuning= fit(14:16);
        [mx xfit] = max(xtuning); [my yfit] = max(ytuning); [msf sffit] = max(sftuning); [mtf tffit] = max(tftuning); gain=fit(17);
        
        xtuning=xtuning-min(xtuning); % ytuning=ytuning-min(ytuning); 
        sftuning=sftuning-min(sftuning); %tftuning=tftuning-min(tftuning); 
        xfit = sum(xtuning.*(1:4))/sum(xtuning); yfit = sum(ytuning.*(1:3))/sum(ytuning); tffit = sum(tftuning.*(1:3))/sum(tftuning);
         sffit = sum(sftuning.*(1:5))/sum(sftuning);
       % ampfit = mx*my*msf*mtf;
       
     basefit = fit(18);
