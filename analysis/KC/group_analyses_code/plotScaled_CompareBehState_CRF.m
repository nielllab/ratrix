function plotScaled_CompareBehState_CRF(loBehState_allSessAllPtsAllDurs_CRF,hiBehState_allSessAllPtsAllDurs_CRF,durat,yMax,yMin,yLimit,x_axis,xMax,xMin,xLimit,stateLegend,uniqueContrasts,reigons,nGroup)

figure
%clear titleText
%titleText = 'CRF: locomotion';
%suptitle(sprintf('%s \n',titleText))

%titleText = 'CRF: '; % making char variables for sprintf/title later
%subjName = groupSubjName{1}; % will be same name if w/in mouse analysis...
%date = groupDate{1};
%suptitle(sprintf('%s',titleText,subjName)); % date, 

global run_or_pup
if run_or_pup == 'run'
    global lighter_blue
    loStateLineColor = lighter_blue;
    global orange
    hiStateLineColor = orange;
end 

global run_or_pup
if run_or_pup == 'pup'
    global light_red
    loStateLineColor = light_red;
    global pea_green
    hiStateLineColor = pea_green;
end 

for d = durat
    
    global visArea
    for i = 1:4
        
        subplot(2,2,i) 
        
        % take mean across sessions, for ith point, lo beh state
        loBehState_meanDthCRFacrossSess = mean(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);
        % Here's how to get STD of this: 
        % std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))',1)
        
        % max of dth ith CRF
        clear maxOfCRF
        maxOfCRF = max(loBehState_meanDthCRFacrossSess);
        
        % scale the CRF to it's max
        scaled_loBehState_meanDthCRFacrossSess = loBehState_meanDthCRFacrossSess/maxOfCRF;
        
        % get stdev across sessions
        %loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(loBehState_allSessAllPtsAllDurs_CRF,4));
        % stderr across mice
        global numMice
        loBehState_stdErrOverSess = std(squeeze(scaled_loBehState_meanDthCRFacrossSess(d,:,i,:))')/sqrt(numMice); 
        %loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))'); 
        
        %plot(x_axis,scaled_loBehState_meanDthCRFacrossSess,'color',loStateLineColor,'lineWidth',2,'MarkerSize',3) 
        errorbar(x_axis,scaled_loBehState_meanDthCRFacrossSess,loBehState_stdErrOverSess,'color',loStateLineColor,'lineWidth',2,'MarkerSize',3) 
        
%         if nGroup == 1
%             
%             plot(x_axis,loBehState_meanDthCRFacrossSess,'-b','lineWidth',1,'MarkerSize',3) 
%         
%         else 
%             
%             % plot for lo beh state
%             errorbar(x_axis,loBehState_meanDthCRFacrossSess,loBehState_stdErrOverSess,'-b','lineWidth',1,'MarkerSize',3) 
%         
%         end 
        
        hold on 
        
        % take mean across sessions, for ith point, hi beh state
        hiBehState_meanDthCRFacrossSess = mean(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);

        % max of dth ith CRF
        clear maxOfCRF
        maxOfCRF = max(hiBehState_meanDthCRFacrossSess);
        
        % scale the CRF to it's max
        scaled_hiBehState_meanDthCRFacrossSess = hiBehState_meanDthCRFacrossSess/maxOfCRF;
        
%        % get stderr across sessions
%        %hiBehState_stdErrOverSess = std(squeeze(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(hiBehState_allSessAllPtsAllDurs_CRF,4)); 
%        % stderr across mice
         global numMice
         hiBehState_stdErrOverSess = std(squeeze(scaled_hiBehState_meanDthCRFacrossSess(d,:,i,:))')/sqrt(numMice); 
          
        %plot(x_axis,scaled_hiBehState_meanDthCRFacrossSess,'color',hiStateLineColor,'LineWidth',2,'MarkerSize',3) 
        errorbar(x_axis,scaled_hiBehState_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'color',hiStateLineColor,'lineWidth',2,'MarkerSize',3) 
        %plot(x_axis,scaled_loBehState_meanDthCRFacrossSess,'color',hiStateLineColor,'lineWidth',2,'MarkerSize',3)   
        
%           if nGroup == 1
%             
%             plot(x_axis,hiBehState_meanDthCRFacrossSess,'-r','lineWidth',1,'MarkerSize',3) 
%             
%         
%         else 
%             
%             % plot for hi beh state
%             errorbar(x_axis,hiBehState_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'-r','lineWidth',1,'MarkerSize',3) 
%             
%         
%         end
        
        title(reigons{i})
    
        ylim(yLimit) 
        xlim(xLimit)
    
        ylabel('dF/F')
        xlabel('contrast (%)')
    
        clear xt
        xt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
        set(gca,'xtick',1:7); 
        set(gca,'xticklabel',xt);
        
%         yt = [-0.01 0 0.02 0.04 0.06 0.08 0.1];
%         set(gca,'YTick',yt)
        
        %legend(stateLegend,'Location','northwest')

    end 

end

