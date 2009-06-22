function t=setRenderMode(t, value)

if ismember(value,'symbolicFlankerFromServerPNG')
    t.renderMode=value;
else
    renderMode=renderMode
    error('renderMode is only approved to be changed from X to symbolicFlankerFromServerPNG at this point')
end