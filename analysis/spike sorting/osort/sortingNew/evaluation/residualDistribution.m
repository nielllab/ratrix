
figure(200);
    
for i=1:length(useNegative)
    clnr=useNegative(i);
    
    spikes = allSpikesNoiseFree ( find(assignedNegative==clnr), :);
    %spikes = newSpikesNegative ( find(assignedNegative==clnr), :);
    
    m=mean(spikes);
    
    resd = (spikes - repmat(m,size(spikes,1),1)).^2;
    
    resdsum=[];
    for j=1:size(spikes,1)
        resdsum(j)=sum(resd(j,:));
    end
    

    subplot(3,3,i);
    hist(resdsum,100);
    xlim([1 100]);
    
    xlabel(['residuals for cl ' num2str(clnr)]);
end


mean(std(allSpikesNoiseFree))