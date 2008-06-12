% Trying java xpath pars
import javax.xml.xpath.*
import javax.xml.parsers.*

% First load the doc and parse it
factory = DocumentBuilderFactory.newInstance();
factory.setNamespaceAware(true);
builder = factory.newDocumentBuilder();
% SVN XML returns two important items, the working copy revision number (entry), and the
% repository location, which can then be used to determine the repository
% revision number
[s w] = dos('svn info -xml');
doc = builder.parse(dsfile);
entryNodeList=doc.getElementsByTagName('entry');
if entryNodeList.length ~= 1
    error('SVN XML Definition changed, multiple commit tags!');
end
entryNode = entryNodeList.item(0);
enMap = entryNode.getAttributes();
entryRevItem = enMap.getNamedItem('revision');
workingCopyRev = sscanf(entryRevItem.getTextContent.toCharArray(),'%d');
xpf = XPathFactory.newInstance();
xpa = xpf.newXPath();


xpa.evaluate('/tag1[tag2="bob"]/name', doc)