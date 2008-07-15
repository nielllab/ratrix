function [FARate, hitRate]= temporalROC(d, conditionInds, smoothingWidth)

totalTrials = length(d.date);
segments=[smoothingWidth:smoothingWidth:(floor(totalTrials/smoothingWidth))*smoothingWidth];
numColors=min([size(segments,2) 100]);
blockEnds=[segments totalTrials];

[dpr dprStats]=dprimePerConditonPerDay(blockEnds,conditionInds,getGoods(d), d);
haveData=find(sum((dpr==-99)')==0);
temp=cell2mat(dprStats(haveData,:));
hits=reshape([temp.hits], size(temp,1),size(temp,2));
CR=reshape([temp.correctRejects], size(temp,1),size(temp,2));
misses=reshape([temp.misses], size(temp,1),size(temp,2));
FA=reshape([temp.falseAlarms], size(temp,1),size(temp,2));
hitRate=[hits./(hits+misses)];
FARate=[FA./(FA+CR)];

%haveData=find(sum(conditionInds')>0);
haveData=find(sum((dpr==-99)')==0);
haveData=haveData(haveData<=5)

temp=cell2mat(dprStats(haveData,:));
hits=reshape([temp.hits], size(temp,1),size(temp,2));
CR=reshape([temp.correctRejects], size(temp,1),size(temp,2));
misses=reshape([temp.misses], size(temp,1),size(temp,2));
FA=reshape([temp.falseAlarms], size(temp,1),size(temp,2));

hitRate=[hits./(hits+misses)];
FARate=[FA./(FA+CR)];


% figure(handles(11)); subplot(subplotParams.y, subplotParams.x, subplotParams.index)
% for i=1:size(startColor,1)
%     colorplot(FARate(i,:),hitRate(i,:), numColors,startColor(i,:),endColor(i,:));
% end
% 
% title(sprintf ('ROC Curve %s ', subject));
% plot([0 1], [0 1],'k')
% ylabel('Hit Rate'); xlabel('False Alarm Rate');
% axis([0 1 0 1])
