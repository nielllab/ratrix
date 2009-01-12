function pass=checkFitRF(sm,fitRF)
%this function only checks the the second, not the first

pass=0;

if ~isempty(fitRF)
    switch fitRF.fitMethod
        case 'elipse'
       %nothing to do
           
        otherwise
            fitRF.fitMethod
            error('bad fit method');
    end
    
     if  ~(ischar(fitRF.which) & ismember(fitRF.which,{'last'}))
                error ('which receptive fields must be last')
     end
     
     if ~(all(size(fitRF.medianFilter)==[3 3]) & islogical(fitRF.medianFilter))
         error('medianFilter must be logical sized [3 3]');
     end

     if ~(isnumeric(fitRF.alpha) & fitRF.alpha>0 & fitRF.alpha<1)
         error('alpha must be between 0 and 1');
     end

     if ~(iswholenumber(fitRF.numSpotsPerSTA))
         error('numSpotsPerSTA must be a whole number');
     end

     if ~(iswholenumber(fitRF.spotSizeInSTA) | isempty(fitRF.spotSizeInSTA))
         error('spotSizeInSTA must be a whole number or empty');
     end

end

pass=1;
