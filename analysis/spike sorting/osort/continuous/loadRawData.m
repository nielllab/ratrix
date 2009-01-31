function [allSamples,CSCTimestamp, eventTimeStamps, Nttls]=loadRawData(basepath, dataFileName)

%convert events
FieldSelection(1) = 1;
FieldSelection(2) = 1;
FieldSelection(3) = 1;
FieldSelection(4) = 1;
FieldSelection(5) = 1;
ExtractHeader = 0;
ExtractMode = 1;
          
[eventTimeStamps, EventIDs, Nttls, Extras, EventStrings] = nlx2matev_v3( [basepath 'Events.Nev'], FieldSelection, ExtractHeader, ExtractMode);

[CSCTimestamp, ChanNum, SampleFrequency, NumValSamples, Samples] = Nlx2MatCSC_v3( [basepath dataFileName '.Ncs'], FieldSelection, ExtractHeader, 1 );

samFreq=SampleFrequency(1);
channelNr = ChanNum(1);
clear SampleFrequency;
clear NumValSamples;
clear ChanNum;

allSamples=Samples(:);
