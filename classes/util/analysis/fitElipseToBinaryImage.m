function [elipseBW params] =fitElipseToBinaryImage(bw)

if ~all(ismember(unique(bw),[0 1]))
    error('only 1 or 0 in biniary Image')
end

if ~exist('fp2missPenaltyRatio','var') || isempty(fp2missPenaltyRatio)
      fp2missPenaltyRatio=1;
end

%test error
 ellipseError(bw,fp2missPenaltyRatio,.5,.5,1,1,0)

      
fp2missPenaltyRatio=1;
params = fminsearch(@(x) ellipseError(bw,fp2missPenaltyRatio,x(1),x(2),x(3),x(4),x(5)),[0.5,0.5,1,1,0]);
params
[er elipseBW]=  ellipseError(bw,fp2missPenaltyRatio,params(1),params(2),params(3),params(4),params(5));
er

function [er elipse fp miss] =ellipseError(bw,fp2missPenaltyRatio,xCenter,yCenter,xScale,yScale,rotation)
% no rotatation in yet

[x y]=meshgrid(linspace(0,1,size(bw,2)),linspace(0,1,size(bw,1)));
x=xScale*(x-xCenter);
y=yScale*(y-yCenter);
elipse=x.^2+y.^2<0.3;
miss=sum(sum(elipse==0 & bw==1));
fp=sum(sum(elipse==1 & bw==0));
er=(fp*fp2missPenaltyRatio)+miss;
% unstable
%could adjust fp & miss to be the distance from the elipse boundary...

viewer=1;
if viewer
    figure(1)
values=(elipse*3)-(2*bw);
imagesc(values)
%pause(0.1)
end


