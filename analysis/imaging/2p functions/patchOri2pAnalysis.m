%patchOri2pAnalysis

dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;

orimoviename = 'C:\patchOrientations15min.mat';
%%%info for this movie: contrast=1, phase=random, radius = 20deg, nx/ny=1, sf = 3x, tf= 2x
load(orimoviename);

contrastrange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
radiusrange=unique(radius); tfrange=unique(tf); dirrange=unique(theta);
thetamod = mod(theta,pi)-pi/8;
oriQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
oriQuad(1,find(-pi/8<=thetamod&thetamod<=pi/8))=1;
oriQuad(1,find(pi/8<=thetamod&thetamod<=3*pi/8))=2;
oriQuad(1,find(3*pi/8<=thetamod&thetamod<=5*pi/8))=3;
oriQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
orirange = unique(oriQuad);


%%for loop
for f=1:length(use)
    filename = files(use(f)).gratinganalysis
    if exist([filename '.mat'])==0
        files(use(f)).subj
        psfile = 'c:\tempPhil2p.ps';
        if exist(psfile,'file')==2;delete(psfile);end
        
        cellCutoff = files(use(f)).cutoff;
        respthresh=0.025;
        
        load(files(use(f)).gratingpts);
        load(files(use(f)).gratingstimObj);
        spInterp = get2pSpeed(stimRec,dt,size(dF,2));
        spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
        
        ntrials= min(dt*length(dF)/(isi+duration),length(sf));
        onsets = dt + (0:ntrials-1)*(isi+duration);
        timepts = 1:(2*isi+duration)/dt;
        timepts = (timepts-1)*dt;
        dFout = align2onsets(dF,onsets,dt,timepts);
        dFout = dFout(1:end-1,:,:); %%%extra cell at end for some reason
    %     dFout = dFout(goodTopo,:,:);
        spikesOut = align2onsets(spikes*10,onsets,dt,timepts);
    %     spikesOut = spikesOut(goodTopo,:,:);
        timepts = timepts - isi;
        running = zeros(1,ntrials);
        for i = 1:ntrials
            running(i) = mean(spInterp(1,1+cyclelength*(i-1):cyclelength+cyclelength*(i-1)),2)>20;
        end

        if exclude
            %threshold big guys out
            sigthresh = 10;
            for i=1:size(dFout,1)
                for j=1:size(dFout,3)
                    if squeeze(max(dFout2(i,1:10,j),[],2))>sigthresh
                        dFout2(i,:,j) = nan(1,size(dFout2,2));
                    end
                end
            end 
        end
        
        %%%subtract baseline period
        dFout2 = dFout;
        spikesOut2 = spikesOut;
        for i = 1:size(dFout,1)
            for j = 1:size(dFout,3)
                dFout2(i,:,j) = dFout(i,:,j)-nanmean(dFout(i,1:4,j));
                spikesOut2(i,:,j) = spikesOut(i,:,j)-nanmean(spikesOut(i,1:4,j));
            end
        end

        %stopped here for thetaQuad revision
        dftuningall = zeros(size(dFout,1),size(dFout,2),length(sfrange),length(tfrange),length(dirrange),length(orirange),2);
        sptuningall = zeros(size(spikesOut,1),size(spikesOut,2),length(sfrange),length(tfrange),length(dirrange),length(orirange),2);
        for h = 1:size(dFout,1)
            for i = 1:length(sfrange)
                for j = 1:length(tfrange)
                    for k = 1:length(dirrange)
                        for l = 1:length(orirange)
                            for m = 1:2
                                dftuningall(h,1:size(dFout,2),i,j,k,l,m,n) = nanmean(dFout2(h,:,find(sf==sfrange(i)&tf==tfrange(j)&theta==dirrange(k)&oriQuad==orirange(l)&running==(m-1))),3);
                                sptuningall(h,1:size(spikesOut,2),i,j,k,l,m,n) = nanmean(spikesOut2(h,:,find(sf==sfrange(i)&tf==tfrange(j)&theta==dirrange(k)&oriQuad==orirange(l)&running==(m-1))),3);
                            end
                        end
                    end
                end
            end
        end
        
        
        
        
    else
        sprintf('skipping %s',filename)
    end
end