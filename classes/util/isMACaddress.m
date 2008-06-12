function out=isMACaddress(s)
out=ischar(s) && length(s)==12;
if out
    try
        hex2dec(s);
    catch
        out=false;
    end
end