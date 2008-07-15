function pmmInspect
%what philip wants to look at
% with the intention of being really quick daily analysis that matters



numFig=18; %number of possible figures
j=0;

 
 subjects={'117','130','144'}
 who='tiltDiscrim';
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


%%
 subjects={'138','139','227','228','231','232','229','230','233','234','237','238'};
 who='15ers';
 subplotParams.x=4; subplotParams.y=3; 
 j=j+1; handles=j.*numFig+[1:numFig];
 dateRange=[now-40 now];
 numRats=size(subjects,2)*size(subjects,1);
 whichPlots=zeros(1,numFig);
 whichPlots(18)=1; %+10
 for i=1:numRats
    subplotParams.index=i;
    d=getSmalls(subjects{i},dateRange);
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
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
