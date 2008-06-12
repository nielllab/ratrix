function ratrixControl
close all

%log into *all* servers and view reports/control them in their own inspector

fWidth=1000;
fHeight=900;
placeholder=1;
margin=5;
units='pixels';

f = figure('Visible','off','MenuBar','none','Name','ratrix control','NumberTitle','off','CloseRequestFcn',@cleanup,'Units',units,'Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt)
        src
        evt
        'all done'
        closereq
    end

mainL = xtargets_borderlayout(f);
serverUIC = uicontainer('units',units);
serverL = xtargets_borderlayout(serverUIC);

serverAddresses={'132.239.158.169','321.123.321.123'};
serverTStr='server:';
serverUpSinceTStr='up since: days:hrs:mins:secs (18 serial port errors, 77 valve errors, 12 healed connection failures)';

serverPHeight=50;

serverP = uipanel('BorderType','none','Units','pixels','Position',[0 0 placeholder serverPHeight]);
serverT = uicontrol(serverP,'Style','text','HorizontalAlignment','Left','String',serverTStr,'Units','pixels');
serverC = uicontrol(serverP,'Style','popupmenu','String',serverAddresses,'Value',1,'Units','pixels');
serverUpSinceT=uicontrol(serverP,'Style','text','HorizontalAlignment','Left','String',serverUpSinceTStr,'Units','pixels');
align([serverT serverC serverUpSinceT],'Fixed',margin,'Bottom');

serverCycleB=uicontrol('Style','pushbutton','String','cycle','Units','pixels');

serverL.add(serverP,'east');
serverL.add(serverCycleB,'west');

inspectorP=uipanel('Title','hey','BorderType','line','Units','pixels');

mainL.add(serverUIC,'north');
mainL.add(inspectorP,'centre');

get(serverUIC)
set(f,'Visible','on')
end

%    layout.add(uicontrol('units','pixels','string','east','position',[0 0 300 placeholder]),'east');