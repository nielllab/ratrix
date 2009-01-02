function station=setMACaddress(station,mac)
    if isMACaddress(mac)
        station.MACaddress=mac;
    else
        error('not a valid mac address')
    end