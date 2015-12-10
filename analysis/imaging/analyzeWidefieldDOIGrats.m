%This file uses shiftData data to compare widefield data across
%conditions using backgroundgratings stimulus
close all
clear all
% profile on
%%

%CHOOSE FILES WITH THE DATA IN THEM
datafiles = {'DOITrainedAnimalsBKGRATSpre',...
            'DOITrainedAnimalsBKGRATSpost'};
% datafiles = {'SalinePreGratings', ...  %1
%             'SalinePostGratings', ...  %2
%             'DOIPreGratings', ...      %3
%             'DOIPostGratings', ...     %4
%             'LisuridePreGratings', ... %5
%             'LisuridePostGratings'};    %6

%CHOOSE FILE WITH POINTS FROM analyzeWidefieldDOI & SET NAMES
load('SalinePoints'); %pre-made points for visual areas used in original analysis
areanames = {'V1','LM','AL','RL','AM','PM','P'};
load mapOverlay;

%CHOOSE PIXEL AVERAGING RANGE
range = (-2:2); % averages signal over 1 pixel + this range   

%optional: adjust plot size if necessary
scscale = 2; % increase to decrease plot sizesn
scsz = get( 0, 'Screensize' ); %get screensize for plots
%screensize = get( groot, 'Screensize' ); %get screensize for plots in R2014b and later

%preallocate data arrays
% allshiftData = zeros(260,260,7,length(datafiles));
allcycavg = zeros(260,260,100,length(datafiles));
allmnfit = zeros(260,260,17,length(datafiles));
% sdshiftData = zeros(260,260,7,length(datafiles));
sdcycavg = zeros(260,260,100,length(datafiles));
sdmnfit = zeros(260,260,17,length(datafiles));
indcycavg = nan(150,10,length(areanames),length(datafiles)); %rows = time, column = animal, 3rd = condition; normal
inddeconcycavg = nan(150,10,length(areanames),length(datafiles)); %rows = time, column = animal, 3rd = condition; deconvolved
% groupcycavg = zeros(260,260,100,10,length(datafiles)); %make for up to 10 animals per condition
% groupfit = zeros(260,260,17,10,length(datafiles));

for i= 1:length(datafiles) %collates all conditions (numbered above)
    
    load(datafiles{i},'fit','mnfit','cycavg');%load data
    
%     mnshiftData = mean(shiftData,4);% get means across animals
    mncycavg = mean(cycavg,4);
    
%     allshiftData(:,:,:,i) = mnshiftData; %create arrays with all group means
    allcycavg(:,:,:,i) = mncycavg;
    allmnfit(:,:,:,i) = mnfit;
    
    
  %  sdshiftData(:,:,:,i) = std(shiftdata,[],4); %create arrays with all group SDs
    sdcycavg(:,:,:,i) = nanstd(cycavg,4)/sqrt(size(cycavg,4));
    sdmnfit(:,:,:,i) = nanstd(fit,4)/sqrt(size(cycavg,4));
    
%     groupcycavg(:,:,:,:,i) = cycavg;
%     groupfit(:,:,:,:,i) = fit;
%     
    doIndCycAvgDecon;
%     
end

dir = 'C:\Users\nlab\Desktop\Widefield Data\DOI';
nam = 'CompareGratings';
save(fullfile(dir,nam),'allcycavg','allmnfit','areanames','datafiles','range','scscale','indcycavg','inddeconcycavg');
%       
% %GENERATE PDFs FOR ALL CONDITIONS
% %%%
% expname = 'SalineCompareGrats.pdf';
% conds = [1 2];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOIGratsplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%

%%%
expname = 'DOICompareGrats.pdf';
conds = [1 2];

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

doDOIGratsplots;

ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
delete(psfilename);
%%%

% %%%
% expname = 'LisurideCompareGrats.pdf';
% conds = [5 6];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOIGratsplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%
% 
% %%%
% expname = 'AllPreCompareGrats.pdf';
% conds = [1 3 5];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOIGratsplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%
% 
% %%%
% expname = 'AllPostCompareGrats.pdf';
% conds = [2 4 6];
% 
% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% doDOIGratsplots;
% 
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,expname));
% delete(psfilename);
% %%%
% % profile viewer



