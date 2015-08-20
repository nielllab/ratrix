function plotGratingResp(phase, amp, fit,rep, xpts, ypts,label)
    figure
    set(gcf,'Name',label);
        subplot(2,3,1);
        if rep ==1 | rep==2 
            range=[1 3];
        elseif rep==4
            range = [1 4]
        else
            range = [1 3];
        end
      
        imAmp = amp; imAmp=imAmp/(prctile(imAmp(:),95));
        imAmp(imAmp>1)=1;imAmp = imAmp.^1;
        
        im = mat2im(phase(:,:,1),jet,range);

        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('x')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        
        
        if rep ==2 | rep ==1
            range = [1 2];
        else range = [1 3];
        end
        subplot(2,3,2);
        im = mat2im(phase(:,:,2),jet,range);
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('y')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
        
        if rep ==1
            range=[1 2];
        elseif rep==2
            range = [2 4];
        elseif rep==3 | rep==4
            range = [2 4];
        end
        subplot(2,3,4);
        im = mat2im(phase(:,:,3),jet,range);
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('sf')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
        
        if rep==2
            range = [1.75 3.25];
        else
            range = [1.25 2.75];
        end
        subplot(2,3,5);
        im = mat2im(phase(:,:,4),jet,range);
        im = im.*(repmat(imAmp,[1 1 3]));
        imshow(im); title('tf')
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
        

        
        subplot(2,3,3)
        imagesc(amp,[-0.005 0.04]); colormap jet ; 
        title('amp'); axis off; axis equal
           hold on; plot(ypts,xpts,'w.','Markersize',2)
           set(gca,'LooseInset',get(gca,'TightInset'))
           
                   
       subplot(2,3,6);
        showGradient(phase(:,:,1:2),imAmp,xpts,ypts);
        set(gca,'LooseInset',get(gca,'TightInset'))
 
        
%         subplot(2,2,2)
%     im = mat2im(round(phase(:,:,1))+4*round(phase(:,:,2)-1),jet,[1 12]);
%         im = im.*(repmat(imAmp,[1 1 3]));
%         imshow(im); title('pos')
%         hold on; plot(ypts,xpts,'w.','Markersize',2)
        
%  subplot(2,2,3)
%        
%  normalize = max(fit(:,:,8:13),[],3);
%  normalize(normalize<=0)=0.01;
%  zerosf = fit(:,:,8); zerosf(zerosf<0)=0;
%  
%     im = mat2im(zerosf./normalize,jet,[0.5 1.5]);
%         im = im.*(repmat(imAmp,[1 1 3]));
%         imshow(im); title('pos')
%         hold on; plot(ypts,xpts,'w.','Markersize',2)
%         
        
%         figure
%              im = mat2im(phase(:,:,2),jet,[1 3]);
%         im = im.*(repmat(imAmp,[1 1 3]));
%         imshow(im); title('y')
%         hold on; plot(ypts,xpts,'w.','Markersize',2)
%         

  
%         subplot(2,3,5);
%         im = mat2im(phase(:,:,5),jet,[1 10]);
%         imAmp = amp; imAmp= imAmp/prctile(imAmp(:),95);
%         imAmp(imAmp>1)=1;
%         im = im.*(repmat(imAmp,[1 1 3]));
%         imshow(im); title('speed')
%         hold on; plot(ypts,xpts,'w.','Markersize',2)