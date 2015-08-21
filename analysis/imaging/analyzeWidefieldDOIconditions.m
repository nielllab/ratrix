%This file uses mnfit and cycavg data to compare widefield data across
%conditions
clear all
close all
%%
%%.jhnfs
%CHOOSE FILES WITH THE DATA IN THEM
datafiles = {'SalinePreDataGood', ...  %1
            'SalinePostDataGood', ...  %2
            'DOIPreDataGood', ...      %3
            'DOIPostDataGood', ...     %4
            'LisuridePreDataGood', ... %5
            'LisuridePostDataGood'};    %6

%CHOOSE CONDITIONS TO COMPARE (SEE DATAFILES BELOW)
conds = [5 6];

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};

%CHOOSE PIXEL AVERAGING RANGE
range = (-2:2); % averages signal over 1 pixel + this range   

%optional: adjust plot size if necessary
scscale = 2; % increase to decrease plot size
%%

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%preallocate here
allmnfit = zeros(260,260,18,length(datafiles));
allcycavg = zeros(260,260,15,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    load(datafiles{i},'mnfit','cycavg');
    allmnfit(:,:,:,i) = mnfit; %%%x,y,sf,tf
    mncycavg = mean(cycavg,4);
    allcycavg(:,:,:,i) = mncycavg;  %%%x,y,t,area
end
      
doDOIplots;

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
