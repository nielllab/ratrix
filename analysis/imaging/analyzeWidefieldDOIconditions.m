%This file uses mnfit and cycavg data to compare widefield data across
%conditions
clear all
close all
psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%load the data first
load('SalinePoints'); %pre-made points for visual areas used in original analysis

datafiles = {'SalinePreDataGood', ...  %1
            'SalinePostDataGood', ...  %2
            'DOIPreDataGood', ...      %3
            'DOIPostDataGood', ...     %4
            'LisuridePreDataGood', ... %5
            'LisuridePostDataGood'};    %6

%preallocate here
allmnfit = zeros(260,260,18,length(datafiles));
% allcycavg = zeros(260,260,15,7,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    load(datafiles{i},'mnfit','cycavg');
    allmnfit(:,:,:,i) = mnfit(:,:,:); %%%x,y,sf,tf
%     allcycavg(:,:,:,:,i) = cycavg(:,:,:,:);  %%%x,y,t,area
end
        


%choose the conditions you want to compare (see names above
conds = [2 4 6];

areanames = {'V1','LM','AL','RL','AM','PM','P'};

%choose pixel averaging range
range = (-2:2); % averages signal over 1 pixel + this range   

%make the plots pretty
scscale = 2; % increase to decrease plot size

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
