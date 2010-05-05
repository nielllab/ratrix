function cfun=fitXCModel(data,rng)
test=false;
if test
    clc
    close all
    
    data=rand(1,20);
    data=[repmat(data,1,25) data(1:18)];
    data=diff(xcorr(data));
    data=data(ceil(length(data)/2) : end);
    data=data-mean(data);
    data=data/max(data);
    
    plot(data,'r')
    hold on
end

n=length(data);

if false
    model=fittype(sprintf('XCModel(x,%g,p)',n));
    
    if ~all(cellfun(@strcmp,coeffnames(model),{'p'}'))
        coeffnames(model)
        error('coeff name error')
    end
    
    lower=[2];
    upper=[Inf];
    options=fitoptions(model);
    options=fitoptions(options,'Lower',lower,'Upper',upper);
    
    cfun = fit((1:n)',data',model,options);
    
    if test
        plot(cfun,'g',1:n,data,'k')
    end
else
    tries=zeros(1,n);
    if exist('rng','var') && ~isempty(rng)
        rng=max(rng(1),2):min(rng(2),n);
    else
        rng=2:n;
    end
    for tp=rng
        tries(tp)=max(xcorr(data,XCModel(1:n,n,tp),'coeff')); %limiting to 100 lags really broke things -- why?
        if rand>.99
            fprintf('%g %% done\n',100*(tp-rng(1))/diff([rng(1) rng(end)]))
        end
    end
    
    [junk order]=sort(tries,'descend');
    
    debug=false;
    if debug
        plot(tries)
    elseif test
        plot(XCModel(1:n,n,order(1)),'g')
    end
    
    cfun=order(1);
end
end