function cleanUpFigure(f,settings)
%
%
%settings.turnOffLines=0;
%settings.turnOffTics=0;
%settings.LineWidth=1.5;
%settings.AxisLineWidth=2;
%settings.fontSize=14;   % control all othewise unspecified fonts
%settings.axisFontSize=settings.fontSize;
%settings.xyLabelFontSize=settings.fontSize;
%settings.titleFontSize=settings.fontSize;
%settings.textObjectFontSize=settings.fontSize;
%settings.tickDir='out';
    
    
if ~exist('f','var') || isempty(f)
   f=gcf;
end

if ~exist('settings','var') || isempty(settings)
   settings.default=1;
end

if ~ismember('turnOffLines',fields(settings)) 
   settings.turnOffLines=0;
end

if ~ismember('turnOffTics',fields(settings)) 
    settings.turnOffTics=0;
end

if ~ismember('LineWidth',fields(settings)) 
    settings.LineWidth=1.5;
end


if ~ismember('AxisLineWidth',fields(settings)) 
    settings.AxisLineWidth=2;
end

if ~ismember('fontSize',fields(settings)) 
    settings.fontSize=14;   % control all othewise unspecified fonts
end

if ~ismember('axisFontSize',fields(settings)) 
    settings.axisFontSize=settings.fontSize;
end

if ~ismember('xyLabelFontSize',fields(settings)) 
    settings.xyLabelFontSize=settings.fontSize;
end

if ~ismember('titleFontSize',fields(settings)) 
    settings.titleFontSize=settings.fontSize;
end

if ~ismember('textObjectFontSize',fields(settings)) 
    settings.textObjectFontSize=settings.fontSize;
end

if ~ismember('tickDir',fields(settings)) 
    settings.tickDir='out';
end






for i=1:length(f)
    if strcmp(get(f(i),'type'), 'figure')
    %get(f(i))
    set(f(i),'Color',[1 1 1])
    children=get(f(i), 'Children');
    doClassSpecificAction(children,settings)
    end
end


function doClassSpecificAction(children,settings)
% childrenTypes=get(children,'type')
for j=1:length(children)
%     childrenTypes(j)
%     class(childrenTypes(j))
    childType=get(children(j),'type');
    sprintf(childType);
    switch childType
        case 'axes'
            succ=cleanUpThisAxis(children(j),settings);
        case 'line'
            succ=cleanUpThisLine(children(j),settings);
        case 'text'
            succ=cleanUpThisText(children(j),settings);
        case 'hggroup'
            succ=cleanUpThisHgGroup(children(j),settings);
        otherwise
            disp(sprintf('Not doing anything to %s', childType))
    end
    
end


function succ=cleanUpThisAxis(a,settings)
% get(a)
set(a,'FontName', 'Helvetica')
set(a,'FontSize', settings.axisFontSize)

set(a,'LineWidth', settings.AxisLineWidth)
if settings.turnOffTics
    set(a,'TickLength', [0.001 0])
end
if settings.tickDir
    set(a,'TickDir', settings.tickDir)
end

children=get(a, 'Children');
doClassSpecificAction(children,settings)


% since the axis labels and titles are text objects, we set them on their
% own after done processing the custom text code objects
settings.textObjectFontSize=settings.xyLabelFontSize;
doClassSpecificAction(get(a, 'XLabel'),settings)
doClassSpecificAction(get(a, 'YLabel'),settings)
doClassSpecificAction(get(a, 'ZLabel'),settings)
settings.textObjectFontSize=settings.titleFontSize;
doClassSpecificAction(get(a, 'Title'),settings)


succ=1;

function succ=cleanUpThisLabel(h,settings)
set(h,'FontSize', settings.xyLabelFontSize)


function succ=cleanUpThisLine(h,settings)
% get(h)
if ~settings.turnOffLines
    set(h,'LineWidth', settings.LineWidth) 
    % set(h,'MarkerSize', 4)
end
succ=1;

function succ=cleanUpThisText(t,settings)
% get(t)
set(t,'fontSize',settings.textObjectFontSize)
succ=1;

function succ=cleanUpThisHgGroup(h,settings)
%get(h)
children=get(h, 'Children');
doClassSpecificAction(children,settings)
if ~settings.turnOffLines
    set(h,'LineWidth',settings.LineWidth) %%once upon a time it errored on:
    % f=figure; flankerAnalysis(removeSomeSmalls(getSmalls('102'),d.step~=12),  'twoFlankers', 'performancePerDeviationPerCondition','pctYes',  'none', false); cleanUpFigure(f)
end
succ=1;

