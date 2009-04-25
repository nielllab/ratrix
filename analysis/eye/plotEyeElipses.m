function  plotEyeElipses(eyeSig,ellipses,within,addText)

hold on; colorplot(eyeSig(:,1)',eyeSig(:,2)',20,[0.2,0.8,0.9],[0.7,0.0,0.1]); % overplot?
colors=jet(length(ellipses));
for i=1:length(ellipses)
    plot(eyeSig(within(:,i),1),eyeSig(within(:,i),2),'.','color',colors(i,:))
    e = fncmb(fncmb(rsmak('circle'),[ellipses(i).stds(1) 0;0 ellipses(i).stds(2)]),[ellipses(i).center(1);ellipses(i).center(2)]);
    fnplt(e,1,'k');
end
if addText
    infoString=sprintf('%2.0f%% (%2.0f%%)',100*mean(~isnan(eyeSig(:,2))), 100*mean(sum(within,2)>0)); %fraction of frames with eyeData
    text(max(eyeSig(:,1)),max(eyeSig(:,2)),infoString,'HorizontalAlignment','right','VerticalAlignment','top');
end