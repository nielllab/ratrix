function out=checkTargetIsPresent(sm,details)
%By default this will error for all stimManager unless they overwrite this
%method in order to express the appropriate logic

class(sm)

error('This stimManager has not defined if a target is present or absent.');
%asymetricReinforcement probably would also handle an output of empty or
%nan, but just erroring here is just more conservative

%out=[];

