function unknownPleasures(dF)

figure
hold on
inds = 1:size(dF,1)
colordef black
set(gcf,'Color',[0 0 0])

for i = length(inds):-1:1
    
    h=bar(dF(inds(i),1:1000)/4 + i,1);
    set(h,'EdgeColor',[0 0 0]);
    plot(dF(inds(i),1:1000)/4 + i,'w');
end
axis off
xlim([1 1000])
set(gca,'Position',[0.2 0.2 0.6 0.65])

colordef white