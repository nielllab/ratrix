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
    
    for i = 1:4
    %for i = 1:size(allSessAllPtsAllDurs_AllStates_CRF,3)
        
        subplot(2,2,i) 
        
        % take mean across sessions, for ith point, lo beh state
        allState_meanDthCRFacrossSess = mean(allSessAllPtsAllDurs_AllStates_CRF(d,:,i,:),4);
        % get stdev across sessions
        %allState_stdErrOverSess = std(squeeze(allSessAllPtsAllDurs_AllStates_CRF(d,:,i,:))')/sqrt(size(allSessAllPtsAllDurs_AllStates_CRF,4)); % stderr over sessions...
        %loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))'); 
        % get stderr across mice
        global numMice
        allState_stdErrOverSess = std(squeeze(allSessAllPtsAllDurs_AllStates_CRF(d,:,i,:))')/sqrt(numMice);
        
        if nGroup == 1
            
            %plot(x_axis,allState_meanDthCRFacrossSess,'-b','lineWidth',1,'MarkerSize',3) 
            plot(x_axis,allState_meanDthCRFacrossSess,'color',C{d},'lineWidth',2,'MarkerSize',2) 
        
        else 
            
            % plot for lo beh state
            errorbar(x_axis,allState_meanDthCRFacrossSess,allState_stdErrOverSess,'color',C{d},'lineWidth',2,'MarkerSize',2) 
        
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

        %axis square

        % visualization

        global fntSize
        global fntName
        global fontMult
        global subt4leg

        set(gca, 'FontSize', fntSize, 'FontName', fntName)

        ylabel('dF/F', 'FontSize', fntSize*fontMult, 'FontName', fntName)
        yt = [0, 0.02, 0.04, 0.06, 0.08, yMax];
        ytl = arrayfun(@num2str, yt, 'UniformOutput', 0);
        set(gca,'YTick',yt)
        set(gca,'YTickLabel',ytl)

        xlabel('contrast (%)', 'FontSize', fntSize*fontMult, 'FontName', fntName)
        xt=[x_axis];
        xtl = {'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'}; 
        set(gca,'xtick',xt); 
        set(gca,'xticklabel',xtl);

        %legend('16 ms','33 ms','66 ms','133 ms','266 ms')
        %legend('66 ms','83 ms','100 ms','116 ms')
        
        %global legendStrings
        %lgd = legend(legendStrings,'Location','northwest');

        %stateLegend = {'stat','run'};
        %lgd2 = legend([loPlot, hiPlot],'stationary','running');
        %lgd.FontSize = fntSize-subt4leg;
   
    end

end

