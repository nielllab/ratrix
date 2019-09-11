clear all

done = 0;
n=0;  %%% #number of files loaded
  
while ~done
    
    %%% get filename
    [f p] = uigetfile('*.mat','data file');
    
    if f==0  %% done when you hit cancel
        done=1;
    else      
        load(fullfile(p,f),'dFrepeats','stimOrder');
        
        %%% get # of stim and length of stim, to check consistency 
        if n==0
            nstim = length(unique(stimOrder));
            stimLength = size(dFrepeats,2);
        end
        
        %%% check consistency
        if length(unique(stimOrder))~=nstim
            display('wrong # of stimuli');
        elseif size(dFrepeats,2) ~=stimLength
            display('wrong stim length');
        
        %%% if all is good, then add on the data
        else
            n=n+1;
            dF(:,n) = squeeze(mean(nanmedian(dFrepeats,3),1));
            labels{n} = input('data label : ','s');
        end    
    end
end

stimDur = stimLength/nstim; %%% frames per cycle

figure
plot(dF); ylim([-0.05 0.15]); hold on
for i = 1:nstim   
    plot([stimDur*i stimDur*i], [-0.1 0.2],'k:')
end
legend(labels);


         
    
