function [h,p,stats] = cochranqtest(X,alpha)
% COCHRANQTEST - Cochran's Q Test on dichotomous data for k-related samples 
%   H = COCHRANQTEST(X) performs the non-parametric Cochran's Q test on the
%   hypothesis that the K columns of N-by-K matrix have the same number of
%   successes and failures.  H==0 indicates that the null hypothesis cannot
%   be rejected at the 5 significance level.  H==1 indicates that the null
%   hypothesis can be rejected at the 5% level.
%
%   X should contain dichotomous values (pass/fail, success/failure,
%   left/right, yes/no, true/false, 0/1, etc.), where one value indicates a
%   "pass" and the other value denotes a "fail". The K columns correspond
%   to K related observations; the N rows correspond to N distinct cases.
%   Note that the coding of "pass" and "fail" does not matter. The highest
%   value will be treated as a "pass". Also note that cases that comprise
%   only passes or only failures do not have an effect on the test
%   statistic.
%
%   X can be cell array of (two different) strings (e.g., 'YES' and 'NO').
%   
%   H = COCHRANQTEST(...,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.  ALPHA must  be a scalar between 0 and 1.
%
%   [H,P] = COCHRANQTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,STATS] = COCHRANQTEST(...) returns a structure with the following fields:
%      'Q'      -- the value of the test statistic
%      'df'     -- the degrees of freedom of the test
%      'fail'   -- the value regarded as a fail
%      'pass'   -- the value regarded as a success
%      'Npass'  -- the sum of successes for each column 
%      'Ne'     -- the number of effective cases (i.e., the number of cases
%                  that do show differences on the K observations)
%
%   COCHRANQTEST(...) without output arguments prints a string saying
%   whether the null-hypothesis should be rejected at significance level
%   APLHA.
%
%   The Cochran Q test is useful for comparing related samples measured on
%   a categorical (nominal) scale. For K=2 this test equals the McNemar
%   test for two related samples.
%
%   EXAMPLE:
%     % In four tedious psychophysical experiments (EEG, color perception,
%     % word-naming, saccadic reaction times) we have noted if each of the 13
%     % participating subjects felt asleep (1) or not (2). Each row is a
%     % subject and each column is one of the four experiments:
%       DATA = [1 2 1 2 ;
%               1 2 1 2 ;
%               1 2 2 1 ;
%               1 2 1 1 ;
%               2 1 1 2 ;
%               2 1 1 2 ;
%               1 1 1 2 ;
%               1 1 1 1 ;
%               1 2 1 2 ;
%               1 2 1 2 ;
%               2 1 1 2 ;
%               1 2 1 2 ;
%               1 2 1 2 ; ] ;
%     % The null hypothesis is that there is no effect of type of
%     % experiment, i.e., the % probability of falling asleep (score 1) is
%     % the same for all four types of experiment. We choose to test this
%     % null hypothesis using the Cochran's Q statistic as the data is
%     % measured on categorical level. 
%       [H,P,STATS] = COCHRANQTEST(DATA,0.01) % ->
%     %     H = 1
%     %     P = 0.0032
%     % STATS =   Q: 13.8261     % test-statistic
%     %          df: 3
%     %        fail: 1           % = felt asleep
%     %        pass: 2           % = stayed awake
%     %       Npass: [3 8 1 10]  % number of people staying awake in an
%     %                          % experiment 
%     %        Neff: 12          % .. note the row with all ones
%     % The test shows that we should probably reject the notion that
%     % all psychophysical experiments are equally boring ...
%
%   See also TTEST, ZTEST, SIGNTEST, SIGNRANK (Statistics Toolbox).
%
%   This submission does not require the statistics toolbox.

% Source: Siegel & Castellan, 1988, "Nonparametric statistics for the behavioral
%         sciences", McGraw-Hill, New York 

% for Matlab R14
% version 2.2 (okt 2007)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History:
% 1.0 (aug 2007) - created
% 1.1 (sep 2007) - small code revisions
% 2.0 (sep 2007) - added extensive help
% 2.1 (okt 2007) - prepared for file exchange
% 2.2 (okt 2007) - corrected some small grammar and spelling errors
%                - fixed coding error for passes and failed 

if nargin==1 || isempty(alpha),
    alpha = 0.05 ;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('cochranqtest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if ndims(X) > 2,
    error('cochranqtest:InvalidData','X should be a 2D matrix.') ;
end

k = size(X,2) ;  % number of related observations
if (k < 2),
    error('cochranqtest:InvalidData','X should contain 2 or more columns.') ;
end

N = size(X,1) ;  % number of cases


try
    % transform the data into logical ones and true
    [C,X,X] = unique(X(:)) ;
    if max(X)>2,
        error('x') ; % pass error to catch ...
    end
    % convert to true and falses, highest values will be regarded as passes
    % (true)
    X = reshape(logical(X-1),N,k) ; 
catch
    error('cochranqtest:InvalidData','Data should be dichotomous (logical true and falses).')
end

G = sum(X,1) ;
L = sum(X,2) ;

% number of effective cases
N2 = N - sum(all(X,2) | all(~X,2)) ;
if (N2<4) || ((N2*k) < 24),
    warning('cochranqtest:SmallSamplesize','Effective sample size may be to small.') ;
end

% compute Cochran's Q statistic
stats.Q  = ((k-1) * (k * sum(G.^2) - sum(G).^2)) ./ ((k .* sum(L)) - sum(L.^2)) ;
stats.df = k-1 ; % degrees of freedom
stats.fail = C(1) ;
stats.pass = C(2) ;
stats.Npass  = G ;   % column sums
stats.Neff = N2 ;  % number of effective cases

% compute probability
p = 1 - gammainc(stats.Q/2,stats.df/2) ;

if p < alpha,
    h = 1 ;
else
    h = 0 ;
end

if nargout==0,
    if h,
        str = 'R' ;
    else
        str = 'Cannot r' ;
    end
    disp(sprintf('%seject the null hypothesis (alpha = %.3f)',str,p)) ;
    clear h
end
