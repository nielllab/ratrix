function out=findStationsForSubject(subject)

switch subject
    case 'rat_113'
        out=3;
    case 'rat_102'
        out=1;
    case 'rat_106'
        out=[1 2]; %rev chron
    case 'rat_114'
        out=[9 11]; %rev chron
    case 'rat_116'
        out=[9];
    case 'rat_117'
        out=[9 4]; %rev chron
    case 'rat_126'
        out=[1 3]; %rev chron
    case 'rat_127'
        out=[1 9];
    case 'rat_128'
        out=2;
    case 'rat_129'
        out=[11 4]; %rev chron
    case 'rat_130'
        out=9;
    case 'rat_131'
        out=4;
    case 'rat_112'
        out=[1 3]; %rev chron
    case 'rat_115'
        out=[9 11];
    case 'rat_118'
        out=9;
    case 'rat_119'
        out=4;
    case 'rat_132'
        out=2;
    case 'rat_133'
        out=2;
    case 'rat_134'
        out=4;
    case 'rat_135'
        out=4;
    case 'rat_136'
        out=4;
    case 'rat_137'
        out=4;
    case 'rat_138'
        out=2;
    case 'rat_139'
        out=2;
    case 'rat_140'
        out=3;
    case 'rat_141'
        out=3;
    case 'rat_142'
        out=3;
    case 'rat_143'
        out=3;
    case 'rat_144'
        out=3;
    case 'rat_145'
        out=11;
    case 'rat_146'
        out=11;
    case 'rat_147'
        out=11;
    case 'rat_148'
        out=11;
    case 'rat_195'
        out=3;
    case 'rat_196'
        out=1;
    case 'rat_213'
        out=3;
    case 'rat_215'
        out=3;
    case 'rat_216'
        out=3;
    case 'rat_214'
        out=11;
    case 'rat_219'
        out=11;
    case 'rat_217'
        out=11;
    case 'rat_218'
        out=11;
    case 'rat_220'
        out=11;
    case 'rat_221'
        out=1;
    case 'rat_222'
        out=1;
    otherwise
        error('unknown rat')
end
