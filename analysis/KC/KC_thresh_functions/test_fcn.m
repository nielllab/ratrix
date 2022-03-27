function [y] = test_fcn(xs)

if nargin==1
    y=gety(gca);
    lbl=[];
elseif nargin==2
    y=gety(gca);
elseif nargin==3
    y=gety(h);
elseif nargin==4
    y=yv;
end


end

