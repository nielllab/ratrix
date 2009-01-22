function [envelopeBW params] =fitGaussianEnvelopeToImage(im,stdThresh,whichForcedPositive,allowXandYsigma,allowRotation)

if ~length(size(im))==2
    error('must be 2d im')
end

if ~exist('stdThresh','var') || isempty(stdThresh)
    stdThresh=0.05;
end

if ~exist('whichForcedPositive','var') || isempty(whichForcedPositive)
    whichForcedPositive=logical(ones(size(im)))
else
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

%deMean
im=im-mean(im(:));

%use deflections in either direction, but ideally only where the FR area is
im(whichForcedPositive)=abs(im(whichForcedPositive));

%guess center of mass from peak, just for init
xd=sum(im,1);
yd=sum(im,2);
guessX=min(find(xd==max(xd))/size(im,2));
guessY=min(find(yd==max(yd))/size(im,1));

initParams=[guessX,guessY,0.01,0.2];

if allowXandYsigma
    initParams(end+1)=0.2;
    if allowRotation
        initParams(end+1)=0;
    end
end



opt = optimset([],'TolX',1e-9);
params = fminsearch(@(p) ellipseError(p,im,stdThresh,allowXandYsigma,allowRotation),initParams,opt);
params
[er envelopeBW]=  ellipseError(params,im,stdThresh,allowXandYsigma,allowRotation);



function [er elipse] =ellipseError(p,im,stdThresh,allowXandYsigma,allowRotation)
disp(p)

x0=p(1);
y0=p(2);
A=p(3);
sigma_x=p(4);

if allowXandYsigma
    sigma_y=p(5);
else
    sigma_y=p(4);
end

if allowRotation
    theta=p(6);
else
    theta=0;
end


a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;

    
[x y]=meshgrid(linspace(0,1,size(im,2)),linspace(0,1,size(im,1)));
g = A*exp( - (a*(x-x0).^2 + 2*b*(x-x0).*(y-y0) + c*(y-y0).^2)) ;

er = sum(sum((g-im).^2));

%if nargout>1
g=reshape(g,size(im,1),size(im,2));
elipse=g>stdThresh;
viewer=1;
if viewer
    if rand<0.01
        figure(1)
        values=im-(0.2*elipse);
        imagesc(values)
        %hist(im)
        %unique(values)
        %         size(x)
        %         size(y)
        %         size(g)
        %surf(x,y,g);
        pause(0.001)
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


