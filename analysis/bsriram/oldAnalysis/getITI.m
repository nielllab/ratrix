function o = getITI(d)
t1 = [d.date];
t2 = [0 t1]; t2(end) = [];
o = t1-t2;

% The first value is likely to be wrong. Set it to the next value.
o(1) = o(2);
end
