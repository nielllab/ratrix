function hateren

%see http://hlab.phys.rug.nl/tslib/index.html
%ftp://hlab.phys.rug.nl/pub/timser/ts001.txt %time series 1: sunny day; wood and meadows

%http://hlab.phys.rug.nl/tslib/ts_descr.html
%These time series were obtained with a photodetector with a similar spatial resolution as a human cone, worn on a headband by a walking person.
%'Processing of natural time series of intensities by the visual system of the blowfly' (J.H. van Hateren) Vision Res. 37:3407-3416, 1997
%The format of the binary version of the files is as follows: 3240000 samples (45 minutes at 1200 samples/sec)
%The samples are linear in intensity, and scaled such that the maximum intensity is limited to 32767.
%Thus the time series are linear in relative intensity (relative radiance),
%but not calibrated in absolute (radiometric) intensity.

ifi=1/85;
outrange=[0 255];
targetSecs=60;
fileName='ts001';

originalFs=1200;

if 2==exist([fileName '.mat'],'file')
    sig=load([fileName '.mat']);
    sig=sig.sig;
elseif 2==exist([fileName '.txt'],'file')
    tic
    sig=load([fileName '.txt']);
    fprintf('load took %g secs\n',toc)
    
    %textscan is slightly slower
%     tic
%     fid = fopen([fileName '.txt']);
%     C = textscan(fid, '%d');
%     fclose(fid);
%     fprintf('textscan took %g secs\n',toc)
%       sig=C{1};

    save([fileName '.mat'],'sig');
else
    error('can''t find file')
end

sig=sig-min(sig);
sig=sig/max(sig);
sig=sig*diff(outrange)+outrange(1);


lastAvailable=length(sig)-targetSecs*originalFs+1;
start=ceil(rand*lastAvailable);
sig=sig(start:start+targetSecs*originalFs-1);


tic
newSig=resample(sig,1/ifi,originalFs);
fprintf('resample took %g secs\n',toc);

if length(sig)/originalFs~=length(newSig)*ifi
    length(sig)/originalFs
    length(newSig)*ifi
    error('resampling gave wrong length for new sig')
end

if length(newSig)*ifi/60~=targetSecs/60
    length(newSig)*ifi/60
    error('resampling didn''t give correct duration signal')
end

% newSig=newSig-min(newSig);
% newSig=newSig/max(newSig);
% newSig=newSig*diff(outrange)+outrange(1);
newSig(newSig<outrange(1))=outrange(1);
newSig(newSig>outrange(2))=outrange(2);

mins=(0:(length(sig)-1))/originalFs/60;
newMins=0:ifi/60:max(mins);

doplot=true;
if doplot
    close all
    plot(mins,sig,'r')
    hold on
    plot(newMins,newSig,'b')
end

dointegrate=true;
if dointegrate
    integratedSig=zeros(1,length(newMins));

    for i=1:length(integratedSig)

        inds=find(mins>=newMins(i) & mins<newMins(i)+ifi/60);
        integratedSig(i)=integratedSig(i)+sum(sig(inds));

        if i~=1
            p=(newMins(i)-mins(min(inds)-1))*60*originalFs;
            integratedSig(i-1)=integratedSig(i-1)+p*sig(min(inds)-1);
            integratedSig(i)=integratedSig(i)+(1-p)*sig(min(inds)-1);
            %[i p min(inds)]
        end

        if rand>.99
            fprintf('%g%% done\n',100*i/length(integratedSig))
        end
    end
    integratedSig=integratedSig-min(integratedSig);
    integratedSig=integratedSig/max(integratedSig);
    integratedSig=integratedSig*range(sig)+min(sig);

    if doplot
        plot(newMins,integratedSig,'g')
    end
end