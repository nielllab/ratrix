
clear, clc
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
%reportSettings % verify new rats are listed but "none" for step

%these rats are already overtrained on coherent dots task
% this protocol contains 4 training steps so far, starting with earned free drinks, 
% then coherent dots varying different params.

r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'195','196'}; %  
MotionPsychophysics(subjIDs); %
  

%NOTE another way to  specify STEP only could return subject and protocol p
% [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'blindsight expt','pr');


% 12/4 graduate 196 to harder task, demote 195 to easier (box changes)
clear, clc
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'196'}; %  196 is plateu'd.  promote to step 5 (new step)
MotionPsychophysics(subjIDs); % run 12/4 7:18pm

  
