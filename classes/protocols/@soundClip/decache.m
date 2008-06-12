function c=decache(c)
    if ~isempty(c.clip)
        %disp(sprintf('decaching %s', sprintf(display(c))));
        c.clip=[];
    end