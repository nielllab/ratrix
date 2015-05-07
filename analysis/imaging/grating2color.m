
clear all
close all


dt = 0.25;
framerate=1/dt;
twocolor = 1;
get2pSession;
 axonsAnalyze;

if ~blank
    gratingfname = 'C:\grating2p8orient2sf.mat';
else
    gratingfname = 'C:\grating2p8orient2sfBlank.mat';
end
load(gratingfname);


dfReshape = reshape(dfofInterp, size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3));
[osi osifit tuningtheta amp  tfpref pmin R resp tuning spont] = gratingAnalysis(gratingfname, startTime,dfReshape,dt,blank);

osi = reshape(osi,   size(dfofInterp,1), size(dfofInterp,2) );
R = reshape(R,size(dfofInterp,1), size(dfofInterp,2));
theta =reshape(tuningtheta,size(dfofInterp,1), size(dfofInterp,2));
tfpref = reshape(tfpref,size(dfofInterp,1), size(dfofInterp,2));
resp = reshape(resp,size(dfofInterp,1), size(dfofInterp,2),size(resp,2));

figure
imagesc(squeeze(mean(resp,3)),[-0.5 0.5]);

for doOrientationFig = 1:0
    figure
    im1=squeeze(max(max(orientation(:,:,[1 5],:),[],4),[],3));
    imagesc(im1,[0 0.75])
    colormap gray
    im1= im1/1;
    im1(im1<0)=0; im1(im1>1)=1;
    im1 = im1(25:end,1:end-25);
    figure
    imshow(im1)
    
    figure
    
    im2=squeeze(max(max(orientation(:,:,[3 7],:),[],4),[],3));
    imagesc(im2,[0 0.75])
    colormap gray
    im2= im2/1;
    im2(im2<0)=0; im2(im2>1)=1;
    im2 = im2(25:end,1:end-25);
    figure
    imshow(im2)
    
    
    im = zeros(size(im1,1),size(im1,2),3);
    im(:,:,1)=im1;
    im(:,:,2)=im2;
    im(:,:,3)=im2;
    
    figure
    imshow(im)
end

figure
imagesc(R,[0 2]);

theta(isnan(theta))=-0.1;
im = mat2im(theta,hsv,[-0.1 pi]);
figure
imshow(im)
osi_norm = 2*osi; osi_norm(isnan(osi_norm))=0; osi_norm(osi_norm>1)=1;
figure
imagesc(osi_norm); title('osinorm')
%osi_norm = osifit;

R_norm=R/2; R_norm(R_norm>1)=1; R_norm(R_norm<0)=0;
figure
imagesc(R_norm); title('Rnorm')
white =ones(size(im(:,:,1)));

for c = 1:3
    im(:,:,c) = (white.*(1-osi_norm) + im(:,:,c).*osi_norm).*R_norm;
end
figure
imshow(imresize(im,4));
title('orientation preference')

j= jet;
j = j(end/2:end,:);
tf_im = mat2im(tfpref,jet,[-1 1]);
for c =1:3
    tf_im(:,:,c) = tf_im(:,:,c).*R_norm;
end
figure
imshow(imresize(tf_im,4));
title('tf preference')


ptsfname = uigetfile('*.mat','pts file');
if ptsfname==0
    [pts dF neuropil] = get2pPts(dfofInterp);
else
    load(ptsfname);
end

col = 'rgbcmykr'
figure
hold on
inds = [1 3 4 5 6 7 8 9]
for i = 1:length(inds)
    plot(dF(inds(i),:)/10 + i,col(i));
end

dFClean = dF-0.8*repmat(neuropil,size(dF,1),1);

[osi osifit tuningtheta amp  tfpref pmin R, resp tuning spont allresp]= gratingAnalysis(gratingfname, startTime,dFClean,dt,blank);

figure
tuning = mean(allresp,4);
for i = 1:100;
    subplot(10,10,i)
    plot(squeeze(tuning(i,:,:)))
    ylim([-0.5 1])
    axis off
    
end

sfclean = tfpref;
sfclean(sfclean<-1)=-1; sfclean(sfclean>1)=1;
use = amp>0.1 & pmin<0.05;
figure
hist(sfclean(use))

figure
plot(sfclean(use),osi(use),'o')


close all
clear correct
clear correctOrient
for fitsf=1:2
    nreps=8;
    data =[];
    for ori = 1:4
        data = [data ; squeeze(allresp(:,2*ori-1,fitsf,:))'];
        %  orientation((ori-1)*nreps + (1:nreps))=mod((ori-1),4)+1;
        
        orientation((ori-1)*nreps + (1:nreps))=2*ori-1;
    end
    
    % figure
    % imagesc(data)
    % figure
    % plot(orientation)
    for sz =1:5
        sampSize = 4^(sz-1);
        if sampSize>size(data,2)
            sampSize = size(data,2)-1
        end
        sampSize
        tic
        counts = zeros(8,1); testcount = zeros(size(data,1),1); trialcorrect=testcount;
        confusion=zeros(8,8);
        for szIter = 1:40
            useSamps = randsample(size(data,2),sampSize);
            useData = data(:,useSamps);
            
            nfold=10;
            c = cvpartition(size(data,1),'k',nfold);
            
            for iter = 1:nfold
                
                sv = fitctree(useData(c.training(iter),:),orientation(c.training(iter)));
                %sv = fitensemble(useData(c.training(iter),:),orientation(c.training(iter)),'Subspace',64,'discriminant');
                label = predict(sv,useData(c.test(iter),:));
                shouldlabel=orientation(c.test(iter));
                tr=find(c.test(iter));
                for l = 1:length(label);
                    counts(shouldlabel(l))=counts(shouldlabel(l))+1;
                    confusion(shouldlabel(l),label(l))= confusion(shouldlabel(l),label(l))+1;
                    testcount(tr(l))=testcount(tr(l))+1;
                    if label(l)==shouldlabel(l)
                        trialcorrect(tr(l))=trialcorrect(tr(l))+1;
                    end
                end
                
                correct(sz,szIter,fitsf,iter) = sum(label' == orientation(c.test(iter)))/length(label);
                correctOrient(sz,szIter,fitsf,iter) = sum(mod(label',4) == mod(orientation(c.test(iter)),4))/length(label);
            end
            
        end
        toc
        figure
        repcounts = repmat(counts',8,1);
        imagesc(confusion./repcounts,[0 1]);
        figure
        plot(trialcorrect./testcount)
        ylim([0 1])
    end
    
end

avgCorrect = squeeze(mean(mean(correct,4),2))
avgCorrectOrient = squeeze(mean(mean(correctOrient,4),2))

stdCorrect = squeeze(std(mean(correct,4),[],2))
stdCorrectOrient = squeeze(std(mean(correctOrient,4),[],2))
figure
errorbar([1 2 3 4 4.5],avgCorrect(:,1),stdCorrect(:,1)/sqrt(size(correct,2)))
hold on
errorbar([1 2 3 4 4.5],avgCorrect(:,2),stdCorrect(:,2)/sqrt(size(correct,2)),'g')
ylim([0 1])

figure
errorbar([1 2 3 4 4.5],avgCorrectOrient(:,1),stdCorrectOrient(:,1)/sqrt(size(correct,2)))
hold on
errorbar([1 2 3 4 4.5],avgCorrectOrient(:,2),stdCorrectOrient(:,2)/sqrt(size(correct,2)),'g')
ylim([0 1])


figure

hold on
errorbar([1 2 3 4 4.5],avgCorrectOrient(:,1),stdCorrectOrient(:,1)/sqrt(size(correct,2)),'g')
errorbar([1 2 3 4 4.5],avgCorrect(:,1),stdCorrect(:,1)/sqrt(size(correct,2)))
ylim([0 1])
legend('orient','direction')



c = 'rgbcmk'
figure
hold on
trange = 50:1250
for i = 1:size(dF,1);
    i
    plot((1:length(trange))*dt/60,(dF(i,trange)-neuropil(trange)) + i,c(mod(i,6)+1));
end
ylim([0 size(dF,1)+2]); xlim([0 length(trange)*dt/60]);
xlabel('mins')

save(sessionName,'osi','osifit','tuningtheta','amp','pmin','R','tfpref','dfofInterp','blank','startTime','cycLength','-v7.3');


