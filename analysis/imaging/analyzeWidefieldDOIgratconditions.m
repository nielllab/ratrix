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
conds = [2 4 6];

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};

%CHOOSE PIXEL AVERAGING RANGE
range = (-2:2); % averages signal over 1 pixel + this range   

%optional: adjust plot size if necessary
scscale = 2; % increase to decrease plot sizesn

%create temp file for PDF
psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%preallocate data arrays
allshiftData = zeros(260,260,7,length(datafiles));
allcycavg = zeros(260,260,25,length(datafiles));
allmnfit = zeros(260,260,17,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    load(datafiles{i},'shiftData','mnfit','cycavg');
    mnshiftData = mean(shiftData,4);
    mncycavg = mean(cycavg,4);
    allshiftData(:,:,:,i) = mnshiftData;
    allcycavg(:,:,:,i) = mncycavg;
    allmnfit(:,:,:,i) = mnfit;
end
      
doDOIplotsgrats;

%save data
[f p] = uiputfile('*.mat','save data?');
if f~=0
    save(fullfile(p,f),'allcycavg','allmnfit','allshiftData','areanames','conds','datafiles','range','scscale');
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