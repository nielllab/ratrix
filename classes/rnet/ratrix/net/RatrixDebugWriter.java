package ratrix.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RatrixDebugWriter
{
    private static boolean isOn=false;
    private static FileWriter fw=null;
    private static File f=null;
    private static int logLevel=0;
    public static final int MIN_LOG_LEVEL=0;
    public static final int MAX_LOG_LEVEL=9;
    public static final int DEFAULT_LOG_LEVEL=0;

    public static boolean initialized()
    {
	return isOn;
    }

    public static void initWriter(String path) throws IOException
    {
	initWriter(path,true);
    }
    
    public static void initWriter(String path, boolean append) throws IOException
    {
	initWriter(path,append,0);
    }

    public static void initWriter(String path, boolean append, int level) throws IOException
    {
	// If the writer was already opened, shut the old one down
	closeWriter();
	if(level < MIN_LOG_LEVEL || level > MAX_LOG_LEVEL)
	{
	    throw new IOException("initWriter(): Not a valid log level");
	}
	logLevel = level;

	f = new File(path);
	if(f.isDirectory())
	{
	    throw new IOException("RatrixDebugWriter: Can't overwrite directory");
	}
	else
	{
	    fw= new FileWriter(f,append);
	}
	isOn = true;
	write("*******DEBUG WRITER V2 INITIALIZED AT " + new Date() + "*************");
    }

    public static void closeWriter()
    {
	if(isOn)
	{
	    if(fw!=null)
	    {	    
		try
		{
		    fw.close();
		}
		catch(Exception e)
		{
		    // Do nothing
		}
	    }
	    isOn=false;
	}
    }

    public static void write(String out)
    {
	write(DEFAULT_LOG_LEVEL,out);
    }

    public static void write(int level, String out)
    {
	// Only log things at least as important as that specified by logLevel
	if(level >= logLevel && isOn)
	{
	    try
	    {
		fw.write(out + "\n");
		fw.flush();
	    }
	    catch(Exception e)
	    {
		System.err.println("RDWriter: Error writing to log file");
		System.out.println(out);
	    }
	}
	else if (!isOn)
	{
	    System.out.println("RDWOFF: " + out);
	}
    }

    public static void error(String out)
    {
	System.err.println(out);
	if(isOn)
	{
	    try
	    {
		fw.write(out + "\n");
		fw.flush();
	    }
	    catch(Exception e)
	    {
		// Don't error on an exception during an error!
	    }
	}
    }


}
