function [ output_args ] = triggered( input_args )
%TRIGGERED Summary of this function goes here
%   Detailed explanation goes here

subclass phase


% stimDetails.responseOptions       %indices of target and distractor ports -- activity on these ports count as responses
% stimDetails.requestOptions        %indices of request ports -- activity on these ports count as requests





%   PHASE: WAIT_FOR_REQUEST
% stimDetails.interTrialStim        %stimSpec - show this til first request (if interTrialStim or requestOptions is empty, go straight to discriminandumStim)
%   PHASE: PROGRESSIVE
% stimDeatils.progressiveStim       %n stimSpecs - "progressive disclosure" required stims before discriminandum (each earned by a request; stims can loop; if empty, phase is skipped)
%                                   %each request rewarded by calling getRequestRewardSize(requestTimes))
% stimDetails.mustCompleteStims     %boolean - true iff additional requests don't count til each stim completes 
% stimDetails.failOnEarlyResponse   %true iff should abort trial with a penalty if response occurs during this phase
%   PHASE: DISCRIMINANDUM
% stimDetails.discriminandumStim	%n stimSpecs, requests iterate through this list (can implment "toggle" as {discrim, blank})
% stimDetails.advanceOnRequestEnd   %true iff ending a request advances to the next item in discriminandumStim, otherwise advance occurs at next request ("toggle" vs. "maintain-poke-to-maintain-stim")
% stimDetails.loopDiscriminandum    %true iff should loop to beginning of discriminandumStim list after last item reached



        
        
        
        
        
        if isempty(requestOptions)
            error('can''t have a progressive phase without any requestOptions')
        end
%i think this is false -- in that case it would play through once like a
%movie and end
        

        if ~isinteger(stimDetails.framesPerRequest) || ~isscalar(stimDetails.framesPerRequest) || any(stimDetails.framesPerRequest<0)
            error('framesPerRequest must be scalar integer >=0')
        end
        %no longer have framesPerRequest idea
        
                if ~isboolean(stimDetails.failOnEarlyResponse) || ~isscalar(stimDetails.failOnEarlyResponse)
            error('failOnEarlyResponse must be scalar boolean')
        end
        