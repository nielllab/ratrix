

orient=pi/12;
d=getSmalls('231');
d=removeSomeSmalls(d,d.step~=9 | d.flankerContrast~=0.4);
[conditionInds names haveData colors]=getFlankerConditionInds(d,getGoods(d),'16flanks');
for i=1:size(conditionInds,1)
    numAttempts(i)=sum(conditionInds(i,:));
    numCorrect(i)=sum(d.correct(conditionInds(i,:)))
end

sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % last variable entry must be targetContrast
sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1],[0.4]};
[images]=getStimSweep(r,d,sweptParameters,sweptValues);
figure; doBarPlotWithStims(numAttempts,numCorrect,images,colors,[20 100])

%%
%find from name or color
combinedAttempts=[]; combinedCorrects=[]; combinedImages=[]; combinedColors=[];
[combinedColors junk which]=unique(colors,'rows');
which
%set the indices from the colors!
combinedColors=combinedColors([3 4 2 1],:)
noTargets=find(which==3);
colin=find(which==4); % 4 is red is colin
popout=find(which==2);
para=find(which==1);
inds={noTargets,colin,popout,para};
for i=1:length(inds)
combinedAttempts(i)=sum(numAttempts(inds{i}));
combinedCorrects(i)=sum(numCorrect(inds{i}));
combinedImages{i}={images{inds{i}}};
end
figure; doBarPlotWithStims(combinedAttempts,combinedCorrects,combinedImages,combinedColors,[50 100])
title(sprintf('%s- per effect type - Hit Rate Only',char(d.info.subject)))
%% pctCorrect pairs

combinedAttempts=[]; combinedCorrects=[]; combinedImages=[]; combinedColors=[];
n=size(conditionInds,1);
combinedColors=colors(((n/2)+1):n,:)
for i=1:n/2
    combinedAttempts(i)=sum(numAttempts(i) + numAttempts(i+n/2));
    combinedCorrects(i)=sum(numCorrect(i) + numCorrect(i+n/2));
    combinedImages{i}={images{i},images{i+n/2}};
end
figure; doBarPlotWithStims(combinedAttempts,combinedCorrects,combinedImages,combinedColors,[0 100])
title(sprintf('%s- matched flanker pairs',char(d.info.subject)))


%% 

combinedAttempts=[]; combinedCorrects=[]; combinedImages=[]; combinedColors=[]; 
[combinedColors junk which]=
unique(colors,'rows');
which(1:n/2)=which(n/2+1:n);  %pair up noTargets with targets
combinedColors=combinedColors([4,2,1],:) % reorder to inds request

%set the indices from the colors!
colin=find(which==4); % 4 is red is colin
popout=find(which==2);
para=find(which==1);
inds={colin,popout,para};
for i=1:length(inds)
combinedAttempts(i)=sum(numAttempts(inds{i}));
combinedCorrects(i)=sum(numCorrect(inds{i}));
combinedImages{i}={images{inds{i}}};
end
figure; doBarPlotWithStims(combinedAttempts,combinedCorrects,combinedImages,combinedColors,[50 100])
title(sprintf('%s- per effect type - matchedflanker pairs',char(d.info.subject)))

