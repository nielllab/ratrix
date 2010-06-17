function doBarPlotWithStims(p1,p2,images,colors,yRange,inputMode,addText, groupingBar,imWidth)
%by default, p1= numAttempts, p2=numCorrect b/c inputMode='binodata'
%can also set set inputMode to 'stats&CI'
% groupingBars are {'label',members,height}

if ~exist('colors') || isempty(colors)
    colors=ones(length(p1),3)*0.8;
end

if ~exist('images') || isempty(images)
    images=[];
end

if ~exist('yRange') || isempty(yRange)
    yBotttom=20;
    yMax=85;
else
    yBotttom=yRange(1);
    yMax=yRange(2);
end

if ~exist('inputMode') || isempty(inputMode)
    inputMode='binodata';
end

if ~exist('addText') || isempty(addText)
    addText=1;
end

if ~exist('groupingBar') || isempty(groupingBar)
    groupingBar=[];
end

if ~exist('imWidth') || isempty(imWidth)
    imWidth=0.6; % normalized to bar width, units of x axis
end


switch inputMode
    case 'binodata'
        numAttempts=p1;
        numCorrect=p2;
        [p ci]=binofit(numCorrect,numAttempts);
        stats=p*100;
        ci=100*ci;
    case 'stats&CI'
        stats=p1;
        ci=p2;
    otherwise
        inputMode
        error('bad inputMode')
end

n=length(stats);


multiImage=0;
if ~isempty(images) && strcmp(class(images{1}),'cell')
    multiImage=1;
end

if multiImage
 imSize=[size(images{1}{1},1) size(images{1}{1},2)];
else
    if ~isempty(images)
        imSize=[size(images{1},1) size(images{1},2)];
    else
        imSize=[0 0];
    end
end

ht=yMax-yBotttom;
imWidthFrac=imWidth/(n+1);  % normalized to figure width
imHeightFrac=imWidthFrac*imSize(1)/imSize(2); % normalized to figure height
imHeight=imHeightFrac*ht; % normalized to figure height, units of y axis

textBelowBarTop=ht/20; %in yaxis pctCorrect units, how do I calculate this, given that figures rescale?


hold on

for i=1:n
    yLength=(yMax-yBotttom);
    imTop=yBotttom+yLength*1.00;
    %imTop=yBotttom+yLength*.95;
    imBottom=imTop-imHeight;
    
    if ~isempty(images)
        if multiImage
            for j=1:length(images{i})
                x=linspace(i-imWidth/2,i+imWidth/2,size(images{i}{j},2));
                y=linspace(imBottom,imTop,size(images{i}{j},1));
                image(x,y-((j-1)*imHeight*1.2),uint8(images{i}{j}));  %images in a column stack
            end
        else
            x=linspace(i-imWidth/2,i+imWidth/2,size(images{i},2));
            y=linspace(imBottom,imTop,size(images{i},1));
            image(x,y,uint8(images{i}));  %single image
        end
    end
end


%%
% b=bar(stats,'stacked');
% cb=get(b,'Children');
% set(cb,'CData',reshape(colors,1,size(colors,1),3))


% area show up in ppt better than colored bars
pad=0.1;
r=[-1 -1 1 1]; %rect
for i=1:n
    x=i+.5*(r)-pad*(r);
    y=[0 stats(i) stats(i) 0];
    a=area(x,y);
    set(a,'EdgeColor', 'none', 'FaceColor' ,colors(i,:));
end

if addText
    for i=1:n
        t=text(i,(stats(i)-textBelowBarTop),sprintf('%2.2g%%',stats(i)));
        set(t,'HorizontalAlignment','center')
    end
end


plot([1:n;1:n],[ci(:,1) ci(:,2)]','k')
axis([0 n+1 yBotttom yMax])
colormap(gray(255))

try
if ~isempty(groupingBar)
    for i=1:size(groupingBar,1)
        txtLabel=groupingBar{i,1};
        members=groupingBar{i,2};
        pip=+0.02*range(get(gca,'yLim'));  % define small unit step size
        if size(groupingBar,2)==2 || isempty(groupingBar{i,3})
            height=max(ci(:))+pip;
        else
            height=groupingBar{i,3};
        end
        plot(minmax(members),height([1 1]),'k');
        t2=text(mean(members),height+pip,txtLabel);
        set(t2,'HorizontalAlignment','center','VerticalAlignment','bottom')
    end
end
catch
    keyboard
end


