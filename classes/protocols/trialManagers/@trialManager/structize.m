function out=structize(s)
%     out=struct(s);
%     if ~isempty(getSuper(s))
%         getSuper(s)
%         display(s)
%         disp(sprintf('structizing a %s, which subclasses %s',class(s),class(getSuper(s))))
%         out.(class(getSuper(s)))=structize(getSuper(s));
%     else
%         disp(sprintf('structizing a %s, which has no superclass but structable',class(s)))
%     end
%     out.soundMgr=struct(s.soundMgr);
    
    disp(sprintf('structizing a %s, which subclasses %s',class(s),class(getSuper(s))))
    out=struct(s);
    out.(class(getSuper(s))) = structize(getSuper(s));
    out.soundMgr=struct(s.soundMgr);