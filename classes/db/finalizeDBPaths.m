function finalizeDBPaths(jdbcPath)

% Why is this a separate function from setupDBPaths? 
% Because of the import line.  An import line cannot appear
% in the same file as where the class was added to the path

% Add path to oracle jdbc driver to system class loader using cpath package
import cpath.ClassPathHacker
cpath.ClassPathHacker.addFile(java.lang.String(jdbcPath));
