function plotCompareBehState_CRF(loBehState_allSessAllPtsAllDurs_CRF,hiBehState_allSessAllPtsAllDurs_CRF,durat,yMax,yMin,yLimit,x_axis,xMax,xMin,xLimit,stateLegend,uniqueContrasts,reigons)

figure
%clear titleText
%titleText = 'CRF: locomotion';
%suptitle(sprintf('%s \n',titleText))

%titleText = 'CRF: '; % making char variables for sprintf/title later
%subjName = groupSubjName{1}; % will be same name if w/in mouse analysis...
%date = groupDate{1};
%suptitle(sprintf('%s',titleText,subjName)); % date, 

for d = durat
    
    for i = 1:size(loBehState_allSessAllPtsAllDurs_CRF,3)
        
        subplot(2,3,i) 
        
        % take mean across sessions, for ith point, lo beh state
        loBehState_meanDthCRFacrossSess = mean(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);
        % get stdev across sessions
        loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(loBehState_allSessAllPtsAllDurs_CRF,4)); 
        
        % plot for lo beh state
        errorbar(x_axis,loBehState_meanDthCRFacrossSess,loBehState_stdErrOverSess,'-b','lineWidth',1,'MarkerSize',3) 
        
        hold on 
        
        % take mean across sessions, for ith point, hi beh state
        hiBehState_meanDthCRFacrossSess = mean(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);
        % get stdev across sessions
        hiBehState_stdErrOverSess = std(squeeze(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(hiBehState_allSessAllPtsAllDurs_CRF,4)); 
        
        % plot for hi beh state
        errorbar(x_axis,hiBehState_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'-r','lineWidth',1,'MarkerSize',3) 
        
        title(reigons{i})
    
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

    end 
    
end

end

