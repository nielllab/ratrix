%this is a sweet function
%
%future ideas:
%just analyze words that *end* in spikes (this reduces library by 50% and guarantees you catch everything.
%even better: only count words that don't contain spikes counted by a later
%word:  for example, if you have a 3-spike burst, you see
%00000000001
%00000000010
%00000000101
%00000001010
%00000010100
%00000101001 <- just count this one
%00001010010
%00010100100
%00101001000
% to do this, for each spike you see, you have to look ahead to where that
% spike is just about to fall out of the window.  only count it if it can't be counted at
% any future time.
% the only thing that screws this up is very regular patterns of exactly the length of our window, because they
% establish no frame (as you'd expect) -- the chain of when to count who
% extends all the way back.
% 00000000100100100100100100100100100100...  works great for window=3, but breaks for window=4
% this is a special case -- more generally, it breaks if it doesn't often happen that you get full windows of zeros -- no natural boundaries.
% but maybe still ok to then just chunk it up into words of your window size (that all end in 1)
% what about overlapping words?  "pivot chord" that plays 2 simultaneous roles?
% how about, never allow a spike not to count in some word, but it's ok for spikes to be in many words
% so, typically, only count a spike if it can't be counted at any future
% time.  but, when a word gets recorded as a necessity for recording a
% spike, include all the present spikes in the window even if they've
% already been counted because some other word had to count them.
% in other words, you never record a "short" word -- all your words have
% the same window.
% i think this unambiguously records the spike train, and highly compresses it.
%you will have compressed it into symbols -- can start looking for
%similarity classes among symbols (as far as what the stim is doing when they happen), a syntax among them, etc.
function [counts, places, words]=getCounts(vectors,ids,wrds)

if size(vectors,1)==1 && length(ids)>1 && length(ids)==size(vectors,2)
    vectors=vectors';
end

% if size(vectors,1)~=length(ids)
%     size(vectors)
%     size(ids)
%     vectors
%     ids
%     error('size problem')
% end

if size(vectors,2)==1
    places={ids(find(vectors==1)) ids(find(vectors==0))};
    counts=[length(places{1}) length(places{2})];
    words = [1;0];
else
    startWithSpk=find(vectors(:,1)==1);
    startWithNoSpk=find(vectors(:,1)==0);

%     if size(vectors(startWithSpk,2:end),1)~=length(startWithSpk) || ...
%             size(vectors(startWithNoSpk,2:end),1)~=length(startWithNoSpk) || ...
%             length(ids) ~= length(startWithSpk) + length(startWithNoSpk) || ...
%             ~isempty(intersect(startWithSpk,startWithNoSpk)) || ...
%             any(startWithSpk>length(ids)) || ... 
%             any(startWithNoSpk>length(ids))% || ...
%             %(all(size(vectors(startWithSpk,2:end))==[1 2]) && all(vectors(startWithSpk,2:end) == [0 0])) || ...
%             %(all(size(vectors(startWithNoSpk,2:end))==[1 2]) && all(vectors(startWithNoSpk,2:end) == [0 0]))
% 
%         ids
% 
%         vectors(startWithSpk,2:end)
%         startWithSpk
%         ids(startWithSpk)
% 
%         vectors(startWithNoSpk,2:end)
%         startWithNoSpk
%         ids(startWithNoSpk)
% 
%         error('here it is')
%     end

    [counts1 places1 words1]=getCounts(vectors(startWithSpk,2:end),ids(startWithSpk),wrds);
    [counts2 places2 words2]=getCounts(vectors(startWithNoSpk,2:end),ids(startWithNoSpk),wrds);

    if any(any(words1~=words2))
        error('word problem')
    else
        words=[ones(size(words1,1),1) words1;zeros(size(words2,1),1) words2];
    end

    counts=[counts1 counts2];

    for i = 1:length(places1)
        places{i}=places1{i};
    end
    for i = 1:length(places1)
        places{i+length(places1)}=places2{i};
    end

    %places={places1 places2};
end


if 0 %funny plot -- compex numbers
    n=-10:.1:10;
    plot(n)
    hold on
    for c=-10:.3:10
        plot(real(c.^n))
    end
end

