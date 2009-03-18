function [within ellipses]=selectDenseEyeRegions(eyeSig,numRegions,stds,plotOn)
% regions are peaks in the histogram and are allowed to overlap
% within is a logical filter over eyeSamples.  [eyeSamples xnumRegions ]

numHistBins=20;
minmaxX=minmax(eyeSig(~isnan(eyeSig(:,1)),1)');
minmaxY=minmax(eyeSig(~isnan(eyeSig(:,2)),2)');

if ~exist('numRegions','var') || isempty(numRegions)
    numRegions=1;
end

if ~exist('stds','var') || isempty(stds)
    % dynamically choose a width of the data... 
    % bad b/c stable eyes will cut out more data!
    % good for testing algorithm when you don't know what a good measure is
    stds=[diff(minmaxX)  diff(minmaxY) ]/10
end

if ~exist('plotOn','var') || isempty(plotOn)
    plotOn=false;
end



edges{1}=linspace(minmaxX(1),minmaxX(2),numHistBins);
edges{2}=linspace(minmaxY(1),minmaxY(2),numHistBins);
[density, centers]=hist3(eyeSig,edges);

[ranked ids]=sort(density(:),'descend');
[x y]=ind2sub(size(density),ids(1:numRegions));  
% could somhow enforce that the don't overlap to get to different regions
% that were saccaded to... but doing the dumb thing now
regionCenters=[centers{1}(x)' centers{2}(y)'];
within=logical(zeros(length(eyeSig),numRegions));
for i=1:numRegions
    normX=(regionCenters(i,1)-eyeSig(:,1))./stds(1);
    normY=(regionCenters(i,2)-eyeSig(:,2))./stds(2);
    within(:,i)=sqrt(normX.^2+normY.^2)<1;
        ellipses(i).center=regionCenters(i,:);
        ellipses(i).stds=stds;
end
sum(within) % 
warning('why is first one zero?')

if plotOn
    figure; colorplot(eyeSig(:,1)',eyeSig(:,2)',20,[0.2,0.8,0.9],[0.7,0.0,0.1]);
    hold on;
    colors=jet(numRegions);
    %colorString={'b','c','y'}
    for i=1:numRegions
        plot(eyeSig(within(:,i),1),eyeSig(within(:,i),2),'.','color',colors(i,:))
        %[elat,elon] = ellipse1(ellipses(i).center(1),ellipses(i).center(2),[5 ellipses(i).stds(1)/ellipses(i).stds(2)]);
        %plotm(elat,elon,'c-')

        e = fncmb(fncmb(rsmak('circle'),[ellipses(i).stds(1) 0;0 ellipses(i).stds(2)]),[ellipses(i).center(1);ellipses(i).center(2)]);
        %fnplt(e,1,colorString{i});
        fnplt(e,1,'k');

    end

end
                
