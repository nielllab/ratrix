function uploadFig(f,subj,width,height,qual)
if ~exist('qual','var') || isempty(qual)
    qual='';
else
    qual=['.' qual];
end

if IsWin
    fn=fullfile('\\reichardt','figures',subj,[datestr(now,30) qual]);
    [s, mess, messid] = mkdir(fileparts(fn));
    if s~=1
        s
        mess
        messid
        error('couldn''t mkdir')
    end
    set(f,'Visible','off') %otherwise screen size limits figure size
    set(f,'Position',[0,200,max(400,width),max(200,height)]) % [left, bottom, width, height]
    set(f,'PaperPositionMode','auto'); %causes print to respect figure size
    set(f,'InvertHardCopy','off'); %preserves black background when colordef black
    
    saveas(f,[fn '.fig']);
    doSVG=false;
    if doSVG
        plot2svg([fn '.svg'],f);
    end
    
    % "When you print to a file, the file name must have fewer than 128 characters, including path name."
    % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/print.html#f30-534567
    dpi=300;
    sfx = 'png';
    latest = [fn '.' num2str(dpi) '.' sfx];
%     try %print/saveas for png doesn't work over remote desktop (unless Visible is off?)
        print(f,'-dpng',['-r' num2str(dpi)],'-opengl',latest); %opengl for transparency -- probably unnecessary cuz seems to be automatically set when needed
        saveas(f,[fn '.' sfx]); %resolution not controllable
%     catch
%         if doSVG
%             sfx = 'svg';
%             latest = [fn '.' sfx];
%         end
%     end
    
%     try
        [status,message,messageid] = copyfile(latest,fullfile(fileparts(latest),['latest' qual '.' sfx]));
        if status~=1
            status
            message
            messageid
            error('couldn''t copy')
        end
%     end
    
    set(f,'Visible','on')
else
    error('haven''t handled non-win uploading to webserver yet')
end
end