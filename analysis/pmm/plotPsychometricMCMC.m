function plotPsychometricMCMC(data)

if ~exist('marg', 'var')
    marg=[0.25 1]; % add on a health pad
end

if ~exist('colors', 'var')
    colors=[1 0 0; 0 1 1; 0 1 0; 0 0 0];
end

if ~exist('difficultyLabel', 'var')
    difficultyLabel='Contrast';
end

records=data.records;

%temp parameters for now
offsetSize=.01;

for i=fliplr(1:length(records))

switch records(i).type
    case 'rweibull'
        typestr='Reversed Weibull';
    case 'weibull'
        typestr='Weibull';
    case 'logistic'
        typestr='Logistic';
    otherwise
        error('unknown type')
end

title([data.source.name '-' typestr])

minX=min(data.difficulty);
maxX=max(data.difficulty);
rng=maxX-minX;
xRez=100;
minX=minX-marg(1)*rng;
maxX=maxX+marg(2)*rng;
xvals=linspace(max(0,minX),maxX,xRez);





[span mode]=calcPsy(xvals,records(i));


hold on;
plot([minX maxX],records(i).chance*ones(1,2),'k')

fadedColor=mean([colors(i,:); 1 1 1; 1 1 1; 1 1 1]);
plot(xvals,span,'Color',fadedColor) 

% span=span';
% [n bins]=hist(span,size(span,1));
% n=n/size(span,1);

%why?? mode or median
%         doMode=false;
%
%         if doMode
%             plot(xvals,span(:,mode),[ck '-'])  %span needs transpose
%             doOver(end).yvals1=span(:,mode);  %span needs transpose
%         else %median
%
%             %f3=figure
%
%             n=cumsum(n);
%             if doMed
%                 for k=1:size(n,2)
%                     %plot(n(:,k))
%                     %hold on
%                     doOver(end).yvals1(k)=bins(min(find(n(:,k)>=.5)));
%                 end
%             else
%                 doOver(end).yvals1=[];
%             end
%             %figure(f1)
%
%             %plot(xvals, ,[ck '-'])
%         end
end

for i=1:length(records)
    location=records(i).samples{2};
    sorted=sort(location);
    alpha=0.05;
    boundInds=round(length(sorted)*[alpha 1-alpha]);
    bounds=sorted(boundInds)
    medianInd=round(0.5*length(sorted));
    medianLocation=sorted(medianInd)
    edges=xvals;
    count=histc(location,edges);
    sum(count)
    b=bar(edges,count./length(location),'histc');
    barColor=repmat(reshape(colors(i,:),[1 1 3]),[length(edges) 1 1]);
    set(b,'CData',barColor)
    hold on
    ebHeight=.1+(.01*i);
    plot([bounds],[ebHeight ebHeight],'color',colors(i,:))
    plot([medianLocation],[ebHeight],'o','color',colors(i,:))

end

offsets=offsetSize*rng*([1:length(records)]-(length(records)+1)/2); % ceneterd offets
for i=1:length(records)
    [phat pci]=binofit(data.pctCorrect(:,i).*data.numAttempted(:,i),data.numAttempted(:,i));
    errorbar(data.difficulty+offsets(i),phat,phat-pci(:,1),pci(:,2)-phat,'.','color',colors(i,:))
end

xlabel(difficultyLabel)
ylabel('p(correct)')

a=[data.records.acceptRate];
msg=sprintf('acceptance: %2.2g %2.2g %2.2g %2.2g',a);
disp(msg)
text(1,.4,msg)

    %axis([0 2 0 .16])
%%
function [yvals mode]=calcPsy(xvals,rec)

params=[rec.samples{1} rec.samples{2} rec.samples{3}];
alpha=rec.alpha;
chance=rec.chance;
t=rec.type;

yvals=nan*zeros(length(xvals),size(params,1));

mode=getMode(params);

for i=1:size(params,1)
    location =params(i,2);
    width =params(i,3);
    lapse=params(i,1);

    switch t
        case 'gumbel'
            yvals(:,i)=(1-exp(-exp(     ((z(alpha)-z(1-alpha))/width) * (xvals-location)  +   z(.5)   )));
        case 'weibull'
            yvals(:,i)=1-exp(-exp(    (2*width*location/log(2)) * (log(xvals)-log(location))  +  (log(log(2)))    ));

        case 'rweibull'
            yvals(:,i)=exp(-exp( (-2*width*location/log(2)) * (log(xvals)-log(location)) + (log(log(2)))   ));
        case 'logistic'
            warning('no logisitic yet... write it now?')
            keyboard
            yvals=nan;
        otherwise
            error('unknown type')
    end

    yvals(:,i)=(1-lapse)*((1-chance)*yvals(:,i) + chance) + chance*lapse;

end
%%

function out=z(alpha)
out=log(-log(alpha));

function m=getMode(params)
[b i j]=unique(params,'rows');
[x y]=hist(j,1:max(j));
[s o]=sort(x,'descend');
m=find(all((params==repmat( b(o(1),:) ,size(params,1),1))'));
