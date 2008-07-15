function et=calibrate(et)

%by default do nothing but enforce that tracking is off; sub classes can override

et=setIsTracking(et,false);