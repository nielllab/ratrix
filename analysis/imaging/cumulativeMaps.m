
 use = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6') &  strcmp({files.task},'HvV_center') &strcmp({files.spatialfreq},'100') )

for f = 1:length(use)
    f
    load(fullfile(pathname,files(use(f)).topox),'dfof_bg');
    refmap = phaseMap(dfof_bg(:,:,:),10,10,1);
    tInd=0;
    for t = [100 200 300 600 1200]
        tInd=tInd+1
        map = phaseMap(dfof_bg(:,:,101:200+t),10,10,1);
        c(f,tInd)=abs(dot(map(:),refmap(:)))/(norm(map(:))*norm(refmap(:)))
    end
end

figure
errorbar([100 200 300 600 1200]/10 ,mean(c,1),std(c,[],1)/sqrt(7))
ylim([0 1])
        