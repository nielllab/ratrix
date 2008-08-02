function doAnalysis(subIDsAndRackNums, dateRange, plots, verbose)
% function doAnalysis(subIDsAndRackNums, dateRange, plots, verbose)
%   Produces plots one rat per window. Calls one other non-standard function
% getArrangement(length). It is implemented as an inline function here.
% Currently implemented to produce the same set of plots for every one of
% the subIDs. doAnalysis makes use of standard ratrix plotting routines -
% run 'setupEnvironment' before running doAnalysis
% 
%   Supported Plots 
%             'percentCorrect',
%             'plotTrialsPerDay',
%             'plotBias',
%             'plotRatePerDay',
%             'plotRewardTime',
%             'plotLickAndRT',
%             'flankerDpr',
%             'plotTemporalROC',
%             'plotBiasScatter'
%
%   Default Plots
%             'percentCorrect',
%             'plotTrialsPerDay',
%             'plotBias',
%             'plotRatePerDay'
%
%   Default Rats can be specified. Enter correct rackNums next to rat
%   number to ensure correct data retrieval.
%
%   Default 'dateRange' is last eight days. Vary dateRange by passing
%   [(now-k) now] to get data for last (k+1) days
%
% -balaji Aug 1, 2008

% Specify defaults for subIDs here
if ~exist('subIDsAndRackNums','var') || isempty(subIDsAndRackNums)
    subIDsAndRackNums = {
        {'267',2},...
        {'268',2},...
        {'269',2},...
        {'270',2},...
        {'159',2},...
        {'161',2},...
        {'180',2},...
        {'186',2},...
        {'181',3},...
        {'182',3},...
        {'187',3},...
        {'188',3}
        }
end

if ~exist('dateRange','var') || isempty(dateRange)
    dateRange = [floor(now-7) floor(now)] % last 8 days days
end

if ~exist('plots','var') || isempty(plots)
    plots = {'percentCorrect',...
        'plotTrialsPerDay',...
        'plotBias',...
        'plotRatePerDay'};
    
else
    supportedPlots = {'percentCorrect',...
        'plotTrialsPerDay',...
        'plotBias',...
        'plotRatePerDay',...
        'plotRewardTime',...
        'plotLickAndRT',...
        'flankerDpr',...
        'plotTemporalROC',...
        'plotBiasScatter'};
    if any(~ismember(plots,supportedPlots))
        unsupportedPlots = setdiff(plots, supportedPlots)
        warning('request for unsupported plot type. removing said plots');
        plots = plots(~ismember(plots,unsupportedPlots))
    end
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = 1
end

[l b] = getArrangement(length(plots));

for ratNo = 1:length(subIDsAndRackNums)
    rat = subIDsAndRackNums{ratNo}{1}; 
    rackForRat = subIDsAndRackNums{ratNo}{2};
    smallData = getSmalls(subIDsAndRackNums{ratNo}{1},dateRange,subIDsAndRackNums{ratNo}{2},verbose);
    
    fhan = figure('Name',rat,'Numbertitle','off');
    
    for plotNo = 1:length(plots)
        doPlot(plots{plotNo},smallData,fhan,l,b,plotNo,[],1);
        title(plots{plotNo}); 
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%INLINE FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [l b] = getArrangement(i)
l = ceil(sqrt(i));
b = l;
end