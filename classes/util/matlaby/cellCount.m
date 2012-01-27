function out=cellCount(argN)
out=mat2cell(argN(1):argN(2),1,ones(1,argN(2)-argN(1)+1));