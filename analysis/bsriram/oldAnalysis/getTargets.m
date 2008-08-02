function o = getTargets(d, side)

targets = [d.target];

switch side
    case 'l'
        o = (targets==1);
    case 'r'
        o = (targets==3);
    case 'lr'
        o = ones(length(1,targets));
    case 'rl'
        o = ones(length(1,targets));
end

end
