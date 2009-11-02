function out=almostEqual(x,y)
out = abs(1-double(x)./double(y)) < .0000001;