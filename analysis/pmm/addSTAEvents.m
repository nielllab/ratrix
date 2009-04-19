function addSTAEvents(events, yval)
hold on;
numEvents=size(events,1);
prevEvent=1;  % init
colors=jet(numEvents);
for i=1:numEvents
	text(events{i,1},yval,events{i,2})  % text
	plot(events{[i i],1},yval([ 1 1]),'color',[.8 .8 .8])  % bar
	plot(events{i,1},yval,'gt') %green triangle
	%fill(prevEvent:events{i,1}, yval,'color',colors(i,:))
	prevEvent=event{i,1};
end
