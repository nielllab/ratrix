figure
for i = 1:1
    for j=1:length(yrange)
        
        spotimg = squeeze(mean(tuning(:,:,i,j,:,1),5));
        imagesc(spotimg,[0 0.03]);
        title(sprintf('%0.2fx %0.2fy',i,j))
        axis off; axis equal
    end
end


[ypt xpt] = ginput(1);

xtrials = find(xpos==1);


for rep=1:100;
thesetrials = ceil(rand(length(xtrials),1)*length(xtrials));
    spotimg = squeeze(mean(trialdata(:,:,xtrials(thesetrials)),3));

    crossSection = mean(spotimg(round(xpt)+(-3:3),:),1);
figure
plot(crossSection);
crossSection = crossSection(100:199);
baseline_est=median(crossSection);
[peak_est x0_est] = max(crossSection);
sigma_est=5;
x=1:length(crossSection);
y=crossSection;
fit_coeff = nlinfit(x,y,@gauss_fit,[ baseline_est peak_est x0_est sigma_est])

%%% parse out results
baseline = fit_coeff(1)
peak = fit_coeff(2)
x0=fit_coeff(3)
sigma_est=fit_coeff(4)

%%% plot raw data and fit
% figure
% plot(x,y)
% hold on
% plot(x,gauss_fit(fit_coeff,x),'g')
xfit(rep)=x0;
fwhm(rep) = 2*sigma_est*1.17*32.5;
end
