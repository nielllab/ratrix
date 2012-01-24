function writeAVI(frames,out,fps)
try
    w=VideoWriter([out '.avi'],'Uncompressed AVI');
    if exist('fps','var')
        w.FrameRate=fps;
    end
    open(w);
    writeVideo(w,frames);
    close(w);
catch ex
    if strcmp(ex.message,'Undefined function or method ''VideoWriter'' for input arguments of type ''char''.')
        aviobj = avifile(out,'compression','None');
        if exist('fps','var')
            aviobj.fps=fps;
        end
        for i=1:size(frames,3)
            aviobj = addframe(aviobj,repmat(frames(:,:,i),[1 1 3]));
        end
        aviobj = close(aviobj);
    else
        rethrow(ex);
    end
end
end