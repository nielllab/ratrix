function d=display(s)
    d=[s.name ':\t' '(cached: ' num2str(~isempty(s.clip)) ')\t' s.description];
    
    