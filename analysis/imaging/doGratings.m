%%%% doGratings
for rep=1:2
mnAmp{rep}=0; mnPhase{rep}=0; mnAmpWeight{rep}=0; mnData{rep}=0;
end

for f = 1:length(use)
    for rep = 2:2
        
        if rep ==1
            [phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch([pathname files(use(f)).grating5sf4tf],'C:\grating5sf3tf_small_fast.mat',10:13,6:8);
        else
            [phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch([pathname files(use(f)).grating3x5],'C:\grating3x5_2sf10min',10:13,6:8);
        end
        
        alldata{f} = imresize(alldata{f},4);
        shiftData = shiftImageRotate(alldata{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        shiftPhase = shiftImageRotate(phAll{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        shiftAmp = shiftImageRotate(ampAll{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        mnPhase{rep} = mnPhase{rep}+shiftPhase;
        mnAmp{rep} = mnAmp{rep}+shiftAmp;
        mnAmpWeight{rep} = mnAmpWeight{rep} + shiftAmp.*shiftPhase;
        
        mnData{rep} = mnData{rep}+shiftData;
        
        plotGratingResp(shiftPhase,shiftAmp,rep,xpts,ypts)
         plotGratingRespFit(shiftData,shiftData(:,:,5)+shiftData(:,:,6),rep,xpts,ypts)
         
         
        subplot(2,3,6)
        title([files(use(f)).subj ' ' files(use(f)).expt])
    end
end

for rep = 1:2
   % plotGratingResp(mnPhase{rep}/length(use),mnAmp{rep}/length(use),rep,xpts,ypts);
    plotGratingResp(mnAmpWeight{rep}./(mnAmp{rep}+0.0001),mnAmp{rep}/length(use),rep,xpts,ypts);
    
    %plotGratingRespFit(mnData{rep}/length(use),(mnData{rep}(:,:,5)+mnData{rep}(:,:,6))/length(use),rep,xpts,ypts)
    
end




