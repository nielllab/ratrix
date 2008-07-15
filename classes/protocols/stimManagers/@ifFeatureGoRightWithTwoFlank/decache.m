function s=decache(s)
%method to deflate stim patches and flush lut

s=deflate(s);
s=flushLUT(s);

