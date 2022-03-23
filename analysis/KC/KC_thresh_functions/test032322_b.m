if nGroup == 1
            
            plot(x_axis,loBehState_meanDthCRFacrossSess,'-b','lineWidth',1,'MarkerSize',3) 
        
        else 
            
            % plot for lo beh state
            errorbar(x_axis,loBehState_meanDthCRFacrossSess,loBehState_stdErrOverSess,'-b','lineWidth',1,'MarkerSize',3) 
        
        end 
        
        hold on 
        
        
         if nGroup == 1
            
            plot(x_axis,hiBehState_meanDthCRFacrossSess,'-r','lineWidth',1,'MarkerSize',3) 
        
        else 
            
            % plot for hi beh state
            errorbar(x_axis,hiBehState_meanDthCRFacrossSess,hiBehState_stdErrOverSess,'-r','lineWidth',1,'MarkerSize',3) 
        
        end
        
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