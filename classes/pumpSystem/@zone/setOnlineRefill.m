function setOnlineRefill(z)
            if sensorBlocked(z)
                setValve(z,z.fillRezValveBit,z.const.valveOn);
            else
                setValve(z,z.fillRezValveBit,z.const.valveOff);
            end