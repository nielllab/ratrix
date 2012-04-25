function align
close all
dbstop if error

x=imread('C:\eflister\Miles_Davis-Tutu-Interior_Frontal.jpg');
x=double(x(:,:,1));
d=size(x);

n=400;
[xs,ys] = meshgrid(linspace(1,d(2),n),linspace(1,d(1),n));
x=interp2(x,xs,ys);
d=size(x);

c = [.4 .65]; %normalized x y
s = ceil([.4 .5].*d); %width height
t = -pi/6; %radians, positive = ccw

center = c.*d;

fig=figure;
n=4;
m=3;
g = @(x,y)(x-1)*m + y;
g2 = @(x)g(1:n,x);

subplot(n,m,g(1,1))
imagesc(x)
hold on
plot(center(1),center(2),'r+')
y = rect(x,center,s,t,'r',3);
axis equal
axis tight
colormap gray

subplot(n,m,g(2,1))
imagesc(y)
axis equal
axis tight
hold on
c=(s+1)/2;
plot(c(1),c(2),'go')

z = imrotate(x,-t*180/pi,'crop');
subplot(n,m,g(3,1))
imagesc(z)
axis equal
axis tight
hold on

zs = @(x) (x-mean(x(:)))/std(x(:));

xc = conv2(zs(z), rot90(conj(zs(y)),2), 'same');

subplot(n,m,g(4,1));
imagesc(xc)
axis equal
axis tight
hold on

[i j]=find(xc==max(xc(:)),1,'first');

plot(j,i,'go')

subplot(n,m,g(3,1))
plot(j,i,'go')

c = rot([j i],t,fliplr((d+1)/2));

subplot(n,m,g(1,1))
plot(c(1),c(2),'go')
rect(x,c,s,t,'g',1);

[p tp] = xcorrn(zs(x),zs(y),g2(2),g2(3),n,m,fig)
[center t]
end

function [p tp]=xcorrn(a,b,f1,f2,fn,fm,fig)
% conv2(a, rot90(conj(b),2)) %sig proc tbx implementation

n = 12;

r = linspace(0,-2*pi,n+1);
a(:,:,2:n)=rect(a,(fliplr(size(a))+1)/2,fliplr(size(a)),r(2:end-1));

fprintf('correlating...\n')
c = convn(a, rot90(conj(b),2), 'same');
fprintf('done convn\n')

[yp,xp,zp]=ind2sub(size(c),find(c==max(c(:)),1,'first'));
tp = r(zp);
p=rot([xp yp],tp,fliplr(([size(a,1) size(a,2)]+1)/2));

if true
    subplot(fn,fm,f1)
    strip(a)
    
    subplot(fn,fm,f2)
    strip(c)
    
    figure
    P = contour3(c);
    
    plot3(xp,yp,P(zp),'ro')
    
    figure(fig)
    subplot(fn,fm,f1)
    y=size(a,1);
    plot(xp,(zp-1)*y+yp,'go')
    
    subplot(fn,fm,f2)
    plot(xp,(zp-1)*y+yp,'go')
end
end

function strip(x)
imagesc(reshape(permute(x,[1 3 2]),[size(x,1)*size(x,3) size(x,2)]));
axis equal
axis tight
hold on
end

function P=contour3(x)
[M,N,P]=size(x);
P = linspace(1,mean([M N]),P);
[X Y Z] = meshgrid(1:N, 1:M, P);

ps = [95 99 99.9];
n = length(ps);
c = colormap('jet');
c = c(ceil(linspace(1,size(c,1),n)),:);
ps = prctile(x(:),ps);

for i=1:n
    p = patch(reducepatch(isosurface(X,Y,Z,x,ps(i),'verbose'),.005));
    set(p,'FaceColor',c(i,:),'EdgeColor','none','FaceAlpha',.1);
    hold on
end

camlight
lighting phong
end

function y=rect(x,center,s,t,col,w)
r = ceil(repmat(center,1,2)+.5*[-1 -1 1 1].*repmat(s,1,2)); %left top right bottom

[xs ys]=meshgrid(linspace(r(1),r(3),s(1)),linspace(r(2),r(4),s(2)));
rs = rot([xs(:) ys(:)],t,center);

f = @(x)reshape(x,[s([2 1]) length(t)]);
y = interp2(x,f(rs(:,1,:)),f(rs(:,2,:)));

% mw = 'C:\Program Files (x86)\MATLAB\R2011b\toolbox\stats\stats\';
% oldDir = cd(mw);
y(isnan(y)) = nanmean(y(:));
% cd(oldDir);

if exist('col','var')
    r=rot(r([1 2; 3 2; 3 4; 1 4]),t,center);
    fill(r(:,1),r(:,2),'k','FaceColor','none','EdgeColor',col,'LineWidth',w);
end
end

function out = rot(x,t,c)
if ~isvector(t) || size(t,1)~=1
    error('t must be row vector')
end

cr = repmat(c,length(t),1);
out = permute(reshape((x-repmat(c,size(x,1),1))*[cos(t) -sin(t); sin(t) cos(t)] + repmat(cr(:)',size(x,1),1),[size(x,1) length(t) size(x,2)]),[1 3 2]);
end