function [rf_az, rf_el] =  octoPix2Deg(rfx, rfy,dist)
pixpercm = 256/95;  %%% screen is 256 pix, 95mm wide
rf_az = (rfx - 128)/pixpercm;
rf_el = (rfy - 96)/pixpercm;
rf_az = atan2d(rf_az, dist);
rf_el = atan2d(rf_el, dist);