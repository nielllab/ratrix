function cluster
clc
close all

if true
    dims = 50;
    n = 1000;
    c = 2;
    
    % make c clusters with n datapoints each in dims dimensional space
    for i = 1:c
        mu = randn(1,dims);%*20*i;
        sig = randn(dims);
        sig = sig'*sig; % covariance matrix must be symmetric positive semi-definite (x'Mx >= 0)
        
        data(:,:,i) = mvnrnd(mu,sig,n);
    end
    
    ids = reshape(repmat(1:c,n,1),[c*n 1]);
    
    % flatten list
    data = reshape(permute(data,[1 3 2]),[c*n dims]);
end

% project along first two dimensions
k = eye(dims,2);
show(data,k,ids,{'dim 1','dim 2'});

% project along principle components
pca = princomp(data);
show(data,pca(:,1:2),ids,{'pca 1','pca 2'})

% useful to understand pca in terms of svd
if false
    data = data-repmat(mean(data),c*n,1);
    
    [U,S,V] = svd(data); % data = U*S*V'
    S=diag(S);
    
    show(data,V(:,1:2)./repmat(S(1:2)',dims,1),ids,{'svd 1','svd 2'});
end

% one good dimension is the one connecting the centroids of the clusters
d = diff(cell2mat(arrayfun(@(x) mean(data(ids==x,:)),[1; 2],'UniformOutput',false)));
d = d'/norm(d);

% http://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence
% kl distance is scalar measure of difference between two distributions
% (the hill climbing isn't working yet...)
%kl = getKL(data,ids,d);
kl = getKL(data,ids,ones(dims,1));

show(data,[kl d],ids,{'kl','u diff'});
end

function show(data,dims,ids,labels)
if ~size(dims,2) == 2
    error('need exactly 2 dims')
end

u = unique(ids);
c = length(u);

data = data*dims;

xlims = minmax(data(:,1));
ylims = minmax(data(:,2));

    function out = minmax(in)
        out = cellfun(@(f) f(in(:)),{@min @max});
    end

colors = colormap;
f = figure;
for i = 1:c
    color = colors(ceil(size(colormap,1)*i/c),:);
    
    subplot(3,3,5)
    d = data(ids==u(i),:);
    plot(f,d(:,1),d(:,2),'.','Color',color);
    
    if i == 1
        xlim(xlims);
        ylim(ylims);
        clean;
        xlabel(labels{1});
        ylabel(labels{2});
        hold on
    end
    
    subplot(3,3,2)
    distPlot(1,xlims,false);
    
    subplot(3,3,6)
    distPlot(2,ylims,true);
end

    function clean
        cellfun(@(x) set(gca,x,[]),{'XTick','YTick'});
    end

    function distPlot(col,lims,vert)
        bins = linspace(lims(1),lims(2),100);
        h = hist(d(:,col),bins);
        if vert
            x=h;
            y=bins;
            f=@ylim;
        else
            x=bins;
            y=h;
            f=@xlim;
        end
        plot(f,x,y,'Color',color);
        
        if i == 1
            f(lims);
            clean;
            hold on
        end
    end

arrayfun(@dimPlot,[8 4],1:2);
    function dimPlot(x,i)
        subplot(3,3,x)
        plot(f,dims(:,i))
        clean;
    end
end

function out = getKL(data,ids,x0)
u = unique(ids);
if length(u)~=2
    error('need exactly 2 ids')
end

out = fminunc(@score,x0);
    function out = score(x)
        x = x/norm(x); % would be better to use polar coordinates and use fmincon on a hemi-hypersphere
        d = data*x;
        m = minmax(d);
        
        dists = cell2mat(arrayfun(@(x) hist(d(ids==x),linspace(m(1),m(2),100)),u,'UniformOutput',false));
        out = -kl(dists');
    end
end

function out=kl(d)
d=d+eps;%prevent nans/infs
out=sum(d(:,1).*reallog(d(:,1)./d(:,2)));
end