function simplePsycho(field,leg,step,xticklab,logx,path)
if ~IsWin
    error('win only for now')
end

date = []; %[2012 6 17];

d = dir(fullfile(path,'*.compiledTrialRecords.*.mat'));
d = {d(cellfun(@isempty,strfind({d.name},'test'))).name};
cellfun(@(x)sessionPsycho(strtok(x,'.'),fullfile(path,x),field,step,date,xticklab,logx,leg),d);
end

function sessionPsycho(sub,file,field,step,date,xticklab,logx,leg)
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
    trials = intersect(trials,find(ismember(ctr.compiledTrialRecords.step,step)));
end

if ~isempty(date)
    trials = intersect(trials,find(datenum(date)<=ctr.compiledTrialRecords.date));
end

u = unique(vals(trials)); %unique sorts
if length(u)>length(vals)/10
    error('haven''t written bucketing yet')
else
    vals = arrayfun(@(x)find(vals==x),u,'UniformOutput',false);
end

%session boundaries whenever there was a half hour gap in the trial start times
sessions = trials([1 find(diff(ctr.compiledTrialRecords.date(trials)) > .5/24) end]);

offset = linspace(-1,1,length(sessions)-1);
lgofst = ones(size(u));
if logx
    lgofst = (max(diff(u))/10)*lgofst.*u/max(u);
else
    offset = offset*min(diff(u))/3;
end

colordef black

if false
    colors = colormap('jet'); %opens figure? :(
else
    if true %perceptually uniform blue -> red, constant luminance/chroma
        %note not truly perceptually uniform, cuz at a given C and L, some H's are out of gamut (see fig 5 http://magnaview.nl/documents/MagnaView-M_Wijffelaars-Generating_color_palettes_using_intuitive_parameters.pdf)
        colors = [repmat([70 100],length(offset),1) 360*linspace(.9,.02,length(offset))'];
    else %increasing chroma, constant luminance
        colors = [50*ones(length(offset),1) linspace(0,100,length(offset))' .05*360*ones(length(offset),1)];
    end
    colors = applycform(applycform(colors,makecform('lch2lab')),makecform('lab2srgb'));
end
cinds = round(linspace(1,size(colors,1),length(offset)));

xlims = u([1 end])+[-1 1]*min(diff(u))/3;
if logx
    pf = @semilogx;
    xlims(end)=xlims(end)*4/3;
else
    pf = @plot;
end

alpha=.05;
d = 10;

doBino(trials,true);
doBino(trials,false);

    function doBino(trials,removeAfterErrors)
        if removeAfterErrors
            trials = trials(trials~=1);
            afterCorrects = trials(ctr.compiledTrialRecords.correct(trials-1) == 1); % ==1 cuz nans
            pac = round(100*(1 - length(afterCorrects)/length(trials)));
            trials = afterCorrects;
        end
        
        for i=1:length(offset)
            these = cellfun(@(x)x(x>=sessions(i) & x<sessions(i+1) & ismember(x,trials)),vals,'UniformOutput',false);
            if any(cellfun(@(x)any(isnan(ctr.compiledTrialRecords.correct(x))),these))
                cellfun(@(x)x(isnan(ctr.compiledTrialRecords.correct(x))),these,'UniformOutput',false)
                error('huh?')
            end
            n = cellfun(@length,these);
            [p, pci] = binofit(cellfun(@(x)sum(ctr.compiledTrialRecords.correct(x)),these),n,alpha);
            if removeAfterErrors
                params={'Color',colors(cinds(i),:)};
            else
                params={'wx','MarkerSize',2};
            end
            enoughs = n>=d;
            if any(enoughs) % we don't get logrithmic axis if we plot all empties
                pf(u+offset(i).*lgofst,n/sum(n),'x','Color',colors(cinds(i),:),'MarkerSize',2);
                hold on
                pf(repmat(u(enoughs)+offset(i).*lgofst(enoughs),2,1),pci(enoughs,:)',params{:});
                if removeAfterErrors
                    pf(u,p,params{:});
                end
            end
        end
    end

title([sub ' ' datestr(ctr.compiledTrialRecords.date(trials(end)),'ddd, mmm dd')])
ylim([0 1]);
xlim(xlims);
set(gca,'XTick',u);
plot(xlims,.5*ones(1,2),'Color',.5*ones(1,3));
plot(xlims,ones(1,2)/length(u),'Color',.5*ones(1,3));
xPos = min(u);
yPos = .25;
textSize = 5;
text(xPos,yPos,'correction trials removed','FontSize',textSize);
text(xPos,yPos-textSize/100,sprintf('x''s include after errors (%g%% more trials, should decrease performance and tighten range)',pac),'FontSize',textSize)
ylabel('% correct')
xlabel(leg)
set(gca,'XTickLabel',xticklab(u));
uploadFig(gcf,sub,length(u)*length(sessions)*3,200,[field '.psycho']);
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