function s=setMaxWidthAndHeight(s,width,height)
if iswholenumber(width) && all(size(width)==1) && width>0
    s.maxWidth=width;
else
    width
    error('bad width')
end

if iswholenumber(height) && all(size(height)==1) && height>0
    s.maxHeight=height;
else
    height
    error('bad height')
end
