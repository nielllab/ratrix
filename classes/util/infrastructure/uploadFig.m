function uploadFig(f,subj,width,height,qual)
if ~exist('qual','var') || isempty(qual)
    qual='';
else
    qual=['.' qual];
end

if ispc
    fn=fullfile('\\reichardt','figures',subj,[datestr(now,30) qual]);
    [s, mess, messid] = mkdir(fileparts(fn));
    if s~=1
        s
        mess
        messid
        error('couldn''t mkdir')
    end
    
    set(f,'PaperPositionMode','auto'); %causes print/saveas to respect figure size
    set(f,'InvertHardCopy','off'); %preserves black background when colordef black
    
    sfx = 'fig';
    latest = [fn '.' sfx];
    saveas(f,latest);
    lqf = ['latest' qual '.'];
    [status,message,messageid] = copyfile(latest,fullfile(fileparts(latest),[lqf sfx]));
    if status~=1
        status
        message
        messageid
        error('couldn''t copy')
    end
    
    set(f,'Visible','off') %otherwise screen size limits figure size
    set(f,'Position',[0,200,max(400,width),max(200,height)]) % [left, bottom, width, height]
    pos=get(f,'Position');
    if pos(3)~=width
        pos(3)
        width
        warning('width maxed out')
    end
    
    doSVG=false;
    if doSVG
        plot2svg([fn '.svg'],f);
    end
    
    sfx = 'png';
    latest = [fn '.' sfx];
    saveas(f,latest); %resolution not controllable
    
    [status,message,messageid] = copyfile(latest,fullfile(fileparts(latest),[lqf sfx]));
    if status~=1
        status
        message
        messageid
        error('couldn''t copy')
    end
    
    try
        dpi=300;
        latest = [fn '.' num2str(dpi) '.' sfx];
        % "When you print to a file, the file name must have fewer than 128 characters, including path name."
        % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/print.html#f30-534567
        print(f,'-dpng',['-r' num2str(dpi)],'-opengl',latest); %opengl for transparency -- probably unnecessary cuz seems to be automatically set when needed
        
        [status,message,messageid] = copyfile(latest,fullfile(fileparts(latest),[lqf sfx]));
        if status~=1
            status
            message
            messageid
            error('couldn''t copy')
        end
    catch ex
        getReport(ex)
        warning('print OOM''d')
        %         Error using hardcopy
        % Out of memory. Type HELP MEMORY for your options.
        %
        % Error in C:\Program Files\MATLAB\R2011b\toolbox\matlab\graphics\hardcopy.p>hardcopy (line 28)
        %
        %
        % Error in render (line 142)
        %             pj.Return = hardcopy( inputargs{:} );
        %
        % Error in print>LocalPrint (line 280)
        %                 pj = render(pj,pj.Handles{i});
        %
        % Error in print (line 237)
        %     LocalPrint(pj);
    end
    
    set(f,'Visible','on')
    close all %otherwise we oom
else
    warning('haven''t handled non-win uploading to webserver yet')
end
end