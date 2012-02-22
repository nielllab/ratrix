function test
x=10*randn(10000,10);

y = abs(s2c(c2s(x))-x);
any(y(:)>10^-9)

x = mod(x,pi);
y = abs(c2s(s2c(x))-x);
any(y(:)>10^-9)

end

function out = c2s(in)
% cartesian to hyperspherical coordinates
% http://en.wikipedia.org/wiki/N-sphere#Hyperspherical_coordinates

out = realsqrt(fliplr(cumsum(fliplr(in.^2),2)));
out(:,end) = mod(2*acot((out(:,end-1) + in(:,end-1))./in(:,end)),2*pi);
out(:,2:end-1) = mod(acot(in(:,1:end-2)./out(:,2:end-1)),pi);
out(isnan(out)) = 0;
end

function x = s2c(x)
% hyperspherical to cartesian coordinates
% http://en.wikipedia.org/wiki/N-sphere#Hyperspherical_coordinates

% for n dimensions, in has columns r, phi1, phi2, ... phi(n-1)
% 0 <= r, 0 <= phi1...phi(n-2) <= pi, 0 <= phi(n-1) < 2pi

%x(:,2:end-1) = mod(x(:,2:end-1),pi);
%x(:,end) = mod(x(:,end),2*pi);
x = cumprod([x(:,1) sin(x(:,2:end))],2) .* [cos(x(:,2:end)) ones(size(x,1),1)];
end

function [dPitch dYaw dRoll] = dBall(dx1,dy1,dx2,dy2)
r = 1;
mouse1 = [0    0 0 -1]; % yaw roll +x(yaw) +x(roll)
mouse2 = [pi/2 0 0  0];

dPitch = 
dYaw = dx1*mouse1(3)/r + dy1*cos(mouse1(3))/r
dRoll = 

    function out = arclen(x)
        out = x/r;
    end
end