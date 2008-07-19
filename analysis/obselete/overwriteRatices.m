%OVERWRITE RATRICES

answer = INPUTDLG('Have you shut off matlab in every remote location? If so type ''yes''.') 
if strcmp(answer,'yes')
    %go on
else
    error('You better know what you are doing if you run this script when matlab is on.')
end

%PARAMETERS
preserveSomeFiles=1;
preservedFileName=[];
preservedFileName{1}='run.m';
preservedFileName{2}='RatSubjectSession.m'
%preservedFileName{3}='RatSubjectInit.m';


%sourceFolder='Server_Station2-20070307T151115';  %first distributed ratrix; pmeier variant
%sourceFolder='Server_Station2-20070309T231848';  
%sourceFolder='Server_Station1-20070320T212104';  %after adding valve error checks
%sourceFolder='Server_Station2-20070321T005711';   %after changing lptWriteBits
  %sourceFolder='Server_Rig1a_20070321T024125';    %ugly ugly ugly just for testing key press right shift
  %sourceFolder=Server_Station2-20070322T153210    %after writing NTrialsThenWait Scheduler, not functional, - just to save
  %not integrated :  doScheduled trials - sitting on Desktop of station 101
%sourceFolder='Server_Station3-20070326T155414 ';  %after modifying mean luminance in detection task
  %sourceFolder='Server_Station3-20070329T155414+'; %added nTrialsThenWait Scheduler
%sourceFolder='Server_Station3-20070329T172630';    %after changing so that scheduler is functional
 %(flushed Init and Session Files)
%sourceFolder='Server_Station3-20070404T015806';    %after adding LUTs
 %(flushed Init and Session Files)
%sourceFolder='Server_Station3-20070404T202142';    %after fixing errorStim and adding low contrast errors for ifFeature
%sourceFolder='Server_Rig1a_200730412-rewound';     %has totem Stim, lacks edits that merge liz and philips init files, see broken version
%sourceFolder='Server_Station11-20070418T112916';    %liz small improvements 1 -- stim is big, cue position is not stuck in center 
        %MERGED WITH EFLISTER VARIANT - no more core code changes after this! 
%sourceFolder='Server_Station2-20070420T192424';    %does not contain liz changes!,  has small change to flanker random in pmm calc stim 
%sourceFolder='Server_Station11-20070423T145335';   %does not contain pmm changes!  cued comes second if trigger,  calcStim cuedIfFeature...
%sourceFolder='Server_Station11-20070423T152911';   %merges liz variant and pmm variant; keeps inits separate, TESTED BOTH
%sourceFolder='Server_Station11-20070424T114900';   %has init with 102-106-107-112-113
%sourceFolder='Server_Station3-20070501T194451';     %backup
%sourceFolder='Server_Rig1a_070501_smallfixes';      %changed request valve so that it closes, stopped framePulse from flushing valve state
%sourceFolder='Server_Station3-20070502T194302';      %started to track errorStim data in trial records, stimOGL initializes response=[]
%sourceFolder='Server_Station3-20070522T132850';      %backup before changes
%sourceFolder='Server_Station3-20070525T000816';      %usefull changes (reward increases) but broken when messed with maxCorrect in Row, has init from 3
%sourceFolder='Server_Station3-20070525T173829';      %usefull changes (reward increases) now fixed - there is no max Correct code anywhere yet - just a variable in the init
%sourceFolder='Server_Station3-20070525T190355';      %max correct code works
%sourceFolder='Server_Station3-20070525T194904';      %small impovement: max correct field always in stim details
%sourceFolder='Server_Station3-20070607T111536';      %working back-up   
%sourceFolder='Server_Station4-20070607T120419';       %working back-up of Liz's right side
%sourceFolder='Server_Station3-20070607T115946';       %added maxCorrect to cuedIfFeatureGoRightWithTwoFlank   
%sourceFolder='Server_Station3-20070613T163210';       %backup   
%sourceFolder='Server_Station2-20070928T100445';       %backup
%sourceFolder='Server_Rig1a_20070927';                 %broadcast after adding free drinks upstairs
%sourceFolder='Server_Station2-20070928T105543';       %with fd in downstairs init, freeDrinksOnlyInit
%sourceFolder='Server_Rig1a_20071001';                 %afer updating ifFeatureGoRight to handle goToSide
%sourceFolder='Server_Rig1a_071006-phasesAdded';        %afer adding phases 
%sourceFolder='Server_Station2-20071015T162636';        %backup -same as above...
%sourceFolder='Server_Station1-20071015T162617';        %hack change to persisting flankers
%sourceFolder='Server_Station2-20071015T162636';        %formal change to persisting flankers
%sourceFolder='Server_pysch1-20071109T201800';          %has inflating on first trial, distractorFlanker added, ratSubjectInit=masterShaping
%sourceFolder='Server_psych1_20071119T1846';             %masterShaping into RatSubjectInit, has access to miniDatabase
%sourceFolder='Server_psych1_20071127T1711';             %screen size set to 1024 x 768
%sourceFolder='Server_psych1_20071129T2120';             %fix default constructor for ifFeature...
%sourceFolder='Server_psych1_20071129T2331';             %new rat order, 5 heats
%sourceFolder='Server_psych1_20071130T1822';             %rate graduation ignores trials that "lick" too fast
%sourceFolder='Server_Station11-20071201T181606';         %has removeSubjectFromPmeierRatrix
%sourceFolder='Server_Station11-20071202T120044';         %fixed removeSubjectFromPmeierRatrix
%sourceFolder='Server_Station11-20071202T1222';          %fixed rateCriterion check that lacks times...
%sourceFolder='Server_Station2-20071202T130203';         %init has +/-45deg for discrim...
%sourceFolder='Server_psych1_20071204T1523';             %removes probabilistic save of db, updatescheduler=0 usually, clearSubjectDataDir after every session end
%sourceFolder='Ratrix_605';                               %test of svn'd ratrix -- can send
%sourceFolder='Ratrix_Station9-20080203T161728';         %test of svn'd ratrix -- can project back 
%sourceFolder='Ratrix_614';                               %protocols added v 1_3 and 1_4
%sourceFolder='Ratrix_641';                               %shaping in dimFlankers
%sourceFolder='Ratrix_658';                               %90 minutes sessions, subjectID on screen, random seed, plot shaping parameter
%sourceFolder='Ratrix_660';                               %added minutesPerSession object and setSeed
%sourceFolder='Ratrix_667';                               %added coherent dot stim
%sourceFolder='Ratrix_767';                                %no more caching gratings
%sourceFolder='Ratrix_769';                                %faster w/o zero contrast flankers
sourceFolder='Ratrix_819';                                %new init

%[3  11]
%[1   9]
%[2   4]
%next time: include new loadRatrixData

stationIP{1}='192.168.0.101';
stationIP{2}='192.168.0.102';
stationIP{3}='192.168.0.103';
stationIP{4}='192.168.0.104';
stationIP{9}='192.168.0.109';
stationIP{11}='192.168.0.111';

%numStations=size(stationIP,2);
%selectedStations=[1:numStations]; %does all but could be just 1 or some

selectedStations=[1 3 9 11];   %does all but could be just 1 or some
selectedStations=[11 1 9];
selectedStations=[1 2 3 ];         %does left side
selectedStations=[4 9 11];         %does right side
selectedStations=[1 2 3 4 9 11];   %does all but could be just 1 or some
selectedStations=[1];  

%removed drives if there THIS COULD POTENTIALLY BE DANGEROUS
command=sprintf('!net use y: /delete'); eval(command);
command=sprintf('!net use z: /delete'); eval(command);

%START
%map network drive for storage server

%%OLD
% sourceIP='132.239.158.177';  %same as sourceIP='Reinagellab';
% sourcePath='\Files';
% password='Pac3111';
% user='rlab';

sourceIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu'; 
sourcePath='\rlab';
password='1Mouse';
user='RODENT';
command=sprintf('!net use z: \\\\%s%s %s /user:%s',sourceIP,sourcePath,password,user)
eval(command);


goingToUse=stationIP(selectedStations)  %for display only
for stationNum=selectedStations
    %map network drive for ratrix station
    sourceIP=stationIP{stationNum}; 
    sourcePath='\c';
    password='Pac3111';
    command=sprintf('!net use y: \\\\%s%s %s /user:rlab',sourceIP,sourcePath,password)
    eval(command);

    %SAVE PRESERVED FILES
    if preserveSomeFiles
        sourcePath='y:\pmeier\Ratrix\example\';
        destinationPath='y:\pmeier\smallTempFiles\';
        for i=1:size(preservedFileName,2)
            [status,message,messageid] = copyfile([sourcePath preservedFileName{i}],[destinationPath preservedFileName{i}],'f');
        end
        %         [status,message,messageid] = copyfile([sourcePath preservedFileName{2}],[destinationPath preservedFileName{2}],'f');
        %         [status,message,messageid] = copyfile([sourcePath preservedFileName{3}],[destinationPath preservedFileName{3}],'f');
        disp(sprintf('saving temp copy of %s on station %d at %s', char(preservedFileName(1)), stationNum, char(stationIP(stationNum))))
        if ~status==1
            error(sprintf('%s -- %s problem with copying files from %s to %s',message,messageid,sourcePath,destinationPath))
        end
    end
    
    %DO MAIN COPY
    destinationPath='y:\pmeier\Ratrix';
    %sourcePath=sprintf('z:\\rodentdata\\pmeier\\RatricesStored\\%s',sourceFolder); %old path
    sourcePath=sprintf('z:\\Rodent-Data\\pmeier\\RatricesStored\\%s',sourceFolder); 
    disp(sprintf('starting copy of %s to station %d at %s', sourceFolder, stationNum, char(stationIP(stationNum))))
    [status,message,messageid] = copyfile(sourcePath,destinationPath,'f');
    if ~status==1
        error(sprintf('%s -- %s problem with copying files from %s to %s',message,messageid,sourcePath,destinationPath))
    end

    %RETURN PRESERVED FILES
    if preserveSomeFiles
        sourcePath='y:\pmeier\smallTempFiles\';
        destinationPath='y:\pmeier\Ratrix\example\';
        for i=1:size(preservedFileName,2)
            [status,message,messageid] = copyfile([sourcePath preservedFileName{i}],[destinationPath preservedFileName{i}],'f');
        end
        [sourcePath preservedFileName{1}]
        [destinationPath preservedFileName{1}]
        disp(sprintf('returning %s to station %d at %s', char(preservedFileName(1)), stationNum, char(stationIP(stationNum))))
        if ~status==1
            error(sprintf('%s -- %s problem with copying files from %s to %s',message,messageid,sourcePath,destinationPath))
        end
    end
    
    command=sprintf('!net use y: /delete'); eval(command);
end

%unmap drive for storage server
command=sprintf('!net use z: /delete'); eval(command);

