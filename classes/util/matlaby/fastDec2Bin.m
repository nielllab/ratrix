function s=fastDec2Bin(d)

chk=false;
if chk %this takes significant time, may want to assume input OK
    if ~isscalar(d) || ~isinteger(d) || d<0 || d>=2^8
        error('d must be scalar integer 0<=d<=255')
    end
end

s=char(rem(floor(d./pow2(7 : -1 : 0)),2)+'0'); %pow2 slightly faster than realpow(2,.)

end