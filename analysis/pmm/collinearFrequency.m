function collinearFrequency(dataSource,doPlot)

if ~exist('dataSource','var')
    dataSource=1;
end

switch dataSource
    case 1
        %load it
        %load('C:\pmeier\mini projects\contrastData\100bsds5grid.mat')  % %first fast
        %load('C:\pmeier\mini projects\contrastData\200bsds100grid.mat')% %devolped it here
        load('C:\pmeier\mini projects\contrastData\200bsds100grid2.mat')% %more stringent independence
    case 2
        %make it
        cd('C:\pmeier\mini projects\pmmTools')
        initPmmTools()
        numImages=10;
        linearGridSamps=10;
        data=getSamples(numImages,linearGridSamps,'haar');
        path=fullfile('C:\pmeier\mini projects\contrastData\',sprintf('%dbsds%dhaar.mat',numImages,linearGridSamps))
        save(path,'data')
end


t=data.t(:)';
%c=sort([data.t(:)' data.f1(:)' data.f2(:)']);  %distribution of all contrasts
c=sort(t);  % all t contrasts sorted
lc2=sort(log(c.^2));
flankerThresh=sqrt(exp(lc2(round(length(c)*0.9)))); %for flanker strength, to condition stimuli
%flankerThresh=c(round(length(c)*0.95));  %simpler linear should be the same, but its not, warrants checking zero centeredness of filters
targetThresh=flankerThresh;  %for flanker strength, to detremin if it "is there"

rng=minmax(c)
e=max(abs(rng));
edges=linspace(-e/2,e/2,33);
logEdges=linspace(-2,floor(log(e^2)),33);
condNames={'col','par','pop_1','pop_2','raw'}%,'oneCol'};
strColors={'r','k','c','c','g'}%,'m'};
colors=[.8 0 0; .6 .6 .6; 0 .8 .8; 0 .8 .8; .2 .5 .2; .8 0 .8];
reorder=[1:5];
reorder=[1 3 4 2 5];

%CONTROLS THE CDF
conditionOn='singleDown'; %'singleUp','singleDown','double'  
[conds pdfs centers contrastPdfs logCenters positivePdfs posCenters]=doubleConditioned(data,flankerThresh,edges,logEdges,conditionOn);

%MAKING THESE INFLUENCES THE BAR PLOT
conditionOn='singleUp'; %'singleUp','singleDown','double'
[condsUp]=doubleConditioned(data,flankerThresh,edges,logEdges,conditionOn);
conditionOn='singleDown'; %'singleUp','singleDown','double'
[condsDown]=doubleConditioned(data,flankerThresh,edges,logEdges,conditionOn);

%% get the image

% this is one-time code not general nor stable to changes in this mfile
colUp=data.f1(:,:,1);
colDn=data.f2(:,:,1);
most=max(colUp(:).*colDn(:));
which=find(colUp(:).*colDn(:)==most);
[whichIm whichSamp]=find(colUp==colUp(which));

sourceFolder='C:\Documents and Settings\rlab\Desktop\BSDS300\images\train';
d=dir(sourceFolder);
x=imread(fullfile(sourceFolder,d(whichIm+2).name));
x=single(rgb2gray(x));



g=gridSampler(100,1,96);
[locX locY]=getLocations(g,size(x));  % the target location
targetX=locX(whichSamp)
targetY=locY(whichSamp);
upY=targetY-23; % up ois lower number in matrix
downY=targetY+23;
upX=targetX+6; % right is higher number in matrix
downX=targetX-6;


% draw an image of the best natural scene
figure(9)
sp=2;
h=2;w=2;
subplot(h,w,sp)
imagesc(x); axis equal;  colormap(gray)
radius=12;
rectangle('Position',[targetX-radius targetY-radius radius*[2 2]],'Curvature', [1 1],'edgeColor',[1 0 0])
rectangle('Position',[upX-radius upY-radius radius*[2 2]],'Curvature', [1 1],'edgeColor',[1 0 0])
rectangle('Position',[downX-radius downY-radius radius*[2 2]],'Curvature', [1 1],'edgeColor',[1 0 0])
set(gca,'xTick',[],'yTick',[])
axis([100 400 0 300]);  %zoom to square

%%
if 0
    sp=1;h=3;w=2;
    subplot(h,w,sp)
    hold off;
    %plot(edges,log(pdf{strcmp(names,'raw')}),'g'); hold on
    someConds={'raw','oneCol','col'}
    someConds={'raw','col','par'}
    %someConds=names
    for i=1:length(pdfs)
        condID=i%find(strcmp(names,someConds{i}));
        plot(centers,log(pdfs{condID}),'color',colors(condID,:));  %strColors{condID}
        hold on;
        
        %TRY FITTING THE DISTRIBUTION: but, its more kurtotic than exponential
        %[est] = MLE(conds{i}(conds{i}>0),'distribution','exp')
        %estDist=pdf('exp',abs(centers),est(1));
        %[est] = MLE(conds{i},'distribution','gev')
        %estDist=pdf('gev',abs(centers),est(1),est(2),est(3));
        
        %[est] = MLE(conds{i}(conds{i}>0),'distribution','gp')
        %estDist=pdf('gp',abs(centers),est(1),est(1));
        
        %[est] = MLE(conds{i}(conds{i}>0),'distribution','lognormal')
        %estDist=pdf('lognormal',abs(centers),est(1),est(1));
        
        %estDist=estDist/sum(estDist);  %normalize to whats here, not mathematical (just like empirical)
        %plot(centers,log(estDist),[strColors{condID} '--'])
    end
    xlabel(sprintf('%d target | both col > flankerThresh',length(conds{1}))); ylabel('log(p)');
    plot(flankerThresh([1 1]),ylim,'color',[.8 .8 .8])
    
    axis([xlim -10 0])
    plot([0 0],ylim,'color',[.2 .2 .2])
    % cdfs
    
    sp=sp+1;
    subplot(h,w,sp)
    hold off;
    %someConds=names
    %%
    for i=1:length(someConds)
        condID=i%find(strcmp(names,someConds{i}));
        plot(centers,cumsum(pdfs{condID}),'color',colors(condID,:));  %strColors{condID}
        hold on;
        
    end
    xlabel(sprintf('%d target | both col > flankerThresh',length(conds{1}))); ylabel('cdf');
    plot(flankerThresh([1 1]),[0 1],'color',[.8 .8 .8])
    plot([0 0],[0 1],'color',[.2 .2 .2])
    axis([xlim 0 1])
    % contrastCdfs
    
end
%% 
sp=1;
%%
subplot(h,w,sp)
hold off; someConds=condNames([2 3 4 1 5])
for i=1:length(someConds)
    condID=find(strcmp(condNames,someConds{i}));
    plot(logCenters,1-cumsum(contrastPdfs{condID}),strColors{condID})
    hold on;
    
end
%xlabel(sprintf('log(target contrast) | condition',length(conds{1}))); 
xlabel(sprintf('   log(target contrast)',length(conds{1}))); 
ylabel('1-cdf');
c_thr=log(flankerThresh.^2)-0.245; 
plot(c_thr([1 1]),[0 1],'color','k')
set(gca,'xTick',logCenters([1 end]),'xTickLabel',logCenters([1 end]))
set(gca,'xTick',[-1 4 9 14],'xTickLabel',{'-15','-10','-5','0'}) %[ -1 4 9 14]-14
set(gca,'xTick',[],'xTickLabel',[])
set(gca,'yTick',[0 .1 .5 1],'yTickLabel',[0 .1 .5 1])
text(10,.8,'C_{thr}')
xl=xlim;
plot([xl(1) c_thr],[.1 .1],'color',[.8 .8 .8])
axis([2 14 0 1])
axis([5 12 0 1])

length(conds{1})
length(conds{1})
%% positiveCdfs
if 0
    sp=sp+1;
    subplot(h,w,sp)
    hold off;
    someConds=names([1:5])
    for i=1:length(someConds)
        condID=find(strcmp(names,someConds{i}));
        plot(posCenters,1-cumsum(positivePdfs{condID}),strColors{condID})
        hold on;
        
    end
    xlabel(sprintf('%d target | both col > flankerThresh',length(conds{1}))); ylabel('1-cdf(positive Feature)');
    plot(flankerThresh([1 1]),[0 1],'color',[.8 .8 .8])
    %set(gca,'xTick',1:length(logCenters),'xTickLabel',1:length(logCenters))
    axis([xlim 0 1])
end
%% bar graph of conditional relation

someConds=condNames(reorder)
for i=1:length(someConds)
    numTested(i)=length(conds{i});
    numThere(i)=sum(log(conds{i}.^2)>log(targetThresh^2));
    
    if exist('condsDown','var')
        numTestedD(i)=length(condsDown{i});
        numThereD(i)=sum(log(condsDown{i}.^2)>log(targetThresh^2));
    end
    
    if exist('condsUp','var')
        numTestedU(i)=length(condsUp{i});
        numThereU(i)=sum(log(condsUp{i}.^2)>log(targetThresh^2));
    end
end




%% bar graph of errors (for main rat 138)

% GET STATS
switch 1
    case 1
        [stats CI names params]=getFlankerStats({'138'},'8flanks+&nfMix',{'pctCorrect'},'9.4range',[0 pmmEvent('endToggle')],[], 0);
    case 2
        [stats CI names params]=getFlankerStats({'228','227','230','233','234','139','138'},'8flanks+&nfMix',{'pctCorrect'},'9.4range',[0 pmmEvent('endToggle')],[], 0);
end

%determine conds
useConds={'colin','para','changeFlank','changeTarget','noFm'};  % display these conditions
usedConditionIDs=[];
for c=1:length(useConds)
    usedConditionIDs(c)=find(strcmp(useConds(c),names.conditions));
end

%% GET IMAGES
sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'};
or=[-1 1]*(pi/12);
sweptImageValues={or,or,or,1,[1 0]};
antiAliasing=false; useSymbolicFlanker=true;
[images]=getStimSweep(sweptImageParameters,sweptImageValues,[],[],'column',false,antiAliasing,useSymbolicFlanker);
barImageOrder=[1 5 2 6 9];;
for i=1:length(barImageOrder)
    barIms{i}=images(:,:,:,barImageOrder(i));
end

%%
sp=4;
subplot(h,w,sp)
%%
switch 1
    case 1 %single rat
        %subjID=strcmp('138',names.subjects);
        p=100*stats(1,usedConditionIDs(reorder),1);
        ci= 100*CI(1,usedConditionIDs(reorder),find(strcmp('pctCorrect',names.stats)),[1:2]);
        ci=reshape(ci(:),length(usedConditionIDs(reorder)),2);
    case 2 % all rats sem
        subjID=1:length(names.subjects)
        ps=100*stats(subjID,usedConditionIDs(reorder),1);
        %ci= mean(100*CI(subjID,usedConditionIDs,find(strcmp('pctCorrect',names.stats)),[1:2]),1);
        %ci=reshape(ci(:),length(usedConditionIDs),2);
        p=mean(ps);
        sem=std(ps)/sqrt(size(ps,1));
        ci=[p-sem; p+sem]';
end
imWidth=0.8; %normalized to barwidth
doBarPlotWithStims(100-p,100-ci,barIms(reorder),colors(reorder,:),[0 50],'stats&CI',false,[],0.8)
ylabel('p(error)'); xlabel('surround conditions')
set(gca,'xTick',[])
set(gcf,'Position',[10 50 900 900])
%set(gca,'xTick',[1:5],'xTickLabel',condNames)
set(gca,'xTick',[],'xTickLabel',[])
set(gca,'yTick',[0 20 40],'yTickLabel',[0 0.2 0.4])
set(gca,'xLim',[.25 5.5])
%%
sp=3;
subplot(h,w,sp)

if exist('condsUp','var')
    %do the average and add dots for up and down
    pp=(numThereU(reorder)+numThereD(reorder))./(numTestedU(reorder)+numTestedD(reorder));
    doBarPlotWithStims(100*pp,nan(size(reorder)),barIms(reorder),colors(reorder,:),[0 50],'stats&CI',false,[],0.8)
    plot(1:5,100*numThereU(reorder)./numTestedU(reorder),'k.')
    plot(1:5,100*numThereD(reorder)./numTestedD(reorder),'k.')
else
    %do both
    doBarPlotWithStims(numTested(reorder),numThere(reorder),barIms(reorder),colors(reorder,:),[0 50],'binodata',false,[],0.8)
end

ylabel('p(target | surround)');  xlabel('surround conditions')
%set(gca,'xTick',[1:5],'xTickLabel',condNames(reorder))
set(gca,'xTick',[],'xTickLabel',[])
set(gca,'yTick',[0 20 40],'yTickLabel',[0 0.2 0.4])
set(gca,'xLim',[.25 5.5])

settings.turnOffTics=true;
settings.textObjectFontSize=12;
settings.PaperPosition=[.5 .5 3.5 3.5];
settings.fontSize=10; %12 is 12 on a 3.5 inch wide column.  10 looks better
settings.MarkerSize=5;%8; 8 is good for dots, x is good for symbols
settings.textObjectFontSize=7;
%%
set(gcf,'Position',[0 40 600 640])
cleanUpFigure(gcf,settings)
subplot(2,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(2,2,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(2,2,3); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(2,2,4); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
subplot(2,2,2); 
set(gca, 'Position',[0.55 0.58 0.37 0.34]);  % b: tweak to make image a bit bigger
%set(gca, 'Position',[0.12 0.59 0.36 0.33]); % a: tweak to make image a bit bigger
%%
savePath='C:\Documents and Settings\rlab\Desktop\graphs';
figureType={'-dtiffn','png'};  renderer= {'-opengl'}; resolution=1200; % paper print quality
warning('should set paper size')
saveFigs(savePath,figureType,gcf,resolution,renderer);

% figure
%
% full=edges>0;
% ROI=edges<flankerThresh & full;
% n=length(conds{i});
% round(sum(pdf{i}(ROI))*n)
%
%
% figure; hold on
% plot(abs(colUp.*colDn),t.^2,'.r')
% plot(abs(parUp.*parDn),t.^2,'.c')

%%  colin density and
if 0
    edges=linspace(-8,15,20);
    binSize=(diff(minmax(edges))/length(edges));
    x=log([colUp' t'].^2);
    minmax(x')
    count2d=hist3(x,'Edges',{edges edges});
    conditional=count2d./repmat(sum(count2d),length(edges),1);
    hold off; imagesc(conditional); colormap(gray)
    set(gca,'yTick',[1 length(edges)],'yTickLabel',[edges(1) edges(end)])
    set(gca,'xTick',[1 length(edges)],'xTickLabel',[edges(1) edges(end)])
    set(gca,'YDir','normal')
    ylabel('log(tc^2) | fc1')
    hold on;
    for i=1:length(edges)-1
        condMed(i)=median(x(x(:,1)>edges(i) & x(:,1)<edges(i+1),2));
        rescaled(i)=(condMed(i)-min(edges))/binSize;
    end
    plot(1:length(edges)-1,rescaled,'.r')
    
    x=log([parUp' t'].^2);
    count2d=hist3(x,'Edges',{edges edges});
    conditional=count2d./repmat(sum(count2d),length(edges),1);
    for i=1:length(edges)-1
        condMed(i)=median(x(x(:,1)>edges(i) & x(:,1)<edges(i+1),2));
        rescaled(i)=(condMed(i)-min(edges))/binSize;
    end
    plot(1:length(edges)-1,rescaled,'.k')
end
%%


%%  colin product density and


% colUp=reshape(data.f1(:,:,1),1,[]);
% colDn=reshape(data.f2(:,:,1),1,[]);
% parUp=reshape(data.f1(:,:,2),1,[]);
% parDn=reshape(data.f2(:,:,2),1,[]);
% po1Up=reshape(data.f1(:,:,3),1,[]);
% po1Dn=reshape(data.f2(:,:,3),1,[]);
% po2Up=reshape(data.f1(:,:,4),1,[]);
% po2Dn=reshape(data.f2(:,:,4),1,[]);

if 0
    
    edges=linspace(-8,15,20);
    binSize=(diff(minmax(edges))/length(edges));
    x=log([abs(colUp.*colDn)' t.^2']);
    minmax(x')
    count2d=hist3(x,'Edges',{edges edges});
    conditional=count2d./repmat(sum(count2d),length(edges),1);
    hold off; imagesc(conditional); colormap(gray)
    set(gca,'yTick',[1 length(edges)],'yTickLabel',[edges(1) edges(end)])
    set(gca,'xTick',[1 length(edges)],'xTickLabel',[edges(1) edges(end)])
    set(gca,'YDir','normal')
    ylabel('log(tc^2) | fc1*fc2')
    hold on;
    for i=1:length(edges)-1
        condMed(i)=median(x(x(:,1)>edges(i) & x(:,1)<edges(i+1),2));
        rescaled(i)=(condMed(i)-min(edges))/binSize;
    end
    plot(1:length(edges)-1,rescaled,'.r')
    
    x=log([abs(parUp.*parDn)' t.^2']);
    count2d=hist3(x,'Edges',{edges edges});
    conditional=count2d./repmat(sum(count2d),length(edges),1);
    for i=1:length(edges)-1
        condMed(i)=median(x(x(:,1)>edges(i) & x(:,1)<edges(i+1),2));
        rescaled(i)=(condMed(i)-min(edges))/binSize;
    end
    plot(1:length(edges)-1,rescaled,'.k')
    cleanUpFigure
end


end


function data=getSamples(numImages,linearGridSamps,mode)


if ~exist('mode','var') || isempty(mode)
    mode='conv'
end

% policy:  1 sample per image
%%
%numImages=200;  % should get more ims...
%linearGridSamps=20;  % gets ^2 to find sampsPerIm
sourceFolder='C:\Documents and Settings\rlab\Desktop\BSDS300\images\train';
d=dir(sourceFolder);
d=d(3:end); %remove . and ..
%% get patch
s=ifFeatureGoRightWithTwoFlank('10');
%s=setStdGaussMask(s,1/16);  %like study
%s=setPixPerCycs(s,32);
s=setStdGaussMask(s,1/64); %scaled geometrically for smaller images
s=setPixPerCycs(s,8);
s=inflate(s);
x=getStimPatch(s,'right',true);
s=struct(s);
f=x(:,:,1,1);
size(f)
f=(double(f)-128)/255;
f=f/(sum(f(:)));
szHlf=size(f,1)/2;
[x y]=meshGrid(-szHlf:szHlf-1,-szHlf:szHlf-1);
enforceZero=(x.^2+y.^2)>18^2;  %everything outside this circle is strictly 0... some overlap may exist
enforceZero=(x.^2+y.^2)>12^2;  %everything outside this circle is strictly 0... no overlap may exists at all
f(enforceZero)=0;
%f=imresize(f,[65 nan]);
f=fliplr(f);
%f=rand(size(f)); confirm this is 0 cntered... it is
f(~enforceZero)=f(~enforceZero)-mean(f(~enforceZero));
imagesc(f); axis square; colormap gray
%%
conds={'col','par','pop1','pop2'};

numImages=min([numImages length(d)]);
fprintf('doing %d images',numImages)

patchSize=[70 70]; N=3;
mask=getMask(N,patchSize);  magicNumber=1.3; % for haar only
[contextPatches contextHaars]=getFourContextPatches(patchSize,N,magicNumber); %these patches are nt zero mean, nor are the Cn's below

for i=1:numImages;
    fprintf('.%d',i)
    x=imread(fullfile(sourceFolder,d(i).name));
    x=single(rgb2gray(x));
    if ~exist('locX','var')
        sz=size(x);
        
        linearOffsetSamps=1;
        gap=8*3; %3 lambda
        maxSafeFilterSize=size(f,2)+2*gap;
        g=gridSampler(linearGridSamps,linearOffsetSamps,maxSafeFilterSize);
        [locX locY]=getLocations(g,sz);  % the target location
        
        %flanker locations (only 1 azimuth)
        upY   = locY - round(gap*sin(s.goRightOrientations(2)));  %up is lower number in matrix
        downY = locY + round(gap*sin(s.goRightOrientations(2)));
        upX   = locX + round(gap*cos(s.goRightOrientations(2)));  %to the right is bigger number (up and right is consistent with the angle we use)
        downX = locX - round(gap*cos(s.goRightOrientations(2)));
        
        %flanker locations (1 azimuth)
        upY   = locY - round(gap*sin(s.goRightOrientations(2)));  %up is lower number in matrix
        downY = locY + round(gap*sin(s.goRightOrientations(2)));
        upX   = locX + round(gap*cos(s.goRightOrientations(2)));  %to the right is bigger number (up and right is consistent with the angle we use)
        downX = locX - round(gap*cos(s.goRightOrientations(2)));
        
        %flanker locations (other azimuth)
        upYaz2   = upY;  % y is the same
        downYaz2 = downY;
        upXaz2   = locX - round(gap*cos(s.goRightOrientations(2)));  %other az switches directions
        downXaz2 = locX + round(gap*cos(s.goRightOrientations(2)));
        
        sampsPerImage=length(locX);
        t=nan(numImages,sampsPerImage);
        f1=nan(numImages,sampsPerImage,4);
        f2=nan(numImages,sampsPerImage,4);
        
        %test=zeros(sz);
        %test(sub2ind(sz,locX,locY))=2;
        %imagesc(test)
    end
    
    switch mode
        case 'conv'
            %if j=1:length(conds)
            filtered=imfilter(x,f,'conv');
            t(i,:) =filtered(sub2ind(sz,locX,locY));
            f1(i,:,1)=filtered(sub2ind(sz,upX,upY)); % colin
            f2(i,:,1)=filtered(sub2ind(sz,downX,downY));
            f1(i,:,2)=filtered(sub2ind(sz,upXaz2,upYaz2)); % par
            f2(i,:,2)=filtered(sub2ind(sz,downXaz2,downYaz2));
            
            filtered=imfilter(x,fliplr(f),'conv');
            f1(i,:,3)=filtered(sub2ind(sz,upX,upY)); % pop1
            f2(i,:,3)=filtered(sub2ind(sz,downX,downY));
            f1(i,:,4)=filtered(sub2ind(sz,upXaz2,upYaz2)); % pop2
            f2(i,:,4)=filtered(sub2ind(sz,downXaz2,downYaz2));
            %end
        case 'haar'
            log=fspecial('log',10,1.5);
            filtered=imfilter(x,log,'conv');
            for j=1:linearGridSamps^2
                    patch=filtered(locY(j)+[-34:35],locX(j)+[-34:35]);
                    [Cn S]=getMaskedHaarCoef(patch,N,mask,magicNumber);
                    fHarr(i,j,1)=mean((Cn-contextHaars{1}).^2);
                    
                    if 1 %look at the metric
                        %                     figure; hold on;  plot(contextHaars{1},'r'); plot(Cn-contextHaars{1},'y'); plot(Cn,'b'); legend('flank','diff','natPatch')
                        %                     xlabel(sprintf('natPower %2.2f;   flankPower: %2.2f',mean(Cn.^2),mean(contextHaars{1}.^2)))
                    
                    xx=zscore(contextHaars{1});
                    yy=zscore(Cn);
                     figure; hold on;  plot(xx,'r'); plot(yy-xx,'y'); plot(yy,'b'); legend('flank','diff','natPatch')
                    xlabel(sprintf('natPower %2.2f;   flankPower: %2.2f',mean(Cn.^2),mean(contextHaars{1}.^2)))
                    pause
                    end
                    
                    %                     fHarr(i,j,2)=mean((Cn-contextHaars{2}).^2);
                    %                     fHarr(i,j,3)=mean((Cn-contextHaars{3}).^2);
                    %                     fHarr(i,j,4)=mean((Cn-contextHaars{4}).^2);
            end   
    end
    
end

data.t=t;
switch mode
    case 'conv'
        data.f1=f1;
        data.f2=f2;
    case 'haar'
        data.fHarr=fHarr;
end


end

function [conds pdfs centers logContrastPdfs logCenters positivePdfs posCenters]=doubleConditioned(data,flankerThresh,edges,logEdges,conditionOn);

t=data.t(:)';

if ~exist('flankerThresh','var')
    c=sort(t);  % all t contrasts sorted
    flankerThresh=c(round(length(c)*0.95));
end

if ~exist('edges','var')
    %c=sort([data.t(:)' data.f1(:)' data.f2(:)']);  %distribution of all contrasts
    c=sort(t);  % all t contrasts sorted
    rng=minmax(c);
    e=max(abs(rng));
    edges=linspace(-e/2,e/2,50);
end

if ~exist('logEdges','var')
    logEdges=(log(edges(edges>0).^2))
end

if ~exist('posEdges','var')
    posEdges=[0 edges(edges>0)];
end

for i=1:size(data.f1,3)
    switch conditionOn
        case 'double'
            conds{i}=t(data.f1(:,:,i)>flankerThresh & data.f2(:,:,i)>flankerThresh);
        case 'singleUp'
            conds{i}=t(data.f1(:,:,i)>flankerThresh);
        case 'singleDown'
            conds{i}=t(data.f2(:,:,i)>flankerThresh);
    end
end

i=i+1;
conds{i}=t;  % raw
i=i+1;
conds{i}=t(data.f1(:,:,1)>flankerThresh);  % single col
i=i+1;
conds{i}=t(data.f1(:,:,1)<flankerThresh & data.f2(:,:,1)<flankerThresh...
    & data.f1(:,:,2)<flankerThresh & data.f2(:,:,2)<flankerThresh...
    & data.f1(:,:,3)<flankerThresh & data.f2(:,:,3)<flankerThresh...
    & data.f1(:,:,4)<flankerThresh & data.f2(:,:,4)<flankerThresh);  % noF


for i=1:length(conds)
    %pdfs
    count=histc(conds{i},edges);
    pdfs{i}=count(1:end-1)/sum(count);  % remove last bin whic his only the ==end edge value
    
    %contrast
    count=histc(log(conds{i}.^2),logEdges);
    logContrastPdfs{i}=count(1:end-1)/sum(count);
    
    %positivePdfs
    count=histc(conds{i}(conds{i}>0),posEdges);
    positivePdfs{i}=count(1:end-1)/sum(count);
end



centers=edges(1:end-1)+(edges(2)-edges(1))/2;
logCenters=logEdges(1:end-1)+(logEdges(2)-logEdges(1))/2;  % this is in the middle which is not necc. true on a log scale
posCenters=posEdges(1:end-1)+(posEdges(2)-posEdges(1))/2;

% colUp=reshape(data.f1(:,:,1),1,[]);
% colDn=reshape(data.f2(:,:,1),1,[]);
% parUp=reshape(data.f1(:,:,2),1,[]);
% parDn=reshape(data.f2(:,:,2),1,[]);
% po1Up=reshape(data.f1(:,:,3),1,[]);
% po1Dn=reshape(data.f2(:,:,3),1,[]);
% po2Up=reshape(data.f1(:,:,4),1,[]);
% po2Dn=reshape(data.f2(:,:,4),1,[]);
end

function [ims Cns]=getFourContextPatches(imSz,N,magicNumber)

p=getDefaultParameters(ifFeatureGoRightWithTwoFlank);
p.mean = 0.5;
p.pixPerCycs =8;
p.stdGaussMask = 1/10; %scaled geometrically for smaller images
p.flankerOffset = 3; %scaled geometrically for smaller images
p.maxHeight=imSz(1);
p.maxWidth=imSz(2);
p.flankerContrast = 1; %scaled geometrically for smaller images
p.goRightContrast = 0; %scaled geometrically for smaller images
p.goLeftContrast = 0; %scaled geometrically for smaller images
p.phase=0;
p.flankerPosAngle=pi/12;

p.goRightOrientation=pi/12;
p.flankerOrientations=pi/12;
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
ims=double(sampleStimFrame(ts));

p.goRightOrientation=-pi/12; %para
p.flankerOrientations=-pi/12;
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
ims(:,:,2)=double(sampleStimFrame(ts));

p.goRightOrientation=pi/12;
p.flankerOrientations=-pi/12; % pop1
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
ims(:,:,3)=double(sampleStimFrame(ts));

p.goRightOrientation=-pi/12; %pop2
p.flankerOrientations=pi/12;
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
ims(:,:,4)=double(sampleStimFrame(ts));



for i=1:4
  [Cns{i} S]=getMaskedHaarCoef(ims(:,:,i),N,[],magicNumber)
end

end

function mask=getMask(N,imSz)

p=getDefaultParameters(ifFeatureGoRightWithTwoFlank);
p.mean = 0.5;
p.pixPerCycs =8;
p.stdGaussMask = 1/10; %scaled geometrically for smaller images
p.flankerOffset = 3; %scaled geometrically for smaller images
p.maxHeight=imSz(1);
p.maxWidth=imSz(2);
p.flankerContrast = 0; %scaled geometrically for smaller images
p.goRightContrast = 1; %scaled geometrically for smaller images
p.pixPerCycs =imSz(1);
p.phase=pi/2;
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
im=sampleStimFrame(ts);
%imagesc(double(im))
%%
[C,S] = WAVEDEC2(im,N,'haar');
mask=[];
ind=S(1,1)*S(1,2); % approximation offset
for n=N:-1:1
    for o=1:3 % 3 orients
        thisSz=S(N-n+2,:);
        thisLength=thisSz(1)*thisSz(2);
        maskCirc=(circle(thisSz(1)/2)==0);
        %C([find(maskCirc)+ind])=10;
        x=reshape(C([ind+1:ind+thisLength]),thisSz);
        mask=[mask; find(maskCirc | x~=0)+ind];  % a running total of masked locations
        
        
%         subplot(N,3,(n-1)*3+o);
%         imagesc(x); colormap(gray); axis square
%         set(gca,'xtick',[],'ytick',[])
%         xlabel(num2str(round([minmax(x(:)')]))) 
        
        ind=ind+thisLength;
    end
end
end

function [Cn S]=getMaskedHaarCoef(im,N,mask,magicNumber)

if ~exist('im','var') || isempty(im)
%% 2 flanks
p=getDefaultParameters(ifFeatureGoRightWithTwoFlank);
p.mean = 0.5;
p.pixPerCycs =8;
p.stdGaussMask = 1/10; %scaled geometrically for smaller images
p.flankerContrast = 1; %scaled geometrically for smaller images
p.goRightContrast = 1; %scaled geometrically for smaller images
p.flankerOffset = 3; %scaled geometrically for smaller images
p.maxWidth=70;
p.maxHeight=70;
[ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
im=sampleStimFrame(ts);
imagesc(double(im))
%% Blob at target

% p.flankerContrast = 0; %scaled geometrically for smaller images
% p.goRightContrast = 1; %scaled geometrically for smaller images
% p.pixPerCycs =80;
% p.phase=pi/2;
% [ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
% im=sampleStimFrame(ts);
% imagesc(double(im))


%%  TIGER
% im=imread('C:\Documents and Settings\rlab\Desktop\BSDS300\images\train\187039.jpg');
% im=single(rgb2gray(im));
% im=im(120:170,100:170);
% imagesc(im); colormap(gray); set(gca,'xtick',[],'ytick',[])
end

if ~exist('mask','var') || isempty(mask)
sz=size(im);
mask=getMask(N,sz)'
end


if ~exist('magicNumber','var') || isempty(magicNumber)
        magicNumber=1.3; % power law coef
end
%%

dwtmode('sp0');
[C,S] = WAVEDEC2(im,N,'haar');
%A = appcoef2(C,S,'haar',N);
a0 = waverec2(C,S,'haar');
t=wpdec2(im,2,'haar');
x=wpcoef(t,2);

ind=S(1,1)*S(1,2); % approximation offset
Cn=zeros(size(C));
viewableMask=ones(size(C));
viewableMask(mask)=0;
Cn(1:ind)=0; % wipe out the 
for n=N:-1:1
    for o=1:3 % 3 orients
        thisSz=S(N-n+2,:);
        thisLength=thisSz(1)*thisSz(2);

        x=reshape(C([ind+1:ind+thisLength]),thisSz);
        m=reshape(viewableMask([ind+1:ind+thisLength]),thisSz);
        
        Cn([ind+1:ind+thisLength])=C([ind+1:ind+thisLength])/n^magicNumber;
        x=x/n^(magicNumber);  % arbitrary scale constant!
        
        ind=ind+thisLength;
        subplot(N,3,(n-1)*3+o);
        imagesc(x); colormap(gray); axis square
        set(gca,'xtick',[],'ytick',[])
        xlabel(num2str(round([minmax(x(:)')]))) 
    end
end
%%
Cn(mask)=nan;
Cn=Cn(~isnan(Cn));
%%
% figure; hold on
% plot(C,'r')
% plot(Cn,'b')
% 
% %%
% find(Cn~=0)
% 
% %%
% p.maxWidth=140;
% p.maxHeight=140;
% p.pixPerCycs =16;
% [ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
% im=sampleStimFrame(ts);
% im=imresize(im,[70 70]);
% imagesc(double(im))
% %%
% p.maxWidth=140;
% p.maxHeight=140;
% p.pixPerCycs =16;
% [ts]=setFlankerStimRewardAndTrialManager(p, 'xxx');
% im=sampleStimFrame(ts);
% im=imresize(im,[70 70]);
% imagesc(double(im))

end