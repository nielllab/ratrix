function exploreDPrime()

close all

numBins=101; %101
numTrials=2*(numBins-1); %200

%assume equal number of signal present / no signal
fractionSigs=0.5;
numSigs=round(fractionSigs*numTrials) %100
numNoSigs=round((1-fractionSigs)*numTrials) %100

%thus 101 bins will be like 100 trials for the target present

%these values are not rates, but number of trials
[FA misses]=meshgrid(0:numSigs, 0:numNoSigs);
CR=numNoSigs-FA;
hits=numSigs-misses;

dpr = sqrt(2) * (erfinv((hits - misses)/numSigs) + erfinv((CR - FA)/numNoSigs)); %what I use (from code)
percentYes = (hits+FA)/numTrials; %(probability of saying yes)
percentCorrect = (hits+CR)/numTrials;

H=(hits)./numSigs %hit rate
F=(FA)./numNoSigs %false alarm rate



B=((H-H.^2)-(F-F.^2))./...  %grier's 1971 B" 
    (H -H.^2 +F -F.^2);

A=(((H-F)+(H-F).^2)./... %grier's 1971 A' 
   (4*H.*(1-F)))+0.5 




C=(erfinv(H)+erfinv(F))/2
C2=C-flipLR(flipUD(C))
C3=erfinv(H)-erfinv(1-F)

sagiDpr=(erfinv(H)-erfinv(F)) %2007
sagiC=(erfinv(H)+erfinv(F))/2




%choose which one for the second plot
figure(2); doPlots(A,B); title('A and B')
figure(3); doPlots(C,C2); title('C and C*')
figure(3); doPlots(sagiDpr,sagiC); title('sagiDpr and sagiC')
figure(4); doPlots(percentCorrect,percentYes); title('percentCorrect and percentYes')


figure
a=subplot(231); imagesc(doRemove(percentCorrect));  title('%correct'); cleanAxis(a)
xlabel('%fA'); ylabel('%hit');
a=subplot(232); imagesc(doRemove(dpr,-4));  title('d'''); cleanAxis(a)
a=subplot(233); imagesc(doRemove(A,1/8));  title('A'''); cleanAxis(a)

a=subplot(234); imagesc(doRemove(percentYes));  title('%yes'); cleanAxis(a)
a=subplot(235); imagesc(doRemove(C2,-1.5));  title('c*'); cleanAxis(a)
a=subplot(236); imagesc(doRemove(-B,-1));  title('B"'); cleanAxis(a)
cleanUpFigure(gcf);

%set the lower right to be its own color, even do dpr is symetric
dpr(hits<FA)=-1;
percentYes(hits<FA)=-1;

A(hits<FA)=0;
B(hits<FA)=0;

figure(1)
a=subplot(2, 2, 1); 
imagesc(dpr)
axis square; cleanAxis(a)
ylabel('hit rate');
xlabel('false alarm rate');


a=subplot(2, 2, 2); 
[cs,h] = contour(flipud(dpr)); clabel(cs,h,[1:3])
axis square; cleanAxis(a)
ylabel('hit rate');
xlabel('false alarm rate');

a=subplot(2, 2, 3); 
imagesc(percentYes)
axis square; cleanAxis(a)
ylabel('hit rate');
xlabel('false alarm rate');

a=subplot(2, 2, 4); 
[cs,h] = contour(flipud(percentYes), (0:0.1:1)); clabel(cs,h,[0.4, 0.5, 0.6])
axis square; cleanAxis(a)
ylabel('hit rate');
xlabel('false alarm rate');

cleanUpFigure(gcf);

function doPlots(sensitivity, bias)

sensitivity=doRemove(sensitivity)
bias=doRemove(bias)

a=subplot(2, 2, 1); 
imagesc(sensitivity)
axis square; cleanAxis(a)

a=subplot(2, 2, 2); 
[cs,h] = contour(flipud(sensitivity)); clabel(cs,h)
axis square; cleanAxis(a)

a=subplot(2, 2, 3); 
imagesc(bias)
axis square; cleanAxis(a)

a=subplot(2, 2, 4); 
[cs,h] = contour(flipud(bias)); clabel(cs,h)
axis square; cleanAxis(a)

cleanUpFigure(gcf);

function cleanAxis(a)

get(a);
set(a, 'XTickLabel', []);
set(a, 'YTickLabel', []);


function x=doRemove(x,val)
if ~exist('val','var'); val=0; end

remove=fliplr(tril(x)~=0)
x(remove)=val;
