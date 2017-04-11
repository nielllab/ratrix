%batch_blind

clear all
close all
dbstop if error
pathname = '\\langevin\backup\widefield\';
datapathname = '\\langevin\backup\widefield\';  %Acrilic cleared skull headplate\

n=0;

%%%execute the shit above here first.

%then select the sessions you need to run

%then execute batchDfofMovieBlind  (make sure the right set of stims are
%commented/uncommented)




n=n+1;
files(n).subj = '2blindg6b.6tt';
files(n).expt = '033017';
files(n).n5sec_16mwdata =  'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run5_blueLED_16mw_medial_5s\2BlindG6B.6tt_run5_blueLED_16mw_medial_5s';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run5_blueLED_16mw_medial_5s\2BlindG6B.6tt_run5_blueLED_16mw_medial_maps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run4_blueLED_750uw_medial_5s\2BlindG6B.6tt_run4_blueLED_750uw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run4_blueLED_750uw_medial_5s\2BlindG6B.6tt_run4_blueLED_750uw_medial_maps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run1_blueLED_375uw_medial_5s\2BlindG6B.6tt_run1_blueLED_375uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run1_blueLED_375uw_medial_5s\2BlindG6B.6tt_run1_blueLED_375uw_medial_maps.mat';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = '';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = '';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = '';
files(n).n100msec_16mwdata =  'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run6_blueLED_16mw_medial_100ms\2BlindG6B.6tt_run6_blueLED_16mw_medial_100ms';
files(n).n100msec_16mw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run6_blueLED_16mw_medial_100ms\2BlindG6B.6tt_run6_blueLED_16mw_medial_maps.mat';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run3_blueLED_750uw_medial_100ms\2BlindG6B.6tt_run3_blueLED_750uw_medial_100ms';
files(n).n100msec_750uw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run3_blueLED_750uw_medial_100ms\2BlindG6B.6tt_run3_blueLED_750uw_medial_maps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run2_blueLED_375uw_medial_100ms\2BlindG6B.6tt_run2_blueLED_375uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\033017 2BlindG6B.6TT light level test\2BlindG6B.6tt_run2_blueLED_375uw_medial_100ms2BlindG6B.6tt_run2_blueLED_375uw_medial_maps.mat';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 

n=n+1;
files(n).subj = 'g62aaa4tt';
files(n).expt = '033017';
files(n).n5sec_16mwdata =  'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run5_blueLED_16mw_medial_5s\g62aaa4tt_run5_blueLED_16mw_medial_5s';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run5_blueLED_16mw_medial_5s\g62aaa4tt_run5_blueLED_16mw_medial_maps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run4_blueLED_750uw_medial_5s\g62aaa4tt_run4_blueLED_750uw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run4_blueLED_750uw_medial_5s\g62aaa4tt_run4_blueLED_750uw_medial_maps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run1_blueLED_375uw_medial_5s\g62aaa4tt_run1_blueLED_375uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run1_blueLED_375uw_medial_5s\g62aaa4tt_run1_blueLED_375uw_medial_maps.mat';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = '';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = '';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = '';
files(n).n100msec_16mwdata =  'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run6_blueLED_16mw_medial_100ms\g62aaa4tt_run6_blueLED_16mw_medial_100ms';
files(n).n100msec_16mw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run6_blueLED_16mw_medial_100ms\g62aaa4tt_run6_blueLED_16mw_medial_maps.mat';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run3_blueLED_750uw_medial_100ms\g62aaa4tt_run3_blueLED_750uw_medial_100ms';
files(n).n100msec_750uw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run3_blueLED_750uw_medial_100ms\g62aaa4tt_run3_blueLED_750uw_medial_maps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run2_blueLED_375uw_medial_100ms\g62aaa4tt_run2_blueLED_375uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\033017 G62AAA4TT light level test\g62aaa4tt_run2_blueLED_375uw_medial_100ms\g62aaa4tt_run2_blueLED_375uw_medial_maps.mat';
files(n).LEDposition = 'medial';
files(n).label = 'ck2 g6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = 'g6blind7b.10lt';
files(n).expt = '033017';
files(n).n5sec_16mwdata =  'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run5_blueLED_16mw_medial_5s\G6Blind7B.10lt_run5_blueLED_16mw_medial_5s';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run5_blueLED_16mw_medial_5s\G6Blind7B.10lt_run5_blueLED_16mw_medial_maps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run4_blueLED_750uw_medial_5s\G6Blind7B.10lt_run4_blueLED_750uw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run4_blueLED_750uw_medial_5s\G6Blind7B.10lt_run4_blueLED_750uw_medial_maps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run1_blueLED_375uw_medial_5s\G6Blind7B.10lt_run1_blueLED_375uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run1_blueLED_375uw_medial_5s\G6Blind7B.10lt_run1_blueLED_375uw_medial_maps.mat';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = '';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = '';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = '';
files(n).n100msec_16mwdata =  'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run6_blueLED_16mw_medial_100ms\G6Blind7B.10lt_run6_blueLED_16mw_medial_100ms';
files(n).n100msec_16mw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run6_blueLED_16mw_medial_100ms\G6Blind7B.10lt_run6_blueLED_16mw_medial_maps.mat';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run3_blueLED_750uw_medial_100ms\G6Blind7B.10lt_run3_blueLED_750uw_medial_100ms';
files(n).n100msec_750uw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run3_blueLED_750uw_medial_100ms\G6Blind7B.10lt_run3_blueLED_750uw_medial_maps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run2_blueLED_375uw_medial_100ms\G6Blind7B.10lt_run2_blueLED_375uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\033017 G6Blind7B.10LT light level test\G6Blind7B.10lt_run2_blueLED_375uw_medial_100ms\G6Blind7B.10lt_run2_blueLED_375uw_medial_maps.mat';
files(n).LEDposition = 'medial';
files(n).label = 'blind ck2g6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = '2blindg6b.6tt';
files(n).expt = '033117';
files(n).n5sec_16mw =  '';
files(n).n5sec_16mwdata = '';
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = '';
files(n).n5sec_375uw = '';
files(n).n5sec_375uwdata = '';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run3_blueLED_16mw_medial_1s\2BlindG6B.6TT_run3_blueLED_375uw_medial_1s';
files(n).n1sec_750uw = 'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run3_blueLED_16mw_medial_1s\2BlindG6B.6TT_run3_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run2_blueLED_750uw_medial_1s\2BlindG6B.6TT_run2_blueLED_375uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run2_blueLED_750uw_medial_1s\2BlindG6B.6TT_run2_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run1_blueLED_375uw_medial_1s\2BlindG6B.6TT_run1_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\033117 2BlindG6B.6TT light level test\2BlindG6B.6TT_run1_blueLED_375uw_medial_1s\2BlindG6B.6TT_run1_blueLED_375uw_medial_1smaps.mat';
files(n).n100msec_16mwdata = '';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = '';
files(n).n100msec_375uw = '';
files(n).n100msec_375uwdata = '';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 

n=n+1;
files(n).subj = 'g62aaa4tt';
files(n).expt = '033117';
files(n).n5sec_16mw =  '';
files(n).n5sec_16mwdata = '';
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = '';
files(n).n5sec_375uw = '';
files(n).n5sec_375uwdata = '';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run3_blueLED_16mw_medial_1s\G62aaa4tt_run3_blueLED_375uw_medial_1s';
files(n).n1sec_750uw = 'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run3_blueLED_16mw_medial_1s\G62aaa4tt_run3_blueLED_375uw_medial_1smap.mat';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run2_blueLED_750uw_medial_1s\g62aaa4tt_run2_blueLED_375uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run2_blueLED_750uw_medial_1s\g62aaa4tt_run2_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run1_blueLED_375uw_medial_1s\g62aaa4tt_run1_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\033117 G62AAA4tt light level test\g62aaa4tt_run1_blueLED_375uw_medial_1s\g62aaa4tt_run1_blueLED_375uw_medial_1smaps.mat';
files(n).n100msec_16mwdata = '';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = '';
files(n).n100msec_375uw = '';
files(n).n100msec_375uwdata = '';
files(n).LEDposition = 'medial';
files(n).label = 'ck2 g6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = 'g6blind7b.10lt';
files(n).expt = '033117';
files(n).n5sec_16mw =  '';
files(n).n5sec_16mwdata = '';
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = '';
files(n).n5sec_375uw = '';
files(n).n5sec_375uwdata = '';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run3_blueLED_16mw_medial_1s\G6Blind7B.10lt_run3_blueLED_375uw_medial_1s';
files(n).n1sec_750uw = 'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run3_blueLED_16mw_medial_1s\G6Blind7B.10lt_run3_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run2_blueLED_750uw_medial_1s\G6Blind7B.10lt_run2_blueLED_375uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run2_blueLED_750uw_medial_1s\G6Blind7B.10lt_run2_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run1_blueLED_375uw_medial_1s\G6Blind7B.10lt_run1_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\033117 G6Blind7B.10LT light level test\G6Blind7B.10lt_run1_blueLED_375uw_medial_1s\G6Blind7B.10lt_run1_blueLED_375uw_medial_1smaps.mat';
files(n).n100msec_16mwdata = '';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = '';
files(n).n100msec_375uw = '';
files(n).n100msec_375uwdata = '';
files(n).LEDposition = 'medial';
files(n).label = 'blind ck2g6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = '2blindg6aflt';
files(n).expt = '040517';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run4_blueLED_16mw_medial_5s\2blindg6aflt_run4_blueLED_16mw_medial_5smaps.mat';
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run4_blueLED_16mw_medial_5s\2blindg6aflt_run4_blueLED_16mw_medial_5s'; 
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = '';
files(n).n5sec_375uw =  'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run1_blueLED_375uw_medial_5s\2blindg6aflt_run1_blueLED_375uw_medial_5smaps.mat';
files(n).n5sec_375uwdata ='Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run1_blueLED_375uw_medial_5s\2blindg6aflt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = '';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = '';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = '';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run3_blueLED_16mw_medial_100ms\2blindg6aflt_run3_blueLED_16mw_medial_100msmaps.mat';
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run3_blueLED_16mw_medial_100ms\2blindg6aflt_run3_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = '';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run2_blueLED_375uw_medial_100ms\2blindg6aflt_run2_blueLED_375uw_medial_100msmaps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6aflt light level test\2blindg6aflt_run2_blueLED_375uw_medial_100ms\2blindg6aflt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'bad imaging session'; %timing & light leak; run 3 okay 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = '2blindg6alt';
files(n).expt = '040517';
files(n).n5sec_16mw =  'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run4_blueLED_16mw_medial_5s\2blindg6alt_run4_blueLED_16mw_medial_5smaps.mat';
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run4_blueLED_16mw_medial_5s\2blindg6alt_run4_blueLED_16mw_medial_5s';
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = '';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run1_blueLED_375uw_medial_5s\2blindg6alt_run1_blueLED_375uw_medial_5smaps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run1_blueLED_375uw_medial_5s\2blindg6alt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = '';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = '';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = '';
files(n).n100msec_16mw = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run3_blueLED_16mw_medial_100ms\2blindg6alt_run3_blueLED_16mw_medial_100msmaps.mat'; 
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run3_blueLED_16mw_medial_100ms\2blindg6alt_run3_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = '';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run2_blueLED_375uw_medial_100ms\2blindg6alt_run2_blueLED_375uw_medial_100msmaps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6alt light level test\2blindg6alt_run2_blueLED_375uw_medial_100ms\2blindg6alt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'bad imaging session'; %timing & light leak
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = 'g62ss4lt';
files(n).expt = '040517';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run7_blueLED_16mw_medial_5s\g62ss4lt_run7_blueLED_16mw_medial_5smaps.mat';
files(n).n5sec_16mwdata =  'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run7_blueLED_16mw_medial_5s\g62ss4lt_run7_blueLED_16mw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run6_blueLED_750uw_medial_5s\g62ss4lt_run6_blueLED_750uw_medial_5smaps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run6_blueLED_750uw_medial_5s\g62ss4lt_run6_blueLED_750uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run1_blueLED_375uw_medial_5s\g62ss4lt_run1_blueLED_375uw_medial_5smaps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run1_blueLED_375uw_medial_5s\g62ss4lt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run9_blueLED_16mw_medial_1s\g62ss4lt_run9_blueLED_16mw_medial_1smaps.mat';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run9_blueLED_16mw_medial_1s\g62ss4lt_run9_blueLED_16mw_medial_1s';
files(n).n1sec_750uw =  'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run4_blueLED_750uw_medial_1s\g62ss4lt_run4_blueLED_750uw_medial_1smaps.mat';
files(n).n1sec_750uwdata ='Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run4_blueLED_750uw_medial_1s\g62ss4lt_run4_blueLED_750uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run3_blueLED_375uw_medial_1s\g62ss4lt_run3_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run3_blueLED_375uw_medial_1s\g62ss4lt_run3_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run8_blueLED_16mw_medial_100ms\g62ss4lt_run8_blueLED_16mw_medial_100msmaps.mat';
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run8_blueLED_16mw_medial_100ms\g62ss4lt_run8_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run5_blueLED_750uw_medial_100ms\g62ss4lt_run5_blueLED_750uw_medial_100msmaps.mat';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run5_blueLED_750uw_medial_100ms\g62ss4lt_run5_blueLED_750uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run2_blueLED_375uw_medial_100ms\g62ss4lt_run2_blueLED_375uw_medial_100msmaps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\040517 g62ss4lt light level test\g62ss4lt_run2_blueLED_375uw_medial_100ms\g62ss4lt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'camk2 gc6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'okay imaging session'; %1s & 100ms stim okay, 5s stim funky 
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = '2blindg6b.1lt';
files(n).expt = '040517';
files(n).n5sec_16mw =  'crilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run7_blueLED_16mw_medial_5s\2blindg6b.1lt_run7_blueLED_16mw_medial_5smaps.mat';
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run7_blueLED_16mw_medial_5s\2blindg6b.1lt_run7_blueLED_16mw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run6_blueLED_750uw_medial_5s\2blindg6b.1lt_run6_blueLED_750uw_medial_5smaps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run6_blueLED_750uw_medial_5s\2blindg6b.1lt_run6_blueLED_750uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run1_blueLED_375uw_medial_5s\2blindg6b.1lt_run1_blueLED_375uw_medial_5smaps.mat';
files(n).n5sec_375uwdata ='Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run1_blueLED_375uw_medial_5s\2blindg6b.1lt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run9_blueLED_16mw_medial_1s\2blindg6b.1lt_run9_blueLED_16mw_medial_1smaps.mat'; 
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run9_blueLED_16mw_medial_1s\2blindg6b.1lt_run9_blueLED_16mw_medial_1s';
files(n).n1sec_750uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run4_blueLED_750uw_medial_1s\2blindg6b.1lt_run4_blueLED_750uw_medial_1smaps.mat';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run4_blueLED_750uw_medial_1s\2blindg6b.1lt_run4_blueLED_750uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run3_blueLED_375uw_medial_1s\2blindg6b.1lt_run3_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run3_blueLED_375uw_medial_1s\2blindg6b.1lt_run3_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run8_blueLED_16mw_medial_100ms\2blindg6b.1lt_run8_blueLED_16mw_medial_100msmaps.mat';
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run8_blueLED_16mw_medial_100ms\2blindg6b.1lt_run8_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run5_blueLED_750uw_medial_100ms\2blindg6b.1lt_run5_blueLED_750uw_medial_100msmaps.mat';
files(n).n100msec_750uwdata ='Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run5_blueLED_750uw_medial_100ms\2blindg6b.1lt_run5_blueLED_750uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run2_blueLED_375uw_medial_100ms\2blindg6b.1lt_run2_blueLED_375uw_medial_100msmaps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.1lt light level test\2blindg6b.1lt_run2_blueLED_375uw_medial_100ms\2blindg6b.1lt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'bad imaging session'; %light leaking; run 3&4 look okay
files(n).LEDcolor = 'blue'; 


n=n+1;
files(n).subj = '2blindg6b.2lt';
files(n).expt = '0405017';
files(n).n5sec_16mw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run9_blueLED_16mw_medial_5s\2blindg6b.2lt_run9_blueLED_16mw_medial_5smaps.mat'; 
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run9_blueLED_16mw_medial_5s\2blindg6b.2lt_run9_blueLED_16mw_medial_5s';
files(n).n5sec_750uw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run4_blueLED_750uw_medial_5s\2blindg6b.2lt_run4_blueLED_750uw_medial_5smaps.mat';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run4_blueLED_750uw_medial_5s\2blindg6b.2lt_run4_blueLED_750uw_medial_5s';
files(n).n5sec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run3_blueLED_375uw_medial_5s\2blindg6b.2lt_run3_blueLED_375uw_medial_5smaps.mat';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run3_blueLED_375uw_medial_5s\2blindg6b.2lt_run3_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run7_blueLED_16mw_medial_1s\2blindg6b.2lt_run7_blueLED_16mw_medial_1smaps.mat';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run7_blueLED_16mw_medial_1s\2blindg6b.2lt_run7_blueLED_16mw_medial_1s';
files(n).n1sec_750uw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run6_blueLED_750uw_medial_1s\2blindg6b.2lt_run6_blueLED_750uw_medial_1smaps.mat';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run6_blueLED_750uw_medial_1s\2blindg6b.2lt_run6_blueLED_750uw_medial_1s';
files(n).n1sec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run1_blueLED_375uw_medial_1s\2blindg6b.2lt_run1_blueLED_375uw_medial_1smaps.mat';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run1_blueLED_375uw_medial_1s\2blindg6b.2lt_run1_blueLED_375uw_medial_1s';
files(n).n100msec_16mw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run8_blueLED_16mw_medial_100ms\2blindg6b.2lt_run8_blueLED_16mw_medial_100msmaps.mat';  
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run8_blueLED_16mw_medial_100ms\2blindg6b.2lt_run8_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = 'crilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run5_blueLED_750uw_medial_100ms\2blindg6b.2lt_run5_blueLED_750uw_medial_100msmaps.mat';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run5_blueLED_750uw_medial_100ms\2blindg6b.2lt_run5_blueLED_750uw_medial_100ms';
files(n).n100msec_375uw = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run2_blueLED_375uw_medial_100ms\2blindg6b.2lt_run2_blueLED_375uw_medial_100msmaps.mat';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\040517 2blindg6b.2lt light level test\2blindg6b.2lt_run2_blueLED_375uw_medial_100ms\2blindg6b.2lt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'blind OPNko';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'bad imaging session';  %timing & light leak; 1s stim timing issues but response okay
files(n).LEDcolor = 'blue'; 

n=n+1;
files(n).subj = 'g62ww3rt';
files(n).expt = '041017';
files(n).n5sec_16mw =  '';   %.mat file generated during analysis here
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run7_blueLED_16mw_medial_5s\g62ww3rt_run7_blueLED_16mw_medial_5s'; 
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run6_blueLED_750uw_medial_5s\g62ww3rt_run6_blueLED_750uw_medial_5s';
files(n).n5sec_375uw = '';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run1_blueLED_375uw_medial_5s\g62ww3rt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run9_blueLED_16mw_medial_1s\g62ww3rt_run9_blueLED_16mw_medial_1s';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run4_blueLED_750uw_medial_1s\g62ww3rt_run4_blueLED_750uw_medial_1s';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run3_blueLED_375uw_medial_1s\g62ww3rt_run3_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  '';
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run8_blueLED_16mw_medial_100ms\g62ww3rt_run8_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run5_blueLED_750uw_medial_100ms\g62ww3rt_run5_blueLED_750uw_medial_100ms';
files(n).n100msec_375uw = '';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ww3rt light level test\g62ww3rt_run2_blueLED_375uw_medial_100ms\g62ww3rt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'camk2 gc6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 

n=n+1;
files(n).subj = 'g62ss4lt';
files(n).expt = '041017';
files(n).n5sec_16mw =  '';   %.mat file generated during analysis here
files(n).n5sec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run7_blueLED_16mw_medial_5s\g62ss4lt_run7_blueLED_16mw_medial_5s';  
files(n).n5sec_750uw = '';
files(n).n5sec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run6_blueLED_750uw_medial_5s\g62ss4lt_run6_blueLED_750uw_medial_5s';
files(n).n5sec_375uw = '';
files(n).n5sec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run1_blueLED_375uw_medial_5s\g62ss4lt_run1_blueLED_375uw_medial_5s';
files(n).n1sec_16mw =  '';
files(n).n1sec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run9_blueLED_16mw_medial_1s\g62ss4lt_run9_blueLED_16mw_medial_1s';
files(n).n1sec_750uw = '';
files(n).n1sec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run4_blueLED_750uw_medial_1s\g62ss4lt_run4_blueLED_750uw_medial_1s';
files(n).n1sec_375uw = '';
files(n).n1sec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run3_blueLED_375uw_medial_1s\g62ss4lt_run3_blueLED_375uw_medial_1s';
files(n).n100msec_16mw =  '';
files(n).n100msec_16mwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run8_blueLED_16mw_medial_100ms\g62ss4lt_run8_blueLED_16mw_medial_100ms';
files(n).n100msec_750uw = '';
files(n).n100msec_750uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run5_blueLED_750uw_medial_100ms\g62ss4lt_run5_blueLED_750uw_medial_100ms';
files(n).n100msec_375uw = '';
files(n).n100msec_375uwdata = 'Acrilic cleared skull headplate\041017 g62ss4lt light level test\g62ss4lt_run2_blueLED_375uw_medial_100ms\g62ss4lt_run2_blueLED_375uw_medial_100ms';
files(n).LEDposition = 'medial';
files(n).label = 'camk2 gc6';          %or  'blind ck2g6' or 'blind OPNko'
files(n).notes = 'good imaging session'; 
files(n).LEDcolor = 'blue'; 












% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).n5sec_16mw =  '';   %.mat file generated during analysis here
% files(n).n5sec_16mwdata = '';  %data path goes here
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
% files(n).label = 'camk2 gc6';          %or  'blind ck2g6' or 'blind OPNko'
% files(n).notes = 'good imaging session'; 
% files(n).LEDcolor = 'blue'; 


for i = 1:length(files);
    files(i).pathname = pathname;
end

