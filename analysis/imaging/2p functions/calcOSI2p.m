function [osi preftheta]= calcOSI2p(R,dsi);
theta = 0:(2*pi/length(R)):(2*pi);
if dsi
     theta=theta(1:end-1);
else
    theta=2*theta(1:end-1);  %%% double for orientation
end
%R(R<0)=0;
if min(R)<0
    R = R-min(R);
end
%R
osi = sum(R.*exp(sqrt(-1)*theta'))/sum(R);

    th = angle(osi);
    th(th<0) = th(th<0)+2*pi;
    if dsi
        preftheta=th;
    else
        preftheta=0.5*th;
    end

osi = abs(osi);
