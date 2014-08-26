figure
imshow(imresize(polarMap(map{1}),2))

[y x] = ginput(1);

for led = 1:3
figure

    data = squeeze(dfof{led}(round(x),round(y),541:2940));  
plot(0.1*(1:length(data)),data-prctile(data,5));
xlabel('secs')
ylabel('dF/F')

for p = 1:10;
    hold on
    plot([(p-1)*10 + 1 (p-1)*10+6],[ 0 0],'Color',[0.5 0.5 0.5],'linewidth',6)
end


for t = 1:100
    meandf(t) = mean(data(t:100:end));
end
figure
plot(meandf-min(meandf))
end

dt = 0.1;
t = (0:9)*dt;
tau = [0.18 0.55];
psf = (1-exp(-t/tau(1))).*exp(-t/tau(2));
psf = psf/sum(psf);


decondf = deconvlucy(repmat(meandf-min(meandf),[1 2]),psf);
decondf = decondf(6:105);
t= 0.1:0.1:10;
figure
plot(t,meandf-min(meandf),'g')
hold on
plot(t,decondf,'b');
xlabel('secs')
ylabel('dfof')