function out=stochasticLoad(filename,fieldsToLoad)
if ~exist('fieldsToLoad','var')
    fieldsToLoad=[];
end

success=false;
while ~success
    try
        if isempty(fieldsToLoad) % default to load all
            out=load(filename);
        else
            evalStr=sprintf('out = load(''%s''',filename);
            for i=1:length(fieldsToLoad)
                evalStr=[evalStr ','''  fieldsToLoad{i} ''''];
            end
            evalStr=[evalStr ');'];
            eval(evalStr);
        end
        success=true;
    catch
        WaitSecs(abs(randn));
        dispStr=sprintf('failed to load %s - trying again',filename);
        disp(dispStr)
    end
end


end % end function