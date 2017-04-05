%batch_blind

clear all
close all
dbstop if error
pathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';
datapathname = '\\langevin\backup\widefield\Acrilic cleared skull headplate\';  

n=0;

%%%execute the shit above here first.

%then select the sessions you need to run

%then execute batchDfofMovieBlind  (make sure the right set of stims are
%commented/uncommented)














% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).n5sec_16mw =  '';
% files(n).n5sec_16mwdata = '';
% files(n).n5sec_750uw = '';
% files(n).n5sec_750uwdata = '';
% files(n).n5sec_375uw = '';
% files(n).n5sec_375uwdata = '';
% files(n).n1sec_16mw =  '';
% files(n).n1sec_16mwdata = '';
% files(n).n1sec_750uw = '';
% files(n).n1sec_750uwdata = '';
% files(n).n1sec_375uw = '';
% files(n).n1sec_375uwdata = '';
% files(n).n100msec_16mw =  '';
% files(n).n100msec_16mwdata = '';
% files(n).n100msec_750uw = '';
% files(n).n100msec_750uwdata = '';
% files(n).n100msec_375uw = '';
% files(n).n100msec_375uwdata = '';
% files(n).LEDposition = 'medial';
% files(n).label = 'camk2 gc6'; %or  'blind ck2g6' or 'blind OPNko'
% files(n).notes = 'good imaging session'; 
% files(n).LEDcolor = 'blue'; 


for i = 1:length(files);
    files(i).pathname = pathname;
end

