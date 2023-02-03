% first go to: C:\Users\nlab\Desktop\KC\stimPics

allStimsFig = figure

subplot(1,7,1)
imshow('Con0.png')
subplot(1,7,2)
imshow('ConPt03.png')
subplot(1,7,3)
imshow('ConPt0625.png')
subplot(1,7,4)
imshow('ConPt125.png')
subplot(1,7,5)
imshow('ConPt25.png')
subplot(1,7,6)
imshow('ConPt5.png')
subplot(1,7,7)
imshow('Con1.png')

print(allStimsFig,'testSmallerEPS','-dsvg')
print(allStimsFig,'testSmallerEPS.fig')