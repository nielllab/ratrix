function [runMean] = runningAverage( rawSignal, windowSize )


runMean=filter( ones(1,windowSize)/windowSize, 1,  rawSignal);


%compute running average
%windowSize=50;    %5ms
% mRawSignal=[]; %zeros(1,length(rawSignal));
% mRawSub=[];
% for i=1:fix(length(rawSignal)/windowSize)
%     if i*windowSize > length(rawSignal)
%         break;
%     end
%     mRawSignal(i) = mean ( rawSignal( (i-1)*windowSize+1: i*windowSize ) );
%     mRawSub((i-1)*windowSize+1: i*windowSize ) =  mRawSignal(i) ;
% end
