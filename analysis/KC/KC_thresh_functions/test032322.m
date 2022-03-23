std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(loBehState_allSessAllPtsAllDurs_CRF,4)); 

stateLegend = {'stat','run'}

yMax = 0.1;
yMin = -0.01;
yLimit = [yMin yMax];
x_axis = [1:length(uniqueContrasts)];
xMax = max(x_axis);
xMin = min(x_axis);
xLimit = [xMin xMax];

title(reigons{i})

plot(x_axis,mnCRF_acrossSess_AllDurAllPts_loBehState(i,:),'b')

errorbar(x_axis,hiBehState_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'-r','lineWidth',1,'MarkerSize',3) 

% for crf figs

ylim(yLimit) 
xlim(xLimit)

ylabel('df/f')
xlabel('contrast (%)')

clear xt
xt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
set(gca,'xtick',1:7); 
set(gca,'xticklabel',xt);

yt = [-0.01 0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1];
set(gca,'YTick',yt)

legend(stateLegend)

