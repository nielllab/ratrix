function o = getResponses(d,side)
% d is a compressedData file
o = zeros(1,length(d));
switch side
    case 'l'
        response = [1 0 0];
    case 'r'
        response = [0 0 1];
end

for i = 1:length(d)
    o(i) = all(d(i).response == response);
end
end