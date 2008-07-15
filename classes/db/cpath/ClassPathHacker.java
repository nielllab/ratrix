package cpath;
import java.lang.reflect.*;
import java.io.*;
import java.net.*;

/*
 * What does this class do? 
 * The following class allows us to add a path to the system class loader dynamically
 * 
 * How does it do it?
 * The SystemClassLoader has no methods to add a file to the class path.  However, it is 
 * actually a subclass of URLClassLoader, so if the system class loader is cast as a URLClassLoader
 * and then by reflection the addURL() method of this cast object is set to be accessible,
 * the method will be able to be called.
 *
 * Why is it needed?
 *
 * The java.sql.DriverManager class expects any jdbc driver to be loaded 
 * using the SystemClassLoader, which is the default class loader in java.
 * However, Matlab uses its own class loader, most likely for the reason that Java's 
 * system class loader does not allow dynamic adding of the java path, which 
 * Matlab wanted to support.  
 *
 * So when the following is called in Matlab:
 *
 * javaaddpath(jdbcPath)
 * ...
 * % Go to different file because Matlab doesn't support the import and the 
 * % add path to be in the same file
 * ...
 * import oracle.jdbc.driver.OracleDriver
 * java.sql.DriverManager.getConnection(url,user,password);
 * 
 * DOES NOT WORK: There will be an error in the getConnection call, because the jdbc driver 
 * is not in the system class loader's path
 *
 * Instead, by using this class, the following can be called in Matlab:
 *
 * javaaddpath(cpathPath)
 * ...
 * % Go to different file
 * ...
 * import cpath
 * cpath.ClassPathHacker.addFile(java.lang.String(jdbcPath)
 * ...
 * % Go to different file
 * ...
 * import oracle.jdbc.driver.OracleDriver
 * java.sql.DriverManager.getConnection(url,user,password);
 *
 * WORKS!
 *
 * Issues?
 * This is a hack that is reliant on two things:
 * 1. The system class loader will continue to remain a subclass of URLClassLoader, 
 *    it is not explicitly listed as one, so Sun is free to change this 
 * 2. That reflection will continue to be allowed to be run on this "internal" object
 *
 * Hopefully things will not change.  If they do, then jdbc drivers can still be used in 
 * Matlab without using the DB toolbox, but the driver .jar file would need to be put in 
 * the static classpath.txt file
 */


public class ClassPathHacker {
 
private static final Class[] parameters = new Class[]{URL.class};
 
public static void addFile(String s) throws IOException {
	File f = new File(s);
	addFile(f);
}//end method
 
public static void addFile(File f) throws IOException {
    URI u = f.toURI();
	addURL(u.toURL());
}//end method
 
 
public static void addURL(URL u) throws IOException {
		
	URLClassLoader sysloader = (URLClassLoader)ClassLoader.getSystemClassLoader();
	Class sysclass = URLClassLoader.class;
 
	try {
		Method method = sysclass.getDeclaredMethod("addURL",parameters);
		method.setAccessible(true);
		method.invoke(sysloader,new Object[]{ u });
	} catch (Throwable t) {
		t.printStackTrace();
		throw new IOException("Error, could not add URL to system classloader");
	}//end try catch
		
}//end method
 
}//end class
