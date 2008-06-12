clc

addpath('C:\Documents and Settings\rlab\Desktop\ratrix\bootstrap')
setupEnvironment

dir1='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\test\subjects\';
dir2='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\test2\subjects\';
targetDir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\subjects\';

d1=dir(dir1);
d2=dir(dir2);

[sorted order1]=sort({d1.name});
[sorted order2]=sort({d2.name});

d1=d1(order1);
d2=d2(order2);


for i=1:length(d1)
    if ~ismember(d1(i).name,{'.','..'})
        if ismember(d1(i).name,{d2.name})
            these=dir(fullfile(dir1,d1(i).name));
            those=dir(fullfile(dir2,d1(i).name));
            if length(these)~=length(those)
                d1(i).name
                'length mismatch'
            else
                [sorted order1]=sort({these.name});
                [sorted order2]=sort({those.name});
                these=these(order1);
                those=those(order1);

                goods=0;
                dates=[];
                news={};
                for j=1:length(these)
                    if ~ismember(these(j).name,{'.','..'})
                        if ~strcmp(these(j).name,those(j).name) || ~strcmp(these(j).date,those(j).date) || these(j).bytes~=those(j).bytes || these(j).isdir~=those(j).isdir || these(j).datenum~=those(j).datenum
                            'mismatch'
                            d1(i).name
                            these(j)
                            those(j)
                        else
                            goods=goods+1;
                            if ~strcmp(datestr(these(j).datenum,0),these(j).date)
                                'date error'
                                d1(i).name
                                datestr(dates(end),0)
                                these(j).date
                            end

                            f=load(fullfile(dir1,d1(i).name,these(j).name));
                            for k=1:length(f.trialRecords)

                                if(datenum(f.trialRecords(k).date)>these(j).datenum+datenum([0 0 0 0 1 0])) %if any trials occurred after the file's date (plus a minute)
                                    d1(i).name
                                    these(j).name
                                    'found trial after file date'
                                end
                            end

                            if these(j).datenum>datenum(2008,2,22)
                                news{end+1}=fullfile(dir1,d1(i).name,these(j).name);
                                targetfile=fullfile(targetDir,d1(i).name,['recovered.' these(j).name '.recovered']);
                                if true
                                    [succ,message,messageid] = copyfile(news{end}, targetfile);
                                    if ~succ
                                        message
                                        messageid
                                        d1(i).name
                                        these(j).name
                                        'problem copying recovery file'
                                    else
                                        fprintf('good copy: %s\n',targetfile)
                                    end
                                end
                            end
                        end
                    end
                end
%                 fprintf('%d matches in %s\n',goods,d1(i).name)
%                 for j=1:length(news)
%                     fprintf('%s\n',news{j})
%                 end
                fprintf('\n')
            end
        else
            'second dir doesn''t contain'
            d1(i).name
        end
    end
end