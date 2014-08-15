function [out, fig] = ledCluster(data)
sz = size(data);
sz = sz(1:2);

ex = rand(1,size(data,3))<.05;

x = double(reshape(permute(data(:,:,ex),[3 1 2]),sum(ex),[]));

m = mean(x);
g = std(x) + eps;
[u,s,v] = svd((x-repmat(m,size(x,1),1))./repmat(g,size(x,1),1),'econ');

t = nan(size(data,3),2);
for i=1:size(data,3)
    t(i,:) = ((double(reshape(data(:,:,i),1,[]))-m)./g)*v(:,1:2); %this reshape is slow and can be done all at once before the loop, but requires space to copy input
end

n = t/s(1:2,1:2);

k=2;
obj = gmdistribution.fit(n,k);
idx = cluster(obj,n);

[~,ord] = sort(obj.PComponents);

fig = figure;
subplot(2,2,2)
hold on
arrayfun(@(x,y)plot(n(idx==ord(x),1),n(idx==ord(x),2),[y '.']),1:k,'gb');
plot(u(:,1),u(:,2),'r.','MarkerSize',1)
axis equal

subplot(2,2,3)
imagesc(mean(data,3))
subplot(2,2,1)
imagesc(reshape(v(:,2),sz))
subplot(2,2,4)
imagesc(reshape(v(:,1),sz))

out = ord(idx);
end

function scratch
f =     'D:\Widefield (12-10-12+)\022213\gcam13tt_r2\gcam13tt_r2g\gcam13tt_r2_123_133_30449.mat';
f = '\\coen\Widefield (12-10-12 )\022213\gcam13tt_r2\gcam13tt_r2g\gcam13tt_r2_123_133_30449.mat';
data = load(f);
sz = size(data.data);
sz = sz(1:2);

d = reshape(permute(data.data,[3 1 2]),size(data.data,3),[]);

ex = rand(1,size(d,1))<.005;

x = double(d(ex,:));

if false
    tic
    [c,s,l] = princomp(zscore(x),'econ');
    toc
    
    figure
    subplot(2,2,2)
    plot(s(:,1),s(:,2),'.')
    axis equal
    
    subplot(2,2,3)
    imagesc(mean(data.data,3))
    subplot(2,2,1)
    imagesc(reshape(c(:,2),sz))
    subplot(2,2,4)
    imagesc(reshape(c(:,1),sz))
end

m = mean(x);
g = std(x);
tic
[u,s,v] = svd((x-repmat(m,size(x,1),1))./repmat(g+eps,size(x,1),1),'econ');
toc

if false %too memory intensive to expand d
    t = double(d)*v(:,[1:2]);
else
    t = nan(size(d,1),2);
    if false
        m = mean(d);
        if false %need doubles
            g = std(d);
        else
            g = nan(1,size(d,2));
            for i=1:size(d,2)
                g(i) = std(double(d(:,i)));
            end
        end
    end
    tic
    for i=1:size(d,1)
        t(i,:) = ((double(d(i,:))-m)./(g+eps))*v(:,[1:2]);
    end
    toc
end
if true
    old_u = u;
    u = t/s(1:2,1:2);
    
    if true
        figure
        plot(old_u(:,1:2),'r','LineWidth',3)
        hold on;
        plot(u(ex,1:2),'y')
    end
end

k=2;
options = statset('Display','final');
options = statset();
tic
obj = gmdistribution.fit(u(:,1:2),k,'Options',options);
toc
tic
idx = cluster(obj,u(:,1:2));
toc

[~,ord] = sort(obj.PComponents,'descend');

figure
subplot(2,2,2)
hold on
arrayfun(@(x,y)plot(u(idx==ord(x),1),u(idx==ord(x),2),[y '.']),1:k,'bg');
plot(old_u(:,1),old_u(:,2),'rx')
% axis equal

subplot(2,2,3)
imagesc(mean(data.data,3))
subplot(2,2,1)
imagesc(reshape(v(:,2),sz))
subplot(2,2,4)
imagesc(reshape(v(:,1),sz))

keyboard
end