function doQuickInspect(subjects,heatViewed,boxViewed,daysBackAnalyzed,suppressUpdates,seeBW,justOne,whichOne,more,rackNum)


%% 
if ~exist('subjects','var')

    subjects=getCurrentSubjects();
    heatViewed=        2;  %1-5; 0 allows all rats and weeklyReports
    boxViewed=         0;  %1-6; filters which box, 0 allows all boxes
    daysBackAnalyzed=  7;  %at least 8 if using weeklyReport
    suppressUpdates=   0;  %0 or 1, if set to 1 it is faster but won't load any new data since last time KEEP OF WHEN NOT ON RS-server
    seeBW=             1;  %1 if you want to see body weights, 0 otherwise
    justOne=           1;  %0 is default, 1 to view a single rat
    whichOne={'rat_114'};  %only used if the above is 1
    more=              0;  %get some more plots
end

masterMode=0;
if masterMode
    %special things happen
end


%**************************************************************************************
%DON'T CHANGE THINGS BELOW HERE UNLESS YOU REALLY KNOW WHAT YOURE DOING -the management


% SETUP
m=more; %more
whichPlots= [1 1 0 m 0 m m 1 0 0 0 0 0 seeBW 1 m m m]; %see basics
%whichPlots=[0 0 0 m 0 m m m 0 0 0 0 0 0 0 1]; %see basics
%whichPlots=[0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0]; %BW only
%whichPlots= [0 0 0 0 0 0 0 0 0 0 0 0 0 seeBW 0 0 1 1]; %see basics

dateRange=[now-daysBackAnalyzed now];
positions=subjects;

if heatViewed>0;
    selected=zeros(size(subjects));
    selected(:,heatViewed)=1;
else
    selected=ones(size(subjects)); %all
end

if boxViewed>0;
    selectedBox=zeros(size(subjects));
    selectedBox(boxViewed,:)=1;
    selected=selectedBox & selected;
else
    selected=selected; %all as determined by heats
end

subjects=(subjects(selected==1)');
if justOne;
    subjects=whichOne;
end
subjects

% if seeBW & ~suppressUpdates
%     useBodyWeightCache = 0; % This will load the new data
% else
%     useBodyWeightCache = 1;
% end
% removed because cache gets over written per subject... pmm 01/06/08

% PATHS
%rootPath='C:\Documents and Settings\rlab\Desktop\localAnalysis';
warning('off','MATLAB:dispatcher:nameConflict')
%addpath(genpath('C:\Documents and Settings\rlab\Desktop\localAnalysis'));
%addpath(genpath(fullfile(rootPath, 'RSTools')));
%addpath(genpath(fullfile(rootPath, 'dataXfer')));


rootPath='C:\pmeier\';
addpath(genpath(fullfile(rootPath, 'Ratrix')));
oracleVersion='classes12_g.jar';  %get this from SVN?
javaaddpath(fullfile(rootPath,'Ratrix','OracleXE',oracleVersion))  % this is to access the oracle database with rat weights, etc
warning('on','MATLAB:dispatcher:nameConflict')


%% Get Data To Usable Format  -- now handled by deamon
if ~suppressUpdates
    forceSmallDataUpdate=0; %don't mess with this unless you know what you're doing
    recompile=forceSmallDataUpdate;
    fieldNames=[]; %use default
    compileTrialRecords(rackNum,fieldNames,recompile)
    %old code for netwrok management with no rnet:
    %junk=allToSmall(subjects,dateRange,suppressUpdates,forceSmallDataUpdate);  
end

%% Display Data
subjects=subjects';
numRats=size(subjects,2)*size(subjects,1)
for i=1:numRats
    %Get Data
    d=getSmalls(subjects{i},dateRange,rackNum);
    numFig=18; %number of possible figures
    if numRats==1
        subplotParams.index=1; subplotParams.x=1; subplotParams.y=1; handles=[1:numFig];
        who=subjects{1};
    elseif numRats<=6
        subplotParams.index=i; subplotParams.x=2; subplotParams.y=3; handles=[numFig+1:2*numFig];
        who=sprintf('heat-%d',heatViewed);
    else
        subplotParams.index=i; subplotParams.x=6; subplotParams.y=6; handles=[(2*numFig)+1:3*numFig];
        who=sprintf('all',heatViewed);
    end
    i
    inspectRatResponses(char(subjects{i}),'noPathUsed',whichPlots,handles,subplotParams,d);
end

%save local and remote graph
whereOnServer=fullfile((fileparts(getSubDirForRack(rackID))),'graphs')
savePlotsToPNG(whichPlots,handles,who,where);
local=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','graphs');
savePlotsToPNG(whichPlots,handles,who,where);


%%
if heatViewed==0 & daysBackAnalyzed>7 & ~justOne
     weeklyReport(rackNum);
end


