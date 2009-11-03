%make simplistic neural response to flanker

%%  


sz=256;
x1=0.45;
x2=0.55;
y1=0.75;
y2=0.25;

baseline=imfilter(randn(sz,sz),fspecial('gauss',64,5));
stimInduced=imfilter(randn(sz,sz),fspecial('gauss',64,5))+.1;
stimLocations=zeros(sz);
%stimLocations(ceil(sz*[y1 y2]),ceil(sz*[x1 x2]))=1; % center of flankers
stimLocations(ceil(sz*y1),ceil(sz*x1))=1; % center of flanker 1
stimLocations(ceil(sz*y2),ceil(sz*x2))=1; % center of flanker 2
mask=imfilter(stimLocations,fspecial('gauss',128,20));
response=0.00005*baseline+stimInduced.*mask;
imagesc(response);

set(gca,'xTickLabel',[],'yTickLabel',[]); axis square;


%%  draw a simtulus of the flanker

%stimulus
%s=ifFeatureGoRightWithTwoFlank('basic')

params=getDefaultParameters(ifFeatureGoRightWithTwoFlank);
params.flankerContrast=1;
params.goRightContrast=0;
                         params.flankerOffset=2;
                         params.stdGaussMask=1/16;
                         params.pixPerCycs=32;            
                         params.maxHeight=1024;
                         
                         %params.pixPerCycs=80;            
                         params.gratingType='sine'
                         
[tm]=setFlankerStimRewardAndTrialManager(params, 'test');
stim=sampleStimFrame(tm);
imagesc(stim); colormap(gray)
set(gca,'xTickLabel',[],'yTickLabel',[],'TickLength',[0 0]); axis square;


