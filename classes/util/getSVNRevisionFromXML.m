function [wcRev,repRev,url] = getSVNRevisionFromXML(svnDir)
% [wcRev,repRev] = getSVNRevisionFromXML(svnDir)
%
% This function returns the revision numbers for the working copy
% and the repository associated with the given directory
%
% svnDir - Directory where the working copy of the code resides
%
% wcRev - The revision of the working copy
% repRev - The revision of the repository

% Trying java xpath pars
import javax.xml.xpath.*;
import javax.xml.parsers.*;
import java.io.*;

% First load the doc and parse it
factory = DocumentBuilderFactory.newInstance();
factory.setNamespaceAware(true);
builder = factory.newDocumentBuilder();
% SVN XML returns two important items, the working copy revision number (entry), and the
% repository location, which can then be used to determine the repository
% revision number
oldWD = pwd;
cd(svnDir);
svnCommand = [GetSubversionPath sprintf('svn info --xml')];
% if IsWin
%   [s w] = dos(svnCommand);
% elseif IsOSX
  [s w] = system(svnCommand);
% end
if s ~= 0
    w
  error('Unable to execute svn command');
end
jStr = java.lang.String(w);
% Create an input stream from the string
is = ByteArrayInputStream( jStr.getBytes() ); 
% Parse the XML
doc = builder.parse(is);
entryNodeList=doc.getElementsByTagName('entry');
if entryNodeList.length ~= 1
    error('SVN XML Definition changed, multiple entry tags!');
end
entryNode = entryNodeList.item(0);
enMap = entryNode.getAttributes();
entryRevItem = enMap.getNamedItem('revision');
wcRev = int64(sscanf(entryRevItem.getTextContent.toCharArray(),'%d'));

% Get repository info
urlNodeList=doc.getElementsByTagName('url');
if urlNodeList.length ~= 1
    error('SVN XML Definition changed, multiple url tags!');
end
urlNode = urlNodeList.item(0);
url = urlNode.getTextContent().toCharArray();
url = url'; % Stored in wrong format

svnCommand = [GetSubversionPath sprintf('svn info --xml %s',url)];
% if IsWin
%   [s w] = dos(svnCommand);
% elseif IsOSX
  [s w] = system(svnCommand);
% end
if s ~= 0
    w
  error('Unable to execute svn command');
end
jStr = java.lang.String(w);
% Create an input stream from the string
is = ByteArrayInputStream( jStr.getBytes() ); 
% Parse the XML
doc = builder.parse(is);
entryNodeList=doc.getElementsByTagName('entry');
if entryNodeList.length ~= 1
    error('SVN XML Definition changed, multiple entry tags!');
end
entryNode = entryNodeList.item(0);
enMap = entryNode.getAttributes();
entryRevItem = enMap.getNamedItem('revision');
repRev = int64(sscanf(entryRevItem.getTextContent.toCharArray(),'%d'));
% Change back to the original directory
cd(oldWD);