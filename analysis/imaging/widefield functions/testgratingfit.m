
f=1
rep=4;

  % [phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62g6lt_run2_4x3y_fstop5.6_exp50msmaps.mat','C:\grating4x3y5sf3tf_short.mat',12:15,8:10);
        %[phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62k2rt_run2_2x1ygrating_Fstop5.6_maps','C:\grating2x1y5sf3tf_short.mat',19:24,15:17);
        %[phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62k2rt_run2_2x1ygrating_Fstop5.6_maps.mat','C:\grating2x1y5sf3tf_short.mat',24:28,18:21);
        [phAll{f} ampAll{f} alldata{f}] = analyzeGratingPatch('g62k2rt_run3_4x3ygrating_Fstop5.6_maps.mat','C:\grating4x3y5sf3tf_short.mat',18:21,13:16);

        
        alldata{f} = imresize(alldata{f},4);
      %  shiftData = shiftImageRotate(alldata{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);

        
      shiftData = alldata{f}
      shiftData(isnan(shiftData))=0;
      xpts =1; ypts=1;
         plotGratingRespFit(shiftData,shiftData(:,:,5)+shiftData(:,:,6),rep,xpts,ypts)
