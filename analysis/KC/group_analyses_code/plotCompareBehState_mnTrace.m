function plotCompareBehState_mnTrace(loRun_mnTraceAllConsDursPts,hiRun_mnTraceAllConsDursPts,cons4axes,visArea,durat,cont,yMax,yMin,yLimit,stateLegend,nGroup)

for d = durat
               
    for i = visArea
        
     figure     
    
     formatSpec = '%d \n'; 
     titleText = sprintf(formatSpec,visArea(i));
     suptitle(titleText)
            
        for c = cont

            subplot(2,4,c) 

            if nGroup == 1

                loBehState_mnTraceOverSess_dthIthCon = loRun_mnTraceAllConsDursPts(c,:,d,i,:);

                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];

                plot(x_axis,loBehState_mnTraceOverSess_dthIthCon,'-b','lineWidth',1,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames (10 Hz)')

            else

                % take mean across sessions, for ith point, lo beh state
                loBehState_mnTraceOverSess_dthIthCon = mean(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))',1);
                % get stdev across sessions
                loBehState_mnTraceOverSess_std = std(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(size(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))',1)); 

                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];

                % plot for lo beh state
                errorbar(x_axis,loBehState_mnTraceOverSess_dthIthCon,loBehState_mnTraceOverSess_std,'-b','lineWidth',1,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames (10 Hz)')

            end % end if nGroup loop

            hold on 

            if nGroup == 1

                hiBehState_mnTraceOverSess_dthIthCon = hiRun_mnTraceAllConsDursPts(c,:,d,i,:);

                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];
                plot(x_axis,hiBehState_mnTraceOverSess_dthIthCon,'-r','lineWidth',1,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames (10 Hz)')

            else

                % take mean across sessions, for ith point, lo beh state
                hiBehState_mnTraceOverSess_dthIthCon = mean(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))',1);
                % get stdev across sessions
                hiBehState_mnTraceOverSess_std = std(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(size(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))',1)); 

                x_axis = [1:length(hiBehState_mnTraceOverSess_dthIthCon)];
                % plot for lo beh state
                errorbar(x_axis,hiBehState_mnTraceOverSess_dthIthCon,hiBehState_mnTraceOverSess_std,'-r','lineWidth',1,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                %tt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'};
                title(cons4axes{c})

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames (10 Hz)')

            end % end of nGroup loop

%             clear xt
%             xt={'1'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
%             set(gca,'xtick',1:1:18); 
%             set(gca,'xticklabel',xt);
%                 
%             yt = [-0.01 0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1];
%             set(gca,'YTick',yt)
            
            legend(stateLegend)
            
            hold on
            
        end % end c loop

    end % end i lopp
    
end % end d loop

end

