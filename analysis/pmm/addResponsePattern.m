
function [d code patternNames]=addResponsePattern(d,type,lengthHistory)

if ~exist('type','var') || isempty(type)
    type='side'; %sideAndCorrect
end
if ~exist('lengthHistory','var') || isempty(lengthHistory)
    lengthHistory=3;
end
d.patternType=zeros(size(d.date));
patternNames={};

switch type
    case 'side'
        which=getGoods(d,'forBias');
        [count patternType uniques]=findResponsePatterns(d.response(which),lengthHistory,2,false);
        d.info.patternTypeUniques=uniques;
        code='LR';
    case 'alternate'
        which=getGoods(d,'forBias');
        alt=diff([0 d.response])~=0;
        [count patternType d.info.patternTypeUniques]=findResponsePatterns(alt(which),lengthHistory,2,false);
        code='RA';
    case 'alternateAndPrevCorrect'
        which=getGoods(d,'forBias');

        alt=diff([0 d.response])~=0;
        whichInds=find(which);
        prevCorrect=[0 d.correct(whichInds(1:end-1))];
        [altCount altType altUniques]=findResponsePatterns(alt(which),lengthHistory,2,false);
        [corCount correctType corUniques]=findResponsePatterns(prevCorrect,lengthHistory,2,false);
        [uniques ind patternType]=unique([altType correctType],'rows');
        for i=1:length(ind)   
            bothPattern=uniques(patternType(ind(i)),:);
            if ~any(isnan(bothPattern))
            bothUniques(i,:)=[altUniques(bothPattern(1),:)...
                corUniques(bothPattern(2),:) ];
            
            %bothUniquesCell{1}(i,:)=sideUniques(bothPattern(1),:);
            %bothUniquesCell{2}(i,:)=corUniques(bothPattern(2),:); 
            
            %ONLY NAMING THE PREVIOUS TRIAL (history of 1 back)
            if altUniques(bothPattern(1),1)==1 % alt
                if corUniques(bothPattern(2),1)==1 % prev correct
                    patternNames{i}='Explore';
                else
                    patternNames{i}='Forage';
                end
            elseif altUniques(bothPattern(1),1)==0  %rep
                if  corUniques(bothPattern(2),1)==1  % prev correct
                    patternNames{i}='Xploit';
                else
                    patternNames{i}='Persist';
                end
            else
                error('unexpected')
            end

            end

        end
        d.info.patternTypeUniques=bothUniques;
        code='1234';
    case 'ROC'
        which=getGoods(d,'forBias');
        if ~isfield(d,'yes')
            d=addYesResponse(d);
        end
        [uniques ind trialType]=unique([d.yes(which); d.correct(which)]','rows');
        if size(uniques,1)>4
            uniques
            error('unexpected entry.. nan''s may result from trials without target contrast, and thus without a "yes" definition (ie. other trial managers)')
        end
        for i=1:size(uniques,1)
            if uniques(i,1)==1 % yes
                if uniques(i,2)==1 % correct
                    code(i)='H';
                else
                    code(i)='F';
                end
            else %no
                if uniques(i,2)==1 % correct
                    code(i)='C';
                else
                    code(i)='M';
                end
            end
        end
        [count patternType d.info.patternTypeUniques]=findResponsePatterns(trialType,lengthHistory,2,false);
    case 'sideAndCorrect'
        which=getGoods(d,'forBias');

        [sideCount sideType sideUniques]=findResponsePatterns(d.response(which),lengthHistory,2,false);
        [corCount correctType corUniques]=findResponsePatterns(d.correct(which),lengthHistory,2,false);
        [uniques ind patternType]=unique([sideType correctType],'rows');
        for i=1:length(ind)   
            bothPattern=uniques(patternType(ind(i)),:);
            if ~any(isnan(bothPattern))
            bothUniques(i,:)=[sideUniques(bothPattern(1),:)...
                corUniques(bothPattern(2),:) ];
            
            %bothUniquesCell{1}(i,:)=sideUniques(bothPattern(1),:);
            %bothUniquesCell{2}(i,:)=corUniques(bothPattern(2),:); 
            end
        end
        d.info.patternTypeUniques=bothUniques;
    otherwise
        type
        error('not yet')
end

if length(patternType)~=sum(which)  % uh oh
    error('can''t align pattern to trial')
end
d.patternType(which)=patternType;
for i=1:length(lengthHistory)
    d.patternType(find(~which)+i)=nan;  % nan out the invalid ones
end
d.info.patternType=type;