function plotAllStates_CRF(allSessAllPtsAllDurs_AllStates_CRF,durat,yMax,yMin,yLimit,x_axis,xMax,xMin,xLimit,uniqueContrasts,uniqueDurations,durs4Legend,reigons,nGroup)

figure
%clear titleText
%titleText = 'CRF: locomotion';
%suptitle(sprintf('%s \n',titleText))

%titleText = 'CRF: '; % making char variables for sprintf/title later
%subjName = groupSubjName{1}; % will be same name if w/in mouse analysis...
%date = groupDate{1};
%suptitle(sprintf('%s',titleText,subjName)); % date, 

C = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
    
for d = durat
    
    for i = 1:size(allSessAllPtsAllDurs_AllStates_CRF,3)
        
        subplot(2,2,i) 
        
        % take mean across sessions, for ith point, lo beh state
        allState_meanDthCRFacrossSess = mean(allSessAllPtsAllDurs_AllStates_CRF(d,:,i,:),4);
        % get stdev across sessions
        allState_stdErrOverSess = std(squeeze(allSessAllPtsAllDurs_AllStates_CRF(d,:,i,:))')/sqrt(size(allSessAllPtsAllDurs_AllStates_CRF,4)); 
        %loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))'); 
        
        if nGroup == 1
            
            %plot(x_axis,allState_meanDthCRFacrossSess,'-b','lineWidth',1,'MarkerSize',3) 
            plot(x_axis,allState_meanDthCRFacrossSess,'color',C{d},'lineWidth',1,'MarkerSize',3) 
        
        else 
            
            % plot for lo beh state
            errorbar(x_axis,allState_meanDthCRFacrossSess,allState_stdErrOverSess,'-b','lineWidth',1,'MarkerSize',3) 
        
        end 
        
        hold on 
        
%         % take mean across sessions, for ith point, hi beh state
%         allStates_meanDthCRFacrossSess = mean(allState_meanDthCRFacrossSess(d,:,i,:),4);
%         % get stdev across sessions
%         hiBehState_stdErrOverSess = std(squeeze(allState_meanDthCRFacrossSess(d,:,i,:))')/sqrt(size(allSessAllPtsAllDurs_AllStates_CRF,4)); 
%         
%         if nGroup == 1
%             
%             plot(x_axis,allStates_meanDthCRFacrossSess,'-r','lineWidth',1,'MarkerSize',3) 
%             
%         
%         else 
%             
%             % plot for hi beh state
%             errorbar(x_axis,allStates_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'-r','lineWidth',1,'MarkerSize',3) 
%             
%         
%         end
        
        title(reigons{i})

        ylim(yLimit) 
        xlim(xLimit)

        axis square

        % visualization

        grid on

        global fntSize
        global fntName
        global fontMult

        set(gca, 'FontSize', fntSize, 'FontName', fntName)

        ylabel('df/F', 'FontSize', fntSize*fontMult, 'FontName', fntName)
        yt = [yMin:0.01:yMax];
        ytl = arrayfun(@num2str, yt, 'UniformOutput', 0);
        set(gca,'YTick',yt)
        set(gca,'YTickLabel',ytl)

        xlabel('contrast (%)', 'FontSize', fntSize*fontMult, 'FontName', fntName)
        xt=[x_axis];
        xtl = {'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'}; 
        set(gca,'xtick',xt); 
        set(gca,'xticklabel',xtl);

        global legendStrings
        legend(legendStrings)

        %stateLegend = {'stat','run'};
        %lgd2 = legend([loPlot, hiPlot],'stationary','running');
        %lgd2.FontSize = fntSize-subt4leg;
   
    end

end

