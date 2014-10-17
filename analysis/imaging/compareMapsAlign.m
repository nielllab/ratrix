function resp = compareMapsAlign(files,pts, xshift,yshift, theta,zoom,sz)


for doi = 1:2
    [f,p] = uigetfile('*.mat',filetype{doi});
    load(files{doi},'cycle_mov');
    for f = 1:length(cycle_mov,3)
        mov{doi}(:,:,f) = shiftImageRotate(squeeze(cycle_mov(:,:,f)),xshift,yshift,theta,zoom,sz);
    end
end

for doi=1:2;
    [peakmax{doi} peaktime{doi}] = max(mov{doi},[],3);
end
figure
imagesc(peaktime{2}-peaktime{1},[-5 5]);
title('latency difference')
figure
imagesc(peakmax{2}-peakmax{1},[-0.05 0.05]);
title('amplitude difference');

    for n=1:size(pts,1);

        range = -3:3;
        figure
        resp(n,1,:)=squeeze(mean(mean(mov{1}(pts(n,1)+range,pts(n,2)+range,:),2),1));
        plot(resp(n,1,:),'g');
        hold on
        resp(n,2,:) =squeeze(mean(mean(mov{2}(pts(n,1)+range,pts(n,2)+range,:),2),1));
        plot(resp(n,2,:),'r')
        title(sprintf('point %d',n));
        legend{'control','doi'};

    end



