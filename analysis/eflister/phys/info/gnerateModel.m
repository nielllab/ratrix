function gnerateModel(dims,stims,trigs)
    numBins=200;

    filtStims=stims*dims';
    filtTrigs=trigs*dims';

    if size(dims,1)>1
        subplot(,1,1)
        plot(filtStims(1),filtStims(2),'k.')
        hold on
        plot(filtTrigs(1),filtTrigs(2),'r.')
        
        subplot(,1,2)
        
        
    else
        subplot(,1,1)
        [h c]=hist(filtStims,numBins);
        hSpk=hist(filtTrigs,c);
        plot(h,'k')
        hold on
        plot(hSpk,'r')
        
        subplot(,1,2)
        
    end
    
    
    
    
    p(stim|resp)p(resp)/p(stim)=p(resp|stim)
    
