function edfRatIDs=getEDFids

%note need to add rack 2 test rats

edfRatIDs=...
...%rack 2 (cockpits) %all on free drinks, then easiest possible go to side (some grating, some image, some dots), then tilt discrim
...% A     B     C          D     E     F
{         '180' '161'                       ... %red
...%       im/tt im/tp
...%
          '160' '163'                       ... %orange
...%       im/tp im/tp
...%
          '186' '202'                       ... %yellow
...%       d/tt  d/gts
...%
          '185' '203'                       ... %green
...%       g /tt g/gts
...%
    '159' '179' '204'                       ... %blue
...% g/tp  g/tt  g/gts
...%
    '162' '164' '192'                       ... %violet
...%(i)gts(i)gts(i)gts
...%
'rack2test1' 'rack2test2' 'rack2test3' 'rack2test4' 'rack2test5' 'rack2test6' ... %test
...%
...%
...%rack 3 (boxes)
...% A     B     C          D     E     F           G     H     I
    '263' '189' '190'      '191'       '181'       '182' '187' '188' ... %orange
...% rb    rb    rb         rb          rc          rc    rc    rc
...%
    '264' '165' '166'      '167' '168' '177'       '178' '183' '184' ... %yellow
...% f     f     f          f     f     bt          bt    bt    bt
...%
    '265' '173' '174'      '175' '176' '169'       '170' '171' '172' ... %green
...% xm    xm    xm         xm    xm    xm          xm    xm    xm
...%
    '266' '193' '194'      '249' '250' '251'       '252' '253' '254' ... %blue
...% rc    rc    rc         rc    rc    rc          rc    rc    rc
...%
    '159' '255' '256'      '257' '258' '259'       '260' '261' '262' ... %violet
...% rb    rb    rb         rb    rb    rb          rb    rb    rb
...%
'rack3test1' 'rack3test2' 'rack3test3' 'rack3test4' 'rack3test5' 'rack3test6' 'rack3test7' 'rack3test8' 'rack3test9' ... %test
};