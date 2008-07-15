%% quick inspect - simple user interface

close all

heatViewed=        2;  %1-5; filters which box, 0 allows all rats and weeklyReports
boxViewed=         0;  %1-6; filters which box, 0 allows all boxes
daysBackAnalyzed=  5;  %at least 8 if using weeklyReport
suppressUpdates=   0;  %0 or 1, if set to 1 it is faster but won't load any new data since last time
seeBW=             1;  %1 if you want to see body weights, 0 otherwise
justOne=           1;  %0 is default, 1 to view a single rat
whichOne={'rat_226'};  %only used if the above is 1
more=              0;  %see more plots
rackNum=           1;  %male =1, female=2; gingers=3;

%don't change the subjects! just for reference
% HEAT       %1        %2       %3        %4     %overnight
subjects = {'rat_223','rat_224','rat_225','rat_226';
    'rat_239','rat_240','rat_241','rat_242'};
% subjects={'rat_140','rat_141','rat_142','rat_195','rat_144';... %3  upper-left
%           'rat_145','rat_146','rat_147','rat_148','rat_129';... %11 upper-right
%           'rat_112','rat_126','rat_102','rat_106','rat_196';... %1  middle-left
%           'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
%           'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
%           'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right
      
          
% subjects={'rat_140','rat_141','rat_142','rat_143','rat_144';... %3  upper-left
%         'rat_145','rat_146','rat_147','rat_148','rat_129';... %11 upper-right
%         'rat_112','rat_126','rat_102','rat_106','rat_127';... %1  middle-left
%         'rat_115','rat_116','rat_117','rat_130','rat_114';... %9  middle-right
%         'rat_132','rat_133','rat_138','rat_139','rat_128';... %2  lower-left
%         'rat_134','rat_135','rat_136','rat_137','rat_131'};   %4  lower-right
    
doQuickInspect(subjects,heatViewed,boxViewed,daysBackAnalyzed,suppressUpdates,seeBW,justOne,whichOne,more,rackNum);