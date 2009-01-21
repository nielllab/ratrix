function ip=getIPAddress
ip='';

if IsWin
    [a b]=dos('ipconfig');
    [matches tokens] = regexpi(b, '(132.239.158.\d{2,3})', 'match', 'tokens');
    if ~isempty(tokens) && length(tokens) == 1
        ip = tokens{1}{1};
    else
        error('failed to retrieve exact IP address for this machine');
    end        
else
    error('only works on windows')
end
