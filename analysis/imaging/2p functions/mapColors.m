function mapColors(x,y,symbol,cmap)
hold on
for i = 1:length(x)
plot(x(i),y(i),symbol,'Color',cmap(i,:));
end