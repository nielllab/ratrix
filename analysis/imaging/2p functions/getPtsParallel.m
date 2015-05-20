function [dF icacorr filling cellImg usePts] = getPtsParallel(dfofInterp,pts,w,p,mn,sigma,showImg)
x=pts(p,1); y= pts(p,2); npts=p;
    %w=12; corrThresh=0.75; neuropilThresh=0.5;

    xmin=max(1,x-w); ymin=max(1,y-w);
    xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
    
   
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
    
    
    [icasig A W] = fastica(obs,'numOfIC',2,'lastEig',3,'g','skew');
    try
        [icasig(3,:) A(:,3) W(3,:)] = fastica(obs,'numOfIC',1,'lastEig',2,'g','skew');
    catch
        icasig(3,:)=0; A(:,3)=0; W(3,:)=0;
    end
        try
        [icasig(4:6,:) A(:,4:6) W(4:6,:)] = fastica(obs,'numOfIC',3,'lastEig',4,'g','skew');
    catch
        icasig(4:6,:)=0; A(:,4:6)=0; W(4:6,:)=0;
    end
    
    
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
    %%% cells = 0.8
    if icacorr>0.75 & (sum(W(ind,:)>0.25*mx)/length(W(ind,:)))<0.3;
        %dF(npts,:) = icasig(ind,:)*max(A(:,ind));
        
        thresh = W(ind,:); thresh(thresh< -0.25*mx)=-0.25*mx; thresh(thresh>0 & thresh<0.001*mx)=0;
        dF(1,:) = obs'*thresh' * max(A(:,ind));
        roi = zeros(size(sigma));
        roi(xmin:xmax,ymin:ymax) =reshape(thresh,size(cc,1),size(cc,2));
        usePts = find(roi>0.25*mx);
        coverage(usePts)=p;
        cellImg(1,:,:) = roi(xmin:xmax,ymin:ymax);
        
    else
        dF(1,:)=0;
        cellImg(1,:,:) =zeros(size(cc));
        usePts=[];
    end
    
    w=12;
    xmin=max(1,x-w); ymin=max(1,y-w);
    xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
    cc=0;
    for f= 1:size(dfofInterp,3);
        cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
    end
    cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));
    
%     subplot(3,6,3)
%     imagesc(cc,[0 1])
%     
%     subplot(3,6,1);
%     imagesc(sigma(xmin:xmax,ymin:ymax),[0 1]);
    
  % close(gcf)
    if mean(dF(1,:))~=0 & showImg
        figure
        subplot(2,3,1:3);
        hold on
        plot(dFcc,'g');
        ylim([-1 5])
        plot(dF(1,:));
        subplot(2,3,4)
        imagesc(cc,[0 1]);
        subplot(2,3,5)
        imagesc(sigma(xmin:xmax,ymin:ymax),[0 1]);
        subplot(2,3,6)
        range = max([0.01 abs(min(min(cellImg(1,:,:)))) abs(max(max(cellImg(1,:,:))))]);
        imagesc(squeeze(cellImg(1,:,:)),[-range range]);
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