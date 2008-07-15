function cleanUpFigure(f,turnOffTics)

if ~exist('turnOffTics','var')
   turnOffTics=0;
end


for i=1:length(f)
    if strcmp(get(f(i),'type'), 'figure')
    get(f(i))
    set(f(i),'Color',[1 1 1])
    children=get(f(i), 'Children')
    doClassSpecificAction(children,turnOffTics)
    end
end


function doClassSpecificAction(children,turnOffTics)
% childrenTypes=get(children,'type')
for j=1:length(children)
%     childrenTypes(j)
%     class(childrenTypes(j))
    childType=get(children(j),'type')

    switch childType
        case 'axes'
            succ=cleanUpThisAxis(children(j),turnOffTics);
        case 'line'
            succ=cleanUpThisLine(children(j));
        case 'text'
            succ=cleanUpThisText(children(j));
        case 'hggroup'
            succ=cleanUpThisHgGroup(children(j));
        otherwise
            disp(sprintf('Not doing anything to %s', childType))
    end
    
end


function succ=cleanUpThisAxis(a,turnOffTics)
% get(a)
set(a,'FontName', 'Helvetica')
set(a,'FontSize', 30)
set(a,'LineWidth', 2)
if turnOffTics
    set(a,'TickLength', [0.001 0])
end
%set(a,'TickLength', [0.01 0.025])
set(a,'TickDir', 'out')
%set(gca,'fontSize', 14)
children=get(a, 'Children')
doClassSpecificAction(children)
succ=1;


function succ=cleanUpThisLine(h)
% get(h)
set(h,'LineWidth', 2.0) %change back to 1.5
% set(h,'MarkerSize', 4)
succ=1;

function succ=cleanUpThisText(t)
% get(t)
%set(t,'fontSize',14)
succ=1;


function succ=cleanUpThisHgGroup(h)
get(h)
set(h,'LineWidth', 2.0) %change back to 1.5 later
succ=1;

