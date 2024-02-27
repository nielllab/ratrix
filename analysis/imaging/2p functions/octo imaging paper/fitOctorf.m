function [p g cc] = fitOctorf(z, zthresh);
%%% fit gaussian rf cmn 2012
%%% peak has to be reasonably high above background for this to work
%%%% fits to gauss2d
%%% p = [A B x0 y0 sigx sigy], where ...
%%% A = amplitude of baseline
%%% B = baseline
%%% x0,y0 = center coordinates
%%% sigx, sigy = width of gaussian
%%%%
%%% g = STA from fit


%%% estimate initial values
baseline = 0;
[amp ind] = max(abs(z(:)));
amp=z(ind);
[max_x max_y] = ind2sub(size(z),ind);

% peakarea = sum(abs(z(:))>0.4*abs(amp));
% sigx = sqrt(peakarea/pi);
% sigy= sigx;
sigx = 3;
sigy = 3;

[y x ] = meshgrid(1:size(z,2),1:size(z,1));

%%% vector of xy coordinates
xy = [x(:) y(:)]; 

%%% put initial estimates into parameter vector
p0(1) = amp;
p0(2) = baseline;
p0(3) = max_x;
p0(4) = max_y;
p0(5)= sigx;
p0(6)=sigy;

%%% perform fit
p = nlinfit(xy,z(:),@gauss2d,p0);
%p_all(:,n) = p;
%%% calculate estimated RF from fit parameters
fit= gauss2d(p,xy);
g= reshape(fit,size(z,1),size(z,2));
err = sqrt(mean((z(:)-fit).^2));
cc = corrcoef(z(:),fit);
cc = cc(1,2);
% figure
% subplot(1,2,1);
% imagesc(z'); axis equal; clim = get(gca,'Clim');
% subplot(1,2,2);
% imagesc(g',clim); axis equal
% sgtitle(sprintf('%d z=%0.1f',n, zscore(useOn(n),1)))
% colormap jet
% figure
% plot(z(round(p(3)),:)); hold on; plot(g(round(p(3)),:))
end