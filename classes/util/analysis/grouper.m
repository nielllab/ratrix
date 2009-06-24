function labels = grouper(labels)

oneRowHeight=25;
margin=10;
fieldWidth=100;
fWidth=2*margin+1*fieldWidth;
fHeight=margin+15*oneRowHeight+margin;

labelStrs={};

f = figure('Visible','off','MenuBar','none','Name','Labels',...
    'NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 fWidth fHeight]);

    function updateUI
        labelStrs={};
        for i=length(labels):-1:1
            labelStrs{end+1}=sprintf('%d - %d',i,labels(i));
        end
        set(eventsSelector,'String',labelStrs);
    end

% ========================================================================================
% event selector (for grouping)


newLabelTag = uicontrol(f,'Style','text','String','label to apply','Visible','on','Enable','on','Units','pixels',...
    'Position',[margin fHeight-1*oneRowHeight-2*margin fieldWidth-margin oneRowHeight]);
newLabelField = uicontrol(f,'Style','edit','String',[],'Visible','on','Enable','on','Units','pixels',...
    'Position',[margin fHeight-2*oneRowHeight-2*margin fieldWidth-margin oneRowHeight]);

eventsSelector = uicontrol(f,'Style','listbox','String',labelStrs,'Visible','on','Units','pixels',...
    'FontWeight','normal','Value',[],'Enable','on','Max',999,'Min',0,...
    'Position',[margin+0*fieldWidth fHeight-13*oneRowHeight-1*margin fieldWidth*1-margin oneRowHeight*10]);

editLabelsButton = uicontrol(f,'Style','pushbutton','String','label','Visible','on','Units','pixels',...
    'Enable','on','Position',[margin fHeight-14*oneRowHeight-2*margin fieldWidth-margin oneRowHeight],...
    'Callback',@editLabels);
    function editLabels(source,eventdata)
        inds=get(eventsSelector,'Value');
        inds=length(labels)-inds+1; % the indices of labels to update
        % check that the new label is valid
        newlabel=str2double(get(newLabelField,'String'));
        if length(newlabel)==1 && (isnumeric(newlabel) || isnan(newlabel))
            labels(inds)=newlabel;
            updateUI();
        else
            errordlg('invalid new label!','invalid label');
        end
    end

saveLabelsButton = uicontrol(f,'Style','pushbutton','String','save labels','Visible','on','Units','pixels',...
    'Enable','on','Position',[margin fHeight-15*oneRowHeight-2*margin fieldWidth-margin oneRowHeight],...
    'Callback',@saveLabels);
    function saveLabels(source,eventdata)
        % return from function and close the figure
        close(f);
        return;
    end

updateUI();
set(f,'Visible','on');
waitfor(f);
end % end main function