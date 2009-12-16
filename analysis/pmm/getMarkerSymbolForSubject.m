function symbol=getMarkerSymbolForSubject(subject)

%standardFlankerPaper2010a
[labeledNames markerSymbols]=assignLabeledNames({subject});
symbol=markerSymbols{1};