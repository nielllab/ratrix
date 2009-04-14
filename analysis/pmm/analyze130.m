%function analyze130

full=getSmalls('130',[],1);
%%
d=removeSomeSmalls(full,~getGoods(full));
d=removeSomeSmalls(full,d.date<now-60);
noiseSteps=unique(d.step(d.xPosNoisePix>0));
d=removeSomeSmalls(d,ismember(d.step,setdiff(1:max(d.step),noiseSteps)));
width=round((3*std(d.xPosNoisePix))/10)*10;
edges=linspace(-width,width,19);

attempts=histc(d.xPosNoisePix,edges);
corrects=histc(d.xPosNoisePix(d.correct==1),edges);
rightwards=histc(d.xPosNoisePix(d.response==3),edges);

sigs=histc(d.xPosNoisePix(d.targetOrientation>0),edges);
noSigs=histc(d.xPosNoisePix(d.targetOrientation<0),edges);
hit=histc(d.xPosNoisePix(d.correct==1 & d.targetOrientation>0),edges);
miss=histc(d.xPosNoisePix(d.correct==0 &d.targetOrientation>0),edges);
CR=histc(d.xPosNoisePix(d.correct==1 & d.targetOrientation<0),edges);
FA=histc(d.xPosNoisePix(d.correct==0 & d.targetOrientation<0),edges);

h=hit./sigs;
f=FA./noSigs;
zHit = norminv(h) ;
zFA  = norminv(f) ;
dpr = zHit - zFA;
cr = (zHit + zFA) ./ (-2);

ed=[1 length(edges)]
yval=[ed(1) round(mean(ed)) ed(2)];
ylab=[-3 0 3];



figure; title('influence of target position in discrimination')
[p ci]=binofit(corrects,attempts);
subplot(2,2,1); errorbar(1:length(edges),p,p-ci(:,1)',ci(:,2)'-p); xlabel('position (std)'); ylabel('% correct'); set(gca,'xLim',ed,'xTickLabel',ylab,'xTick',yval)
[p ci]=binofit(rightwards,attempts);
subplot(2,2,2); errorbar(1:length(edges),p,p-ci(:,1)',ci(:,2)'-p); xlabel('position (std)'); ylabel('% rightward'); set(gca,'xLim',ed,'xTickLabel',ylab,'xTick',yval)
subplot(2,2,3); plot(1:length(edges),dpr); xlabel('position (std)'); ylabel('dpr'); set(gca,'xLim',ed,'xTickLabel',ylab,'xTick',yval)
subplot(2,2,4); plot(1:length(edges),cr); xlabel('position (std)'); ylabel('cr'); set(gca,'xLim',ed,'xTickLabel',ylab,'xTick',yval)


