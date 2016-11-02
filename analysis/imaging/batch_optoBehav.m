%batch_optoBehav


clear all
close all
dbstop if error
trialRecpathname = '\\langevin\backup\ballData2\PermanentTrialRecordStore\';  
%outpathname = '';
n=0;




%g62gg10lt
n=n+1;
files(n).subj = 'g62gg10lt';
files(n).expt = '100716';
files(n).trialRec =  'trialRecords_341-558_20161007T124406-20161007T130556';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62gg10lt';
files(n).expt = '101016';
files(n).trialRec =  'trialRecords_586-846_20161010T102023-20161010T104653';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62gg10lt';
files(n).expt = '101116';
files(n).trialRec =  'trialRecords_873-1104_20161011T123045-20161011T130002';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert'; 
files(n).SilenceArea = 'full window'; 

n=n+1;
files(n).subj = 'g62gg10lt';
files(n).expt = '101316';
files(n).trialRec =  'trialRecords_1130-1404_20161013T122436-20161013T125521';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert'; 
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62gg10lt';
files(n).expt = '101316';  %(2)
files(n).trialRec =  'trialRecords_1443-1690_20161013T150201-20161013T152823';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

%Pvchr3b15rt

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101316';
files(n).trialRec =  'trialRecords_4233-4438_20161013T172905-20161013T174946';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';


n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101416';
files(n).trialRec =  'trialRecords_4680-4937_20161014T103648-20161014T110306';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101416';  %(2)
files(n).trialRec =  'trialRecords_4970-5221_20161014T134019-20161014T140854';
files(n).power = '11mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101516';
files(n).trialRec =  'trialRecords_5336-5592_20161015T104840-20161015T111422';
files(n).power = '11mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101716';
files(n).trialRec =  'trialRecords_5706-5905_20161017T114640-20161017T120844';
files(n).power = '22mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'not good session'; %greg ran alone; bias - performance not diff from chance for bottom stim
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '101816';
files(n).trialRec =  'trialRecords_6388-6595_20161018T170423-20161018T172415 ';
files(n).power = '22mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '102016';
files(n).trialRec =  ' trialRecords_7228-7429_20161020T162302-20161020T164515';
files(n).power = '22mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '102616';
files(n).trialRec =  'trialRecords_7612-7807_20161026T162244-20161026T164348';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'V1';

n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '102716';
files(n).trialRec =  'trialRecords_8223-8425_20161027T162211-20161027T164356';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'V1';


n=n+1;
files(n).subj = 'pvchr3b15rt';
files(n).expt = '102716';
files(n).trialRec =  'trialRecords_8578-8766_20161028T153323-20161028T155702';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; %non-opto performance in 70s.. ok i think
files(n).monitor = 'vert';
files(n).SilenceArea = 'V1';




%g62y3lt
n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '102416';
files(n).trialRec =  'trialRecords_706-909_20161024T171946-20161024T174135';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '102516';
files(n).trialRec =  'trialRecords_947-1146_20161025T123248-20161025T125148';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '102616';
files(n).trialRec =  'trialRecords_1228-1483_20161026T153936-20161026T160614';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62y3lt';
files(n).expt = '102716';
files(n).trialRec =  'trialRecords_1518-1710_20161027T131004-20161027T132725';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

%g62gg5rt

n=n+1;
files(n).subj = 'g62gg5';
files(n).expt = '102616';
files(n).trialRec =  'trialRecords_1330-1499_20161025T151706-20161025T153740';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'not good session'; %ryan ran alone 1st time, slacking toward end. long RT's
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

n=n+1;
files(n).subj = 'g62gg5';
files(n).expt = '102616';
files(n).trialRec =  'trialRecords_1552-1806_20161026T135130-20161026T141814';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';

%g62tx15
n=n+1;
files(n).subj = 'g62tx15lt';
files(n).expt = '102716';
files(n).trialRec =  'trialRecords_846-1065_20161027T180135-20161027T182241';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';


n=1;
files(n).subj = 'g62tx15lt';
files(n).expt = '110116';
files(n).trialRec =  'trialRecords_1468-1679_20161101T152656-20161101T154527';
files(n).power = '45mw';
files(n).task = 'GTS';
files(n).geno = 'camk2 gc6';
files(n).notes = 'good session'; 
files(n).monitor = 'vert';

