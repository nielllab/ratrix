function explainShuffleCI(nullDist,data)

maxX=5;
maxY=100;
edges=linspace(-maxX,maxX,100);
count=histc(nullDist,edges);



nullDist=sort(nullDist);
lowTail=ceil(0.05*length(nullDist));
pastThresh=nullDist(1:lowTail);

sigCount=histc(pastThresh,edges);
max(pastThresh)



hold off; 
fill([nullDist(lowTail([1 1])); maxX; maxX],maxY*[0 1 1 0],'r','faceColor',[0.9 0.9 0.9],'edgeColor',[0.9 0.9 0.9]);
hold on;
b=bar(edges,count,'histc'); set(b,'FaceColor','k');
yl=ylim;
plot(data,yl(2)/2,'bo')
b=bar(edges,sigCount,'histc'); set(b,'FaceColor','b','EdgeColor','b');
axis([-maxX maxX 0.01 maxY])
xlabel('\Delta % correct')
ylabel('probability')
set(gca,'yTick',[0 maxY],'yTickLabel',[0 maxY/length(nullDist)])
cleanUpFigure


