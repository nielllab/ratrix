%%%
clear all
close all

dt = 0.25;
framerate=1/dt;
twocolor = input('# of channels : ');
twocolor= (twocolor==2)
blank =1;
get2pSession_sbx;

cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
imshow(img)
colormap(hsv); colorbar
phaseImg = img;

if twocolor
    clear img
    img(:,:,1) = redframe/prctile(redframe(:),95);
    img(:,:,2) = amp;
    img(:,:,3)=amp;
    figure
    imshow(img)
end
title('visual resp (cyan) vs tdtomato')

if ~blank
    gratingfname = 'C:\grating2p8orient2sf.mat';
else
    gratingfname = 'C:\grating2p8orient2sfBlank.mat';
end
load(gratingfname);


clear cycAvg
for i = 1:cycLength
    cycAvg(:,:,i) = squeeze(mean(dfofInterp(:,:,i:cycLength:end),3));
end


dfReshape = reshape(dfofInterp, size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3));
[osi osifit tuningtheta amp  tfpref pmin R resp tuning spont] = gratingAnalysis(gratingfname, 1,dfReshape,dt,blank);

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


selectPts = input('select points for further analysis? 0/1 ')
if selectPts==1
    
    useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
    if useOld ==1
        [pts dF ptsfname icacorr cellImg usePts] = align2pPts(dfofInterp,greenframe);
    elseif useOld==2
        [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
        
    else
        ptsfname = uigetfile('*.mat','pts file');
        load(ptsfname);
    end

%     col = 'rgbcmykr'
%     figure
%     hold on
%     inds = 1:65
%     colordef black
%     set(gcf,'Color',[0 0 0])
%     
%     for i = length(inds):-1:1
%         
%         h=bar(dF(inds(i),1:1000)/4 + i,1);
%         set(h,'EdgeColor',[0 0 0]);
%         plot(dF(inds(i),1:1000)/4 + i,'w');
%     end
%     axis off
%     xlim([1 1000])
%     set(gca,'Position',[0.2 0.2 0.6 0.65])
%     colordef white
%     
    dFClean = dF-0.6*repmat(neuropil,size(dF,1),1);
 %  dFClean = dF;
    nonzeropts = find(mean(dF,2)~=0)

    
    
    [osi osifit tuningtheta amp  tfpref pmin R, resp tuning spont allresp]= gratingAnalysis(gratingfname, startTime,dFClean,dt,blank);

       figure
       hist(osi)
       xlabel('osi')
    
   use = find(pmin<0.05 & R>0.1);
resp = length(use)/length(pmin);
sprintf('%d out of %d responsive = %f',length(use),length(pmin),resp)
       
       save(ptsfname,'pmin','osi','amp','R','tuning','tuningtheta','allresp','tfpref','-append');

    
         
    figure
   c = corrcoef(dF(nonzeropts,:)');
   imagesc(c,[-1 1])
   title('corr coef')
   
   figure
   hist(c(:),-0.95:0.1:0.95)
   xlabel('correlation coeff')

    
    figure
    %tuning = mean(allresp,4);
    for i = 1:min(length(nonzeropts),100);
        subplot(10,10,i)
        plot(squeeze(tuning(nonzeropts(i),:,:)))
        ylim([-0.5 1])
        axis off      
    end
    
       
       
       
       clear cycAvg
       for i = 1:cycLength;
           cycAvg(:,i) = mean(dF(:,i:cycLength:end),2);
       end
       for i = 1:size(cycAvg,1)
           cycAvg(i,:) = cycAvg(i,:)-min(cycAvg(i,:));
       end
       figure
       plot((1:cycLength)*dt,cycAvg')
       
       
       use = find(mean(dF,2)~=0);
       notuse = find(mean(dF,2)==0);
       
       figure
       hold on
       for i = 1:length(use);
           plot(pts(use(i),2),pts(use(i),1),'o','Color',cmapVar(R(use(i)),-1,1))
       end
       plot(pts(notuse,2),pts(notuse,1),'*')
       axis ij; axis square; axis([0 256 0 256])
       
            figure
       hold on
       for i = 1:length(pts);
           if ~isnan(osi(i))
               plot(pts(i,2),pts(i,1),'o','Color',cmapVar(osi(i),0,0.35))
           end
       end
       plot(pts(notuse,2),pts(notuse,1),'k.')
       axis ij; axis square; axis([0 256 0 256])
       
       
         figure
       hold on
       for i = 1:length(pts);
         if ~isnan(tuningtheta(i)) & osi(i)>0.15
             plot(pts(i,2),pts(i,1),'o','Color',cmapVar(tuningtheta(i),0,pi,hsv))
         end
         if osi(i)<0.15
             plot(pts(i,2),pts(i,1),'ko')
         end
         
       end
            plot(pts(notuse,2),pts(notuse,1),'k.')
       axis ij; axis square; axis([0 256 0 256])
       colormap hsv; colorbar;set(gca,'clim',[0 180])
       
       figure
       draw2pSegs(usePts,tuningtheta,hsv,256,find(~isnan(tuningtheta)&osi>0.25),[0 pi])
    
       figure
       draw2pSegs(usePts,mean(resp,2),jet,256,nonzeropts,[-1 1])
       

        figure
       draw2pSegs(usePts,osi,jet,256, find(~isnan(tuningtheta)&osi>0.25),[0 0.35])
end
    %
    % close all
    % clear correct
    % clear correctOrient
    % for fitsf=1:2
    %     nreps=8;
    %     data =[];
    %     for ori = 1:4
    %         data = [data ; squeeze(allresp(:,2*ori-1,fitsf,:))'];
    %               %  orientation((ori-1)*nreps + (1:nreps))=mod((ori-1),4)+1;
    %
    %         orientation((ori-1)*nreps + (1:nreps))=2*ori-1;
    %     end
    %
    %     % figure
    %     % imagesc(data)
    %     % figure
    %     % plot(orientation)
    %     for sz =1:5
    %         sampSize = 4^(sz-1);
    %         if sampSize>size(data,2)
    %             sampSize = size(data,2)-1
    %         end
    %         sampSize
    %        tic
    %        counts = zeros(8,1); testcount = zeros(size(data,1),1); trialcorrect=testcount;
    %        confusion=zeros(8,8);
    %        for szIter = 1:40
    %             useSamps = randsample(size(data,2),sampSize);
    %             useData = data(:,useSamps);
    %
    %             nfold=10;
    %             c = cvpartition(size(data,1),'k',nfold);
    %
    %             for iter = 1:nfold
    %
    %                 sv = fitctree(useData(c.training(iter),:),orientation(c.training(iter)));
    %                 %sv = fitensemble(useData(c.training(iter),:),orientation(c.training(iter)),'Subspace',64,'discriminant');
    %                 label = predict(sv,useData(c.test(iter),:));
    %                 shouldlabel=orientation(c.test(iter));
    %                 tr=find(c.test(iter));
    %                 for l = 1:length(label);
    %                    counts(shouldlabel(l))=counts(shouldlabel(l))+1;
    %                    confusion(shouldlabel(l),label(l))= confusion(shouldlabel(l),label(l))+1;
    %                   testcount(tr(l))=testcount(tr(l))+1;
    %                    if label(l)==shouldlabel(l)
    %                        trialcorrect(tr(l))=trialcorrect(tr(l))+1;
    %                    end
    %                 end
    %
    %                 correct(sz,szIter,fitsf,iter) = sum(label' == orientation(c.test(iter)))/length(label);
    %                 correctOrient(sz,szIter,fitsf,iter) = sum(mod(label',4) == mod(orientation(c.test(iter)),4))/length(label);
    %             end
    %
    %        end
    %         toc
    %            figure
    % repcounts = repmat(counts',8,1);
    % imagesc(confusion./repcounts,[0 1]);
    % figure
    % plot(trialcorrect./testcount)
    % ylim([0 1])
    %     end
    %
    % end
    %
    % avgCorrect = squeeze(mean(mean(correct,4),2))
    % avgCorrectOrient = squeeze(mean(mean(correctOrient,4),2))
    %
    % stdCorrect = squeeze(std(mean(correct,4),[],2))
    % stdCorrectOrient = squeeze(std(mean(correctOrient,4),[],2))
    % figure
    % errorbar([1 2 3 4 4.5],avgCorrect(:,1),stdCorrect(:,1)/sqrt(size(correct,2)))
    % hold on
    % errorbar([1 2 3 4 4.5],avgCorrect(:,2),stdCorrect(:,2)/sqrt(size(correct,2)),'g')
    % ylim([0 1])
    %
    % figure
    % errorbar([1 2 3 4 4.5],avgCorrectOrient(:,1),stdCorrectOrient(:,1)/sqrt(size(correct,2)))
    % hold on
    % errorbar([1 2 3 4 4.5],avgCorrectOrient(:,2),stdCorrectOrient(:,2)/sqrt(size(correct,2)),'g')
    % ylim([0 1])
    %
    %
    % figure
    %
    % hold on
    % errorbar([1 2 3 4 4.5],avgCorrectOrient(:,1),stdCorrectOrient(:,1)/sqrt(size(correct,2)),'g')
    % errorbar([1 2 3 4 4.5],avgCorrect(:,1),stdCorrect(:,1)/sqrt(size(correct,2)))
    % ylim([0 1])
    % legend('orient','direction')
    %
    %
    %
    % c = 'rgbcmk'
    % figure
    % hold on
    % trange = 50:1250
    % for i = 1:size(dF,1);
    %     i
    %     plot((1:length(trange))*dt/60,(dF(i,trange)-neuropil(trange)) + i,c(mod(i,6)+1));
    % end
    % ylim([0 size(dF,1)+2]); xlim([0 length(trange)*dt/60]);
    % xlabel('mins')
    
 
    
