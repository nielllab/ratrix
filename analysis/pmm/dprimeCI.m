function [CI details]=dprimeCI(x, dprimeMethod, alpha)

if ~exist('x', 'var')
    x.hits=[5 8];
    x.misses=[5 2];
    x.FAs=[5 5];
    x.CRs=[5 5];
end

if ~exist('dprimeMethod', 'var') || isempty(dprimeMethod)
    dprimeMethod='dprimeMCMC';

end

if ~exist('alpha', 'var') || isempty(alpha)
    alpha=.05;
end


switch dprimeMethod
    case 'dprimeMCMC'


        
        whichParams=[1 1 1 1 1 1];
        whichParams=[0 0 0 0 0 0]; %turn off plotting
        %d h f k c b
        N = length(x.hits(:));
        names=num2cell(num2str(1:N));
        names(strcmp(names, ' '))=[]; %remove spaces


        D.ndatasets=N;  %he number of data sets to be analyzed.
        D.sdt=[x.hits(:), x.FAs(:), x.misses(:), x.CRs(:)] %This is a matrix with the rows representing data sets, and the columns representing signal detection data counts. The four columns correspond to hits, false alarms, misses, and correct rejections respectively.
        D.nsamples=1000; %500; is the number of posterior samples to generate.
        D.nbins=50; %  is the number of bins to use in drawing histograms of the posterior densities.
        D.labels=names;   %  is a character array with a string label for each dataset.
        D.linecolor=jet(N); % {'r','g','b','m','k','k','k','k'};  %  is a character array with a Matlab color for each data set, using the standard Matlab plot colors.
        D.linestyle= repmat({'-'},1,N); %is a character array with a Matlab color for each data set, using the standard Matlab line styles.
        D.linewidth= 2*ones(1,N); %is an array of positive numbers containing line widths for each data set.
        D.dcheck=whichParams(1)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the d parameter should be analyzed.
        D.hcheck=whichParams(2)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the h parameter should be analyzed.
        D.fcheck=whichParams(3)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the f parameter should be analyzed.
        D.kcheck=whichParams(4)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the k parameter should be analyzed.
        D.ccheck=whichParams(5)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the c parameter should be analyzed.
        D.bcheck=whichParams(6)*ones(1,N); %is a vector of 0 and 1 entries for each data set, indicating whether or not the b parameter should be analyzed.

        prevDir=pwd;
        cd(fullfile(getRatrixPath, 'analysis', 'matbugs', 'BayesSDT')); 
        [samples mcmcStats]=BayesSDT(D);
        cd(prevDir); %return to where you were

        percentileInd=round(D.nsamples*([alpha 1-alpha]));
        returnStatistics=fields(samples);
       
        for i=1:N
            for j=1:length(returnStatistics)
                sorted=sort(samples.(returnStatistics{j})(1, :, i), 'ascend');
                CI.(returnStatistics{j})(i, 1:2)=sorted(percentileInd);
            end
        end

        details.samples=samples;
        details.mcmcStats=mcmcStats;
        

    otherwise
        dprimeMethod
        error('bad method');
end