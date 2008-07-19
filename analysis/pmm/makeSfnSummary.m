function makeSfnSummary()


%%
load out\smallData.mat


%%
close all

figID=figure(5);
axisLineWidth=1.5;

subplot(4,2,1);
xPos=([1/4:1/4:1]-1/8);
params = [1/16 32 0 pi/2 1 0.001 1/2 1/2];
params=repmat(params,12,1);
params(:,7)=repmat(xPos,1,3);
params(1:4,8)=0.5+(1/8); %y position
params(9:12,8)=0.5-(1/8); 
params(logical([1 0 1 0 1 1 0 0 1 0 1 0]),4)=pi; %orientation, ((-1).^[1:12])>0
im=computeGabors(params,0.5,2048,768,'square','normalizeVertical',1);
imagesc(im);
colormap(gca,gray)
[m n]=size(im);
title('sample stimuli')
% set(h,'YTick', m*[1/8:1/8:1]-1/16)
set(gca,'XTick', n*xPos)
set(gca,'XTickLabel', {'vv', 'vh', 'hv', 'hh'}) % , 'v', '-', '-v', '-h'})
set(gca,'YTick', [])
set(gca,'YTickLabel', {})

%%

subplotParams.x=1; subplotParams.y=1; subplotParams.index=1; handles=[1:13];
whichPlots=[0 1 0 0 0 1 0 0 0 0 0 0 0]; %performance and density for all data
savePlots=whichPlots; 
dateRange=[now-200 now]
allowed=smallData.date>dateRange(1) & smallData.date<dateRange(2);
numTrials=sum(allowed);
inspectRatResponses('rat_102',[],whichPlots,handles,subplotParams,smallData,dateRange)

%life long performance 
p.x=2; p.y=4; p.index=3; h=copyFigure(2, 1, 5, 1, p) 
axis([1 numTrials .4 1])
title('life long performance')
set(h,'linewidth',axisLineWidth) 
set(h,'YTick', [.5 .85 1])
set(h,'YTickLabel', {'50%', '85%', '100%'})
set(h,'XTick', [1 numTrials*0.9])
set(h,'XTickLabel', {'1', sprintf('%d trials', numTrials)})

%density
p.x=2; p.y=4; p.index=2; h=copyFigure(6, 2, 5, 1, p)
[m n junk]=size(get(get(h, 'Children'), 'CData'))
axis([0 m-1 0 n-1])
title('response density')
set(h,'YTick', [.1*m .9*m])
set(h,'YTickLabel', {'1st day', 'last day'})
set(h,'XTick', [m/5 m/2 m*4/5])
set(h,'XTickLabel', {'morn', 'noon', 'eve'})
%colormap for density
C=hsv2rgb([linspace(0, .4, 256);...
    linspace(1, 1, 256);...
    linspace(.9, .9, 256)]')
%colormap(h,C) %how can we perserve this and keep the colormap for the sample stimuli (ARRGGHH!!)
% hc=colorbar
% get(hc)
% set(hc,'YTick', [25 230])
% set(hc,'YTickLabel', {'chance', '100%'})


subplotParams.x=1; subplotParams.y=1; subplotParams.index=1; handles=[101:113];
whichPlots=[0 1 0 0 0 0 0 0 0 0 0 0 0]; %performance and density for all data
savePlots=whichPlots; 
dateRange=[now-30 now]
allowed=smallData.date>dateRange(1) & smallData.date<dateRange(2);
numTrials=sum(allowed);
inspectRatResponses('rat_102',[],whichPlots,handles,subplotParams,smallData,dateRange)


%short performance 
p.x=2; p.y=4; p.index=4; h=copyFigure(102, 1, 5, 1, p) 
axis([1 numTrials .4 1])
set(h,'YTick', [.5 .85 1])
set(h,'YTickLabel', {'50%', '85%', '100%'})
set(h,'linewidth',axisLineWidth) 

subplotParams.x=1; subplotParams.y=1; subplotParams.index=1; handles=[101:113];
whichPlots=[0 0 1 0 0 1 0 0 0 0 0 1 0]; %performance and density for all data
savePlots=whichPlots; 
dateRange=[now-30 now]
allowed=smallData.date>dateRange(1) & smallData.date<dateRange(2);
numTrials=sum(allowed);
inspectRatResponses('rat_102',[],whichPlots,handles,subplotParams,smallData,dateRange)

%d prime 
p.x=2; p.y=4; p.index=6; h=copyFigure(102, 2, 5, 1, p) 
axis([1 numTrials -.2 2])
set(h,'linewidth',axisLineWidth) 
set(h,'YTick', [0 1 2])
set(h,'YTickLabel', {'0', '1', '2'})
ylabel('d''');
%xlabel('day');

%effect histogram
p.x=2; p.y=4; p.index=8; h=copyFigure(112, 1, 5, 1, p) 
%axis([1 numTrials -.2 2])
set(h,'linewidth',axisLineWidth) 
set(h,'YTick', [])
set(h,'YTickLabel', {})
ylabel('count');
set(h,'XTick', [-0.2  0  .2])
set(h,'XTickLabel', {'-20%', '0%', '+20%'})

xlabel('performance difference(VH-VV)');

% %correct per contrast 
allowed=smallData.date>dateRange(1) & smallData.date<dateRange(2);
smallData=restrictSmallData(smallData, allowed)
peekAtData
p.x=4; p.y=4; p.index=13; h=copyFigure(1, 4, 5, 1, p) 
axis([-.1 1.1 0.4 1])
set(h,'linewidth',axisLineWidth) 
title('%correct per contrast')
set(h,'XTick', [0 0.75 1])
set(h,'XTickLabel', {'0', '0.75', '1'})
set(h,'YTick', [.5 .85 1])
set(h,'YTickLabel', {'50%', '85%', '100%'})
xlabel('contrast');

%d prime per contrast
p.x=4; p.y=4; p.index=14; h=copyFigure(1, 2, 5, 1, p) 
axis([-.1 1.1 -.5 2])
set(h,'linewidth',axisLineWidth) 
title('d'' per contrast')
set(h,'XTick', [0 0.75 1])
set(h,'XTickLabel', {'0', '0.75', '1'})
set(h,'YTick', [0 1 2])
set(h,'YTickLabel', {'0', '1', '2'})
%ylabel('d''');
xlabel('contrast');
% who='sfnSummary102'; where='C:\Documents and Settings\rlab\Desktop\localAnalysis\plots';
% savePlotsToPNG(savePlots,handles(1),who,where);


load out\smallData_rat_133.mat
dateRange=[now-33 now];
allowed=smallData.date>dateRange(1) & smallData.date<dateRange(2);
smallData=restrictSmallData(smallData, allowed);

subplotParams.x=1; subplotParams.y=1; subplotParams.index=1; handles=[101:113];
whichPlots=[0 1 0 0 0 0 0 0 0 0 0 0 0]; %performance and density for all data
savePlots=whichPlots; 
inspectRatResponses('rat_133',[],whichPlots,handles,subplotParams,smallData,dateRange)
numTrials=4000;

%young rat performance
p.x=2; p.y=4; p.index=5; h=copyFigure(102, 1, 5, 1, p) 
axis([1 numTrials .4 1])
set(h,'linewidth',axisLineWidth) 
title('new rat performance')
set(h,'YTick', [.5 .85 1])
set(h,'YTickLabel', {'50%', '85%', '100%'})
%%
fullscreen(figID),set(gcf,'PaperPositionMode','manual'); 
set(gcf, 'PaperPosition', [1.0 0.1 7 9]); 
%orient(gcf, 'landscape');
print -dtiff -r150 sfnSummary.tif 

close (figID);

%%


function [graphicHandles numGraphics]=getGraphicsFromFigure(sourceFigure, subPlotNum)
figureHandle=sourceFigure;
axesHandles=get(figureHandle, 'Children'); %multiple values if there are subplots
axesHandle=axesHandles(subPlotNum); 
graphicHandles=get(axesHandle, 'Children');
numGraphics=size(graphicHandles,1);


function destination=copyFigure(sourceFigure, sourceSubPlot, destinationFigure, destinationSubPlot, destinationSubPlotParams)
figure(destinationFigure);
p=destinationSubPlotParams;
destination=subplot(p.y, p.x, p.index);
%destination=axes;
hold on;
[graphicHandles numGraphics]=getGraphicsFromFigure(sourceFigure, sourceSubPlot)
for i=fliplr([1:numGraphics])
    newH(i)=copyobj(graphicHandles(i),destination);
end