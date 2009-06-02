function [s newRes]=setResolutionAndPipeline(s,res,imagingTasks)

if res.pixelSize~=32
    error('color depth must be 32')
end

oldRes=Screen('Resolution', s.screenNum);

if oldRes.width~=res.width || oldRes.height~=res.height || oldRes.hz ~=res.hz || oldRes.pixelSize~=res.pixelSize || ...
        ~allImagingTasksSame(s.imagingTasks,imagingTasks)

    resolutions=Screen('Resolutions', s.screenNum);

    match=[[resolutions.width]==res.width; [resolutions.height]==res.height; [resolutions.hz]==res.hz; [resolutions.pixelSize]==res.pixelSize];

    ind=find(sum(match)==4);

    if length(ind)>1
        ind
        warning('multiple matches')
        ind=min(ind);
    elseif length(ind)<1
        res
        unique([resolutions.width])
        unique([resolutions.height])
        unique([resolutions.hz])
        unique([resolutions.pixelSize])
        
        [resolutions.width]==res.width
        [resolutions.height]==res.height
         [resolutions.hz]==res.hz
         [resolutions.pixelSize]==res.pixelSize
        error('target res not available')
    end

    s=stopPTB(s);

    Screen('Resolution', s.screenNum, res.width, res.height, res.hz, res.pixelSize);
    s=startPTB(s,imagingTasks);
    
    newRes=Screen('Resolution', s.screenNum);
    if ~all([newRes.width==res.width newRes.height==res.height newRes.pixelSize==res.pixelSize newRes.hz==res.hz])
        requestRes=res
        newRes=newRes
        warning('failed to get desired res') 
        sca
        keyboard
        error('failed to get desired res') %needs to be warning to work with remotedesktop
    end

else
    newRes=oldRes;
end
end % end function


function out = allImagingTasksSame(oldTasks,newTasks)
% compare the two lists of imaging tasks and return if they are the same or not
out=true;
% do they have same # of tasks?
if ~all(size(oldTasks)==size(newTasks))
    out=false;
    return
end
% check that each task is the same...what about if they are in diff order?
% for now, enforce that the tasks must be in same order as well
% ie [4 5 6] is not equal to [5 4 6]
for i=1:length(oldTasks)
    a=oldTasks{i};
    b=newTasks{i};
    if length(a)~=length(b)
        out=false;
        return
    end
    for j=1:length(a)
        if strcmp(class(a{j}),class(b{j})) % same class, now check that they are equal
            if ischar(a{j})
                if strcmp(a{j},b{j})
                    %pass
                else
                    out=false;
                    return
                end
            elseif isnumeric(a{j}) 
                if a{j}==b{j}
                    %pass
                else
                    out=false;
                    return
                end
            else
                error('found an argument that was neither char nor numeric');
            end
        else
            out=false; % args have diff class
            return
        end
    end
end
end % end function