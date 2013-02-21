function colors = getUniformSpectrum(in)
if ~all(0<=in & in<=1)
    error('0 <= [in] <= 1')
end

if true
    %perceptually uniform blue -> red, constant luminance/chroma
    %note not truly perceptually uniform, cuz at a given C and L, some H's are out of gamut (see fig 5 http://magnaview.nl/documents/MagnaView-M_Wijffelaars-Generating_color_palettes_using_intuitive_parameters.pdf)
    colors = [repmat([70 100],length(in),1) 360*interp1([0 1], [.87 .05], in)'];
else %increasing chroma, constant luminance, red hue
    colors = [50*ones(length(in),1) interp1([0 1], [0 100],in)' .05*360*ones(length(in),1)];
end
colors = applycform(applycform(colors,makecform('lch2lab')),makecform('lab2srgb'));
end