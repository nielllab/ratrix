
function [count patternType uniques]=findResponsePatterns(responses,lengthHistory,numResponseTypes,plotOn)
%out=responsePattern(responses,lengthHistory,numResponseTypes,plotOn)
%out=responsePattern(rand(1,500)>0.5,3,2,1)

if isinteger(lengthHistory)
    lengthHistory=int32(lengthHistory);
    %to avoid errors with x(end-n) construction for n>intmax
end

[a b c]=unique(responses);
numResponseTypesInData=size(b,2);

if numResponseTypes==2 && numResponseTypesInData<=2
    %set all responses to 0 and 1, even if start as 1 and 3 or any 2
    %uniques responses
    responses=c-1;
else
    error ('code for findAllPatterns will break b/c more than 2 response types')
end


rSz=length(responses);
pattern=zeros(lengthHistory,rSz+(lengthHistory-1));
for i=1:lengthHistory
  pattern(i,i:rSz+i-1)=responses;
end

pattern=pattern(:,lengthHistory:end-(lengthHistory-1))';

p=findAllPatterns(lengthHistory);

%this adds on one of each unique type
pattern(end+1:end+size(p,1),:)=p; % wil garauntee on of each type so that numerical ID means the same thing even if type "2" happens to be absent from this data set
[uniques ind patternType]=unique(pattern,'rows');
pattern(end-size(p,1)+1:end,:)=[]; %remove what we added
patternType(end-size(p,1)+1:end)=[];  %remove what we added
patternType=[nan(lengthHistory-1,1); patternType]; % front pad the trials that did not have enough history

edges=[0:max(patternType)]+0.5;
n=histc(patternType,edges);
count=n(1:end-1)'-1;  %subtracts the one we added on

if plotOn
    hSz=size(count,2)/2;
    blankhalf=zeros(1,hSz); 
    hold off
    ltbars=bar([count(1:hSz) blankhalf],'FaceColor',[1 0 0]);
    hold on
    rtbars=bar([blankhalf count(hSz+1:end)],'g');


    %THIS PLOTTING DOESN'T WORK.  TRICKY TO CHANGE COLORS.
    %baseline_rtbars = get(rtbars,'BaseLine');
    %set(baseline_rtbars,'LineStyle','--','Color','red')

    %FaceColor1=get(rtbars,'FaceColor');
    %set(FaceColor1,'Color','red')
end

out=count;


function out=findAllPatterns(lengthHistory)

    sz=2^lengthHistory;
    p=zeros(sz,lengthHistory);
    for i=1:lengthHistory
        inds=mod(0:sz-1,sz/2^(i-1))>=sz/2^(i);
        p(find(inds==1),i)=1;
    end
    out=p;






