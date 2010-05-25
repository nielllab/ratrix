function summarize(aggregateFileName,analysis)
clc
close all

analysis='entropy';
%aggregateFileName='/Users/eflister/Desktop/spkEnt.mat';
%aggregateFileName='/Users/eflister/Desktop/final aggregate/20100227T065419.tmpFile.mat'; %'/Users/eflister/Desktop/final cosyne/gauss hat.mat';

analysis='sinusoidal';
aggregateFileName='C:\Documents and Settings\rlab\Desktop\analysis tmp\20100525T085520.tmpFile.mat';% 20100520T232713.tmpFile.mat';%\20100519T085245.tmpFile.mat';
%20100525T083741.tmpFile.mat
%20100525T085520.tmpFile.mat

z=load(aggregateFileName);
z={z.z.(analysis)};
z=z(~cellfun(@isempty,z));
z=parse(cellfun(@(x) setfield(x{2},'uID',x{1}),z)); %gah
z=groupBy(z,{'z','chunk','hash'});

switch analysis
    case 'entropy'
        entropy(z);
    case 'sinusoidal'
        sinusoidal(z);
    otherwise
        error('unrecognized analysis')
end
end

function sinusoidal(in)
contrasts=[];
cols=2;
c=colormap;
    colors=c(ceil(linspace(1,size(c,1),size(in,1))),:);
    
for i=1:size(in,1)
    if isempty(contrasts)
        contrasts=in{i,2}.uContrasts;
    elseif ~all(in{i,2}.uContrasts == contrasts)
        error('contrasts don''t match')
    end
    
    for j=1:length(contrasts)
        
        subplot(length(contrasts),cols,cols*(j-1)+1)
        plot(in{i,2}.uFreqs,in{i,2}.mn(:,j)/max(in{i,2}.mn(:)),'Color',colors(i,:))
        hold on
        title(sprintf('contrast = %g',contrasts(j)))
        ylim([0 1])
        
        if j==ceil(length(contrasts)/2)
            ylabel('normalized (all contrasts) rate')
        end
        if j==length(contrasts)
            xlabel('freq (hz)')
        end
        
        subplot(length(contrasts),cols,cols*(j-1)+2)
        plot(in{i,2}.uFreqs,in{i,2}.mn(:,j)/max(in{i,2}.mn(:,j)),'Color',colors(i,:))
        hold on
        if j==ceil(length(contrasts)/2)
            ylabel('normalized (this contrast) rate')
        end
        ylim([0 1])
        
        if j==length(contrasts)
            xlabel('freq (hz)')
        end
    end
end
end

function entropy(in)
%this is only getting 23 records when it should be getting 24+1.  figure out why

gaussians={};
haterens={};
gRates={};
hRates={};

for i=1:size(in,1)
    gaussians{i}={};
    haterens{i}={};
    gRates{i}={};
    hRates{i}={};
    
    for j=1:length(in{i,2})
        switch in{i,2}(j).stimType
            case {'gaussian','gaussgrass'}
                gRates{i}{end+1}={in{i,2}(j).tonicRate, in{i,2}(j).burstRate};
                gaussians{i}{end+1}=in{i,2}(j).bitsPerSpk;
            case 'hateren'
                hRates{i}{end+1}={in{i,2}(j).tonicRate, in{i,2}(j).burstRate};
                haterens{i}{end+1}=in{i,2}(j).bitsPerSpk;
            otherwise
                'skipping'
                in{i,2}(j).stimType
        end
    end
end

if length(gaussians)~=length(haterens)
    error('grouping error')
end

maxH=0;
for i=1:length(gaussians)
    if ~isempty(gaussians{i})
        hs=[gaussians{i}{:}];
        plot(ones(1,length(hs)),hs,'ko')
        if max(hs)>maxH
            maxH=max(hs);
        end
        hold on
    end
    if ~isempty(haterens{i})
        hs=[haterens{i}{:}];
        plot(2*ones(1,length(hs)),hs,'ko')
        if max(hs)>maxH
            maxH=max(hs);
        end
        hold on
    end
    if ~isempty(gaussians{i}) && ~isempty(haterens{i})
        for j=1:length(gaussians{i})
            for k=1:length(haterens{i})
                plot([1 2],[gaussians{i}{j} haterens{i}{k}],'k')
            end
        end
    end
end
ylabel('bitsPerSpk')
set(gca,'xtick',[1 2],'xticklabel',{'gaussian','hateren'})
xlim([0 3])
ylim([0 maxH*1.1])

figure
for i=1:length(gRates)
    if ~isempty(gRates{i})
        gHandle=plot(gRates{i}{1}{1},gRates{i}{1}{2},'bo');
    end
    hold on
end
for i=1:length(hRates)
    if ~isempty(hRates{i})
        hHandle=plot(hRates{i}{1}{1},hRates{i}{1}{2},'g*');
    end
    hold on
end
%axis square
%axis equal
xlabel('tonic rate (hz)')
ylabel('burst rate (hz)')
legend([gHandle hHandle],'Gaussian','natural')
%legend(hHandle,'natural')

keyboard

end

function out=groupBy(in,fields)
out={};
for i=1:length(in)
    found=[];
    for k=1:size(out,1)
        if isempty(found) && all(cellfun(@(x) myEq(out{k,1}.(x),in(i).(x)),fields));
            found=k;
        end
    end
    if isempty(found)
        out{end+1,1}=cell2struct(cellfun(@(x) in(i).(x),fields,'UniformOutput',false)',fields);
        found=length(out);
        out{found,2}=in(i);
    else
        out{found,2}(end+1)=in(i); %lame this has to be special cased
    end
end
end

function out=myEq(a,b)
out=strcmp(class(a),class(b));
if out
    out=all(size(a)==size(b));
    if out
        out=all(a(:)==b(:));
    end
end
end

function out=substru(in,fields)

c={};
for i=1:length(fields)
    c(end+1,:)={in.(fields{i})};
end
%cellfun(@(x) c{end+1,:}={in.(x)},fields); %why not good?

out=uniqueStruct(cell2struct(c,fields));
end

function out=uniqueStruct(in)

end

function in=parse(in)
d='.';

for i=1:length(in)
    done=false;
    tok={};
    
    rem=in(i).uID;
    while ~done
        [tok{end+1},rem]=strtok(rem,d);
        done=isempty(rem);
    end
    
    [in(i).num toks tok]=getPosNumber(tok);
    if toks~=1
        error('first should be a whole number')
    end
    
    in(i).stimType=tok{1};
    stimTypeFieldName='stimType';
    if isfield(in(i),stimTypeFieldName)
        tok=getStr(tok,in(i).(stimTypeFieldName));
    else
        tok=tok(2:end);
    end
    
    tok=getStr(tok,'z');
    
    [in(i).z toks tok]=getPosNumber(tok);
    
    tok=getStr(tok,'t');
    
    tok=goTil(tok,'chunk');
    
    [in(i).chunk toks tok]=getPosNumber(tok);
    if toks ~= 1
        error('chunk should be a whole number')
    end
    
    if length(tok)~=1 || length(tok{1})~=40
        error('last should be a sha1 40 digit hash')
    else
        in(i).hash=tok{1};
    end
end
end

function rest=goTil(toks,str)
done=false;
count=0;
while ~done && ~isempty(toks)
    done=strcmp(toks{1},str);
    if ~done
        count=count+1;
    end
    toks=toks(2:end);
end
rest=toks;
if count<=0
    error('expected at least one before str')
end
end

function rest=getStr(toks,str)
str=sanitize(str);
if ~strcmp(toks{1},str)
    str
    error('expecting this str')
else
    rest=toks(2:end);
end
end

function [num toks rest]=getPosNumber(tok)
done=false;
toks=0;
num=0;
while ~done
    if isWholePosNumber(tok{1})
        toks=toks+1;
        switch toks
            case 1
                num=num+str2num(tok{1});
            case 2
                num=num+str2num(tok{1})/10^length(tok{1});
            otherwise
                error('more than 2 in a row')
        end
        tok=tok(2:end);
    else
        done=true;
    end
end
rest=tok;
if toks<1 || toks >2
    error('expecting a pos num')
end
end

function out=isWholePosNumber(tok)
out=all(isstrprop(tok,'digit'));
end