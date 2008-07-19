function out=isVectorOfType(vect,type)
    out = 1;
    for i = 1:length(vect)
        out  = out && isa(vect{i},type);
    end