function date=pmmEvent(id)
% commonly used dates for analysis

switch id
    case '228flankerContrastSweepDone'
        % applies to some rats long ago:  228,  but not? 138 
        % and not 232, who just has one .5 value
        %other rats unknown
        date=datenum('May.04,2008')

        %         d=getSmalls('232',[0 now]); d=removeSomeSmalls(d,~ismember(d.step,[9]));
        %         datestr(d.date(ismember(d.flankerContrast,[.5]))),22) % only one trial!
        %         %
        %         d=getSmalls('228',[0 now]); d=removeSomeSmalls(d,~ismember(d.step,[9]));
        %         datestr(max(d.date(ismember(d.flankerContrast,[.6 .7 .8 .9]))),22)
        %May.03,2008
    case 'allTilted'
            %beforeTilt=isnan(d.flankerPosAngle);
    case 'last139problem'
        date=datenum('Nov.15,2008');
        %Nov.15,2008=datestr(ceil(d.date(max(find(d.targetContrast==1)))),22)
        %Mar.16,2008=datestr(ceil(d.date(max(find(d.targetContrast>0 & d.targetContrast<.7)))),22)
    case 'endToggle'
        date=datenum('Apr.13,2009')
    case 'firstBlocking'
        date=datenum('May.11,2009')
    case 'startBlocking10rats'
        date =datenum('Jun.09,2009');
    case '231&234-jointSweep'
         date =datenum('Jul.22,2009');
    case '231-test200msecDelay'
        date =datenum('Nov.02,2009');
    case '231-test60msecDelay' %multi-contrast
        date =datenum('05-Nov-2009 11:01:50');
    case '231&234-SOA'
        date =datenum('07-Dec-2009 20:14:37');
    case 'patternRatsDelay' % single-contrast
        date =datenum('07-Dec-2009 20:14:37');
    otherwise
        id
        error('bad event id')
end