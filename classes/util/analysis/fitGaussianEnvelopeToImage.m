function [envelopeBW params] =fitGaussianEnvelopeToImage(im,stdThresh,whichForcedPositive,allowXandYsigma,allowRotation)

if ~length(size(im))==2
    error('must be 2d im')
end

if ~exist('stdThresh','var') || isempty(stdThresh)
    stdThresh=1.96; % whats right for a 2d gauss?
end

if ~exist('whichForcedPositive','var') || isempty(whichForcedPositive)
    whichForcedPositive=logical(zeros(size(im)));
else
    if (all([1 1]==size(whichForcedPositive)) & islogical(whichForcedPositive))
        whichForcedPositive=whichForcedPositive(ones(size(im)));
    end
    if ~(all(size(im)==size(whichForcedPositive)) & islogical(whichForcedPositive))
        class(whichForcedPositive)
        error('whichForcedPositive must be a mask of logicals the size of the image')
    end
end

if ~exist('allowXandYsigma','var') || isempty(allowXandYsigma)
    allowXandYsigma=true;
end

if ~exist('allowRotation','var') || isempty(allowRotation)
    allowRotation=true;
end

if any(whichForcedPositive)
    %deMean
    im=im-mean(im(:));
    
    %use deflections in either direction, but ideally only where the FR area is
    im(whichForcedPositive)=abs(im(whichForcedPositive));
    
    im=im/sum(im(:)); % more like a pdf
end

%guess center of mass from peak, just for init
xd=sum(im,1);
yd=sum(im,2);
guessX=min(find(xd==max(xd))/size(im,2));
guessY=min(find(yd==max(yd))/size(im,1));

initParams=[mean(im(:)) guessX,guessY,1,0.2];

if allowXandYsigma
    initParams(end+1)=0.4;
    if allowRotation
        initParams(end+1)=0;
    end
end

% i think this is for 1D, not 2D! does it need a sqtr(2) or something fancier?
probabilityThresh= 1-diff(normcdf([-stdThresh stdThresh])); %   1.96 = 95% confidence interval for gaussian, norminv(.975)

opt = optimset([],'TolX',1e-9); % increase 'MaxFunEvals'
params = fminsearch(@(p) ellipseError(p,im,probabilityThresh,allowXandYsigma,allowRotation),initParams,opt);
[er envelopeBW]=  ellipseError(params,im,probabilityThresh,allowXandYsigma,allowRotation);
params(5)=params(5)*stdThresh; % adjust for requested bound


function [er elipse] =ellipseError(p,im,probabilityThresh,allowXandYsigma,allowRotation)
%disp(p)

mean=p(1);
x0=p(2);
y0=p(3);
A=p(4);
sigma_x=p(5);

if allowXandYsigma
    sigma_y=p(6);
else
    sigma_y=p(5);
end

if allowRotation
    theta=p(7);
else
    theta=0;
end

enforceBoundaries=false;
if enforceBoundaries
    cs=1; % use a quadatric cost scalar than punishes bad values... feels very hack
    
    % % 1) amplitude can't just vanish (bad local minimum is the squared error of the STA)
    % if A<0.5; A=0.5; end
    Amin=0.5; % this is dangerous b/c it makes you inc your AMP. and thus reduce your STD
    cs=cs*(1+(Amin-A).^2*(A<Amin));
    
    % % 2) niether x0 nor y0 can leave the screen;  could relax this so that it
    % % could be off by 1-2 std... but really...?
    % if  x0>1; x0=1;  end
    % if  x0<0; x0=0;  end
    % if  y0>1; y0=1;  end
    % if  y0<0; y0=0;  end
    cs=cs*(1+(x0-1).^2*(x0>1));
    cs=cs*(1+(0-x0).^2*(x0<1));
    cs=cs*(1+(y0-1).^2*(y0>1));
    cs=cs*(1+(0-y0).^2*(y0<1));
    
    
    %
    % % 3) sigmaX and y can't get smaller than 1/30 of the screen
    minSTD=1/100;
    % if  sigma_x<minSTD; sigma_x=minSTD;  end
    % if  sigma_y<minSTD; sigma_x=minSTD;  end
    cs=cs*(1+(minSTD-sigma_x).^2*(sigma_x<minSTD));
    cs=cs*(1+(minSTD-sigma_y).^2*(sigma_y<minSTD));
    
else
    cs=1; % cost scalar is one, thus using normal squared error
end



a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;


[x y]=meshgrid(linspace(0,1,size(im,2)),linspace(0,1,size(im,1)));
g = exp( - (a*(x-x0).^2 + 2*b*(x-x0).*(y-y0) + c*(y-y0).^2)) ;

g2=mean+A*g;
er = sum(sum((g2-im).^2))*cs;


%if nargout>1
g=reshape(g,size(im,1),size(im,2));
elipse=g>probabilityThresh;
viewer=0;
if viewer
    if rand<0.01
        figure(1)
        values=im-(0.2*elipse);
        subplot(1,3,1); imagesc(values)
        subplot(1,3,2); imagesc((g2-im).^2); colormap(gray)
        subplot(1,3,3); imagesc(elipse); colormap(gray)
        text(5,5,sprintf('%2.2f',cs),'color',[1 0 0])
        %hist(im)
        %unique(values)
        %         size(x)
        %         size(y)
        %         size(g)
        %surf(x,y,g);
        pause(0.1)
    end
end
%end



% rm=[cos(p(4)) -sin(p(4)); sin(p(4)) cos(p(4))]; % rotation matrix
% c=[p(3) 0; 0 p(3)]; %basic covariance matrix = scaled inentity
% Sigma = rm*c % rm'*c*rm
% %Sigma = [p(3) p(4); p(4) p(3)*p(5)]
% mu = [p(1) p(2)];
% [x y]=meshgrid(linspace(0,1,size(im,2)),linspace(0,1,size(im,1)));
% X=[x(:) y(:)];
% g = mvnpdf(X, mu, Sigma);



%%% fspecial('gaussian',size(im),SIGMA)
% miss=sum(sum(elipse==0 & bw==1));
% fp=sum(sum(elipse==1 & bw==0));
%
% er=(fp*fp2missPenaltyRatio)+miss;
% % unstable
% %could adjust fp & miss to be the distance from the elipse boundary...
%
% viewer=1;
% if viewer
%     figure(1)
% values=(elipse*3)-(2*bw);
% imagesc(values)
% %pause(0.1)
% end


