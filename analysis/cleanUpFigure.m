function cleanUpFigure(f,settings)
%philip meier.  2009.   freely avaiable for use.  As-is. pmm or ucsd not
%responsible for its use. 
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
%settings.MarkerSize=4;
    
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

if ~ismember('MarkerSize',fields(settings)) 
   settings.MarkerSize=[];
end

if ~ismember('box',fields(settings)) 
   settings.box=[];
end

if ~ismember('alphaLabel',fields(settings)) 
   settings.alphaLabel=[];
end

if ~ismember('Units',fields(settings)) 
   settings.Units=[];
end

if ~ismember('PaperPosition',fields(settings)) 
   settings.PaperPosition=[];
end

if ~ismember('FontName',fields(settings)) 
   settings.FontName=[];
end


for i=1:length(f)
    if strcmp(get(f(i),'type'), 'figure')
        set(f(i),'Color',[1 1 1])
        
        if ~isempty(settings.Units)
            set(f(i),'Units', settings.Units)
        end
        if ~isempty(settings.PaperPosition)
            set(f(i),'PaperPosition', settings.PaperPosition)
        end
        
        
        children=get(f(i), 'Children');
        doClassSpecificAction(children,settings)

    elseif strcmp(get(f(i),'type'), 'axes')
        cleanUpThisAxis(f(i),settings)
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

if ~isempty(settings.FontName)
    set(a,'FontName', settings.FontName); %'Helvetica')
end

set(a,'FontSize', settings.axisFontSize)

set(a,'LineWidth', settings.AxisLineWidth)
if settings.turnOffTics
    set(a,'TickLength', [0.001 0])
end
if settings.tickDir
    set(a,'TickDir', settings.tickDir)
end

if ~isempty(settings.box)
    set(a,'box', settings.box)
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

if ~isempty(settings.alphaLabel)
    ys=ylim; xs=xlim;
    fractionOutOfCorner=[0.1 0.1];
    if strcmp(get(a,'xDir'),'normal')
        x=xs(1)-fractionOutOfCorner(1)*range(xs);
    else % reverse
        x=xs(2)+fractionOutOfCorner(1)*range(xs);
    end
    if strcmp(get(a,'yDir'),'normal')
        y=ys(2)+fractionOutOfCorner(2)*range(ys);
    else % reverse
        y=ys(1)-fractionOutOfCorner(2)*range(ys);
    end
    text(x,y, settings.alphaLabel,...
        'fontSize',settings.titleFontSize,'HorizontalAlignment','right','VerticalAlignment','bottom','fontweight','b');
end

succ=1;

function succ=cleanUpThisLabel(h,settings)
set(h,'FontSize', settings.xyLabelFontSize)


function succ=cleanUpThisLine(h,settings)
% get(h)
if ~settings.turnOffLines
    set(h,'LineWidth', settings.LineWidth) 
   
end

if ~isempty(settings.MarkerSize)
    set(h,'MarkerSize', settings.MarkerSize)
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

