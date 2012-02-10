% http://en.wikipedia.org/wiki/N-sphere#Hyperspherical_coordinates
function test
close all
clc

x=c2s([1 1 1])
y=s2c(x)

x=c2s([0 0 1])
y=s2c(x)

x=s2c([1 pi/4 pi/2])
y=c2s(x)

x=randn(100,3);
y=s2c(c2s(x));
subplot(3,1,1)
plot(x(:,1),x(:,2),'.')
subplot(3,1,2)
plot(y(:,1),y(:,2),'.')
subplot(3,1,3)
z=abs(x-y);
imagesc(z)
if any(z(:)>10^-5)
    error('huh')
end
end

function out = c2s(in)
out = realsqrt(fliplr(cumsum(fliplr(in.^2),2))); % 1:n 2:n ... n-2:n n-1:n n
out(:,end) = 2*acot((out(:,end-1) + in(:,end-1))./in(:,end));
out(:,2:end-1) = acot(in(:,1:end-2)./out(:,2:end-1));
out(isnan(out)) = 0;
end

function x = s2c(x)
% for n dimensions, in has columns r, phi1, phi2, ... phi(n-1)
% 0 <= r, 0 <= phi1...phi(n-2) <= pi, 0 <= phi(n-1) < 2pi

x = cumprod([x(:,1) sin(x(:,2:end))],2) .* [cos(x(:,2:end)) ones(size(x,1),1)];
end
