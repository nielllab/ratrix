clear all
pack
clc

clf

width=40;

y=sin(0:2*pi/width:2*pi);
z=[zeros(1,2*width) y zeros(1,width)];
z=z/norm(z);

n=100000;
%n=57250;
%n=200000;
t=.05;

skew=0;
if skew
    %stims=gamrnd(3,10,n,length(z));
    stims=lognrnd(0,.6,n,length(z));
else
    stims=randn(n,length(z));    
end

filts=z*stims';
[sortedFilts filtOrder]=sort(filts);

complex=0;

if complex
    z2=[zeros(1,3*width/2) y zeros(1,3*width/2)];
    z2=z2/norm(z2);
    subplot(2,1,1)
    plot(z,'b')
    hold on
    plot(z2,'r')
    
    filts2=z2*stims';
    
    filts=filts.*filts2;
    [sortedFilts filtOrder]=sort(filts);
else
    subplot(2,1,1)
    plot(z)
end

trigs=stims(filtOrder(end-round(t*n):end),:);
subplot(2,1,2)
plot(trigs')    

clf
plot((stims(1:round(t*n),:))')

cStims=cov(stims(1:size(trigs,1),:));
cTrigs=cov(trigs);
imagesc(cStims);
imagesc(cTrigs);
deltaC=cTrigs-cStims;
imagesc(deltaC)

subplot(3,1,1)
[vects,eigs]=eig(deltaC);
plot(diag(eigs),'bo')
hold on
projStims=stims(1:size(trigs,1),:)*vects;
vars=var(projStims);
plot(vars,'kx')
plot((diag(eigs))'./vars,'rx')
[sortedEigs order]=sort((abs(diag(eigs)))'./vars);
plot(sortedEigs,'gx')

subplot(3,1,2)
plot(z,'k')
hold on
if complex
    plot(z2+.5,'k')
end

temp=diag(eigs);
dims=5;

plot(vects(:,order(end-dims(end)+1:end))+repmat(1:dims,size(vects,1),1),'r')
%plot(vects(:,order(1:dims(end)))+repmat(1:dims,size(vects,1),1),'r')

sta=mean(trigs);
plot(((sta-mean(sta))/norm(sta-mean(sta)))-1,'b')

subplot(3,1,3)
hist(stims(1:1000*length(z)),1000)