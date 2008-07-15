function pmmInspect
%what philip wants to look at
% with the intention of being really quick daily analysis that matters


%%
numFig=18; %number of possible figures
j=0;
%%
 
 subjects={'117','130','144'}
 who='tiltDiscrim';
 subplotParams.x=2; subplotParams.y=2; 
  j=j+1; handles=j.*numFig+[1:numFig];
 dateRange=[now-30 now];
 numRats=size(subjects,2)*size(subjects,1);
 whichPlots=zeros(1,numFig);
 whichPlots([17 18])=1;
 for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
 end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);


%%
 subjects={'138','139','227','228','231','232','229','230','233','234','237','238'};
 who='15ers';
 subplotParams.x=4; subplotParams.y=3; 
 j=j+1; handles=j.*numFig+[1:numFig];
 dateRange=[now-40 now];
 numRats=size(subjects,2)*size(subjects,1);
 whichPlots=zeros(1,numFig);
 whichPlots(10)=1; %+18,17
 for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange); 
    allBeforeTilt=d.trialNumber<=(d.trialNumber(max(find(d.flankerPosAngle==0))));
    d=removeSomeSmalls(d,allBeforeTilt); %datestr(d.date(min(find(d.flankerPosAngle==pi/12))),22)
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
 end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);

%% overlap hack  --turn off doInset in inspect rat response to get it to work

 subjects={'138','139','227','228','231','232','229','230','233','234','237','238'};
 who='15ers';
 subplotParams.x=4; subplotParams.y=3; 
 %subplotParams.x=2; subplotParams.y=1;  subjects={'138','228'};
 j=j+1; handles=j.*numFig+[1:numFig];
 dateRange=[now-90 now];
 numRats=size(subjects,2)*size(subjects,1);
 whichPlots=zeros(1,numFig);
 whichPlots(10)=1; %+18,17
 figure; hold on
 for i=1:numRats
    subplotParams.index=i; % set to 1
    d=getSmalls(subjects{i},dateRange);
    %allBeforeTilt=d.trialNumber<=(d.trialNumber(max(find(d.flankerPosAngle==0))));
    if ismember('currentShapedValue',fields(d))
        allBut3to4and8=~ismember(d.currentShapedValue,[0.2,0.3,0.4,0.8])
        d=removeSomeSmalls(d,allBut3to4and8); %datestr(d.date(min(find(d.flankerPosAngle==pi/12))),22)
        if length(d.date)>100
            inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
        end
    end
 end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);

%%
subjects= {'136','137','131','135'};
who='goToSide';
subplotParams.x=2; subplotParams.y=2;
j=j+1; handles=j.*numFig+[1:numFig];
dateRange=[now-10 now];
numRats=size(subjects,2)*size(subjects,1);
whichPlots=zeros(1,numFig);
%whichPlots(10)=1;
for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
end
where='C:\Documents and Settings\rlab\Desktop\graphs\'
savePlotsToPNG(whichPlots,handles,who,where);
