function unknownPleasuresOcto(dF)


figure
hold on
for i = 1:max(c);
    plot(mean(nanmean(dFrepeats(c==i,:,:),3),1))
end

dF = medfilt1(nanmean(dFrepeats(  c==3 | c==4,:,:),3),3,[],2);
%dF = medfilt1( dFrepeats(c==3 | c==4,:,1),3,[],2);
%dF = medfilt1(nanmean(dFrepeats( :,:,:),3),3,[],2);

npts = size(dF,2)
inds = randsample(size(dF,1),100);
figure; hold on

for i = length(inds):-1:1
    i
    h=bar(dF(inds(i),1:npts)*15 + i,1);
    set(h,'EdgeColor',[1 1 1]);
    set(h,'FaceColor',[1 1 1]);
    plot(dF(inds(i),1:npts)*15 + i,'k');
end
ylim([0 length(inds)+2]);
set(gca,'Xtick',0:100:400); set(gca,'Xticklabel',{'0','10','20','30','40'});
xlabel('secs'); ylabel('cell #')
