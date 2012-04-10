function cluster
clc
close all

if true
    if ismac
        file = '/Users/eflister/Desktop/waveformdata.mat'; % potential units: 5,6,11
    else
        file = 'C:\Users\nlab\Desktop\cluster\waveformdata.mat';
    end
    data = load(file);
    ics = data.score;
    
    ids = data.idx == 11;
    
    % get mean waveform across all leads
    dataMod = permute(data.X,[1 3 2]);
    dataMod = mean(reshape(dataMod,[prod(arrayfun(@(x) size(dataMod,x),[1 2])) size(dataMod,3)]));
    
    trodes = size(data.X,3);
    dims = prod(arrayfun(@(x) size(data.X,x),[2 3]));
    data = reshape(data.X,[size(data.X,1) dims]);
    
    % find ic's
    dataMod = data-repmat(dataMod,size(data,1),4);
    icDims = dataMod\ics; % solve dataMod*icDims=ics;
    err = abs(dataMod*icDims - ics);
    if false
        max(err(:))
    end
    
    % for testing, only use some of the data
    frac = .25;
    sel = rand(size(ids))<frac;
    ids = ids(sel);
    data = data(sel,:);
else
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

if exist('icDims','var') && false
    % project along ic's
    show(dataMod,icDims(:,1:2),ids,{'ic 1', 'ic 2'});
end

if false
    % project along first two dimensions
    k = eye(dims,2);
    show(data,k,ids,{'dim 1','dim 2'});
end

if false
    % project along principle components
    pca = princomp(data);
    show(data,pca(:,1:2),ids,{'pc 1','pc 2'})
    
    % useful to understand pca in terms of svd
    if false
        data = data-repmat(mean(data),c*n,1);
        
        [U,S,V] = svd(data); % data = U*S*V'
        S=diag(S);
        
        show(data,V(:,1:2)./repmat(S(1:2)',dims,1),ids,{'svd 1','svd 2'});
    end
end

% one good dimension is the one connecting the centroids of the clusters
d = diff(cell2mat(arrayfun(@(x) mean(data(ids==x,:)),unique(ids),'UniformOutput',false)));
d = d'/norm(d);

% http://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence
% kl distance is scalar measure of difference between two distributions
kl = getKL(data,ids,d+.1*d.*randn(dims,1));
%kl = getKL(data,ids,ones(dims,1));
%kl = getKL(data,ids,randn(dims,1));

show(data,[kl d],ids,{'kl','u diff'});
subplot(3,3,7)
plot(d-kl)
clean
axis tight
hold on

arrayfun(@(i) divideTrodes(i),[3 4 7 8])
    function divideTrodes(i)
        subplot(3,3,i)
        pos = linspace(1,dims,trodes+1);
        pos = pos(2:end-1);
        for p = pos
            plot(p*ones(1,2),100*[-1 1],'Color',.85*ones(1,3))
        end
    end
end

function show(data,dims,ids,labels)
if ~size(dims,2) == 2
    error('need exactly 2 dims')
end

u = unique(ids);
c = length(u);

% make unit vectors
dims = cell2mat(arrayfun(@(x) dims(:,x)/norm(dims(:,x)),1:size(dims,2),'UniformOutput',false));

proj = data*dims;

lims = cell2mat(arrayfun(@(x) minmax(proj(:,x)),(1:2)','UniformOutput',false));

fig = figure;
colors = colormap;
for i = 1:c
    inds = find(ids==u(i));
    
    color = colors(ceil(size(colormap,1)*i/c),:);
    
    subplot(3,3,3)
    plot(data(inds,:)','Color',color);
    hold on
    clean
    axis tight
    
    d = proj(inds,:);
    
    subplot(3,3,5)
    h=scatter(d(:,1),d(:,2),1,repmat(color,size(d,1),1),'.');
    h=get(h,'Children');
    for j=1:length(h)
        set(h(j),'HitTest','on');
        set(h(j),'ButtonDownFcn',{@callback,fig,data(inds(j),:),color});
    end
    
    if i == 1
        xlim(lims(1,:));
        ylim(lims(2,:));
        clean;
        xlabel(labels{1});
        ylabel(labels{2});
        hold on
    end
    
    subplot(3,3,2)
    distPlot(1,lims(1,:),false);
    
    subplot(3,3,6)
    distPlot(2,lims(2,:),true);
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
        plot(x,y,'Color',color);
        
        if i == 1
            f(lims);
            clean;
            hold on
        end
    end

arrayfun(@dimPlot,[8 4],1:2);
    function dimPlot(x,i)
        subplot(3,3,x)
        plot(dims(:,i))
        clean;
        axis tight
        hold on
    end

    function callback(src,evt,f,vect,color)
        figure(f);
        arrayfun(@(x)plotPoint(x,vect,color),[8 4]);
    end

hs = [];
    function plotPoint(x,vect,color)
        subplot(3,3,x)
        hs(end+1) = plot(vect/norm(vect),'Color',color);
    end

uicontrol('Style','pushbutton','String','clear','Units','normalized','Position',[.3 .3 .1 .1],'Callback',@clear);
    function clear(src,evt)
        delete(hs);
        hs = [];
    end
set(fig,'Toolbar','figure');
end

function clean
cellfun(@(x) set(gca,x,[]),{'XTick','YTick'});
end

function out = getKL(data,ids,x0)
u = unique(ids);
if length(u)~=2
    error('need exactly 2 ids')
end

demo = false;
if demo
    score(x0)
    score(randn(size(x0)))
    keyboard
end

if false
    opts = optimset('fminunc');
    opts.Diagnostics = 'on';
    opts.Display = 'iter-detailed';
    opts.FunValCheck = 'on';
    
    [out,~,exitflag,output] = fminunc(@score,x0,opts);
elseif true
    opts = optimset('fminsearch');
    opts.Display = 'iter';
    opts.FunValCheck = 'on';
    opts.TolFun = 10^-7;
    opts.TolX = 10^-7;
    
    [out,~,exitflag,output] = fminsearch(@score,x0,opts);
else
    n = 1000;
    tries = randn(size(x0,1),n);
    scores = arrayfun(@(x)score(x),1:n);
    [~,i] = min(scores);
    out = tries(:,i);
    
    output.message = '';
    exitflag = 1;
end
output
output.message
if exitflag < 1
    exitflag
    error('minimization problem')
end

    function out = score(x)
        x = x/norm(x); % would be better to use polar coordinates and use fmincon on a hemi-hypersphere
        % check http://en.wikipedia.org/wiki/N-sphere#Hyperspherical_coordinates
        % and cart2sph for 3-space
        d = data*x;
        m = minmax(d);
        
        bins = 10^5;
        dists = cell2mat(arrayfun(@(x) hist(d(ids==x),linspace(m(1),m(2),bins)),u,'UniformOutput',false))';
        dists = dists./repmat(sum(dists),bins,1);
        
        if demo
            figure
            plot(dists)
        end
        
        out = -kl(dists);
    end
end

function out = kl(d)
d = d+eps; % prevent nans/infs
out = sum(d(:,1).*reallog(d(:,1)./d(:,2)));
end

function out = minmax(in)
out = cellfun(@(f) f(in(:)),{@min @max});
end