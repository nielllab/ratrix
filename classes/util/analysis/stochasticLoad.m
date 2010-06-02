function [out success]=stochasticLoad(filename,fieldsToLoad, noAttempts)
if ~exist('fieldsToLoad','var')
    fieldsToLoad=[];
end
if ~exist('noAttempts','var')
    noAttempts = Inf;
end

currAttempt = 1;
success=false;
while ~success && currAttempt<noAttempts
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
        currAttempt = currAttempt+1;
        WaitSecs(abs(randn));
        dispStr=sprintf('failed to load %s - trying again',filename);
        disp(dispStr)
    end 
end
if ~success 
    out = [];
end


end % end function