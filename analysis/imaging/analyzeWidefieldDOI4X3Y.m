%This file uses mnfit and cycavg from 4X3Y analysis output to compare widefield data across
%conditions
close all
clear all
profile on
%%

%CHOOSE FILES WITH THE DATA IN THEM
datafiles = {'DOITrainedAnimals4X3Ypre',...
            'DOITrainedAnimals4X3Ypost'}
% datafiles = {'SalinePreDataGood', ...  %1
%             'SalinePostDataGood', ...  %2
%             'DOIPreDataGood', ...      %3
%             'DOIPostDataGood', ...     %4
%             'LisuridePreDataGood', ... %5
%             'LisuridePostDataGood'};    %6

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};

%CHOOSE PIXEL AVERAGING RANGE
range = (-2:2); % averages signal over 1 pixel + this range   

%optional: adjust plot size if necessary
scscale = 2; % increase to decrease plot sizesn
scsz = get( 0, 'Screensize' ); %get screensize for plots
%screensize = get( groot, 'Screensize' ); %get screensize for plots in R2014b and later

%%
%preallocate here
allmnfit = zeros(260,260,18,length(datafiles));
allcycavg = zeros(260,260,15,length(datafiles));
sdmnfit = zeros(260,260,18,length(datafiles));
sdcycavg = zeros(260,260,15,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    load(datafiles{i},'fit','mnfit','cycavg');
    allmnfit(:,:,:,i) = mnfit; %%%x,y,sf,tf
    mncycavg = mean(cycavg,4);
    allcycavg(:,:,:,i) = mncycavg;  %%%x,y,t,area
    
    sdcycavg(:,:,:,i) = std(cycavg,[],4)/sqrt(size(cycavg,4));
    sdmnfit(:,:,:,i) = std(fit,[],4)/sqrt(size(fit,4));
end
      
dir = 'C:\Users\nlab\Desktop\Widefield Data\DOI';
nam = 'Compare4X3Y';
save(fullfile(dir,nam),'allcycavg','allmnfit','areanames','datafiles','range','scscale','sdcycavg','sdmnfit');
      
%GENERATE PDFs FOR ALL CONDITIONS
%%%
% expname = 'SalineCompare4X3Y.pdf';
% conds = [1 2];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOI4X3Yplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%

%%%
expname = 'DOICompare4X3Y.pdf';
conds = [1 2];

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

doDOI4X3Yplots;

ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
delete(psfilename);
%%%

%%%
% expname = 'LisurideCompare4X3Y.pdf';
% conds = [5 6];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOI4X3Yplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%
% 
% %%%
% expname = 'AllPreCompare4X3Y.pdf';
% conds = [1 3 5];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOI4X3Yplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%
% 
% %%%
% expname = 'AllPostCompare4X3Y.pdf';
% conds = [2 4 6];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOI4X3Yplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
%%%

profile viewer



