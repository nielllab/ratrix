function plotCompareBehState_mnTrace(loRun_mnTraceAllConsDursPts,hiRun_mnTraceAllConsDursPts,cons4axes,visArea,durat,cont,yMax,yMin,yLimit,stateLegend,nGroup)

for d = durat
               
    for i = visArea
        
     figure     
    
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

%      formatSpec = '%d \n'; 
%      titleText = sprintf(formatSpec,visArea(i));
%      suptitle(titleText)
            
        for c = cont(2:end)

            subplot(2,3,c-1) 

            if nGroup == 1

                loBehState_mnTraceOverSess_dthIthCon = loRun_mnTraceAllConsDursPts(c,:,d,i,:);

                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];

                plot(x_axis,loBehState_mnTraceOverSess_dthIthCon,'color',loStateLineColor,'lineWidth',2,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames')

            else

                % take mean across sessions, for ith point, lo beh state
                loBehState_mnTraceOverSess_dthIthCon = mean(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))',1);
                %loBehState_mnTraceOverSess_dthIthCon = mean(squeeze(loRun_mnTraceAllConsDursPts(c,:,i,:))',1);
                % get stdev across sessions
                %loBehState_mnTraceOverSess_std = std(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(size(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))',1)); 
                %loBehState_mnTraceOverSess_std = std(squeeze(loRun_mnTraceAllConsDursPts(c,:,i,:))')/sqrt(size(squeeze(loRun_mnTraceAllConsDursPts(c,:,i,:))',1)); 
                % stderr over mice
                global numMice
                loBehState_mnTraceOverSess_std = std(squeeze(loRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(numMice); 
                
                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];

                % plot for lo beh state
                errorbar(x_axis,loBehState_mnTraceOverSess_dthIthCon,loBehState_mnTraceOverSess_std,'color',loStateLineColor,'lineWidth',2,'MarkerSize',2) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('dF/F')
                xlabel('frames')

            end % end if nGroup loop

            hold on 

            if nGroup == 1

                hiBehState_mnTraceOverSess_dthIthCon = hiRun_mnTraceAllConsDursPts(c,:,d,i,:);

                x_axis = [1:length(loBehState_mnTraceOverSess_dthIthCon)];
                plot(x_axis,hiBehState_mnTraceOverSess_dthIthCon,'color',hiStateLineColor,'lineWidth',2,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames')

            else

                % take mean across sessions, for ith point, lo beh state
                hiBehState_mnTraceOverSess_dthIthCon = mean(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))',1);
                % get stdev across sessions
                %hiBehState_mnTraceOverSess_std = std(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(size(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))',1)); 
                % stderr over mice
                global numMice
                hiBehState_mnTraceOverSess_std = std(squeeze(hiRun_mnTraceAllConsDursPts(c,:,d,i,:))')/sqrt(numMice); 

                x_axis = [1:length(hiBehState_mnTraceOverSess_dthIthCon)];
                % plot for lo beh state
                errorbar(x_axis,hiBehState_mnTraceOverSess_dthIthCon,hiBehState_mnTraceOverSess_std,'color',hiStateLineColor,'lineWidth',2,'MarkerSize',3) 

                xMin = min(x_axis);
                xMax = max(x_axis);
                xLimit = [xMin xMax];
                xlim(xLimit);

                %tt={'0'; '3' ; '6' ; '12' ; '25' ; '50'; '100'};
                title(cons4axes{c})

                ylim(yLimit) 
                ylabel('df/f')
                xlabel('frames')

            end % end of nGroup loop

%             clear xt
%             xt={'1'; '3' ; '6' ; '12' ; '25' ; '50'; '100'} ; 
%             set(gca,'xtick',1:1:18); 
%             set(gca,'xticklabel',xt);
%                 
%             yt = [-0.01 0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1];
%             set(gca,'YTick',yt)

                ax = gca; % axes handle
                ax.YAxis.Exponent = 0;
            
        fntSize = 10;
        fntName = 'SansSerif';

        set(gca, 'FontSize', fntSize, 'FontName', fntName)

        fontMult = 1.5;

        %xlabel('speed (cm/sec)', 'FontSize', fntSize*fontMult, 'FontName', fntName)
        %ylabel('frequency', 'FontSize', fntSize*fontMult, 'FontName', fntName)

        yt = [yMin 0 0.02 0.04 0.06 0.08 yMax];
        ytl = arrayfun(@num2str, yt, 'UniformOutput', 0);
        set(gca,'YTick',yt)
        set(gca,'YTickLabel',ytl)

        xt = [0:4:length(loRun_mnTraceAllConsDursPts)];
        xtl = arrayfun(@num2str, xt, 'UniformOutput', 0);
        set(gca,'xtick',xt); 
        set(gca,'xticklabel',xtl);
        
            %legend(stateLegend)
            
            hold on
            
        end % end c loop

    end % end i lopp
    
end % end d loop

end

