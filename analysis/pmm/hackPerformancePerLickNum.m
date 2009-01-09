

%multiLickDependancy

rackNum=1;
subjects={'229'}
subjects={'138','139','227','228','231','232','229','230','233','234','237','274','278'}
tempPath='C:\Documents and Settings\rlab\Desktop\test';
compileTrialRecords(rackNum,{'numRequestLicks',{''}; 'correct',{''}; 'step',{''}; 'correctionTrial',{'stimDetails','correctionTrial'};},0,subjects,getSubDirForRack(rackNum),tempPath)

%%
f=dir(tempPath);
for i=1:length(subjects)
    fileName=f(find(strncmp(subjects(i),{f.name},3))).name;
    ctr=load(fullfile(tempPath,fileName));
    d2=ctr.compiledTrialRecords;
    d=getSmalls(subjects{i});

    %might have to remove all smalls after d2.date(end)
    %     extras=setdiff(d2.date, d.date);
    sum(d.date>d2.date(end))
    length(d.date>d2.date(end))
    d=removeSomeSmalls(d,d.date>d2.date(end));

    if length(d.date)==length(d2.date) && all(d.date==d2.date)
        d.numRequestLicks=d2.numRequestLicks;
    else
        length(d.date)
        length(d2.date)
        error('not the same records');
    end
    goods=getGoods(d);
    d=removeSomeSmalls(d,~goods);
    subplot(3,5,i)
    edges=[1:8]-.1;
    [count binID]=histc(d.numRequestLicks,edges);
    bar(edges,count/max(count),'histc');
    hold on
    ylim=get(gca, 'yLim');
    for j=1:max(binID)
        x(j)=sum(d.correct(binID==j));
        n(j)=sum(binID==j);
    end
    XX=1:max(binID);
    [p CI]=binofit(x,n);
    plot([XX; XX], [CI(:,1)'; CI(:,2)']-1, 'r');
    delta=p(2)-p(1);
    text(1,-.2,sprintf('%1.1g%%', delta*100))
    %         p=mean(d.correct(binID==j));
    plot(XX, p-1, 'k.');
    title(subjects(i))
    axis([0 10 -.5 ylim(2)]);
    set(gca, 'YTickLabel', {'50%', '100%'});
    set(gca, 'YTick', [-.5 0]);
end
