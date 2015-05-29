function [dF icacorr filling cellImg usePts] = getPtsParallel(dfofInterp,pts,w,p,mn,sigma,showImg)
x=pts(p,1); y= pts(p,2); npts=p;
if x<1
    x=1;
end
if y<1
    y=1;
end
if x>size(dfofInterp,1)
    x=size(dfofInterp,1)
end
if y>size(dfofInterp,2)
    y=size(dfofInterp,2);
end

%w=12; corrThresh=0.75; neuropilThresh=0.5;

xmin=max(1,x-w); ymin=max(1,y-w);
xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
if xmin==1
    xmax = 2*w+1;
end
if ymin ==1
    ymax = 2*w+1;
end
if xmax==size(dfofInterp,1);
    xmin = xmax-2*w;
end
if ymax==size(dfofInterp,2);
    ymin = ymax-2*w;
end
roi = dfofInterp(xmin:xmax,ymin:ymax,:);
obs =reshape(roi,size(roi,1)*size(roi,2),size(roi,3));
cc=0;
for f= 1:size(dfofInterp,3);
    cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
end
cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));
%      figure
%      subplot(3,6,2);
%     imagesc(cc,[0 1])
roicc = cc>0.75;
dFcc = obs'*roicc(:)/sum(roicc(:));



try
    [icasig(1,:) A(:,1) W(1,:)] = fastica(obs,'numOfIC',1,'lastEig',1,'g','skew','verbose','off');
catch
    icasig(1,:)=0; A(:,1)=0; W(1,:)=0;
end

try
    [icasig(2:3,:) A(:,2:3) W(2:3,:)] = fastica(obs,'numOfIC',2,'lastEig',2,'g','skew','verbose','off');
catch
    icasig(2:3,:)=0; A(:,2:3)=0; W(2:3,:)=0;
end

try
    [icasig(4:6,:) A(:,4:6) W(4:6,:)] = fastica(obs,'numOfIC',3,'lastEig',3,'g','skew','verbose','off');
catch
    icasig(4:6,:)=0; A(:,4:6)=0; W(4:6,:)=0;
end

try
    [icasig(7:10,:) A(:,7:10) W(7:10,:)] = fastica(obs,'numOfIC',4,'lastEig',4,'g','skew','verbose','off');
catch
    icasig(7:10,:)=0; A(:,7:10)=0; W(7:10,:)=0;
end

try
    [icasig(11,:) A(:,11) W(11,:)] = fastica(obs,'numOfIC',1,'lastEig',1,'verbose','off');
catch
    icasig(11,:)=0; A(:,11)=0; W(11,:)=0;
end

try
    [icasig(12:13,:) A(:,12:13) W(12:13,:)] = fastica(obs,'numOfIC',2,'lastEig',2,'verbose','off');
catch
    icasig(12:13,:)=0; A(:,12:13)=0; W(12:13,:)=0;
end

try
    [icasig(14:16,:) A(:,14:16) W(14:16,:)] = fastica(obs,'numOfIC',3,'lastEig',3,'verbose','off');
catch
    icasig(14:16,:)=0; A(:,14:16)=0; W(14:16,:)=0;
end

try
    [icasig(17:20,:) A(:,17:20) W(17:20,:)] = fastica(obs,'numOfIC',4,'lastEig','verbose','off');
catch
    icasig(17:20,:)=0; A(:,17:20)=0; W(17:20,:)=0;
end





if size(A,1)==1
    icacorr=0; filling=0;
else
    for i = 1:size(A,2)
        
        range = max([0.01 abs(min(A(:,i))) abs(max(A(:,i)))]);
        if mean(A(ceil(0.5*(2*w+1)^2),i))<0
            A(:,i) = -A(:,i);
            W(i,:) = -W(i,:);
            icasig(i,:) = -icasig(i,:);
        end
        %         subplot(3,6,i+6);
        %         imagesc(reshape(A(:,i),size(roi,1),size(roi,2)),[-range range]);
        %roicorr = sum(A(:,i).*cc(:))/sqrt(sum(A(:,i).*A(:,i))*sum(cc(:).*cc(:)))
        r = corrcoef(W(i,:),cc(:));
       % roicorr(i) = r(1,2);
        roicorr(i) = r(1,2);
        if abs(min(W(i,:)))>0.75*max(W(i,:))
            roicorr(i)=0;
        end
        range = max([0.01 abs(min(W(i,:))) abs(max(W(i,:)))]);
        %         title(sprintf('%f',roicorr(i)));
        %         subplot(3,6,i+12)
        %         imagesc(reshape(W(i,:),size(roi,1),size(roi,2)),[-range range]);
    end
    
    [icacorr ind] = max(roicorr);
    mx = max(W(ind,:));
    filling = (sum(W(ind,:)>0.25*mx)/length(W(ind,:)));
end

%%% cells = 0.8, axons = 0.7
if icacorr>0.8 & (sum(W(ind,:)>0.25*mx)/length(W(ind,:)))<0.35;
    %dF(npts,:) = icasig(ind,:)*max(A(:,ind));
    
    thresh = W(ind,:); thresh(thresh< -0.2*mx)=-0.2*mx; thresh(thresh>0 & thresh<0.001*mx)=0;
    dF(1,:) = obs'*thresh' * max(A(:,ind));
    roi = zeros(size(sigma));
    roi(xmin:xmax,ymin:ymax) =reshape(thresh,size(cc,1),size(cc,2));
    usePts = find(roi>0.25*mx);
    coverage(usePts)=p;
    cellImg(1,:,:) = roi(xmin:xmax,ymin:ymax);
    
else
    dF(1,:)=0;
    cellImg(1,:,:) = zeros(size(cc));
    usePts=[];
end

w=12;
xmin=max(1,x-w); ymin=max(1,y-w);
xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
% cc=0;
% for f= 1:size(dfofInterp,3);
%     cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
% end
% cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));

%     subplot(3,6,3)
%     imagesc(cc,[0 1])
%
%     subplot(3,6,1);
%     imagesc(sigma(xmin:xmax,ymin:ymax),[0 1]);

% close(gcf)
%if mean(dF(1,:))~=0 & showImg
    if  showImg
    figure
    subplot(2,3,1:3);
    hold on
    plot(dFcc,'g');
    ylim([-1 5])
    plot(dF(1,:));
    subplot(2,3,4)
    imagesc(cc,[0 1]);
    subplot(2,3,5)
   % imagesc(sigma(xmin:xmax,ymin:ymax),[0 1]);
   plot(cc(:),W(ind,:)','.');
   title(sprintf('%0.2f',corr(cc(:),W(ind,:)','type','spearman')));
    subplot(2,3,6)
%     range = max([0.01 abs(min(min(cellImg(1,:,:)))) abs(max(max(cellImg(1,:,:))))]);
%     imagesc(squeeze(cellImg(1,:,:)),[-range range]);
%     
        range = max([0.01 abs(min(W(ind,:)))  abs(max (W(ind,:)))]);
    imagesc(reshape(W(ind,:),size(cc,1),size(cc,2)),[-range range]);
    
    title(sprintf('%f',icacorr));
end
%     roi = zeros(size(sigma));
%     roi(xmin:xmax,ymin:ymax) =cc;
%
%     subplot(3,3,3);
%     imagesc(roi,[0 1]);
%     axis equal
%
%     subplot(2,2,2);
%     imagesc(roi>corrThresh); axis equal
%     usePts{npts} = find(roi>corrThresh);
%     if length(usePts{npts})<=6
%         dF(npts,:) = 0;
%         coverage(usePts{npts})=-20;
%     else
%     dF(npts,:) = squeeze(mean(dfReshape(usePts{npts},:),1));
%     coverage(usePts{npts})=npts;
%     end


%     subplot(2,2,3);
%     imagesc(cc,[0 1]);
%