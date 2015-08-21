%This file uses shiftData data to compare widefield data across
%conditions using backgroundgratings stimulus
clear all
close all
%%

%CHOOSE FILES WITH THE DATA IN THEM
datafiles = {'SalinePreGratings', ...  %1
            'SalinePostGratings', ...  %2
            'DOIPreGratings', ...      %3
            'DOIPostGratings', ...     %4
            'LisuridePreGratings', ... %5
            'LisuridePostGratings'};    %6

%CHOOSE CONDITIONS TO COMPARE (SEE DATAFILES BELOW)
conds = [1 2];

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};

%CHOOSE PIXEL AVERAGING RANGE
range = (-2:2); % averages signal over 1 pixel + this range   

%optional: adjust plot size if necessary
scscale = 2; % increase to decrease plot sizesn
%

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%preallocate here
mnshift = zeros(260,260,7,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    load(datafiles{i},'shiftData');
    mnshiftData = mean(shiftData,4);
    allshiftData(:,:,:,i) = mnshiftData;  %%%x,y,t,area
end
      
doDOIplotsgrats;



%save data

[f p] = uiputfile('*.mat','save data?');
if f~=0
    save(fullfile(p,f),'allmnfit');
%     save(fullfile(p,f),'allmnfit','allcycavg');
end

%save PDF
[f p] = uiputfile('*.pdf','save pdf');
if f~=0
    try
        ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
    catch
        display('couldnt generate pdf');
    end
end
delete(psfilename);