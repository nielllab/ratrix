function out=authorCheck(r,author) %stupid that all functions in an object directory have to be methods (we don't need ratrix for this)
    if strcmp(author,'edf') || strcmp(author,'pmm') || strcmp(author,'ear') || strcmp(author,'hvo') || strcmp(author,'pr') || strcmp(author,'dfp') || strcmp(author,'ratrix') || strcmp(author,'bs')
        out=1;
    else
        out=0;
        warning('author must be one of edf, pmm, ear, hvo, pr, dfp, bs')
    end