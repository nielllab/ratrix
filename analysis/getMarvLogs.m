%function eventLog=getMarvLogs()

eventNum = 0;
eventLog=[];

% lastEvent=eventLog{end}
% details=eventLog{end}.details

%% sample

eventNum = eventNum +1;  %good format
eventLog{eventNum}.date =datenum('Dec.12,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease'};
eventLog{eventNum}.subject ={'rat_138'};
eventLog{eventNum}.stationID =2;
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='low body weight for 7 days'; 
eventLog{eventNum}.details.from =[1];
eventLog{eventNum}.details.to =[2];


%% events

eventNum = eventNum +1; %bad format --now good? yes
eventLog{eventNum}.date =datenum('Dec.12,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease'};
eventLog{eventNum}.subject ={'rat_141'};
eventLog{eventNum}.stationID =3;
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='low body weight'; 
eventLog{eventNum}.details.from =[3];
eventLog{eventNum}.details.to =[4];


eventNum = eventNum +1; %bad format
eventLog{eventNum}.date =datenum('Dec.14,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_138','rat_139','rat_140','rat_141','rat_142','rat_143','rat_144','rat_145','rat_146','rat_147','rat_148'};
eventLog{eventNum}.stationID ={'2','2','3','3','3','3','3','11','11','11','11','11'};
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='all need to learn more stringent; 141 uniquely found at 4000 msPenalty'; 
eventLog{eventNum}.details.from ='1000';
eventLog{eventNum}.details.to ='10000';

eventNum = eventNum +1;  %bad format
eventLog{eventNum}.date =datenum('Dec.14,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='penaltyIncrease';
eventLog{eventNum}.subject ={'rat_136','rat_137'};
eventLog{eventNum}.stationID ={'4','4'};
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='b/c'; 
eventLog{eventNum}.details.from ='1000';
eventLog{eventNum}.details.to ='4000';

eventNum = eventNum +1; %good format
eventLog{eventNum}.date =datenum('Dec.15,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease'};
eventLog{eventNum}.subject ={'rat_132'};
eventLog{eventNum}.stationID =2;
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='dangerously below body weight threshold'; 
eventLog{eventNum}.details.from =[1];
eventLog{eventNum}.details.to =[3];  

eventNum = eventNum +1; %okay
eventLog{eventNum}.date =datenum('Dec.16,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='ratrix down on 12-15-07, no stations working except middle left #1, according to Aria';
eventLog{eventNum}.subject ='rat_128';
eventLog{eventNum}.stationID ='2';
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='corrected error of missing bracket line 90'; 
eventLog{eventNum}.details.from ='subject {i.';
eventLog{eventNum}.details.to ='subject {i.}';


eventNum = eventNum +1; %bad format, see below --pmm
eventLog{eventNum}.date =datenum('Dec.17,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='rewardIncrease';
eventLog{eventNum}.subject ={'rat_132' ,'rat_133','rat_138','rat_139','rat_128'};
eventLog{eventNum}.stationID =2; %E
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='station is weak in water flow reward & rats are all below body weight threshold'; 
eventLog{eventNum}.details.from =[1,1,2,1,1];
eventLog{eventNum}.details.to =[4,4,4,4,4];  
eventLog{eventNum}.eventName ='penaltyDecrease';
eventLog{eventNum}.details.from =[10000,10000,10000,10000,10000];
eventLog{eventNum}.details.to =[4000,4000,4000,4000,4000];


%this is a good sample for multi rat, multi feature
eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Dec.17,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease','penaltyDecrease'};
eventLog{eventNum}.subject ={'rat_134', 'rat_135', 'rat_137'};
eventLog{eventNum}.stationID =4; %F
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='several days below body weight threshold'; 
eventLog{eventNum}.details.from =[1, 1, 1; 10000,10000,10000];
eventLog{eventNum}.details.to   =[5, 5, 4; 4000,  4000, 4000];  

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Dec.17,2007');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease', 'penaltyDecrease'};
eventLog{eventNum}.subject =    {'rat_143'};
eventLog{eventNum}.stationID =3; %A
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='several days below body weight threshold'; 
eventLog{eventNum}.details.from =[3;10000];
eventLog{eventNum}.details.to   =[4; 4000];  

eventNum = eventNum +1;m %bad format --pmm
eventLog{eventNum}.date =datenum('Dec.17,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='rewardIncrease, penaltyDecrease';
eventLog{eventNum}.subject =   {'rat_145, rat_148'};
eventLog{eventNum}.stationID =11; %B
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='several days below body weight threshold'; 
eventLog{eventNum}.details.from ='3,10000; 3,10000';
eventLog{eventNum}.details.to   ='4, 4000; 4, 4000';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Dec.17,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='penalty decrease';
eventLog{eventNum}.subject =    'rat_115';
eventLog{eventNum}.stationID =9; %D
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='several days below body weight threshold'; 
eventLog{eventNum}.details.from ='10000';
eventLog{eventNum}.details.to   =' 4000'; 

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Dec.19,2007');%datestr(now,21)
eventLog{eventNum}.eventName ='reward increase, penalty decrease';
eventLog{eventNum}.subject =     'rat_132, rat_133';
eventLog{eventNum}.stationID =2; %E 
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='additional change since station E appears not to respond to previous changes to increase reward & decrease penalty '; 
eventLog{eventNum}.details.from ='4, 4000; 4, 4000';  
eventLog{eventNum}.details.to   ='6, 2000; 6, 2000';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Jan.16,2008');%datestr(now,21)
eventLog{eventNum}.eventName ='reward decrease';
eventLog{eventNum}.subject =  'rat_138';
eventLog{eventNum}.stationID =2; %E
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='above thresh, only 150 trials/day'; 
eventLog{eventNum}.details.from ='6';  
eventLog{eventNum}.details.to   ='3';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Jan.16,2008');%datestr(now,21)
eventLog{eventNum}.eventName ='reward decrease';
eventLog{eventNum}.subject =  'rat_137';
eventLog{eventNum}.stationID =4; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='above thresh, only 250 trials/day'; 
eventLog{eventNum}.details.from ='4';  
eventLog{eventNum}.details.to   ='3';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Jan.16,2008');%datestr(now,21)
eventLog{eventNum}.eventName ='reward decrease';
eventLog{eventNum}.subject =  'rat_139';
eventLog{eventNum}.stationID =2; %these MUST be numbers!, you can comment letters after (see above)
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='above thresh, only 250 trials/day'; 
eventLog{eventNum}.details.from ='6';  
eventLog{eventNum}.details.to   ='4';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Jan.17,2008 08:19:22');%datestr(now,21)
eventLog{eventNum}.eventName ='lightChange';
eventLog{eventNum}.subject =  'all in B228';
eventLog{eventNum}.stationID ='all in B228'; %these MUST be numbers!, you can comment letters after (see above)
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='changed (probably by 8am, def by 1pm)when I talked to Mike, maybe more changes, pending protocol...'; 
eventLog{eventNum}.details.from ='flourcent cycling by vivarium staff';  
eventLog{eventNum}.details.to   ='emergency only';  

eventNum = eventNum +1; %bad format --pmm
eventLog{eventNum}.date =datenum('Jan.18,2008 15:19:22');%datestr(now,21)
eventLog{eventNum}.eventName ='cockpitChange';
eventLog{eventNum}.subject =  'all in station 1';  %bad
eventLog{eventNum}.stationID =[1]; %these MUST be numbers!, you can comment letters after (see above)
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='all rats in the station had a strong left bias, also right water tube was found chewed and needed replacing. square hole for right eye created a new tube just like old.'; 
eventLog{eventNum}.details.from ='one tube';  
eventLog{eventNum}.details.to   ='another tube'; 

%marv - could you make sure to use good format, and change the ones with
%bad format? thx -pmm 080116

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Jan.30,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject =    {'rat_137','rat_143','rat_145','rat_148'};
eventLog{eventNum}.stationID =[4 3 11 11]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='prob wont''t learn with that fast penalty'; 
eventLog{eventNum}.details.from =[4000];
eventLog{eventNum}.details.to   =[10000];  

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Jan.30,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject =    {'rat_132','rat_133'};
eventLog{eventNum}.stationID =[2 2]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='prob wont''t learn with that fast penalty, stuck at full flankers'; 
eventLog{eventNum}.details.from =[2000];
eventLog{eventNum}.details.to   =[10000];  


eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.02,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject =  {'rat_140','rat_141','rat_142','rat_143','rat_144'};
eventLog{eventNum}.stationID =[3]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='top station sees more room lights, trashbag while aria builds a better cape'; 
eventLog{eventNum}.details.from ='no cover';
eventLog{eventNum}.details.to   ='trash bag'; 

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.03,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'reinitializeRatrix'};
eventLog{eventNum}.subject =  {};
eventLog{eventNum}.stationID =[1 2 3 4 9 11]; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='added in v1_3 and v1_4 with no horizontal stims, mostly effect rats on stations 1, 2, 4 but re-inited all 6'; 
eventLog{eventNum}.details.from =[];
eventLog{eventNum}.details.to   =[];  

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.08,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'schedulerChange'};
eventLog{eventNum}.subject =  {};
eventLog{eventNum}.stationID =[1 2 3 4 9 11]; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='all rats running 90 minutes sessions'; 
eventLog{eventNum}.details.from ='noTimeOff - about 2 hours for most rats, way more for overnighters';
eventLog{eventNum}.details.to   ='90 minutes';  

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.09,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject =  {'rat_140','rat_141','rat_142','rat_143','rat_144'};
eventLog{eventNum}.stationID =[3]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='top station sees more room lights, trashbag while aria builds a better cape'; 
eventLog{eventNum}.details.from ='trash bag';
eventLog{eventNum}.details.to   ='test cape'; 


eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.16,2008 11:45:32');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease'};
eventLog{eventNum}.subject =  {'rat_141','rat_145','rat_146'};
eventLog{eventNum}.stationID =[3 11 11]; 
eventLog{eventNum}.issuedBy ='hvo';
eventLog{eventNum}.comment ='not gaining fast enough; 600-900 secs/week'; 
eventLog{eventNum}.details.from =[4 4 3];
eventLog{eventNum}.details.to   =[5 5 5];  

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.17,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject =  {'rat_140','rat_141','rat_142','rat_143','rat_144'};
eventLog{eventNum}.stationID =[3]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='definitely curtain on by feb 18, maybe aria put it as early as feb 15? cape removed from upper left'; 
eventLog{eventNum}.details.from ='test cape';
eventLog{eventNum}.details.to   ='no cover';   %see next entry

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.17,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject =  {};
eventLog{eventNum}.stationID =[]; %
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='definitely curtain on by feb 18, maybe aria put it as early as feb 15? cape removed from upper left'; 
eventLog{eventNum}.details.from ='no cover';
eventLog{eventNum}.details.to   ='curtain'; 


eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.17,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject =  {};
eventLog{eventNum}.stationID =[]; %
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='definitely curtain on by feb 18, maybe aria put it as early as feb 15? cape removed from upper left'; 
eventLog{eventNum}.details.from ='no cover';
eventLog{eventNum}.details.to   ='curtain'; 

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'protocolChange'};
eventLog{eventNum}.subject =  {'rat_138','rat_139','rat_117'};
eventLog{eventNum}.stationID =[]; %
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='some rats to step one of acuity for cosyne, influenced box 4 dim flankers reset to .1'; 
eventLog{eventNum}.details.from =['setShaping'];
eventLog{eventNum}.details.to   =['setAcuity']; 

eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'moveStation',};
eventLog{eventNum}.subject =  {'rat_127'};
eventLog{eventNum}.stationID =[9]; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='extra experience for head fixing, flunked from 8 to 5, moved to middle right station form previous middle left'; 
eventLog{eventNum}.details.from =[1];
eventLog{eventNum}.details.to   =[9]; 


eventNum = eventNum +1; %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'protocolChange'};
eventLog{eventNum}.subject =  {'rat_135'};
eventLog{eventNum}.stationID =[4]; %
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='changed pixPerCyc from 32 to 64 b/c he sucked at VV for 7+ days'; 
eventLog{eventNum}.details.from =['one param'];
eventLog{eventNum}.details.to   =['another']; 

%
eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease','penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_134', 'rat_135', 'rat_137'};
eventLog{eventNum}.stationID =4; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='chronic poor performance in 135, clear cause and effect'; 
eventLog{eventNum}.details.from =[5, 5, 3; 4000,  4000,10000];  
eventLog{eventNum}.details.to   =[2, 2, 2; 10000,10000,10000];


eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease','penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_137', 'rat_138','rat_139'};
eventLog{eventNum}.stationID =[2]; %?  2  ??E 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='138 and 139 are pretty good and going to sweeps, so only penalty to 6000'; 
eventLog{eventNum}.details.from =[2, 3, 4; 2000, 2000,2000];  
eventLog{eventNum}.details.to   =[2, 2, 2; 10000,6000,6000];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'rat_144'};
eventLog{eventNum}.stationID =[3]; %A
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='overnighter with slow rise, trying to push him'; 
eventLog{eventNum}.details.from =[3];  
eventLog{eventNum}.details.to   =[1]; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_135','rat_136'};
eventLog{eventNum}.stationID =4; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='gets the task, slow shaping contrast, yet not fast enough'; 
eventLog{eventNum}.details.from =[1000, 4000];  
eventLog{eventNum}.details.to   =[10000,8000];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'rat_129'};
eventLog{eventNum}.stationID =11?; %B
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='good weight,slightly above chance, pushable'; 
eventLog{eventNum}.details.from =[5];  
eventLog{eventNum}.details.to   =[2]; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'rat_130'};
eventLog{eventNum}.stationID =9?; %D
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='good weight,slightly above chance, pushable'; 
eventLog{eventNum}.details.from =[3];  
eventLog{eventNum}.details.to   =[1]; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.18,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease','penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_115'};
eventLog{eventNum}.stationID =9; %D
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='stuck at chance, push some, he''s also an overnighter now'; 
eventLog{eventNum}.details.from =[4, 4000];  
eventLog{eventNum}.details.to   =[2,10000];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.22,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyDecrease'};
eventLog{eventNum}.subject ={'rat_117','rat_138','rat_139'};
eventLog{eventNum}.stationID =[9 2 2]; %D E E
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='going to get contrast sweep as well as pixPerCycs'; 
eventLog{eventNum}.details.from =[10000,6000,6000];  
eventLog{eventNum}.details.to   =[4000,4000,4000];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.22,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualStepChange'};
eventLog{eventNum}.subject ={'rat_117','rat_138','rat_139'};
eventLog{eventNum}.stationID =[9 2 2]; %D E E
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='doing acuity; going to start contrast sweep as well as pixPerCycs'; 
eventLog{eventNum}.details.from =[1,1,1];  
eventLog{eventNum}.details.to   =[2,2,2];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.23,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualStepChange'};
eventLog{eventNum}.subject ={'rat_129'};
eventLog{eventNum}.stationID =[11]; %B
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='why found on 2?  returned him to 5, no trials done on 2 while he was in box'; 
eventLog{eventNum}.details.from =[2];  
eventLog{eventNum}.details.to   =[5];

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.25,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardIncrease'};
eventLog{eventNum}.subject ={'rat_116'};
eventLog{eventNum}.stationID =9?; %D
eventLog{eventNum}.issuedBy ='hvo';
eventLog{eventNum}.comment ='dehydrated but not sick, vet agrees, increasing water reward'; 
eventLog{eventNum}.details.from =[2];  
eventLog{eventNum}.details.to   =[4]; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.25,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'monitorRefreshRateChange'};
eventLog{eventNum}.subject ={};
eventLog{eventNum}.stationID =[1 2 3 4 9 11]; %all
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='switch up to 100Hz, not recommended option w/ shitty graphics card'; 
eventLog{eventNum}.details.from =[85,85,85,85,85,60];  
eventLog{eventNum}.details.to   =[100,100,100,100,100,100]; 


eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Feb.28,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'sentinelChange'};
eventLog{eventNum}.subject ={};
eventLog{eventNum}.stationID =[]; %all
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='+/- 3 days; male and female sentinels added to male ratrix room'; 
eventLog{eventNum}.details.from ='no sentinel';  
eventLog{eventNum}.details.to   ='male and female sentinel'; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Mar.4,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'waterChange'};
eventLog{eventNum}.subject ={'rat_112', 'rat_126', 'rat_102','rat_106','rat_196'};
eventLog{eventNum}.stationID =[1]; %C
eventLog{eventNum}.issuedBy ='mrz';
eventLog{eventNum}.comment ='replaced lines, center line leaked, left line port was weak'; 
eventLog{eventNum}.details.from ='bad';  
eventLog{eventNum}.details.to   ='good'; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Mar.10,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'waterChange'};
eventLog{eventNum}.subject ={'rat_127', 'rat_116', 'rat_117','rat_130','rat_115'};
eventLog{eventNum}.stationID =[4]; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='many rats biased right, found left spout unglued & retracted; maybe 40% less water; repositioned it'; 
eventLog{eventNum}.details.from ='right biased';  
eventLog{eventNum}.details.to   ='more equal'; 

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Mar.12,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'monitorRefreshRateChange'};
eventLog{eventNum}.subject ={'rat_112', 'rat_126', 'rat_102','rat_106','rat_196','rat_145', 'rat_146', 'rat_147','rat_148','rat_1929'}; 
eventLog{eventNum}.stationID =[4 1]; %B C
eventLog{eventNum}.issuedBy ='a2c';
eventLog{eventNum}.comment ='found 2 stations at 60Hz, put back to 100Hz'; 
eventLog{eventNum}.details.from =[60,60];  
eventLog{eventNum}.details.to   =[100,100]; 


eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Mar.15,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_117','rat_138','rat_139'};
eventLog{eventNum}.stationID =[9 2 2]; %D E E
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='performance suffered over days, psycho is easier (117) or gone now (138-9)'; 
eventLog{eventNum}.details.from =[4000,4000,4000];  
eventLog{eventNum}.details.to   =[10000,6000,6000];

eventLog{eventNum}.date =datenum('Mar.15,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'changedMean'};
eventLog{eventNum}.subject ={'rat_135'};
eventLog{eventNum}.stationID =[4]; %F
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='still bad at task, maybe its easier with a dark background'; 
eventLog{eventNum}.details.from =[0.5];  
eventLog{eventNum}.details.to   =[0.2];

eventLog{eventNum}.date =datenum('Mar.19,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'changedSensor'};
eventLog{eventNum}.subject ={};
eventLog{eventNum}.stationID =[2]; %E
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='switched physical boxes from 1B to 11E, so that soy has windows'; 
eventLog{eventNum}.details.from ='window';  
eventLog{eventNum}.details.to   ='slot';

eventLog{eventNum}.date =datenum('Mar.19,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'changedSensor'};
eventLog{eventNum}.subject ={}; % all new rats here, start with soy
eventLog{eventNum}.stationID =[11]; %B
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='switched physical boxes from 1B to 11E, so that soy has windows'; 
eventLog{eventNum}.details.from ='slot';  
eventLog{eventNum}.details.to   ='window';

eventLog{eventNum}.date =datenum('Mar.19,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'changedRewardType'};
eventLog{eventNum}.subject ={}; % all new rats here, start with soy
eventLog{eventNum}.stationID =[11]; %B % top right
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='controlled with brothers on water on top left'; 
eventLog{eventNum}.details.from ='water';  
eventLog{eventNum}.details.to   ='soy';

eventLog{eventNum}.date =datenum('Apr.9,2008');%datestr(now,21) % happened a few days before this but rats were not running yet
eventLog{eventNum}.eventName ={'lightingChange'};
eventLog{eventNum}.subject ={}; % all new rats here, start with soy
eventLog{eventNum}.stationID ={'1A', '1B', '1C', '1D', '1E', '1F'}; %all
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='day light comes on from 12 to 8, but it might be an hour off from daylight savings'; 
eventLog{eventNum}.details.from ='curtain';  % SamH says the old standard was 'the lights cycle at 7am to 9pm' since the vivarium opened in 1993
eventLog{eventNum}.details.to   ='phaseShifted';

eventLog{eventNum}.date =datenum('Apr.10,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'softwareChange'};
eventLog{eventNum}.subject ={}; % all new rats here, start with soy
eventLog{eventNum}.stationID ={'1A', '1B', '1C', '1D', '1E', '1F'}; %all
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='most debugged merged network code, about 60% of rats run daily'; 
eventLog{eventNum}.details.from ='maleCode';  %svn pmeier branch
eventLog{eventNum}.details.to   ='merge20080324'; %rev ~900-956

eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Apr.17,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject ={'rat_231','rat_238','rat_241','rat_242'};
eventLog{eventNum}.stationID ={'1C' '1F' '1E' '1F'}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='doing hundreds of trials were set to 1000, but it appeared to be 1ms'; 
eventLog{eventNum}.details.from =[1000,1000,1000,1000];  
eventLog{eventNum}.details.to   =[6000,6000,6000,6000];


eventNum = eventNum +1;  %good format --pmm
eventLog{eventNum}.date =datenum('Apr.17,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'flunked'};
eventLog{eventNum}.subject ={'223','226','rat_230','233','234','240'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='marv noted they have a hard time... backing up to '; 
eventLog{eventNum}.details.from =[4,4,4,4,4,4];  %or 5
eventLog{eventNum}.details.to   =[3,3,3,3,3,3];

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'102'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='only 75% correct, 250 trials a day, rate 4 times slower in second half of session'; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[1];


eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'flunked'};
eventLog{eventNum}.subject ={'135'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='at chance, exploiting CTs, 300 trials a day, flunked to higher contrast, but moved from expt. 1 to expt. 2, now all flankers vertical like the target'; 
eventLog{eventNum}.details.from =[13]; 
eventLog{eventNum}.details.to   =[14]; %even that he's moving up in expt. still considered a flunk, because contrast of target increased 



eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'135'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='trying to get him to change strategy, bw stably increased like healthy rat, but consistently at 77% of normalized '; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[1.5]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'138'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='slow 10 days recovery from bad 4 day at chance fullFlanker experience, bw increasing and above 85%, currently ~75% correct'; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[1]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'139'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='hugging 80-85% correct, juicy rewards, oddly many correction trials (>60%!)'; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[1]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'penaltyIncrease'};
eventLog{eventNum}.subject ={'237'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='stuck on step 5, while brothers on 9, large oscillation around 75% correct'; 
eventLog{eventNum}.details.from =[1000]; 
eventLog{eventNum}.details.to   =[6000]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'233'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='very good but too few trials per day, about 200 at 90% correct ... but overnight in 3 sessions'; 
eventLog{eventNum}.details.from =[1]; 
eventLog{eventNum}.details.to   =[.6];

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'rewardDecrease'};
eventLog{eventNum}.subject ={'137'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='stable bw, performance just below 85% correct, very few trials all in the beginning'; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[1]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.24,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualStepChange'};
eventLog{eventNum}.subject ={'117'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='no more acuity; back to basic tilt discrim. why? performance at chance, left bias, dropping bw slowly, increasing ct exploitation, contrast [0 0.125 0.25 0.5 0.75 1], pixperCycs [4 8 16 32 64 128],  '; 
eventLog{eventNum}.details.from =[2]; 
eventLog{eventNum}.details.to   =[6]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.27,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualProtocolChange'};
eventLog{eventNum}.subject ={'229','230','233','234','237','238','227','228','231','232','138','139'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='target gets dimmer on step 10, all these detection rats now have flankers, and the orients will include diagonals (prev just HV flanks, 4 orient targets))'; 
eventLog{eventNum}.details.from ='1_1'; 
eventLog{eventNum}.details.to   ='1_6'; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.27,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'uncomfortableMedicalIntervention'};
eventLog{eventNum}.subject ={'102'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='dime-size abcess popped by catherine, fluff cage, recommends daily irrigation for a week.'; 
eventLog{eventNum}.details.from ='lump'; 
eventLog{eventNum}.details.to   ='openWound'; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('May.30,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'flunked'};
eventLog{eventNum}.subject ={'137','139'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='full flankers are too hard, esp with a dim target (0.3)'; 
eventLog{eventNum}.details.from =[10]; 
eventLog{eventNum}.details.to   =[9]; 

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('Jun.05,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualProtocolChange'};
eventLog{eventNum}.subject ={'144'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='swicthed from +/-45 to +-30; might as well synchronize while he sucks, currently at chance and upside down for many months'; 
eventLog{eventNum}.details.from ='1_1'; 
eventLog{eventNum}.details.to   ='2_0'; %has size shaping

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('Jun.05,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualProtocolChange'};
eventLog{eventNum}.subject ={'130'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='added shrinking stim capacity for the next step (8). he''s on 7, oddly his performance plummeted the day BEFORE this change'; 
eventLog{eventNum}.details.from ='1_0'; 
eventLog{eventNum}.details.to   ='2_0'; %has size shaping

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('Jun.05,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'manualProtocolChange'};
eventLog{eventNum}.subject ={'117'};
eventLog{eventNum}.stationID ={}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='added shrinking stim capacity for an upcoming step (8). he''s on 6, recouping from acuity sweeps'; 
eventLog{eventNum}.details.from ='1_0'; 
eventLog{eventNum}.details.to   ='2_0'; %has size shaping

eventNum = eventNum +1;  
eventLog{eventNum}.date =datenum('Jun.11,2008');%datestr(now,21)
eventLog{eventNum}.eventName ={'wrongRat'};
eventLog{eventNum}.subject ={'234','240'};
eventLog{eventNum}.stationID ={'1B','1F'}; 
eventLog{eventNum}.issuedBy ='pmm';
eventLog{eventNum}.comment ='240 and 234 were switched with each other in the violate heat of 6/11/08, alee mistake'; 
eventLog{eventNum}.details.from =''; 
eventLog{eventNum}.details.to   =''; 