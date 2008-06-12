function [ output_args ] = calcState( input_args )
%DOFRAME Summary of this function goes here
%   Detailed explanation goes here

 state=timeout.calcState
 check input
 
         if isempty(requestOptions)
            done=true;
         end
        
         
         

 
         if isempty(stimSpec)
            done=true;
         else
            
             
                     %         requestRewardStarted=false;
        %         requestRewardDone=false;
        %         requestRewardPorts=0*readPorts(station);
        %         requestRewardDurLogged=false;
        %         isRequesting=0;

        %the request that ended the waitForRequest phase counts as the first request
        numRequests=1;
        lastRequestFrame=1;