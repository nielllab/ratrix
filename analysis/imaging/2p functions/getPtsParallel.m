function [dF icacorr filling cellImg usePts] = getPtsParallel(dfofInterp,pts,w,p,mn,sigma,showImg)

%%% check points are in boundaries
x=pts(p,1); y= pts(p,2); npts=p;
if x<1,    x=1; end
if y<1,    y=1; end
if x>size(dfofInterp,1),    x=size(dfofInterp,1);  end
if y>size(dfofInterp,2),    y=size(dfofInterp,2);  end

xmin=max(1,x-w); ymin=max(1,y-w);
xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
if xmin==1,    xmax = 2*w+1; end
if ymin ==1,    ymax = 2*w+1; end
if xmax==size(dfofInterp,1);    xmin = xmax-2*w; end
if ymax==size(dfofInterp,2);    ymin = ymax-2*w; end

%%% grab ROI around points
roi = dfofInterp(xmin:xmax,ymin:ymax,:);
obs =reshape(roi,size(roi,1)*size(roi,2),size(roi,3));

%%% calculate local correlation map (how correlated is each point in ROI to the selected point?)
cc=0;
for f= 1:size(dfofInterp,3);
    cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
end
cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));

%%% chose an ROI mask based on cc
roicc = cc>0.75;
dFcc = obs'*roicc(:)/sum(roicc(:));

%%% do ICA over increasing # of components
%%% use a try catch because sometimes there aren't that many components
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


if size(A,1)==1   %%% if you can't even get one component
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
        mx = max(W(i,:));
         filling = sum(W(i,:)>0.2*mx)/length(W(i,:));
        if abs(min(W(i,:)))>0.75*mx || filling > 0.5  %%% get rid of ones that are biphasic or fill the whole ROI
            roicorr(i)=0;
        end
        range = max([0.01 abs(min(W(i,:))) abs(max(W(i,:)))]);
        %         title(sprintf('%f',roicorr(i)));
        %         subplot(3,6,i+12)
        %         imagesc(reshape(W(i,:),size(roi,1),size(roi,2)),[-range range]);
    end
    
    [icacorr ind] = max(roicorr);
      mx = max(W(ind,:));
      filling = sum(W(ind,:)>0.2*mx)/length(W(ind,:));
    
   
end

%%% cells = 0.8, axons = 0.7
if icacorr>0.8 ;
    %dF(npts,:) = icasig(ind,:)*max(A(:,ind));
    
    thresh = W(ind,:); thresh(thresh< -0.2*mx)=-0.2*mx; thresh(thresh>0 & thresh<0.1*mx)=0;
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

if  showImg
    figure
    subplot(2,3,1:3);
    hold on
    plot(dFcc,'g');  plot(dF(1,:));
     legend('raw dfof','ica dfof')
    subplot(2,3,4)
    imagesc(cc,[0 1]); colormap jet
     title(sprintf('corr coef %0.2f',icacorr));
    subplot(2,3,5)
    % imagesc(sigma(xmin:xmax,ymin:ymax),[0 1]);
    plot(cc(:),W(ind,:)','.');
    title(sprintf('spearman %0.2f',corr(cc(:),W(ind,:)','type','spearman')));
    subplot(2,3,6)
    %     range = max([0.01 abs(min(min(cellImg(1,:,:)))) abs(max(max(cellImg(1,:,:))))]);
    %     imagesc(squeeze(cellImg(1,:,:)),[-range range]);
    %
    range = max([0.01 abs(min(W(ind,:)))  abs(max (W(ind,:)))]);
    imagesc(reshape(W(ind,:),size(cc,1),size(cc,2)),[-range range]); colormap jet    
   title(sprintf('filling %0.2f',filling));
    drawnow
end