%%%written by Elliott Abe & Phil Parker, 2017
%%%takes in an image, masks an ellipsoid area based on selection
function [ExtractPart,P,t] = neuropilEllipse(resp,pfile)

satis=0; %%%allows reselection if unsatisfied
while satis==0
    figure; subplot(1,2,1); colormap jet
    title('select center and right (short) axis of ellipse')
    respimg = imresize(mat2im(resp,jet,[-0.01 0.05]),0.5);
    imshow(respimg);set(gca,'ytick',[],'xtick',[]);hold on;
    for i = 1:2
        [dy(i) dx(i)] = ginput(1);
        plot(dy(i),dx(i),'g*'); 
        dy(i)=dy(i)*2;dx(i)=dx(i)*2;
        P(i,:) = round([dx(i),dy(i)]);
    end
    hold off;respimg = mat2im(resp,jet,[-0.01 0.05]);
    imshow(respimg);set(gca,'ytick',[],'xtick',[]);hold on;
    t = atan2(dx(2)-dx(1),dy(2)-dy(1))-pi/2;
    alength = sqrt((dx(2)-dx(1))^2+(dy(2)-dy(1))^2);blength = 2*alength;
    P(3,:) = round([dx(1)+blength*sin(t),dy(1)+blength*cos(t)]);
    plot(P(:,2),P(:,1),'g*')
    t = t + pi/2;
    % P(3,:) = [dx(1)+10,dy(1)];
    % t= atan2(abs(det([P(3,:)-P(1,:);P(2,:)-P(1,:)])),dot(P(3,:)-P(1,:),P(2,:)-P(1,:)));

    % t = pi/4;
    N = 100;        %default: 100 points
    th = [0 2*pi];  %default: full ellipse
    th = linspace(th(1),th(2),N);

    rx = sqrt((P(1,1)-P(2,1))^2+(P(1,2)-P(2,2))^2);
    ry = 2*rx;
    %calculate x and y points
    x = dy(1) + rx*cos(th)*cos(t) - ry*sin(th)*sin(t);
    y = dx(1) + rx*cos(th)*sin(t) + ry*sin(th)*cos(t);
    plot(x,y,'g.');

    subplot(1,2,2)
    ExtractPart = zeros(size(resp));
    [x1, y1] = meshgrid(1:size(ExtractPart,2),1:size(ExtractPart,1));
    % xgrid=(x1-dx(1)); ygrid=(y1-dy(1));
%     xgrid=(x1); ygrid=(y1);
%     x1 = xgrid; y1=ygrid;
    ExtractPart((((cos(t)*(x1-dy(1))+sin(t)*(y1-dx(1))).^2)/rx.^2+(((sin(t)*(x1-dy(1))-cos(t)*(y1-dx(1)))).^2)/ry.^2<1)) = 1;

    respimg = mat2im(ExtractPart,jet,[0.1 0.9]);
    imshow(respimg);set(gca,'ytick',[],'xtick',[]);hold on;plot(x,y,'g.');
    
    satis = input('satisfied? 0=no,1=yes: ');
end

if exist('pfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',pfile,'-append');
end       
end
