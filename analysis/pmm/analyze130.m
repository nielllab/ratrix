function analyze130

   d=getSmalls('130',[],1);
     d=removeSomeSmalls(d,~getGoods(d))
     noiseSteps=unique(d.step(d.xPosNoise>0));
     d=removeSomeSmalls(d,~noiseSteps)
     width=3*std(d.xPosNoise)
     edges=linespace(-width,width,20);
     attempts=histc(d.xPosNoise,edges);
     corrects=histc(d.xPosNoise(d.correct),edges);
     rightwards=histc(d.xPosNoise(d.response==3),edges);
     [p ci]=binofit(corrects,attempts);
     figure; title('influence of target position in discrimination')
     subplot(2,1,1); errorbar(p,p-ci(1),ci(2)-p); xlabel('position'); ylabel('% correct')
     [p ci]=binofit(rightwards,attempts);
     subplot(2,1,2); errorbar(p,p-ci(1),ci(2)-p); xlabel('position'); ylabel('% rightward')
