function out=doubleSlashes(in)
if ischar(in) && isvector(in)
    out='';
    numSlashes=0;
    for i=1:length(in)
        if in(i)=='\'
            numSlashes=numSlashes+1;
            out(end+1)='\';
        end
        out(i+numSlashes)=in(i);
    end
else
    error('in must be a character vector (a string)')
end