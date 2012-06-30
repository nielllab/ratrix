function simplePsycho
if ~IsWin
    error('win only for now')
end

field = 'orientations';
step = uint8(7);
%date = [2012 6 17];
date = [];
path = '\\mtrix4\Users\nlab\Desktop\mouseData\CompiledTrialRecords\';
%path = 'C:\eflister\ctr\';

d = dir(fullfile(path,'*.compiledTrialRecords.*.mat'));
d = {d(cellfun(@isempty,strfind({d.name},'test'))).name};
cellfun(@(x)sessionPsycho(strtok(x,'.'),fullfile(path,x),field,step,date),d);
end

function sessionPsycho(sub,file,field,step,date)
close all
ctr = load(file);

vals = nan(size(ctr.compiledTrialRecords.trialNumber));
vals(ctr.compiledDetails.trialNums) = ctr.compiledDetails.records.(field)(1,:); %hmm, this will depend on field's structure
trials = find(all(~isnan([vals;ctr.compiledTrialRecords.correct])));

if ~all(isnan(ctr.compiledTrialRecords.correctionTrial)) %weird, i thought i moved these to here?
    error('huh?')
end
if true %remove correction trials
    corrections = nan(size(ctr.compiledTrialRecords.trialNumber));
    corrections(ctr.compiledDetails.trialNums) = ctr.compiledDetails.records.correctionTrial;
    trials = setdiff(trials,find(corrections));
end

if ~isempty(step)
    trials = intersect(trials,find(step==ctr.compiledTrialRecords.step));
end

if ~isempty(date)
    trials = intersect(trials,find(datenum(date)<=ctr.compiledTrialRecords.date));
end

u = unique(vals(~isnan(vals))); %unique sorts
if length(u)>length(vals)/10
    error('haven''t written bucketing yet')
else
    vals = arrayfun(@(x)find(vals==x),u,'UniformOutput',false);
end

%session boundaries whenever there was a half hour gap in the trial start times
sessions = trials([1 find(diff(ctr.compiledTrialRecords.date(trials)) > .5/24) end]);
offset = linspace(-1,1,length(sessions)-1)*min(diff(u))/3;

colordef black

colors = colormap('jet'); %opens figure? :(
cinds = round(linspace(1,size(colors,1),length(offset)));

alpha=.05;
d = 10;

for i=1:length(offset)
    these = cellfun(@(x)x(x>=sessions(i) & x<sessions(i+1) & ismember(x,trials)),vals,'UniformOutput',false);
    if any(cellfun(@(x)any(isnan(ctr.compiledTrialRecords.correct(x))),these))
        cellfun(@(x)x(isnan(ctr.compiledTrialRecords.correct(x))),these,'UniformOutput',false)
        error('huh?')
    end
    n = cellfun(@length,these);
    [~, pci] = binofit(cellfun(@(x)sum(ctr.compiledTrialRecords.correct(x)),these),n,alpha);
    plot(repmat(u(n>=d)+offset(i),2,1),pci(n>=d,:)','Color',colors(cinds(i),:));
    hold on
end

title([sub ' ' datestr(ctr.compiledTrialRecords.date(trials(end)),'ddd, mmm dd')])
ylim([0 1])
set(gca,'XTick',u);
plot(u([1 end])+offset([1 end]),.5*ones(1,2),'w');
uploadFig(gcf,sub,length(u)*length(sessions)*3,200,'psycho');
end

function uploadFigMini(f,subj,width,height,qual)
qual=['.' qual];

fn=fullfile('C:\eflister\ctr\',[subj '.' datestr(now,30) qual]);

set(f,'PaperPositionMode','auto'); %causes print to respect figure size
set(f,'InvertHardCopy','off'); %preserves black background when colordef black

set(f,'Position',[0,200,max(400,width),max(200,height)]) % [left, bottom, width, height]

sfx = 'png';
latest = [fn '.' sfx];
saveas(f,latest); %resolution not controllable

if false
    dpi=300;
    latest = [fn '.' num2str(dpi) '.' sfx];
    print(f,'-dpng',['-r' num2str(dpi)],'-opengl',latest);
end
end