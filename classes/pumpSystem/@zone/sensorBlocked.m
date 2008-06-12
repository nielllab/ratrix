function out=sensorBlocked(z)
out = lptReadBit(z.rezSensorBit{1},z.rezSensorBit{2})==z.const.sensorBlocked;