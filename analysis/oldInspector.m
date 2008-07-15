function junk=inspectAllRats(dateRange)
%extracts small data from stations and analyzes it
%will also save copies of largeData, replaces old large data local

%% setup
%this needs to be called outside a function?
rootPath='C:\pmeier\';
dataStoragePath=fullfile('C:\pmeier\RSTools','out');
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath(fullfile(rootPath, 'RSTools')));
addpath(genpath(fullfile(rootPath, 'dataXfer')));
addpath(genpath(fullfile(rootPath, 'Ratrix/Server')));
oracleVersion='classes12_g.jar';  %get this from SVN?
javaaddpath(fullfile(rootPath,'Ratrix','OracleXE',oracleVersion))  % this is to access the oracle database with rat weights, etc
warning('on','MATLAB:dispatcher:nameConflict')


if exist('dateRange','var')
    if size(dateRange,2)==2
        loadMethod='betweenDates'
        loadMethodParams=dateRange;
    elseif size(dateRange,2)==1
        loadMethod='sinceDate'
        loadMethodParams=dateRange;
    else
        error('dateRange must be 1 or 2 dates')
    end
else
    loadMethod='betweenDates'
    loadMethodParams=[now-5,now-0];
    %loadMethodParams=[datenum('Oct.02,2007')  datenum('Oct.22,2007')];
end


whichPlots=[1 1 0 0 0 0 0 0 1 0 0 0 0]; %see basics
numPlots=size(whichPlots,2);
plotGroup=0;
    
%% for viewing
    close all
    whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1]; %see a lot ; 
    whichPlots=[1 1 0 0 0 0 0 0 1 0 0 0 0]; %see basics
    whichPlots=[1 1 1 1 0 0 0 1 1 0 0 0 0]; %see a little more
    savePlots=whichPlots; %zeros(size(whichPlots))
   
%% overnight %% transfer data from stations
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_113'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},loadMethod,loadMethodParams,1,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},loadMethod,loadMethodParams,1,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_114'},loadMethod,loadMethodParams,9,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116'},loadMethod,loadMethodParams,9,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_117'},loadMethod,loadMethodParams,9,[],1)
%% overnight heat
    subplotParams.x=2; subplotParams.y=3; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
    subplotParams.index=1; inspectRatResponses('rat_113',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=3; inspectRatResponses('rat_102',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_106',dataStoragePath,whichPlots,handles,subplotParams)
      whichPlots(1,[10,11,12])=0; %to include flanker analysis don't plot cued stims, which hve all 0s in cond inds
    subplotParams.index=2; inspectRatResponses('rat_114',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_116',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=6; inspectRatResponses('rat_117',dataStoragePath,whichPlots,handles,subplotParams)
     who='overnight'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);

%% morn
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_126'},loadMethod,loadMethodParams,1 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_127'},loadMethod,loadMethodParams,1 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_128'},loadMethod,loadMethodParams,2 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_129'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_130'},loadMethod,loadMethodParams,9 ,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_131'},loadMethod,loadMethodParams,4,[],1)


%% morning heat
    subplotParams.x=2; subplotParams.y=3; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
    ssubplotParams.index=1; inspectRatResponses('rat_126',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=3; inspectRatResponses('rat_127',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_128',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=2; inspectRatResponses('rat_129',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_130',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=6; inspectRatResponses('rat_131',dataStoragePath,whichPlots,handles,subplotParams) 
    who='morning'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
%% aft
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112'},loadMethod,loadMethodParams,3,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,1,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_***'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_115'},loadMethod,loadMethodParams,11,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_118'},loadMethod,loadMethodParams,9,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_119'},loadMethod,loadMethodParams,4,[],1)
%% afternoon heat
    plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots]; 
    subplotParams.index=1; inspectRatResponses('rat_112',dataStoragePath,whichPlots,handles,subplotParams)
    %subplotParams.index=3; inspectRatResponses('rat_***',dataStoragePath,whichPlots,handles,subplotParams)
    %subplotParams.index=5; inspectRatResponses('rat_***',dataStoragePath,whichPlots,handles,subplotParams)   
    subplotParams.index=2; inspectRatResponses('rat_115',dataStoragePath,whichPlots,handles,subplotParams)
    %subplotParams.index=4; inspectRatResponses('rat_118',dataStoragePath,whichPlots,handles,subplotParams)
    %subplotParams.index=6; inspectRatResponses('rat_119',dataStoragePath,whichPlots,handles,subplotParams) 
    who='afternoon'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
    
%% prevRats
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_132'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_133'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_134'},loadMethod,loadMethodParams,4,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_135'},loadMethod,loadMethodParams,4,[],1)
%% new Rats
%     subplotParams.x=2; subplotParams.y=2; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
%     whichPlots=[1 1 1 1 0 1 1 1 1 0 0 0 0]; %see basics
%     savePlots=whichPlots; %zeros(size(whichPlots))
%     subplotParams.index=1; inspectRatResponses('rat_132',dataStoragePath,whichPlots,handles,subplotParams)  
%     subplotParams.index=3; inspectRatResponses('rat_133',dataStoragePath,whichPlots,handles,subplotParams)
%     subplotParams.index=2; inspectRatResponses('rat_134',dataStoragePath,whichPlots,handles,subplotParams)
%     subplotParams.index=4; inspectRatResponses('rat_135',dataStoragePath,whichPlots,handles,subplotParams) 
%     who='boxRace'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
%     savePlotsToPNG(savePlots,handles,who,where);

%% 45ers
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_140'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_141'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_142'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_143'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_144'},loadMethod,loadMethodParams,3,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_145'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_146'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_147'},loadMethod,loadMethodParams,11,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_148'},loadMethod,loadMethodParams,11,[],1)
%% 45ers
    subplotParams.x=3; subplotParams.y=3; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
    whichPlots=[1 1 0 0 0 0 0 1 1 0 0 0 0]; %see basics
    %whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1];
    savePlots=whichPlots; %zeros(size(whichPlots))
    subplotParams.index=1; inspectRatResponses('rat_140',dataStoragePath,whichPlots,handles,subplotParams)  
    subplotParams.index=4; inspectRatResponses('rat_141',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=7; inspectRatResponses('rat_142',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=2; inspectRatResponses('rat_143',dataStoragePath,whichPlots,handles,subplotParams) 
    subplotParams.index=5; inspectRatResponses('rat_144',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=8; inspectRatResponses('rat_145',dataStoragePath,whichPlots,handles,subplotParams) 
    subplotParams.index=3; inspectRatResponses('rat_146',dataStoragePath,whichPlots,handles,subplotParams) 
    subplotParams.index=6; inspectRatResponses('rat_147',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=9; inspectRatResponses('rat_148',dataStoragePath,whichPlots,handles,subplotParams) 
    who='45ers'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
    
%% goTo rats

[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_134'},loadMethod,loadMethodParams,4,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_135'},loadMethod,loadMethodParams,4,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_136'},loadMethod,loadMethodParams,4,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_137'},loadMethod,loadMethodParams,4,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_131'},loadMethod,loadMethodParams,4,[],1)

%% goToRats
    subplotParams.x=2; subplotParams.y=3; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
    whichPlots=[1 1 0 0 0 0 0 0 0 0 0 0 0]; %see basics
    savePlots=whichPlots; %zeros(size(whichPlots))
    subplotParams.index=1; inspectRatResponses('rat_134',dataStoragePath,whichPlots,handles,subplotParams)  
    subplotParams.index=3; inspectRatResponses('rat_135',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=2; inspectRatResponses('rat_136',dataStoragePath,whichPlots,handles,subplotParams)  
    subplotParams.index=4; inspectRatResponses('rat_137',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_131',dataStoragePath,whichPlots,handles,subplotParams)
    who='goToRats'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);

%% 4-orient detector
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_138'},loadMethod,loadMethodParams,2,[],1)
[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_139'},loadMethod,loadMethodParams,2,[],1)

%%
 subplotParams.x=2; subplotParams.y=1; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
 subplotParams.index=1; inspectRatResponses('rat_138',dataStoragePath,whichPlots,handles,subplotParams)  
 subplotParams.index=2; inspectRatResponses('rat_139',dataStoragePath,whichPlots,handles,subplotParams)


%%  template 
    subplotParams.x=2; subplotParams.y=3; plotGroup=plotGroup+1; handles=(plotGroup*numPlots)+[1:numPlots];
    whichPlots=[1 1 0 1 0 0 1 1 0 0 0 0 0]; %see basics
    savePlots=whichPlots; %zeros(size(whichPlots))
    subplotParams.index=1; inspectRatResponses('rat_116',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=3; inspectRatResponses('rat_117',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=5; inspectRatResponses('rat_115',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=2; inspectRatResponses('rat_114',dataStoragePath,whichPlots,handles,subplotParams)
    subplotParams.index=4; inspectRatResponses('rat_129',dataStoragePath,whichPlots,handles,subplotParams) 
    subplotParams.index=6; inspectRatResponses('rat_130',dataStoragePath,whichPlots,handles,subplotParams)
    who='graduationCheck'; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);


%% make reports

a=weeklyReport({'rat_113','rat_102','rat_106'; 'rat_114','rat_116','rat_117'}',1,1,'overnight');
b=weeklyReport({'rat_126','rat_127','rat_128';'rat_129','rat_130','rat_131'}',1,1,'morning');
c=weeklyReport({'rat_112','','';'rat_115','',''}',1,1,'afternoon');
d=weeklyReport({'rat_132','rat_133','rat_134','rat_135'}',1,1,'newrats');
e=weeklyReport({'rat_140','rat_141','rat_142','rat_143','rat_144','rat_145','rat_146','rat_147','rat_148'}',1,1,'45ers');
f=weeklyReport({'rat_138','rat_139','rat_136','rat_137'}',1,1,'detectNside');

f=weeklyReport({'rat_138'}',1,1,'detectNside');

%add in goToRats and 45ers 4orientRats

%% 
inspectSpecificSubject=0;
if inspectSpecificSubject
%% inspect specific subject
    subject='rat_138';
    whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1];
    whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1];
    whichPlots=[1 1 0 0 0 0 0 0 1 0 0 0 0]; %see basics
     whichPlots=[1 1 1 1 0 1 1 1 1 1 1 1 1];
    savePlots= whichPlots;
    subplotParams.x=1; subplotParams.y=1; handles=[1:13];
    subplotParams.index=1; inspectRatResponses(subject,dataStoragePath,whichPlots,handles,subplotParams)
    who=subject; where='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\rats\6trixPlots\';
    savePlotsToPNG(savePlots,handles,who,where);
%% end inspect
end


%% tools
if 0  %to see whats in a strange smallData
    load out/rat_132/smallData.mat
    datestr(cell2mat(smallData.info.sessionIDs))
    firstTrial=datestr(min(smallData.date))
    lastTrial=datestr(max(smallData.date))
end


%% old stuff saved for history sake

% 
% if 0 %testing
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112'},'sinceDate',[now-1],3,[],1) %look at unique(smallData.expectedRewardIfRight)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},'betweenDates',[now-2 now-1],2,[],1)
%     %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_107'},'sinceDate',then,3,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'test'},'sinceDate',then,3,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},'betweenDates',[now-60 now-59],2,[],1)
% end
% 
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112-113'},loadMethod,loadMethodParams,3,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_114-115'},loadMethod,loadMethodParams,11,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116-118'},loadMethod,loadMethodParams,9,[],1)
% 
% useOldTools=0;
% if useOldTools
%     loadMethod='betweenDates'
%     loadMethodParams=[now-1,now-0.01];
% 
% 
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_113'},loadMethod,loadMethodParams,3,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},loadMethod,loadMethodParams,1,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},loadMethod,loadMethodParams,2,[],1)
%     %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_112-113'},loadMethod,loadMethodParams,3,[],1)
% 
%     
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_114-115'},loadMethod,loadMethodParams,11,[],1)
%     %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116-118'},loadMethod,loadMethodParams,9,[],1)
%     %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_118'},loadMethod,loadMethodParams,9,[],1)
%     %[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_119'},loadMethod',loadMethodParams,4,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_116'},loadMethod,loadMethodParams,9,[],1)
%     [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_117'},loadMethod,loadMethodParams,4,[],1)
% 
% 
%     inspectRatResponses('rat_113')
%     inspectRatResponses('rat_102')
%     inspectRatResponses('rat_106')
%     %inspectRatResponses('rat_112-113')
% 
%     inspectRatResponses('rat_114-115')
%     %inspectRatResponses('rat_116-118')
%     %inspectRatResponses('rat_118')
%     %inspectRatResponses('rat_119')
%     inspectRatResponses('rat_116')
%     inspectRatResponses('rat_117')
% end
% 
% peekAt=0;
% if peekAt
%     load out/rat_102/smallData
%     figure; peekAtData; pause
%     load out/rat_106/smallData
%     load out/rat_107/smallData
% 
% end


%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_107'},'lastNfiles',int8(3),3,[],1)
%[smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},'all',[],3,[],1)

%add a method that write the date range of the large files, save backup id dfi locaton if "all"


%ERROR
% %192.168.0.102\C\pmeier\Ratrix\Boxes\box1\oldSubjectData.20070220T103806\rat_106\trialRecords.mat has non-existent field 'containedManualPokes'.
%load backup\rat_106\smallData
%datestr(smallData.date(1581),30)                    %--->20070220T101053 %before
%datestr(smallData.date(1690),30)                    %--->20070220T110506 %after
%smallData.containedManualPokes(1581:1690)
%%smallData.containedManualPokes is defined all around it! what happened to the data extractor that it breaks now? what change?

%again
%going to load 9 files since 14-Apr-2007 20:31:02
%loading \\192.168.0.103\C\pmeier\Ratrix\Boxes\box1\subjectData\rat_107\trialRecords.mat
%Reference to non-existent field 'containedManualPokes'.


