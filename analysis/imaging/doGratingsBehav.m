%%%% doGratings
x=0;
for rep=1:4 %%% 1 = 3x 1sf 4 orient behav passiv 2 = simple behavior passive 2x, 2sf;
    mnAmp{rep}=0; mnPhase{rep}=0; mnAmpWeight{rep}=0; mnData{rep}=0; mnFit{rep}=0;
    clear shiftData shiftAmp shiftPhase fit cycavg
    
    for f = 1:length(use)
        figure
        set(gcf,'Name',[files(use(f)).subj ' ' files(use(f)).expt])
        
        
        for i = 1:2  %%%% load in topos for check
            if i==1
                load([pathname files(use(f)).topox],'map');
            elseif i==2
                load([pathname files(use(f)).topoy],'map');
            elseif i==3 && length(files(use(f)).topoyland)>0
                load([pathname files(use(f)).topoyland],'map');
            elseif i==4 &&length(files(use(f)).topoxland)>0
                load([pathname files(use(f)).topoxland],'map');
            end
            subplot(2,2,i);
            imshow(polarMap(shiftImageRotate(map{3},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz),90));
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
        
        if rep==1
            if ~isempty(files(use(f)).behavstim3x4orient)
                load ([pathname files(use(f)).behavstim3x4orient ], 'dfof_bg','sp','stimRec')
                zoom = 260/size(dfof_bg,1);
                if ~exist('sp','var')
                    sp =0;stimRec=[];
                end
                dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
                tuningAll3x(rep,f,:,:,:,:) = analyzeGratingPatchBehav(imresize(dfof_bg,0.5),sp,...
                    'C:\behavStim3sf4orient',26:30,18:20,xpts/2, ypts/2, [files(use(f)).subj ' ' files(use(f)).expt],stimRec);
            end
        elseif rep==2
            if ~isempty(files(use(f)).behavstim2sf)
                load ([pathname files(use(f)).behavstim2sf ], 'dfof_bg','sp','stimRec')
                zoom = 260/size(dfof_bg,1);
                if ~exist('sp','var')
                    sp =0;stimRec=[];
                end
                dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
                tuningAll2x(f,:,:,:,:,:)=analyzeGratingPatchBehav(imresize(dfof_bg,0.5),sp,...
                    'C:\behavStim2sfSmall3366',26:30,18:20,xpts/2, ypts/2, [files(use(f)).subj ' ' files(use(f)).expt],stimRec);
            end
        elseif rep==3
            if ~isempty(files(use(f)).behavstim3x4orientLOW)
                load ([pathname files(use(f)).behavstim3x4orientLOW ], 'dfof_bg','sp','stimRec')
                zoom = 260/size(dfof_bg,1);
                if ~exist('sp','var')
                    sp =0;stimRec=[];
                end
                dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
                tuningAll3x(rep,f,:,:,:,:) = analyzeGratingPatchBehav(imresize(dfof_bg,0.5),sp,...
                    'C:\behavStim3x4orientLOW',26:30,18:20,xpts/2, ypts/2, [files(use(f)).subj ' ' files(use(f)).expt],stimRec);
            end
        elseif rep==4
            if ~isempty(files(use(f)).behavstim2sfLOW)
                load ([pathname files(use(f)).behavstim2sfLOW ], 'dfof_bg','sp','stimRec')
                zoom = 260/size(dfof_bg,1);
                if ~exist('sp','var')
                    sp =0;stimRec=[];
                end
                dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
                tuningAll2x(f,:,:,:,:,:)=analyzeGratingPatchBehav(imresize(dfof_bg,0.5),sp,...
                    'C:\behavStim2sfLOW',26:30,18:20,xpts/2, ypts/2, [files(use(f)).subj ' ' files(use(f)).expt],stimRec);
            end
        end
    end
end

figure
set(gcf,'Name',files(alluse(1)).subj)
nf = size(tuningAll2x,1);
for f = 1:nf
    for im = 1:4
        subplot(nf,4,(f-1)*4+im);
        imagesc(squeeze(mean(tuningAll2x(f,:,:,mod(im-1,2)+1,ceil(im/2),:),6)),[0 0.12])
        axis off; axis equal; set(gca,'LooseInset',get(gca,'TightInset'))
    end
end

figure
set(gcf,'Name',files(alluse(1)).subj)
nf = size(tuningAll2x,1);
for f = 1:2
    for im = 1:4
        subplot(2,4,(f-1)*4+im);
        if f==1
            imagesc(squeeze(mean(mean(tuningAll2x(1:2,:,:,mod(im-1,2)+1,ceil(im/2),:),6),1)),[0 0.12])
        else
            imagesc(squeeze(mean(mean(tuningAll2x(end-1:end,:,:,mod(im-1,2)+1,ceil(im/2),:),6),1)),[0 0.12])
        end
        hold on; plot(ypts/4,xpts/4,'w.','Markersize',2)
        axis off; axis equal; set(gca,'LooseInset',get(gca,'TightInset'))
    end
    
end


figure
set(gcf,'Name',files(alluse(1)).subj)
tuningAll3x = squeeze(tuningAll3x);
nf = size(tuningAll3x,1);
for f = 1:nf
    for im = 1:6
        subplot(nf,6,(f-1)*6+im);
        imagesc(squeeze(mean(tuningAll3x(f,:,:,mod(im-1,3)+1,[1 3]+floor((im-1)/3)),5)),[0 0.12])
        axis off; axis equal; set(gca,'LooseInset',get(gca,'TightInset'))
    end
end

figure
set(gcf,'Name',files(alluse(1)).subj)
tuningAll3x = squeeze(tuningAll3x);
nf = size(tuningAll3x,1);

avg = tuningAll3x(:,40,40,1,1);
z = find(avg==0);
if length(z>0)
    first = max(z)+1;
else first=1;
end

for f = 1:2
    for im = 1:6
        subplot(2,6,(f-1)*6+im);
        if f==1
            imagesc(squeeze(mean(mean(tuningAll3x(first:first+1,:,:,mod(im-1,3)+1,[1 3]+floor((im-1)/3)),5),1)),[0 0.12])
        else
            imagesc(squeeze(mean(mean(tuningAll3x(end-1:end,:,:,mod(im-1,3)+1,[1 3]+floor((im-1)/3)),5),1)),[0 0.12])
        end
        axis off; axis equal; set(gca,'LooseInset',get(gca,'TightInset'))
        hold on; plot(ypts/2,xpts/2,'w.','Markersize',2)
    end
end

clear tcourse2x
range = -5:5;
for i = 1:2
    figure
    imagesc(squeeze(mean(tuningAll2x(:,:,:,i,1),1))); hold on; plot(ypts/2,xpts/2,'w.','Markersize',2)
    [y x] = ginput(1); x=round(x); y=round(y);
    close
    tcourse2x(i,:,:) = squeeze(mean(mean(mean(tuningAll2x(:,x+range,y+range,i,:,:),6),3),2));
    yall(i)=y; xall(i)=x;
end
tcourse2x = tcourse2x/max(tcourse2x(:));
figure
for i = 1:2
    subplot(2,2,i)
    imagesc(squeeze(mean(tuningAll2x(:,:,:,i,1),1))); hold on; plot(ypts/2,xpts/2,'w.','Markersize',2)
    plot(yall(i),xall(i),'g*')
    subplot(2,2,i+2)
    plot(squeeze(tcourse2x(i,:,:)));
    ylim([0 1.1])
    xlim([1 size(tcourse2x,2)])
end

clear tcourse3x
tuningAll3x = squeeze(tuningAll3x);
for i = 1:3
    figure
    imagesc(squeeze(mean(mean(tuningAll3x(:,:,:,i,:),5),1))); hold on; plot(ypts/2,xpts/2,'w.','Markersize',2)
    [y x] = ginput(1); x=round(x); y=round(y);
    close
    tcourse3x(i,:,1) = squeeze(mean(mean(mean(tuningAll3x(:,x+range,y+range,i,[1 3]),5),3),2));
    tcourse3x(i,:,2) = squeeze(mean(mean(mean(tuningAll3x(:,x+range,y+range,i,[2 4]),5),3),2));figure
    xall(i)=x; yall(i)=y;
end

figure
tcourse3x = tcourse3x/max(tcourse3x(:));
tcourse3x(tcourse3x==0)=NaN;
for i = 1:3
    subplot(2,3,i)
    imagesc(squeeze(mean(mean(tuningAll3x(:,:,:,i,:),5),1))); hold on; plot(ypts/2,xpts/2,'w.','Markersize',2)
    hold on; plot(yall(i),xall(i),'g*')
    subplot(2,3,i+3)
    plot(squeeze(tcourse3x(i,:,:)))
    ylim([0 1.1])
    xlim([1 size(tcourse3x,2)])
end



