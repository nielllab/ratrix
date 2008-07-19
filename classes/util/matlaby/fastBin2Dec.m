function x=fastBin2Dec(s)
if ~ischar(s) || ~ isvector(s) || any(s~='0' & s~='1') || length(s)>52 %matlab's bin2dec doesn't want more than 52, but why not floor(log2(realmax))?  maybe cuz eps(realmax) is too sparse?
    error('must be character vector with only ''0'' and ''1'' with 52 or fewer elements'); 
end
x = sum([s - '0'] .* pow2(length(s)-1:-1:0));