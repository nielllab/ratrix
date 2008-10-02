function SVNproperties = getSVNPropertiesForPath(SVNpath, properties)
% This retrieves the selected properties from the svn info XML output for the given SVNpath
% INPUT: SVNpath, properties (cell array of strings)
% OUTPUT: struct SVNproperties, with fields corresponding to the input properties

% Required java import and setup
% Trying java xpath pars
import javax.xml.xpath.*;
import javax.xml.parsers.*;
import java.io.*;

% First load the doc and parse it
factory = DocumentBuilderFactory.newInstance();
factory.setNamespaceAware(true);
builder = factory.newDocumentBuilder();

% Initialize output variables
SVNproperties = [];

svnCommand = [GetSubversionPath sprintf('svn info --xml %s', SVNpath)];
[s w] = system(svnCommand);
if s ~= 0
    pwd
    svnCommand
    s
    w

    if ~isempty(strfind(w,'No route to host')) || ~isempty(strfind(w,'Can''t connect to host'))
        error('can''t see svn server')
        %return empty in this case and try to move on?
        SVNproperties=[];
        return
    else
        error('Unable to execute svn command');
    end
end

jStr = java.lang.String(w);
% Create an input stream from the string
is = ByteArrayInputStream( jStr.getBytes() );
% Parse the XML - loop for each tag in tags
doc = builder.parse(is);

for i=1:length(properties)
    property = properties{i};

    % switch statement on the tag - handle differently depending on each tag
    switch(property)
        case 'revision'
            entryNodeList=doc.getElementsByTagName('entry');
            if entryNodeList.length ~= 1
                error('SVN XML Definition changed, multiple entry tags!');
            end
            entryNode = entryNodeList.item(0);
            enMap = entryNode.getAttributes();
            entryRevItem = enMap.getNamedItem('revision');
            SVNproperties.revision = int64(sscanf(entryRevItem.getTextContent.toCharArray(),'%d'));

        case 'url'
            % Get repository info
            urlNodeList=doc.getElementsByTagName('url');
            if urlNodeList.length ~= 1
                error('SVN XML Definition changed, multiple url tags!');
            end
            urlNode = urlNodeList.item(0);
            url = urlNode.getTextContent().toCharArray();
            SVNproperties.url = url'; % Stored in wrong format

        case 'commit'
            commitNodeList=doc.getElementsByTagName('commit');
            if commitNodeList.length ~= 1
                error('SVN XML Definition has changed, multiple commit tags!');
            end
            commitNode = commitNodeList.item(0);
            commitMap = commitNode.getAttributes();
            commitRevItem = commitMap.getNamedItem('revision');
            SVNproperties.commit = int64(sscanf(commitRevItem.getTextContent.toCharArray(),'%d'));

        otherwise
            error('unsupported property - must be from {wcRev, url}');
    end

end % end loop


end % end function


