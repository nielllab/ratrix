function fitWeights
clc
close all

%longer data available here, but doesn't match early data
%http://jn.nutrition.org/cgi/reprint/100/1/59.pdf
% day=   [30   60    90    120   150   180   360   540  ]';
% male=  [72   189.5 270   312   341.5 364.7 443.8 507.4]';
% female=[64.7 154.2 197.1 225.2 238.8 250.5 262.6 262.4]';


%http://www.harlan.com/models/longevans.asp
%note table does not match graph!  ex: male 10 weeks is >300 in graph, but <300 in table!
%   grams     male days        female days
d={...
    [35 49]    [20 23]      [20 24]; ...
    [50 74]    [24 29]      [25 30]; ...
    [75 99]    [30 33]      [31 35]; ...
    [100 124]  [34 37]      [36 41]; ...
    [125 149]  [38 41]      [42 49]; ...
    [150 174]  [42 45]      [50 56]; ...
    [175 199]  [46 49]      [57 69]; ...
    [200 224]  [50 57]      [70 89]; ...
    [225 249]  [58 64]      [90 110]; ...
    [250 274]  [65 70]      []; ...
    [275 299]  [71 79]      []; ...
    [300 324]  [80 90]      []; ...
    [325 349]  [91 100]     []; ...
    [350 374]  [101 110]    []...
    };

male_day=[];female_day=[];male=[];female=[];
for i=1:size(d,1)
    for j=d{i,1}(1):d{i,1}(2)
        for k=d{i,2}(1):d{i,2}(2)
            male(end+1,1)=j;
            male_day(end+1,1)=k;
        end
        if ~isempty(d{i,3})
            for k=d{i,3}(1):d{i,3}(2)
                female(end+1,1)=j;
                female_day(end+1,1)=k;
            end
        end
    end
end

plot(male_day,male,'bo');
hold on
plot(female_day,female,'ro');

% a=curve
% b=scale
% c=y offset
% d=x offset

logMod = 'c+(b*log(x-d)/log(a))';
rootMod = 'c+(b*(abs(x-d))^(1/a))';

logF = fittype(logMod)
rootF= fittype(rootMod)

targetNames={'a' 'b' 'c' 'd'}';
if ~all(strcmp(coeffnames(logF),targetNames)) || ~all(strcmp(coeffnames(rootF),targetNames))
    error('unexpected ordering of names -- will misinterpret up lower/upper vectors')
end

logOpts=fitoptions(logMod)
rootOpts=fitoptions(rootMod)

logOpts.Lower=[1 0];
rootOpts.Lower=[1 0];

[logMale,gof,output] = fit(male_day,male,logF,logOpts)
[rootMale,gof,output] = fit(male_day,male,rootF,rootOpts)

% exclude=logical([0 0 0 0 0 1 1]');
% exclude=[];
%logOpts.Exclude=exclude;
%rootOpts.Exclude=exclude;
[logFemale,gof,output] = fit(female_day,female,logF,logOpts)
[rootFemale,gof,output] = fit(female_day,female,rootF,rootOpts)

plot(logMale,'b-')
plot(rootMale,'b--')
plot(logFemale,'r-')
plot(rootFemale,'r--')
ylim([0 600])