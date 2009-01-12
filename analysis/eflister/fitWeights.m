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
xlim([0 600])

ylabel('grams')
xlabel('day')

plotOracle=true;
if plotOracle
    t=.85;
    c=dbconn;
    ids={'106','177'};
    [maleW maleD maleT] = getBodyWeightHistory(c,ids{1});
    [femaleW femaleD femaleT] = getBodyWeightHistory(c,ids{2});
    s=getSubjects(c,ids);
    closeconn(c);
    if s(1).gender=='M' && s(2).gender=='F'
        plot(maleD-s(1).dob,[maleW maleT/t],'bx')
        hold on
        plot(femaleD-s(2).dob,[femaleW femaleT/t],'rx')
    else
        error('bad genders')
    end
end

% a=curve
% b=scale
% c=y offset
% d=location

mods={...
    'log'       'c+(b*log(x-d)/log(a))'     {'a' 'b' 'c' 'd'}   [1 0]   '-'    {[] []};...
    'root'      'c+(b*(abs(x-d))^(1/a))'    {'a' 'b' 'c' 'd'}   [1 0]   '--'   {[] []};...

    'logNorm'   'c+(b*logncdf(x,d,a))'      {'a' 'b' 'c' 'd'}   [0]      '+' {[0.7759 467.9 -12.32 4.036] [0.6011 242.8 13.21  3.798]};...
    'gauss'     'c+(b*normcdf(x,d,a))'      {'a' 'b' 'c' 'd'}   [0 0]      'o' {[77.3834647674482 1648.77075229918 -1235.11038096151 -35.4854723926335]  [46.1687313615877 603.042351484134 -357.985060210495 2.98819459316451]};...

    'atan'      'c+(b*atan(x-d))'           {'b' 'c' 'd'}       []      'x' {[64147.2790884138 -100037.152240227 -70.550853890521] [6725 -1.027e+004 -2.296]};...
    'sig'       'c+(b/(1+exp(a*(d-x))))'        {'a' 'b' 'c' 'd'}       [0 .75*max(female)]      '*' {[] []};...

    %e is a "scale parameter" and may be redundant with b (choose e to be 1, the default)
    'wbl'       'c+(b*wblcdf(x-d,e,a))'     {'a' 'b' 'c' 'd' 'e'} [0 -inf -inf -inf 0] '-.' {[0.867145410886847 457.96805958187 55.4593110159781 28.1607492830005 70.5208590545724] [1.14150787475503 210.345141355582 42.1940257499687 22.62263879965 35.286474278694]};...
    };

for i=1:size(mods,1)
    f=fittype(mods{i,2});

    if ~all(strcmp(coeffnames(f),mods{i,3}'))
        error('unexpected ordering of names -- will misinterpret up lower/upper vectors')
    end

    opts=fitoptions(mods{i,2});

    opts.MaxFunEvals=10000;
    opts.MaxIter=10000;

    if ~isempty(mods{i,4})
        opts.Lower=mods{i,4};
    end

    if ~isempty(mods{i,6}{1})
        opts.StartPoint=mods{i,6}{1};
    end

    doFit(male_day,male,f,opts,[mods{i,1} ' male'],['b' mods{i,5}]);

    if ~isempty(mods{i,6}{2})
        opts.StartPoint=mods{i,6}{2};
    else
        opts.StartPoint=[];
    end
    doFit(female_day,female,f,opts,[mods{i,1} ' female'],['r' mods{i,5}]);
end
end


function doFit(day,data,f,opts,name,pStr)
done=false;

try
    warning('off','curvefit:fit:noStartPoint')
    [theFit,gof,output] = fit(day,data,f,opts);
    warning('on','curvefit:fit:noStartPoint')
    done=true;
catch 
    lasterror
    name
    error('got a nan, you need to set bounds')
end
fprintf([name ':\n'])
z=struct(theFit);
disp([z.coeffValues{:}])
if output.exitflag<=0
    output.exitflag
    warning('no converge')
    pause
end

plot(theFit,pStr)
end