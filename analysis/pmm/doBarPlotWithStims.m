function doBarPlotWithStims(p1,p2,images,colors,yRange,inputMode,addText)
%by default, p1= numAttempts, p2=numCorrect b/c inputMode='binodata'
%can also set set inputMode to 'stats&CI'

if ~exist('colors') || isempty(colors)
    colors=ones(length(numAttempts),3)*0.8;
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
        
ht=yMax-yBotttom;
imHeight=ht/20; %in yaxis pctCorrect units, how do I calculate this, given that figures rescale?
textBelowBarTop=ht/25; %in yaxis pctCorrect units, how do I calculate this, given that figures rescale?



multiImage=0;
if ~isempty(images) && strcmp(class(images{1}),'cell') 
    multiImage=1;
end



n=length(stats);

hold on

for i=1:n
    yLength=(yMax-yBotttom);
    imTop=yBotttom+yLength*.95;
    imBottom=imTop-imHeight;

    if ~isempty(images)
        if multiImage
            for j=1:length(images{i})
                x=linspace(i-0.3,i+0.3,size(images{i}{j},2));
                y=linspace(imBottom,imTop,size(images{i}{j},1));
                image(x,y-((j-1)*imHeight*1.2),uint8(images{i}{j}));  %images in a column stack
            end
        else
            x=linspace(i-0.3,i+0.3,size(images{i},2));
            y=linspace(imBottom,imTop,size(images{i},1));
            image(x,y,uint8(images{i}));  %single image
        end
    end
end


%%
b=bar(stats,'stacked');
cb=get(b,'Children');
set(cb,'CData',reshape(colors,1,size(colors,1),3))


if addText
    for i=1:n
        t=text(i,(stats(i)-textBelowBarTop),sprintf('%2.2g%%',stats(i)));
        set(t,'HorizontalAlignment','center')
    end
end


%%
plot([1:n;1:n],[ci(:,1) ci(:,2)]','k')
axis([0 n+1 yBotttom yMax])
colormap(gray(255))

