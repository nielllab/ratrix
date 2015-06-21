batch2pBehavior

for f = 2:2
    
    %%% get topo information
    display('loading topox')
    load([pathname files(f).expt  ' ' files(f).subj '\' files(f).topox_pts]);
    xph = phaseVal; xCyc = cycAvg;
    xrf = mod(angle(xph),2*pi)*128/(2*pi); xamp = abs(xph);
    xdF = dF;
    
    display('loading topoy')
    load([pathname files(f).expt  ' ' files(f).subj '\' files(f).topoy_pts]);
    yph = phaseVal; yCyc = cycAvg;
    yrf = mod(angle(yph),2*pi)*72/(2*pi); yamp=abs(yph);
    ydF=dF;
    figure
    plot(yrf(yamp>0.02 & xamp>0.02),xrf(yamp>0.02 & xamp>0.02),'o');
    axis equal ;axis([0 72 0 128]);
    
    clear rfmap
    for i = 1:length(xph)
        rfmap(:,:,i) = xCyc(i,:)'*yCyc(i,:);
    end
    
    rfmap=imresize(rfmap,[128 72]);
    figure
    for i = 1:100
        subplot(10,10,i)
        imagesc(rfmap(:,:,i)); axis equal; axis([ 0 72 0 128]);
        set(gca,'Xtick',[]); set(gca,'Ytick',[])
    end
    
    %%% get behav information
    display('loading behav')
    load([pathname files(f).expt  ' ' files(f).subj '\' files(f).behav_pts]);
       for i = 1:length(trialRecs)
        xpos(i) = trialRecs(i).stimDetails.subDetails.xPosPcts;
    end
    
    results = [ sum(correct & xpos<0.5)  sum(~correct&xpos<0.5) sum(~correct & xpos>0.5)  sum(correct & xpos>0.5)];
    results = results/sum(results(:))
    figure
    pie(results); legend('bottom correct','bottom error','top error','top correct');
    
    results = [ sum(correct & orient==0)  sum(~correct&orient==0) sum(~correct & orient==pi/2)  sum(correct & orient==pi/2)];
    results = results/sum(results(:))
    figure
    pie(results); legend('vert? correct','vert? error','horiz? error','horiz? correct');
    
    choice = sign(targ .* (correct-0.5));
    figure
    pie([sum(choice<0) sum(choice>0)]); legend('left','right')
    
    bdF = dF;
    correctRate = conv(double(correct),ones(1,10),'same')/10;
      resptime = (starts(:,3)-starts(:,2))*10^4;
    resprate = conv(resptime,ones(3,1),'same')/3;
     stoptime = (starts(:,2)-starts(:,1))*10^4;
     stoprate = conv(stoptime,ones(3,1),'same')/3;
    figure
    subplot(6,6,7:36);
    dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
    imagesc(corrcoef(dFlist(usenonzero,:)),[0 1]); xlabel('frame'); ylabel('frame')
    subplot(6,6,1:6); plot(correctRate,'Linewidth',2); hold on; plot([1 length(correctRate)],[0.5 0.5],'r:'); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
    hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
    plot(resprate/5,'g','Linewidth',2); plot(stoprate/5,'r','Linewidth',2)
    
    behavtimepts = timepts;
    
    dFalignfix = dFalign;
    for i=1:size(dFalign,1);
        for j = 1:size(dFalign,3);
            dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,3:5,j));
        end
    end
    usetrials=1;
    clear data err
    allTrials = zeros(size(dFalign,2),4,size(dFalign,1));
    

    
    for i = 1:size(dFalign,1)
        
        for j = 1:4
            if j==1
                use = xpos<0.5 & orient==0 & usetrials;
            elseif j==2
                use = xpos<0.5 & orient>0& usetrials;
            elseif j ==3
                use = xpos>0.5 & orient==0& usetrials;
            else
                use = xpos>0.5 & orient>0& usetrials;
            end
            d = nanmean(dFalignfix(i,:,use),3);
            data(:,j) = d; %-mind(d);
            err(:,j) = nanstd(dFalignfix(i,:,use),[],3)/sqrt(sum(use));
            
        end
        data = data-min(data(:));
        allTrials(:,:,i) = data;
        allTrialsErr(:,:,i) = err;
    end
    
    leftResp = max(allTrials(6,1:2,:),[],2);
    leftResp = squeeze(leftResp-mean(allTrials(4,1:2,:),2));
    rightResp = max(allTrials(6,3:4,:),[],2);
    rightResp = squeeze(rightResp-mean(allTrials(4,3:4,:),2));
    
    vertResp = max(allTrials(6,[1 3],:),[],2);
    vertResp = squeeze(vertResp-mean(allTrials(4,[1 3],:),2));
    horizResp = max(allTrials(6,[2 4],:),[],2);
    horizResp = squeeze(horizResp-mean(allTrials(4,[2 4],:),2));
    figure
    plot(leftResp,rightResp,'o'); hold on; plot([0 1],[0 1]); axis equal; xlabel('bottom?'); ylabel('top?')
    figure
    plot(vertResp,horizResp,'o');hold on; plot([0 1],[0 1]);axis equal; xlabel('horiz?'); ylabel('vert?')
    
  clear respdF
    for i = 1:2
        if i==1
            usetrial = ~correct
        else
            usetrial = correct;
        end
        respOnset= onsets(usetrial) + resptime(usetrial)';      
        respPts = -1:0.25:2;
        respalign = align2onsets(dF,respOnset,0.25,respPts);
        for j = 1:size(dF,1);
            respdF(j,:,i) = mean(respalign(j,:,:),3);
            respdF(j,:,i) = respdF(j,:,i) - min(squeeze(respdF(j,3:5,i)));
        end
    end
%     figure
%     imagesc(respdF(:,:,1),[0 1]); title('incorrect')
%      figure
%     imagesc(respdF(:,:,2)),[0 1]; title('correct')
%         
        
        %%% get 3x passive behav
        load([pathname files(f).expt  ' ' files(f).subj '\' files(f).behavstim3x4orient_pts]);
        dFalign = dfAlign;
        dF3=dF;
        timepts3x = timepts; dF3x=dF;
        
        x = unique(xpos);
        t = find(timepts3x==0.5); tpre = find(timepts3x==0);
        for i=1:3
            xtuning(:,i) = mean(dFalign(:,t,xpos==x(i)),3) -  mean(dFalign(:,tpre,xpos==x(i)),3);
        end

        th = unique(theta);
        for i=1:4
            thetatuning(:,i) = mean(dFalign(:,t,theta==th(i)),3) -  mean(dFalign(:,tpre,theta==th(i)),3);
        end
 
        
        usepts = sort(find(timepts3x>=-1 & timepts3x<=2));
        dFalignfix = dFalign;
        for i=1:size(dFalign,1);
            for j = 1:size(dFalign,3);
                dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,usepts(3:5),j));
            end
        end
        
        figure
        imagesc(mean(dFalign,3))
        
        allTrials3x = zeros(length(usepts),4,size(dFalign,1));
        for i = 1:size(dF,1)
            
            for j = 1:4
                if j==1
                    use =xpos==x(1) & theta==0;
                elseif j==2
                    use = xpos==x(1) & theta==pi/2;
                elseif j ==3
                    use = xpos== x(end) & theta==0;
                else
                    use =xpos==x(end) & theta==pi/2;
                end
                d = mean(dFalignfix(i,usepts,use),3);
                data(:,j) = d; %-mind(d);
                err(:,j) = std(dFalignfix(i,usepts,use),[],3)/sqrt(sum(use));
                
            end
            data = data-min(data(:));
            allTrials3x(:,:,i) = data;
            allTrialsErr3x(:,:,i) = err;
        end

        
        %%% get 2x behav passive
        load([pathname files(f).expt  ' ' files(f).subj '\' files(f).behavstim2sf_pts ]);
        dF2 = dF;
        dFalign = dfAlign;
        timepts2x = timepts; dF2x=dF;
        usepts = sort(find(timepts2x>=-1 & timepts2x<=2));
        
        dFalignfix = dFalign;
        for i=1:size(dFalign,1);
            for j = 1:size(dFalign,3);
                dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,usepts(3:5),j));
            end
        end
        
        sfs = unique(sf);
      t = find(timepts2x==0.5); tpre = find(timepts2x==0);
        for i=1:2
            sftuning(:,i) = mean(dFalign(:,t,sf==sfs(i)),3) -  mean(dFalign(:,tpre,sf==sfs(i)),3);
        end
        
        x = unique(xpos);
        allTrials2x = zeros(length(usepts),4,size(dFalign,1));
        for i = 1:size(dF,1)
            
            for j = 1:4
                if j==1
                    use =xpos==x(1) & theta==0;
                elseif j==2
                    use = xpos==x(1) & theta==pi/2;
                elseif j ==3
                    use = xpos== x(end) & theta==0;
                else
                    use =xpos==x(end) & theta==pi/2;
                end
                d = mean(dFalignfix(i,usepts,use),3);
                data(:,j) = d; %-mind(d);
                err(:,j) = std(dFalignfix(i,usepts,use),[],3)/sqrt(sum(use));
                
            end
            data = data-min(data(:));
            allTrials2x(:,:,i) = data;
            allTrialsErr2x(:,:,i) = err;
        end

        
        %%% get grating data
        load([pathname files(f).expt  ' ' files(f).subj '\' files(f).Orientations_w_blank_pts]);
        
        dFgrating=dF;
        gratingTuning = tuning;
        gratingAmp=amp;
        for i = 1:32;
            gcycAvg(:,i) = mean(dF(:,i:32:end),2);
        end
        for i = 1:size(gcycAvg,1)
            gcycAvg(i,:) = gcycAvg(i,:)-min(gcycAvg(i,:));
        end
        
        
        nStimResp = double(mean(dFgrating,2)~=0) + double(mean(bdF,2)~=0) + double(mean(xdF,2)~=0 | mean(ydF,2)~=0) + double(mean(dF2,2)~=0 | mean(dF3,2)~=0);
        figure
        hist(nStimResp);
       
        nUnits = [mean(mean(xdF,2)~=0) mean(mean(ydF,2)~=0) mean(mean(bdF,2)~=0) mean(mean(dF2,2)~=0) mean(mean(dF3,2)~=0) mean(mean(dFgrating,2)~=0)];
        figure
        bar(nUnits); ylim([0 1]); set(gca,'Xtick',1:6); ylabel('% units detected'); set(gca,'Xticklabel',{'topox','topoy','behav','pass 2x','pass 3x','grating'})
        
        keyboard
        %%% start plotting!
        for i = 1:size(xdF,1)
            %if mean(bdF(i,:),2)~=0 | mean(dF2(i,:),2)~=0 | mean(dF3(i,:)~=0)
             if nStimResp(i)==4;  

                 figure
                
                %%% topo x / y
                subplot(3,4,1);
                imagesc(rfmap(:,:,i)); axis equal; axis([ 0 72 0 128]); axis xy
                
                subplot(3,4,2);
                plot(yrf(i),xrf(i),'o');  axis equal; axis([0 72 0 128]);
                
                %%% behav
                subplot(3,4,4); hold on
                col = 'rmbc';
                for j= 1:4;
                    plot(behavtimepts,allTrials(:,j,i),col(j))
                end
                axis([-1 2 -0.2 2]); hold on; plot([-1 2],[0 0],'k:')
                
                %%% passive 3x
                subplot(3,4,8); hold on
                col = 'mrcb';
                for j= 1:4;
                    plot(behavtimepts,allTrials3x(:,j,i),col(j))
                end
                axis([-1 2 -0.2 2]); hold on; plot([-1 2],[0 0],'k:');  plot([0 0],[0 2],'r:'); plot([1 1],[0 2],'r:')
                
                subplot(3,4,12); hold on
                col = 'mrcb';
                for j= 1:4;
                    plot(behavtimepts,allTrials2x(:,j,i),col(j))
                end
                axis([-1 2 -0.2 2]); hold on; plot([-1 2],[0 0],'k:'); plot([0 0],[0 2],'r:'); plot([1.95 1.95],[0 2],'r:')
                
                subplot(3,4,3);
                plot(respPts,respdF(i,:,1),'r'); hold on;
                plot(respPts,respdF(i,:,2),'g');
                axis([-1 2 -0.2 2]); plot([-2 2],[0 0],'k:'); plot([0 0],[-0.5 2],'b:');
                
                subplot(3,4,5);
                plot(xtuning(i,:)); hold on;axis([0.5 3.5 -0.25 1]); plot([0.5 3.5],[0 0],'k:');xlabel('xpos')
                
                subplot(3,4,6);
                plot(thetatuning(i,:)); hold on;axis([0.5 4.5 -0.25 1]); plot([0.5 4.5],[0 0],'k:');xlabel('theta');
                
                subplot(3,4,11);
                plot(sftuning(i,:)); hold on; axis([0.5 2.5 -0.25 1]); plot([0.5 2.5],[0 0],'k:'); xlabel('sf');
                
                subplot(3,4,9);
                plot(tuning(i,:)); axis([1 8 -0.5 1.5]); hold on; plot([1 8],[0 0],'k:')
                
                subplot(3,4,10);
                plot(gcycAvg(i,:)); axis([1 32 0 1]); hold on; plot([16 16],[0 1],'r:');
                subplot(3,4,10);
                title(sprintf('cell %d',i))
            end
        end
    end
