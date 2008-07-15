function  out = viewStim(r,subIDs)
%returns a single image for each requested rat
%future idea:  pass in a rackNumber instead of a subjectIDlist
% example: viewStim(r,'136')


if ~exist('subIDs','var')
    subIDs=getSubjectIDs(r)
end

switch class(subIDs)
    case 'char'
        subIDs={subIDs}
        xGrid=1;
        yGrid=1;
        numSubjects=1;
    case 'cell'
        numSubjects=length(subIDs)
        xGrid=ceil(sqrt(numSubjects));
        yGrid=ceil(numSubjects./xGrid);
    case 'double'
        %treatNumbers as rack IDs
        if size(subIDs)==[1 1]
            rackNum=subIDs;
        else
            error('must be rackNum')
        end
        %how do you know this ratrix has all the rats in that rack? you dont
        subIDs=getCurrentSubjects(rackNum)
        numSubjects=length(subIDs(:))
        xGrid=size(subIDs,1);
        yGrid=size(subIDs,2);
    otherwise
        error('bad input')
end



figure
for i=1:numSubjects
    subplot(xGrid,yGrid,i)
    disp(sprintf('doing %s',subIDs{i}))
    im=sampleStimFrame(getSubjectFromID(r,subIDs{i}));
    if isinteger(im)
        imagesc(im,[0 intmax(class(im))]); 
    else
        imagesc(im,[0 1]); 
    end
    colormap(gray)
    title(subIDs{i})
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
    set(gca,'TickLength',[0 0]);
end