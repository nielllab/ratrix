function align
close all
dbstop if error

filename = 'C:\eflister\Miles_Davis-Tutu-Interior_Frontal.jpg';
filename = 'Miles_Davis-Tutu-Interior_Frontal.jpg';

x=imread(filename);
x=double(x(:,:,1));
d=size(x);

n=400;
[xs,ys] = meshgrid(linspace(1,d(2),n),linspace(1,d(1),n));
x=interp2(x,xs,ys);
d=size(x);

snip = [.27 .32];
%snip = [.4 .5];

c = [.4 .65]; %normalized x y
c = snip/2+rand(1,2).*(1-snip);
t = -pi/6 - pi/12; %radians, positive = ccw
t = 10^6*randn;

s = ceil(snip.*d); %width height

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

xc = conv2(zs(z), rot90(zs(y),2), 'same');

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

[p tp fig3 P r] = xcorrn(zs(x),zs(y),g2(2),g2(3),n,m,fig);
[p tp]
[center t]

fig2=figure;
subplot(2,1,1)
merge(x,y,p,tp);

[tpo, po] = optimize(zs(x),zs(y),tp);
figure(fig2)
subplot(2,1,2)
merge(x,y,po,tpo);

rs=wrap(r,0,2*pi);
inds=find(diff(rs)>0);
rs(inds)=rs(inds)+2*pi;
if any(diff(rs)>0)
    error('whoops')
end

figure(fig3)
p3(po,tpo,'ko',5);
p3(center,t,'ro',7);
p3(c,t,'go',10);

    function p3(pp,tpp,m,ms)
        pr=rot(pp,-tpp,fliplr(([size(x,1) size(x,2)]+1)/2));
        to = interp1(rs,P,wrap(tpp,0,2*pi));
        if any(isnan([pr to]))
            error('got nan')
        end
        plot3(pr(1),pr(2),to,m,'MarkerSize',ms)
    end

wrap(t,0,2*pi)
end

function in=wrap(in,min,range)
in = in-range*floor((in-min)/range);
end

function [out,p]=optimize(x,y,tp)

    function out=score(t)
        r = rect(y,fliplr(size(y)+1)/2,fliplr(size(y)),-t);
        c = conv2(x, rot90(r,2), 'same');
        [out,p] = max(c(:));
        out = -out;
        [i j] = ind2sub(size(c),p);
        p = [j i];
    end

problem.objective=@score;
problem.lb=0;
problem.ub=2*pi;

if false %faster to use bounds than constraints, even though we can't give good initial point, but then gets stuck in local mins
    problem.options=optimset(optimset('fminbnd'),optimset('FunValCheck','on','Display','iter','PlotFcns',{@optimplotx,@optimplotfval}));
    
    [out,fval,exitflag,output] = fminbnd(problem.objective,problem.lb,problem.ub,problem.options);
else
    problem.x0=wrap(tp,problem.lb,problem.ub-problem.lb);
    problem.Aineq=[];
    problem.bineq=[];
    problem.Aeq=[];
    problem.beq=[];
    problem.nonlcon=[];
    problem.solver='fmincon';
    
    problem.options=optimset(optimset('fmincon'),optimset('Algorithm','active-set','Diagnostics','on','FunValCheck','on','PlotFcns',{@optimplotx,@optimplotfval},'Display','iter-detailed')); %'notify-detailed'
    % picks sqp for us, even if we ask for active-set
    %'Algorithm','interior-point'
    [out,fval,exitflag,output,lambda,grad,hessian] = fmincon(problem);
end

if exitflag~=1
    warning('bad exit')
    exitflag
end
output.message
out
wrap(tp,problem.lb,problem.ub-problem.lb)

if score(tp)<score(out) %careful! we depend on side effect of score(out) setting final value for p!
    warning('fmin* returned worse point than initial value!') %added this once i saw a case where this should trip
end
end

function merge(x,y,p,tp)
im(:,:,1) = normalize(x);
im(:,:,[2 3]) = 0;

y=rect(y,fliplr(size(y)+1)/2,fliplr(size(y)),-tp,[],[],false);

y(isnan(y))=0;
y=normalize(y);

xs = round(p(2)+(1:size(y,1))-size(y,1)/2);
ys = round(p(1)+(1:size(y,2))-size(y,2)/2);
xout = xs <= 0 | xs > size(x,1);
yout = ys <= 0 | ys > size(x,2);
xs=xs(~xout);
ys=ys(~yout);

im(xs,ys,2) = y(~xout,~yout);

imagesc(im)
axis equal
axis tight
end

function x=normalize(x)
x = x-min(x(:));
x = x/max(x(:));
end

function [p tp fig2 P r]=xcorrn(a,b,f1,f2,fn,fm,fig)
% conv2(a, rot90(conj(b),2)) %sig proc tbx implementation
fig2 = [];
P = [];

n = 12;

r = linspace(0,-2*pi,n+1);
%r=r(1:end-1);
a(:,:,2:n+1)=rect(a,(fliplr(size(a))+1)/2,fliplr(size(a)),r(2:end));

fprintf('correlating...\n')
br = rot90(b,2);
if false
    c = convn(a, br, 'same');
else %sadly faster
    c = nan(size(a));
    for i=1:size(a,3)
        c(:,:,i)=conv2(a(:,:,i), br, 'same');
    end
end
fprintf('done convn\n')

[yp,xp,zp]=ind2sub(size(c),find(c==max(c(:)),1,'first'));
tp = r(zp);
p=rot([xp yp],tp,fliplr(([size(a,1) size(a,2)]+1)/2));

if true
    subplot(fn,fm,f1)
    strip(a)
    
    subplot(fn,fm,f2)
    strip(c)
    
    fig2 = figure;
    P = contour3(c);
    
    plot3(xp,yp,P(zp),'co')
    
    figure(fig)
    subplot(fn,fm,f1)
    y=size(a,1);
    plot(xp,(zp-1)*y+yp,'co')
    
    subplot(fn,fm,f2)
    plot(xp,(zp-1)*y+yp,'co')
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

function y=rect(x,center,s,t,col,w,doNan)
r = ceil(repmat(center,1,2)+.5*[-1 -1 1 1].*repmat(s,1,2)); %left top right bottom

[xs ys]=meshgrid(linspace(r(1),r(3),s(1)),linspace(r(2),r(4),s(2)));
rs = rot([xs(:) ys(:)],t,center);

f = @(x)reshape(x,[s([2 1]) length(t)]);
y = interp2(x,f(rs(:,1,:)),f(rs(:,2,:)));

if ~exist('doNan','var') || isempty(doNan) || doNan
    mw = 'C:\Program Files (x86)\MATLAB\R2011b\toolbox\stats\stats\';
    oldDir = cd(mw);
    y(isnan(y)) = nanmean(y(:));
    cd(oldDir);
end

if exist('col','var') && ~isempty(col)
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