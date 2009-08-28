function [MI, hOut, hSpkOut, edges,stimCounts,trigCounts]=mutualInfo(stim,responses,responseIndex,numBins,numRepeats)

method='mi';

switch method
    %xc probably doesn't work for more than single-channel stims
    case 'xc'  %very strange, this method is always yielding the exact same gradient vector
        %works well tho!
        %stim=randn(1,length(stim)); %sanity check
        psth=sum(responses);
        xc=xcorr(stim,psth/norm(psth));
        %MI=xc(floor(length(xc)/2));
        MI=max(xc);

    case 'mi'

        binsPerDim=floor(numBins^(1/size(stim,1)));
        %binsPerDim
        
        edges=linspace(min(stim(:))-0.1,max(stim(:))+0.1,1+binsPerDim);
        [h b]=histc(stim',edges);

        if min(b(:))<1 || max(b(:))>binsPerDim
            [row col]=ind2sub(size(b),find(b<1 | b>binsPerDim));
            b(row,:)
            stim(:,row)
            [min(edges) max(edges)]
            error('bad histc output 2')
        end

        if size(stim,1)>1
            sz=binsPerDim*ones(1,size(stim,1));
        else
            sz=[binsPerDim 1];
        end
        h=accumarray(b,size(stim,1)*ones(1,size(stim,2)),sz);
        stimCounts=h*numRepeats;
        h=h/sum(h(:));%size(stim,2);

        if 0 %general method that works for any word length (doesn't work yet)
            hs=zeros(length(responseIndex),length(c));
            for i=1:length(responseIndex)
                vals{i}=stim(responseIndex{i});
                if length(vals{i})>0
                    hs(i,:)=hist(vals{i},c)/length(vals{i});
                end
            end
            spkH=hs(1,:); %code below only works for words of length 1, and assumes they are spikes
        else %just do spike triggered (assumes independence among spikes)
            vals = stim(:,responseIndex{1});

            [spkH b]=histc(vals',edges);

            if min(b(:))<1 || max(b(:))>binsPerDim
                [row col]=ind2sub(size(b),find(b<1 | b>binsPerDim));
                b(row,:)
                vals(:,row)
                [min(edges) max(edges)]
                error('bad histc output 2')
            end

            spkH=accumarray(b,ones(1,size(vals,2)),sz);
            trigCounts=spkH;
            spkH=spkH/size(vals,2);
        end

        %             figure
        %             subplot(2,1,1)
        %             plot(counts)
        %             subplot(2,1,2)
        %             plot(h,'k','LineWidth',3)
        %             hold on
        %             plot(hs')

        %disp(['h is ' num2str(100*sum(h(:)==0)/length(h(:))) '% zeros'])

        %size(spkH)
        %size(h)

        if any(spkH(h==0)>0)
            error('found a trig that was not a stim!')
        end
        %h(h==0)=eps; %don't need cuz these will be among the zeros canceled out next

        tol=0.001;
        if abs(1-sum(spkH(:)))>tol || abs(1-sum(h(:)))>tol
            sum(spkH(:))
            sum(h(:))
            error('n-d pdists don''t sum to 1')
        end

        %[h spkH] = doHistogram(stim,responseIndex{1});

        hOut=h;
        hSpkOut=spkH;

        %need to guarantee that 0's in spkH don't contribute to sum
        nulls=spkH==0;
        spkH(nulls)=1;
        h(nulls)=1;

        entropies=spkH.*reallog(spkH./h);
        MI=sum(entropies(:)); %calculates KL(spike condtioned || prior) as in sharpee 2004 (eqn 2.5)

    otherwise
        error('bad method')
end