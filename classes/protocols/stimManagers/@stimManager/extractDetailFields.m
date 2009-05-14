function [out newLUT]=extractDetailFields(sm,basicRecords,trialRecords,LUTparams)
out=struct;
newLUT=LUTparams.compiledLUT;
%out=struct('a',num2cell(1:length(trialRecords)));
%out=rmfield(out,'a'); %makes a 1xn struct array with no fields (any nicer way to make this?)

verifyAllFieldsNCols(out,length(trialRecords));
end