%%%% doGratings

mnAmp=0; mnPhase=0;

for f = 1:length(use)
    [phAll{f} ampAll{f}] = analyzeGratingPatch(files(f).grating5sf4tf,'D:\grating5sf3tf_small_fast.mat',8:12,4:6);
    
    shiftPhase = shiftImageRotate(phAll{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
    shiftAmp = shiftImageRotate(ampAll{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
    mnPhase = mnPhase+shiftPhase;
    mnAmp = mnAmp+shiftAmp;
    
    figure
    subplot(2,2,1);
    im = mat2im(shiftPhase(:,:,3),jet,[1 5]);
    amp = shiftAmp(:,:,3); amp= amp/prctile(amp(:),90);
    amp(amp>1)=1;
    im = im.*(repmat(amp,[1 1 3]));
    imshow(im); title('sf')
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    
    subplot(2,2,2);
    im = mat2im(shiftPhase(:,:,4),jet,[1 3]);
    amp = shiftAmp(:,:,4); amp= amp/prctile(amp(:),90);
    amp(amp>1)=1;
    im = im.*(repmat(amp,[1 1 3]));
    imshow(im); title('tf')
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    
    subplot(2,2,3);
    im = mat2im(shiftPhase(:,:,5),jet,[3 7]);
    amp = shiftAmp(:,:,5); amp= amp/prctile(amp(:),90);
    amp(amp>1)=1;
    im = im.*(repmat(amp,[1 1 3]));
    imshow(im); title('speed')
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    
end
