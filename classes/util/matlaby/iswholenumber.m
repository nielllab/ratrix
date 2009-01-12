function pass=iswholenumber(x)
%returns true for whole numbers (negative, 0, positive)
%acts similar to isinteger, but okay on class doubles 
%for matrices operates on each element

pass=mod(x,1)==0;

