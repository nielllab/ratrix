function [r,c] = getSpreadsheetData
% change ...\ratrix\analysis\liza\generateBlogReport.m to use this

% dbstop if error

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
        else
            val = str2double(r(j).(ifs{i}));
            if isnan(val)
                r(j).(ifs{i})
                error('bad spreadsheet entry')
            end
            r(j).(ifs{i}) = val;
        end
    end
end

% profile viewer

if false
    arrayfun(@(x) fprintf([cell2mat(cellfun(@(f) sprintf([x.(f) '\t']),fs,'UniformOutput',false)) '\n']),r)
end
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