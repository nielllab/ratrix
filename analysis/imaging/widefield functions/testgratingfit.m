
f=1
rep=4;

  % [phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62g6lt_run2_4x3y_fstop5.6_exp50msmaps.mat','C:\grating4x3y5sf3tf_short.mat',12:15,8:10);
        %[phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62k2rt_run2_2x1ygrating_Fstop5.6_maps','C:\grating2x1y5sf3tf_short.mat',19:24,15:17);
        %[phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62k2rt_run2_2x1ygrating_Fstop5.6_maps.mat','C:\grating2x1y5sf3tf_short.mat',24:28,18:21);
       % [phAll{f} ampAll{f} alldata{f} fit{f}] = analyzeGratingPatch('g62b3rt_run2_fstop56_exp50ms_4x3_maps.mat','C:\grating4x3y5sf3tf_short011315.mat',13:16,8:9);
      %  [phAll{f} ampAll{f} alldata{f} fit{f}] = analyzeGratingPatch('g62j4rt_run4_fstop5.6_exp50ms_4x3_maps.mat','C:\grating4x3y5sf3tf_short011315.mat',13:16,8:9);
             sp = [];
             load('g62b1lt_run7_4x3ygrating_landscape_Fstop5.6_maps.mat',dfof_bg,sp);
             [phAll{f} ampAll{f} alldata{f} fit{f}] = analyzeGratingPatch(dfof_bg,sp,'C:\grating4x3y5sf3tf_short011315.mat',13:16,8:9);

        alldata{f} = imresize(alldata{f},4);
      %  shiftData = shiftImageRotate(alldata{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);

        
      shiftData = alldata{f}
      shiftData(isnan(shiftData))=0;
      xpts =1; ypts=1;
         plotGratingRespFit(shiftData,shiftData(:,:,5)+shiftData(:,:,6),rep,xpts,ypts)

         yfig = gcf;
         
         fitdata = fit{f};
         
         
         for i = 1:25
             figure(yfig);
             [y x] = ginput(1); y= round(y/4); x= round(x/4);
             amp = max(fitdata(x,y,5:7))*max(fitdata(x,y,8:13))*max(fitdata(x,y,14:16));
             figure
             subplot(2,3,1)
             imagesc(shiftData(:,:,5) + shiftData(:,:,6)); 
             hold on; plot(ypts,xpts,'w.','Markersize',2);
             plot(y*4,x*4,'o');
             subplot(2,3,2); 
             plot(squeeze(fit{f}(x,y,1:4))*amp); 
             hold on; plot([1 4],[0 0]); title('x'); xlim([1 4])
             subplot(2,3,3)
             plot(squeeze(fit{f}(x,y,5:7))/max(squeeze(fit{f}(x,y,5:7))));hold on; plot([1 3],[0 0]);  title('y');
             subplot(2,3,4);
              plot(squeeze(fit{f}(x,y,8:13))/max(squeeze(fit{f}(x,y,8:13)))); 
              hold on; plot([1 6],[0 0]); title('sf'); xlim([1 6])
              subplot(2,3,5);
              plot(squeeze(fit{f}(x,y,14:16))/max(squeeze(fit{f}(x,y,14:16)))); hold on; plot([1 3],[0 0]); title('tf');
         end
         
             