function [delta CI]=diffOfBino(x1,x2,n1,n2,method,alpha)
%this function is used to select a method of drawing errorbars for
%estimating the diffrence of binomials
%delta is the expected difference between the two probabilities
%CI is the confidednce interval of the delta, size [2 x N]
%x1 and x2 are vectors of the number of successes
%n1 and n2 are vectors of the number of attempts
%all vectors must have the same length [1 x N] accept the optional alpha
%alpha defaults to 0.05 which is 100*(1-alpha)=95%
%
%Method: choose one:
%
%wald - estimates the variance of the normal distribution, fine for large
%sample size (>30) without extreme values of p
%agrestiCaffo - better for small sample size
%testing - use to validate techniques, including wald
%profileLiklihood - not implimented
%   method by Pradhan, Vivek and Banerjee, Tathagata(2008)
%   Confidence Interval of the Difference of Two Independent Binomial Proportions Using Weighted Profile Likelihood
%   http://pdfserve.informaworld.com/513718_770849120_791517658.pdf
%beals - not implimented
%   %Revisiting beal's confidence intervals for the difference of two binomial proportions
%   %Roths & Tebbs, 2008
%bayes -
%  this is probably equivalent to the Clopper-Pearson interval, which is
%  'exact' and has a few formulations in either binomial, f-distribution or
%  beta distribution. Some papers argue that there are problems with this
%  under certain conditions. (i think near extreme values, close to 0 or 1)
%  especially for small sample sizes
%  the method used applies the beta distribution as done in:
%  Ross (2003) Accurate confidence intervals for binomial proportion and Poisson rate estimation
%
%   you should be able to calculate the joint distribution pdf for both
%   p1 and p2 and find the line p2-p1>delta, such that the sum of the pdf mass
%   above/ below it is 5%.
%
%example: [delta CI]=diffOfBino(60,70,100,100,'wald')
%example: [delta CI]=diffOfBino(60,70,100,100,'bayes')
%example: [delta CI]=diffOfBino(60,70,100,100,'testing')
%example: [delta CI]=diffOfBino(120,140,200,200,'testing')

if ~exist('alpha','var')
    alpha=0.05;
end

if ~(size(alpha)==[1 1])
    error('code accepts only one alpha per function call!')
end

if ~ismember(method,{'testing','wald','agrestiCaffo','bayes','profileLiklihood','beal'})
    method
    error('not a valid method')
end

if ~(length(x1)==length(x2) && length(x2)==length(n1) && length(n1)==length(n2)) || ~(size(x1,1)==1 && size(x2,1)==1 && size(n1,1)==1 && size(n2,1)==1)
    size(x1)
    size(x2)
    size(n1)
    size(n2)
    error('lengths for x1, x2, n1, & n2 must be the same')
end

verbose=0;
if verbose
    disp(sprintf('samples per type: %d / %d - ratio: %2.2g',n1,n2,n1/n2))
end

[p1 c1] =binofit(x1,n1,alpha);
[p2 c2] =binofit(x2,n2,alpha);


switch method
    case 'wald'
        %wald interval
        if ~all(n1>30 & n2>30 & x1>5 & x2>5 & (n1-x1)>5 & (n2-x2)>5)
            error('wald interval is only good for large sample sizes, consider AgrestiCaffo')
        end

        var=(p1.*(1-p1)./n1) + (p2.*(1-p2)./n2);
        delta=p2-p1;
        

        %er=erfinv(1-alpha/2)*sqrt(var);
        %er=erfinv(1-alpha/2)*sqrt(var); % used erf before Jan 1st 2009
        er=norminv(1 - alpha/2, 0, 1).*sqrt(var); % used after looking at ztest.m... is this right?
        %er=norminv(1 - alpha/2, 0, sqrt(var)); % same thing
   
        CI(1,:)=delta-er;
        CI(2,:)=delta+er;  
    case 'agrestiCaffo'
        
        %similar to wald, but deals with small numbers more gracefully
        %add one positive and one negative observation
        x1=x1+1;
        x2=x2+1;
        n1=n1+2;
        n2=n2+2;
        %note: Wilson score interval for 95% confidence is almost identical
        %to adding one more positive and one more negative
        %http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval

        %estimate p
        p1=x1./n1;
        p2=x2./n2;

        var=(p1.*(1-p1)./n1) + (p2.*(1-p2)./n2);
        delta=p2-p1;
        %er=erfinv(1-alpha/2)*sqrt(var); % used erf before Jan 1st 2009
        er=norminv(1 - alpha/2, 0, 1).*sqrt(var); % used after looking at ztest.m... is this right?
        CI(1,:)=delta-er;
        CI(2,:)=delta+er;
    case 'ztest'
        %should be the same as a wald interval
         % looked at ztest.m and 
         % http://stattrek.com/AP-Statistics-4/Test-Difference-Proportion.aspx?Tutorial=AP
         pooled=(p1*n1+p2*n2)/(n1+n2); % pooled sample proportion
         ser=sqrt(pooled*(1-pooled)*((1/n1)+(1/n2))); % another way of getting the standard error, within rounding error of aggresti / wald code
         delta=p2-p1;
         
         % looked at ztest.m
         %z=delta/ser;
         %p = 2 * normcdf(-abs(z),0,1) % a p-value
         crit = norminv(1 - alpha/2, 0, 1) .* ser
         ci = [delta-crit delta+crit];
         
    case 'bayes'
        %from Ross (2003)
        %In MATLAB code this is simply the integral over t of betapdf(t,a1,b1).×betacdf(t-delta,a2,b2), where a1=x1+1,b1=n1?x1+1,a2=x2+1, and b2=n2?x2+1

        % see SPIE'01 paper for proportion posterior distribution in terms
        % of beta functions.
        for j=1:length(x1)
            a1=x1(j)+1;
            b1=n1(j)-x1(j)+1;
            a2=x2(j)+1;
            b2=n2(j)-x2(j)+1;
            step=0.01; %evaluated every one percent -- this limits fidelity of CI, but saves compute time alot
            deltas=[-.5:step:.5];  % a reasonable range if best is 100% and worst is 50% performance
            pGreaterThanDelta=zeros(1,length(deltas));
            for i=1:length(deltas)
                %prob of first one * prob of 2nd one greater than that
                f=@(x)betapdf(x,a1,b1).*betacdf(x+deltas(i),a2,b2); %make the function
                pGreaterThanDelta(i) = quadl(f,0,1,10^-6,0); %evaluate the integral from 0 to 1, estimation is faster than sum
                %Ross has shortcuts to shorten the range of the integral, i think for speed, but they are kindof hack
            end
            indexCI=[min(find(pGreaterThanDelta>=alpha))  max(find(pGreaterThanDelta<=(1-alpha)))]; %index of lower confidence bound
            indexML=min(find(pGreaterThanDelta>.5)); %index of most likely difference
            CI(:,j)=deltas(indexCI);
            delta(j)=deltas(indexML);
        end

    case 'testing'
        samps=5*10^4;
        numBins=201;

        
        %does this assume an equal number of samples from the two
        %distributions!? No, it preserves n1 & n2.
        r1 = binornd(n1,p1,[1 samps])/n1;
        r2 = binornd(n2,p2,[1 samps])/n2;
        deltaSamps=r2-r1;
        %what did this assume:  that we knew the REAL p from our estimate
        %(but we don't, its only the single best guess)
        %better would be to use the prob distribution of possible p's that
        %generated the data, for this, see bayes

        figure
        if 0 % seeRaw
            subplot(3,1,1); hist(r1,numBins); axis([0 1 0 samps/5])
            subplot(3,1,2); hist(r2,numBins); axis([0 1 0 samps/5])
            subplot(3,1,3);
            meanDelta=mean(deltaSamps)
            modeDelta=mode(deltaSamps)
        end
        
        
        [count, vals]=hist(deltaSamps,numBins);
        cpdf=cumsum(count);

        %find the index of the top and bottom of the distribution
        ciTop=max(find(cpdf<=(1-alpha/1)*samps)); %should I divide alpha by 2 here? it seems so, but if I do then the EQN below has to dive alpha by 8 instead of 2, and that make little sense...
        ciBottom=min(find(cpdf>=alpha/1*samps));
        CI=vals([ciBottom,ciTop])


        hist(deltaSamps,numBins)
        hold on
        hEmperic=plot(vals([ciTop ciBottom]),[0,0], '*r');

        [x,i]=max(count);
        empiric_delta=vals(i)
        analytic_delta=p2-p1
        delta=analytic_delta;

        var=(p1*(1-p1)/n1) + (p2*(1-p2)/n2)
        %CIwald=(p2-p1)+(erfinv(1-alpha/2)*sqrt(var)*[-1 1]) % old wrong
        CIwald=(p2-p1)+(norminv(1 - alpha/2, 0, 1)*sqrt(var)*[-1 1]) 
        hWald=plot(CIwald,[-100,-100], '^b');



        %from Ross (2003)
        %In MATLAB code this is simply the integral over t of betapdf(t,a1,b1).×betacdf(t-delta,a2,b2), where a1=x1+1,b1=n1?x1+1,a2=x2+1, and b2=n2?x2+1

        % see SPIE'01 paper for proportion posterior distribution in terms
        % of beta functions.
        a1=x1+1;
        b1=n1-x1+1;
        a2=x2+1;
        b2=n2-x2+1;
        fidelity=0.01; %evaluated every one percent
        deltas=[-.5:fidelity:.5];  % a reasonable range if best is 100% and worst is 50% performance
        pGreaterThanDelta=zeros(1,length(delta));
        for i=1:length(deltas)
            %prob of first one * prob of 2nd one greater than that
            f=@(x)betapdf(x,a1,b1).*betacdf(x+deltas(i),a2,b2); %make the function
            pGreaterThanDelta(i) = quadl(f,0,1,10^-6,0); %evaluate the integral, estimation is faster than sum
        end
        indexCI=[min(find(pGreaterThanDelta>=alpha))  max(find(pGreaterThanDelta<=(1-alpha)))]; %index of lower confidence bound
        indexML=min(find(pGreaterThanDelta>.5)); %index of most likely difference
        CIbayes=deltas(indexCI)
        delta=deltas(indexML);
        hBayes=plot(CIbayes,[-150,-150], '^g');
        legend([hEmperic hWald hBayes], {'Emperic', 'Wald', 'Bayes'})
        
        if 1 %nice bayes result plot
            figure
            plot(deltas,pGreaterThanDelta,'k')
            hold on
            plot([deltas(indexCI(1)) deltas(indexCI(1))],[0 pGreaterThanDelta(indexCI(1))],'r')
            plot([deltas(indexML) deltas(indexML)],[0 pGreaterThanDelta(indexML)],'b')
            ylabel('probability (p2<p1+delta)')  %p2-p1<delta
            xlabel('difference in % correct')
            set(gca, 'XTickLabel', {'-50%','-30%','-10%','10%','30%','50%'});
            set(gca, 'XTick', [-.5: .2 : .5]);
            text(-.4,1.1,sprintf('It is most likely that p2>p1 by %2.2g%% performance',100*delta),'color',[0 0 .9])
            text(-.4,1.05,sprintf('There is a %d%% chance that p2>p1 by at least %2.2g%% performance',100*(1-alpha),100*deltas(indexCI(1))),'color',[.9 0 0])
            axis([minmax(deltas) 0 1.2])
%             figure(gcf-1)
        end

        if 0 %slow confirmation tests for bayes, bayes explanation plot
            figure
            step=10^-6;
            t=0:step:1;
            bp=betapdf(t,a1,b1);
            bc=betacdf(t+delta,a2,b2);
            xx=betapdf(t,a1,b1).*betacdf(t+delta,a2,b2); %prob of first one * prob of 2nd one greater than that
            plot(xx,'k')
            hold on
            plot(bp,'r')
            plot(bc,'g')
            pGreaterThanDelta=sum(xx)*step;
        end

    case 'beal'
        %Revisiting beal's confidence intervals for the difference of two binomial proportions
        %Roths & Tebbs, 2008
        %http://www.stat.sc.edu/~tebbs/R_code_Beal.htm
        %http://www.informaworld.com/smpp/content~content=a759223385?words=roths&hash=2375993252
        error('not yet')
    case 'profileLiklihood'
        error('not yet')
        %   method by Pradhan, Vivek and Banerjee, Tathagata(2008)
        %   Confidence Interval of the Difference of Two Independent Binomial Proportions Using Weighted Profile Likelihood
        %   http://pdfserve.informaworld.com/513718_770849120_791517658.pdf
end

