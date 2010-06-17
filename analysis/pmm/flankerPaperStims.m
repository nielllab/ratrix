%close all
clear all

resolutionScale=8;
sx=384*resolutionScale;
sy=512*resolutionScale;
[param]=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection','2_4','Oct.09,2007')
param.maxWidth    =sx;
param.maxHeight   =sy;
param.pixPerCycs  =16*resolutionScale;
param.flankerContrast  =0.4;
param.flankerOffset=3;
param.stdGaussMask=1/16;
param.mean= 0.5;
param.phase= 0;
[step]=setFlankerStimRewardAndTrialManager(param, 'test')
sm=getStimManager(step);

desiredX=250*resolutionScale;
desiredY=400*resolutionScale;
padX=(sx-desiredX)/2; padY=(sy-desiredY)/2;
borderWidth=5*resolutionScale;

or=pi/12;
torients=[-or or];
forients=[-or or];
tcontrasts=[0.8 0];
fpas=[-or or];
sizes=[2 2 2 2];
images=zeros(desiredY,desiredX,3,16,'uint8');%length(torients),length(forients),length(tcontrasts),length(fpas));
colors=[.9 0 0;  0 .8 .8 ; 0 .8 .8 ; .2 .2 .2];
order=[1:8 fliplr(9:12) fliplr(13:16)];
for i=1:length(torients)
    forceStimDetails.targetOrientation=torients(i);
    for j=1:length(forients)
        forceStimDetails.flankerOrientation=forients(j);
        for k=1:length(tcontrasts)
            forceStimDetails.targetContrast=tcontrasts(k);
            for l=1:length(fpas)
                forceStimDetails.flankerPosAngle=fpas(l);

                %border color
                colorInd=2;
                if torients(i)==forients(j)
                    if torients(i)==fpas(l)
                        colorInd=1;% colin
                    else
                        colorInd=4;% para
                    end
                end

                [im0 details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
                %grab the thing in the center
                im1=uint8(255*repmat(reshape(colors(colorInd,:),[1 1 3]),[desiredY desiredX 1]));
                center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
                im1(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;

                %[i j k l]=ind2sub(sizes,ind);
                ind=sub2ind(sizes,i, j, k, l)
                ind=order(ind);
                images(:,:,:,ind)=uint8(im1);
                %                 imtool(im1)
                %                 pause
            end
        end
    end
end

% figure
% montage(images,'DisplayRange',[0 255],'Size',[2 8]); % or [2 2] if
% title('sample stimuli')

%
noFlanks=zeros(desiredY,desiredX,3,2,'uint8');%length(torients),length(forients),length(tcontrasts),length(fpas));
forceStimDetails.flankerContrast=0;
nfColor=[.2 .5 .2];

%blank

forceStimDetails.targetContrast=tcontrasts(2);
forceStimDetails.targetOrientation=torients(1);
[im0 details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
%grab the thing in the center
im1=uint8(255*repmat(reshape([nfColor],[1 1 3]),[desiredY desiredX 1]));
center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
im1(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;
blank=uint8(im1);


forceStimDetails.targetContrast=tcontrasts(1);

for i=1:length(torients)
                forceStimDetails.targetOrientation=torients(3-i);
                [im0 details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
                %grab the thing in the center
                im1=uint8(255*repmat(reshape([nfColor],[1 1 3]),[desiredY desiredX 1]));
                center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
                im1(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;
                noFlanks(:,:,:,i)=uint8(im1);
end
   


%%             
if 0 % optional stim figures
    close all
    figure%(14)
    settings.fontSize=12;
    
        subplot(2,2,1); image(blank);
        xlabel('target absent, F^-'); set(gca,'xtick',[],'ytick',[])
        settings.alphaLabel='a'; cleanUpFigure(gca,settings)
        
        subplot(2,2,2); image(noFlanks(:,:,:,[1]));
                xlabel('target present, F^-'); set(gca,'xtick',[],'ytick',[])
                settings.alphaLabel='b'; cleanUpFigure(gca,settings)
                
        subplot(2,2,3); image(images(:,:,:,[13]));
                        xlabel('target absent, F^+'); set(gca,'xtick',[],'ytick',[])
                        settings.alphaLabel='c'; cleanUpFigure(gca,settings)
                        
        subplot(2,2,4); image(images(:,:,:,[ 9]));
                                xlabel('target present, F^+'); set(gca,'xtick',[],'ytick',[])
                                settings.alphaLabel='d'; cleanUpFigure(gca,settings)
                                
end
%%
if 1 % optional stim figures
    close all
    figure(13)
    settings.fontSize=12;
    
    %temp1=[blank 255*ones(size(blank,1),size(blank,2)/4,3) noFlanks(:,:,:,[1])];
    subplot(1,2,1); montage(temp1,'DisplayRange',[0 255],'Size',[1 1]);
    xlabel('detection without flankers (F^-)'); set(gca,'xtick',[],'ytick',[])
    settings.alphaLabel='a'; cleanUpFigure(gca,settings)
    text(1000,2900,'target absent','HorizontalAlignment','center')
    text(3500,2900,'target present','HorizontalAlignment','center')
    text(2270,2000,'vs.','HorizontalAlignment','center')

    %temp2=[images(:,:,:,13) 255*ones(size(blank,1),size(blank,2)/4,3) images(:,:,:,9)];
    subplot(1,2,2); montage(temp2,'DisplayRange',[0 255],'Size',[1 1]);
    xlabel('detection with flankers (F^+)'); set(gca,'xtick',[],'ytick',[])
    settings.alphaLabel='b'; cleanUpFigure(gca,settings)
    text(1000,2900,'target absent','HorizontalAlignment','center')
    text(3500,2900,'target present','HorizontalAlignment','center')
    text(2270,2000,'vs.','HorizontalAlignment','center')
    
    set(gcf,'PaperSize',[3.5 3.5])
    savePath='C:\Documents and Settings\rlab\Desktop\graphs';
    figureType={'-dtiffn','png'};  renderer= {'-opengl'}; resolution=1000; % paper print quality
    %clearvars -except temp1 temp2
    saveFigs(savePath,figureType,gcf,resolution,renderer);
end

     
%%
if 1 % optional stim figures
    close all
    clearvars -except images noFlanks blank
    figure(14)
    settings.fontSize=12;
    settings.LineWidth=1;
    temp=images(:,:,:,[11]);
    subplot(1,2,1); montage(temp,'DisplayRange',[0 255],'Size',[1 1]); hold on
    set(gca,'xtick',[],'ytick',[])
    settings.alphaLabel='a'; cleanUpFigure(gca,settings)
    

    x=[590 700];   y=1600-(x-1000)/tan(pi/12); plot(x,y,'k')
    x=[1300 1410]; y=1600-(x-1000)/tan(pi/12); plot(x,y,'k')
    x=[630]; y=1600-(x-1000)/tan(pi/12); plot(x([1 1]),y+[0 -265],'k')
    x2=[680]; y2=1600-(x2-1000)/tan(pi/12); plot([x2 x],[y2 y-200],'k')
    
    text(1200,2700,'\theta_F','HorizontalAlignment','center')
    text(1400,1900,'\theta_T','HorizontalAlignment','center')
    text(1600,1100,'\theta_F','HorizontalAlignment','center')
    text(500,2900,'\omega','HorizontalAlignment','center')
    set(gca,'Position', [0.2500    0.1100    0.17    0.8150])
    
    theseIms=images(:,:,:,[ 9 11 2 4 1 3 10 12 ]);
    subplot(1,2,2); montage(theseIms,'DisplayRange',[0 255],'Size',[ 2 4]);
    xlabel('detection with flankers (F^+)'); set(gca,'xtick',[],'ytick',[])
    settings.alphaLabel='b'; cleanUpFigure(gca,settings)
    xlabel('col        pop_1       pop_2       par')
     settings.alphaLabel
     cleanUpFigure(gcf,settings)
     set(gcf,'PaperSize',[3.5 3.5])
     
    savePath='C:\Documents and Settings\rlab\Desktop\graphs';
    figureType={'-dtiffn','png'};  renderer= {'-opengl'}; resolution=1000; % paper print quality
    saveFigs(savePath,figureType,gcf,resolution,renderer);
end
%%
clearvars -except images noFlanks blank
figure(12)
subplot(1,2,1)
m1=montage(images(:,:,:,[ 13 9]),'DisplayRange',[0 255],'Size',[1 2]);
%title('colinear example')
%xlabel('left = no                 right = yes')
xlabel('target absent         target present')
%%

subplot(1,2,2)
theseIms=images(:,:,:,[ 9 11 2 4 16 1 3 10 12 16]);
theseIms(:,:,:,[5 10])=noFlanks;
%clearvars -except theseIms
%montage(images(:,:,:,[1 3 2 4 9 11 10 12 ]),'DisplayRange',[0 255],'Size',[2 4]);
%
m2=montage(theseIms,'DisplayRange',[0 255],'Size',[2 5]);
%title('stimulus grouping')

%
set(gca,'xTick',diff(get(gca,'Xlim'))*[1:4]/5)
set(gca,'xTickLabel',diff(get(gca,'Xlim'))*[1:4]/5)
xlabel('col        pop_1       pop_2       par         F-')
%set(gca,'xTickLabel',{'col','po1','po2','par'})

subplot(1,2,1)
settings.alphaLabel='a'
settings.fontSize=12;
cleanUpFigure(gca,settings)
	%get(gca,'Position')
set(gca ,'Position',[0.08 0.11 0.32013 0.815])
   get(m2)
   %set(m1,'XData',[1 900])


subplot(1,2,2)
settings.alphaLabel='b'
cleanUpFigure(gca,settings)
get(gca,'Position')
 set(gca ,'Position',[0.52    0.1100    0.4    0.8150])

%%
 clear all
savePath='C:\Documents and Settings\rlab\Desktop\graphs';
figureType={'-dtiffn','png'};  renderer= {'-opengl'}; resolution=1000; % paper print quality
saveFigs(savePath,figureType,gcf,resolution,renderer);