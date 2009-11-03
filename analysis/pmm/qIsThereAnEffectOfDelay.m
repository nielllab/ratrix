%compare blocked vs. paper rats



%subjects={'228','227','230','233','234','138','139'}; %in paper
%subjects={'228','227','230','233','234','138','139'}; %have blocked data post paper
%subjects={'227', '229', '230', '237', '232', '233'}; %many flank types, 5 contrasts
%subjects={'138','139', '228','277'}; %many flanks, one contrast  -- can these be directly compared to interleaved trials?


         %%
         d=getSmalls('231');
         close all
         %%
         tContrast=0.75; %[0.25 0.5 0.75 1];
         fContrast=0.5; % this is fixed in the data

               
         d16=removeSomeSmalls(d,d.step~=16);
         d16=removeSomeSmalls(d16,~getGoods(d16,'withoutAfterError'));
         d16=addPhantomTargetContrast(d16);
         d16=removeSomeSmalls(d16,~(d16.phantomTargetContrastCombined==tContrast & d16.flankerContrast==fContrast));
         
         d17=removeSomeSmalls(d,d.step~=17);
         d17=removeSomeSmalls(d17,~getGoods(d17,'withoutAfterError'));
         figure; 
         subplot(2,1,1); doPlotPercentCorrect(d17,[],50); 
         subplot(2,1,2); doPlot('plotBias',d17);
        figure
         d17=addPhantomTargetContrast(d17);
         d17.phantomTargetContrastCombined
         d17=removeSomeSmalls(d17,~(d17.phantomTargetContrastCombined==tContrast & d17.flankerContrast==fContrast));
         
         [p16 ci16]=binofit(sum(d16.correct),length(d16.correct)); % unused... just raw
         [p17 ci17]=binofit(sum(d17.correct),length(d17.correct)); % unused... just raw

         correct=[   sum(d16.correct)    sum(d17.correct)];
         attempt=[length(d16.correct) length(d17.correct)]
         doBarPlotWithStims(attempt,correct,[],[1 0 0; 0 1 1]);%,yRange,inputMode,addText, groupingBar,imWidth)
         legend({'jointSweep-matchedContrasts','after delay'});
         %cleanUpFigure
         
         %%
         %close all
         figure; subplot(1,2,1)
         filter{1}.type='flankerContrast';
         filter{1}.contrast=0.5;
         filter{2}.type='16';
         dateRange=[pmmEvent('231&234-jointSweep') now]
         [stats CI names params]= getFlankerStats({'231'},'allPhantomTargetContrastsCombined',[],filter,dateRange);
         doHitFAScatter(stats,CI,names,params);
         
         subplot(1,2,2)
         filter{2}.type='17';
         numDaysAfterStart=0;
         dateRange=[pmmEvent('231-test200msecDelay')+numDaysAfterStart now];
         [stats CI names params]= getFlankerStats({'231'},'allPhantomTargetContrastsCombined',[],filter,dateRange);
         doHitFAScatter(stats,CI,names,params);
         
         