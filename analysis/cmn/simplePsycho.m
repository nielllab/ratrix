function simplePsycho
if ~IsWin
    error('win only for now')
end

field = 'orientations';
path = '\\mtrix4\Users\nlab\Desktop\mouseData\CompiledTrialRecords\';

d = dir([path '*.compiledTrialRecords.*.mat']);
subs = cellfun(@(x)textscan(x,'%s.compiledTrialRecords.%*u-%*u.mat'),{d.name}','UniformOutput',false);
subs = subs(~strfind(subs,'test'));

% j10ln
% j10lt
% j8ln
% j8lt

cellfun(@(x,y)sessionPsyco(y,x.name,field),cellfun(@(x)dir([path x '.compiledTrialRecords.*.mat']),subs,'UniformOutput',false),subs);
end

function sessionPsyco(sub,file,field)
ctr = load(file);

vals = ctr.compiledDetails.(field)(1,:); %hmm, this will depend on field's structure
u = unique(vals(~isnan(vals))); %unique sorts

if length(u)>length(vals)/10
    error('haven''t written bucketing yet')
else
    vals = arrayfun(@(x)find(vals==x),u,'UniformOutput',false);
end

trials = find(~isnan(vals));

%session boundaries whenever there was a half hour gap in the trial start times
sessions = trials([1 find(diff(ctr.compiledTrialRecords.date(trials)) > .5/24) end]);
offset = (1:length(sessions)-1)-length(sessions)/2; %needs adjustment depending on diff(u)

colors = colormap('jet');
cinds = round(linspace(1,size(colors,1),length(offset)));

colordef black
f = figure;

alpha=.05;

for i=1:length(offset)
    these = cellfun(@(x)x(x>=sessions(i) & x<sessions(i+1)),vals,'UniformOutput',false);
    [~, pci] = binofit(cellfun(@(x)sum(ctr.compiledTrialRecords.correct(x)),these),cellfun(@length,these),alpha);
    plot(repmat((u+offset(i))',1,2),pci','Color',colors(cinds(i)));
    hold on
end

title([sub datestr(ctr.compiledTrialRecords.date(trials(end)),'ddd, mmm dd')])
ylim([0 1])
xtick(u)
plot(u([1 end])+offset([1 end]),.5*ones(1,2),'w');
uploadFig(f,sub,length(u)*length(sessions)*5,200,'psycho');
end