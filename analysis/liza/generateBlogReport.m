function out = generateBlogReport
% clc
dbstop if error

if verLessThan('matlab','8.4')
    error('need at least 2014b for web* functions')
end

% profile on

key = '1igb_1ijKPaDViLho90IUvpmX-H58LXA9_YOHd6f0JeA';

data = getURL(key,'worksheets');

d = [data.feed.entry.title];
k = find(strcmp({d.x_t},'assignments'));

if ~isscalar(k)
    {d.x_t}
    error('not exactly one sheet named ''assignments''?')
end

d = data.feed.entry(k);

k = strfind(d.id.x_t,data.feed.id.x_t);
if ~isscalar(k) || k~=1 || d.id.x_t(length(data.feed.id.x_t)+1) ~= '/'
    d.id.x_t
    data.feed.id.x_t
    error('bad id structure?')
end

sheet = d.id.x_t(length(data.feed.id.x_t)+2:end);

data = getURL(key,'cells',sheet);
for i = 1:length(data.feed.entry)
    if isfield(data.feed.entry(i).gs_cell,'numericValue')
        if str2double(data.feed.entry(i).gs_cell.numericValue) ~= str2double(data.feed.entry(i).gs_cell.x_t)
            data.feed.entry(i).gs_cell
            error('numericValue and x_t don''t match')
        end
        data.feed.entry(i).gs_cell = rmfield(data.feed.entry(i).gs_cell,'numericValue');
    end
end
d = [data.feed.entry.gs_cell];
n = max(str2double({d.row})) - 1;
d = d(strcmp({d.row},'1'));
[~,o] = sort(str2double({d.col}));
fs = {d(o).x_t};

data = getURL(key,'list',sheet);
[r,c] = readHeirarchicalRecs(data.feed.entry,fs(1:3));
if length(r) ~= n
    error('no blank lines allowed')
end

fs = cellfun(@(f) f(~any(cell2mat(arrayfun(@(c) f==c,(' :')','UniformOutput',false)))), fs, 'UniformOutput',false);

for i = 4:length(fs)
    r = copyfield(r,fs{i},data.feed.entry);
end
    function targ = copyfield(targ,f,src)
        s = [src.(['gsx_' f])];
        [targ.(f)] = s.x_t;
    end

ifs = {'reward' 'timeout'};

for i = 1:length(ifs)
    for j = 1:length(r)
        if isempty(r(j).(ifs{i}))
            if j == 1
                ifs{i}
                error('must have entry in first row')
            else
                r(j).(ifs{i}) = r(j-1).(ifs{i});
            end
        end
    end
end

% profile viewer

arrayfun(@(x) fprintf([cell2mat(cellfun(@(f) sprintf([x.(f) '\t']),fs,'UniformOutput',false)) '\n']),r)

c = fliplr(c);
for i = 1:size(c,2)
    for j = 1:size(c,1)
        if ~isempty(c{j,i})
            s = repmat(' ',[1 4*(i-1)]);
            if i ~= size(c,2)
                c{j,i} = [s '- ' c{j,i}];
            else
                c{j,i} = [s imgLink(c{j,i})];
            end
            
        end
    end
end
c = c';
c = c(:);
c(cellfun(@isempty,c)) = [];
c

out = 'currentBehavior.md';

outh = fopen(out,'wt');
if outh<=2
    outh
    error('couldn''t fopen')
end
fprintf(outh,intercolate(c,'\n'));
outh = fclose(outh);
if outh~=0
    outh
    error('couldn''t fclose')
end

server = 'reichardt.uoregon.edu'; % inputEF('server' ,'reichardt.uoregon.edu');
id     = '999';                   % inputEF('id (new, 906/liza, 784/BLTest, 856/joe, 999/current)' ,'999');
login  = 'niellLabReport'; % inputEF('login'); % ,'eflister');
pw     = inputEF('password');

cmd = ['BlogLiterately --blog http://' server '/blog/xmlrpc.php --user ' login ' --password ' pw ' --publish --page'];

switch id
    case 'new'
        title = inputEF('title');
    case '784'
        title = 'BLTest';
        cmd = [cmd ' --postid ' id];
    case '856'
        title = 'joe behavior'
        cmd = [cmd ' --postid ' id];
    case '999'
        title = 'current'
        cmd = [cmd ' --postid ' id];
    otherwise
        error('bad id')
end
cmd = [cmd ' --title "' title '" ' out];

if true
    [status result] = system(cmd);
    result
    if status~=0
        status
        error('you may need to install haskell and/or BlogLiterately')
    end
else
    cmd
end

out = {};
for i = 1:length(r)
    out{end+1} = {r(i).station {r(i).subject}};
end
end

function out = inputEF(s,d)
if ~exist('d','var') || isempty(d)
    d2 = '';
else
    d2 = [' [' d ']'];
end

out = input([s d2 '\n'],'s');

if isempty(out)
    out = d;
end
end

function out = imgLink(sub,which,comment)
if ~exist('which','var') || isempty(which)
    which = {''};
end

if ~exist('comment','var') || isempty(comment)
    comment = '';
else
    comment = [' (' comment ')'];
end

root = 'http://reichardt.uoregon.edu/figures/';

out = cellfun(@f,which,'UniformOutput',false);

    function this = f(w)
        switch w
            case {'orientations','pixPerCyc','amp'}
                w = ['.' w '.psycho'];
            otherwise
                %pass
        end
        this = [root sub '/latest' w '.png'];
        this = ['[![' sub '](' this ')](' this ')'];
    end
out = ['- ' sub comment '\n' intercolate(out,'\n')];
end

function out = intercolate(c,i)
out = cell2mat(cellfun(@(x)[x i],{c{:}},'UniformOutput',false));
end

function [out, c] = readHeirarchicalRecs(d,fs)
if isempty(fs)
    out = struct([]);
    c = {};
else
    [out, c] = readHeirarchicalRecs(d,fs(2:end));
    f = fs{1};
    gf = ['gsx_' f];
    t = [d.(gf)];
    c(:,end+1) = {t.x_t};
    for i = 1:length(d)
        if isempty(d(i).(gf).x_t)
            if i == 1
                error(['first entry must have ' f])
            elseif isscalar(fields(out))
                error(['line %d: all entries must have ' f], i+1)
            else
                out(i).(f) = out(i-1).(f);
            end
        elseif any(cellfun(@(x) isempty(d(i).(['gsx_' x]).x_t),fs(2:end)))
            error('line %d: if specifying a field, all subsequent fields must be specified', i+1)
        else
            out(i).(f) = d(i).(gf).x_t;
        end
    end
end
end

function data = getURL(key,item,id)
% doc: https://developers.google.com/google-apps/spreadsheets/

base = 'https://spreadsheets.google.com/feeds/';
vis = 'public'; % private
proj = 'full'; % basic
sep = '/';

url = [base item sep key sep];
if exist('id','var')
    url = [url id sep];
end
url = [url vis sep proj];

data = webread(url,'alt','json',weboptions('ContentType','json'));
end