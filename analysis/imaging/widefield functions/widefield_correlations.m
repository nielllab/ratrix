%%% calculate correlations across time and space from widefield data
%%% loads in maps.mat file from widefield analysis
%%% user selects a point for center of analysis
%%% outputs:
%%% xc_all(n,t) = auto-correlation over time for all pixels in area
%%% lag_t = timepoints for cross-correlation over time
%%% xc_all_d(n) = correlation coefficient between pairs of pixels
%%% r(n) = distance between pixel pairs
%%% xc_d_mn(r) = correlation as a function of distance (in pix) from seed pixel

%%% load data
[fname pname] = uigetfile('*.mat','map file');
load(fullfile(pname,fname), 'dfof_bg','map');

%%% show polar map and select point
figure
imshow(polarMap(map{1}))
axis on
[xb yb] = ginput(1);
xb = round(xb); yb = round(yb);


%%% loop over pixels with xr bounding box and compute their auto-correlation
clear xc_all
n= 0;
nlags = 100;
xc = [];
xr = 50;
range= -50:50;
for x = xb-xr:xb+xr;
    for y = yb-xr:yb+xr;
        n = n+1;
        d = squeeze(dfof_bg(y,x,:));
        xc = xcorr(d,d,nlags,'coeff');
        xc_all(n,:) = xc;
    end
end

%%% plot mean autocorrelation
lag_t = (-nlags:nlags)*0.1;
figure
plot(lag_t,mean(xc_all,1))
xlabel('lag (secs');
ylabel('correlation coeff');

%%% loop over all pixels in bounding box and compute correlation
%%% coefficient with seed pixel
n=0;
xr = 100;
clear xc_all_d r
d = squeeze(dfof_bg(yb,xb,:));
for x = xb-xr:xb+xr;
    for y = yb-xr:yb+xr;
        n = n+1;
        d2 = squeeze(dfof_bg(y,x,:));
        xc = xcorr(d,d2,0,'coeff');
        xc_all_d(n) = xc;
        r(n) = sqrt((x-xb).^2 + (y-yb).^2);
        if xc_all_d(n)==0
            break
        end
    end
end

%%% bin based on distance from seed pixel
rd = round(r);
for i = 1:max(rd);
    xc_d_mn(i) = mean(xc_all_d(rd ==i));
end

%%% plot
figure
plot(r,xc_all_d,'.')
hold on
plot(1:max(rd),xc_d_mn)
xlabel('distance (pixels)');
ylabel('correlation');





