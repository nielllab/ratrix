package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RlabNetworkInputWorker extends RlabNetworkWorker
{
    // Class Variables
    public static final double KEEP_ALIVE_TIMEOUT_DEFAULT = 4.0;

    // Instance Variables
    private List incomingCommands[]; // Incoming list of commands coming from the other side
    private InputStream in = null;
    private ObjectInputStream objIn = null;
    protected long lastKeepAlive;
    protected double keepAliveTimeout=KEEP_ALIVE_TIMEOUT_DEFAULT; // Restart connection if keep alive not sent in time (seconds)


    // Class Constructors
    public RlabNetworkInputWorker(RlabNetworkNode node, Socket socket) throws InstantiationException
    {
	this(node,socket,KEEP_ALIVE_TIMEOUT_DEFAULT);
    }

    public RlabNetworkInputWorker(RlabNetworkNode node, Socket socket, double keepAliveTimeout) throws InstantiationException
    {
	super(node,socket);
	
	incomingCommands = new List[RlabNetworkCommand.MAX_PRIORITIES+1];
	for(int i=0;i<incomingCommands.length;i++)
	    incomingCommands[i] = Collections.synchronizedList(new ArrayList());
	try
	{
	    in = socket.getInputStream(); // Assign the input stream
	    objIn = new ObjectInputStream(in);
	}
	catch (java.io.IOException e)
	{
	    throw new InstantiationException("Unable to open input streams on socket in input worker thread" + e);
	}
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
            if(this.objIn != null)
	    {
                objIn.close();
		objIn = null;
	    }
            if(this.in != null)
	    {
                in.close();
		in = null;
	    }
            RlabDebugWriter.write("RlabNetworkInputWorker garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
    
    protected synchronized void putIncomingCommand(RlabNetworkCommand com)
    {
	// put command on queue
	incomingCommands[com.priority].add(com);
	// notify everyone that there is a command
	notifyAll();
    }

    public synchronized RlabNetworkCommand waitForCommands(Integer possibleCommands[])
    {
	Integer priorities[] = new Integer[possibleCommands.length];
	for(int i=0;i<possibleCommands.length;i++)
	{
	    priorities[i] = RlabNetworkCommand.MIN_PRIORITY;
	}
	return waitForCommands(possibleCommands,priorities);
    }

    public synchronized RlabNetworkCommand waitForCommands(Integer possibleCommands[], Integer priorities[])
    {
	// Default to no timeout
	return waitForCommands(possibleCommands,priorities,0);
    }

    public synchronized RlabNetworkCommand waitForCommands(Integer possibleCommands[], Integer priorities[], double timeout)
    {
	// timeout is defined in seconds
	RlabNetworkCommand com=null;
	long startTime = System.currentTimeMillis();
	com = findCommands(possibleCommands,priorities);
	// We should only wait for commands if we're still connected to avoid waiting forever
	while(this.node.isConnected()  && com == null && (System.currentTimeMillis()-startTime < timeout*1000 || timeout == 0))
        {
	    try
	    {
		wait(500);  // Every 500 milliseconds wake up and check if we're actually still connected
	    } catch (InterruptedException e)  { }
	    com = findCommands(possibleCommands,priorities);
	}
	if(com == null && timeout != 0 && System.currentTimeMillis()-startTime > timeout*1000)
	{
	    RlabDebugWriter.write("Timed out waiting for commands in RlabNetworkInputWorker.waitForCommands()");
	}
	return com;
    }

    // This method is different than the rest of the API, in that it looks for the given commands at any priority that is equal to or higher than the passed in priority
    // Other methods only look at the particular passed in priority.  To prevent outside classes from being confused with this inconsistency, it is made private
    // This doesn't alter the fact that waitForCommands() (and any other method that calls this function) still behaves differently, however.
    private RlabNetworkCommand findCommands(Integer possibleCommands[], Integer priorities[])
    {
	RlabNetworkCommand com=null;
	// Check for highest priority first
	for(int i=0;i<incomingCommands.length;i++)
	{
	    for(int j=0;j<possibleCommands.length;j++)
	    {
		// If the current priority in the loop is an equal or lower number (meaning equal or higher priority) than the given command's minimum priority then check if it exists
		if(i<=priorities[j])
		{
		    com = checkForSpecificCommand(possibleCommands[j],i);
		    if(com!=null)
		    {
			return com;
		    }
		}
	    }
	}
	return null;
    }

    public int incomingCommandsAvailable(int priority)    {
	// Return the number of incoming commands available
	if(priority < 0 || priority >= incomingCommands.length)
	    return 0;
	return incomingCommands[priority].size();
    }

    public int incomingCommandsAvailable()
    {
	int avail=0;
	for(int i=0;i<incomingCommands.length;i++)
	{
	    avail+=incomingCommands[i].size();
	}
	return avail;
    }

    public RlabNetworkCommand checkForSpecificCommand(int command,int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	for(int i=0;i<incomingCommands[priority].size();i++)
	{
	    RlabNetworkCommand cmd = (RlabNetworkCommand) incomingCommands[priority].get(i); 
	    if(cmd.command == command)
	    {
		return getNextCommand(priority,i);
	    }
	}
	return null;
    }

    public RlabNetworkCommand checkForSpecificCommand(int command)
    {
	for(int i=0;i<incomingCommands.length;i++)
	{
	    for(int j=0;j<incomingCommands[i].size();j++)
	    {
		RlabNetworkCommand cmd = (RlabNetworkCommand) incomingCommands[i].get(j); 
		if(cmd.command == command)
		{
		    return getNextCommand(i,j);
		}
	    }
	}
	return null;
    }

    public RlabNetworkCommand checkForSpecificPriority(int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>0)
	{
	    RlabNetworkCommand cmd = (RlabNetworkCommand) incomingCommands[priority].get(0); 
	    return (RlabNetworkCommand) incomingCommands[priority].remove(0);
	}
	return null;
    }

    public RlabNetworkCommand getNextCommand(int priority, int index)
    {
	RlabNetworkCommand cmd;
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>index)
	{
	    cmd = (RlabNetworkCommand) incomingCommands[priority].remove(index);
	    if(cmd != null)
	    {
		RlabDebugWriter.write("RNIWInQueueCmd("+cmd+")");
	    }
	    return cmd;
	}
	return null; // No commands available
    }

    public RlabNetworkCommand getNextCommand(int priority)
    {
	return getNextCommand(priority,0);
    }

    public RlabNetworkCommand getNextCommand()
    {
	RlabNetworkCommand cmd;
	for(int i=0;i<incomingCommands.length;i++)
	{
	    cmd = getNextCommand(i,0);
	    if(cmd != null)
	    {
		return cmd;
	    }
	}
	return null; // No commands available
    }

    public RlabNetworkCommand peekNextCommand(int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>0)
	{
	    return (RlabNetworkCommand) incomingCommands[priority].get(0);
	}
	return null; // No commands available
    }

    public RlabNetworkCommand peekNextCommand()
    {
	for(int i=0;i<incomingCommands.length;i++)
	{
	    if(incomingCommands[i].size()>0)
	    {
	    return (RlabNetworkCommand) incomingCommands[i].get(0);
	    }
	}
	return null; // No commands available
    }

    public boolean checkAlive()
    {
	double secondsSince = (System.currentTimeMillis()-this.lastKeepAlive)/1000.0;
	if(secondsSince > this.keepAliveTimeout)
	    return false;
	else
	    return true;
    }

    public void resetKeepAlive()
    {
	this.lastKeepAlive = System.currentTimeMillis();
    }


    protected void handleRequests()
    {
	
	RlabNetworkCommand com;
	resetKeepAlive();
	//RlabDebugWriter.write("Entering input worker loop with on status " + workerOn);	
	while(workerOn)
	{
	    // Try and write any commands out and read any new commands coming in
	    try
	    {
		com = (RlabNetworkCommand) objIn.readObject();
	    }
	    catch (java.net.SocketTimeoutException e)
	    {
		// Timed out waiting for an object
		continue;
	    }
	    catch (Exception e)
	    {
		RlabDebugWriter.error("Unable to read the network command object from the socket in the input worker thread" + e);
		workerOn = false;
		break;
	    }
	    com.setArrivalTime(); // Set the arrival time on the incoming command
	    RlabDebugWriter.write(RlabDebugWriter.MIN_LOG_LEVEL,"RNIWRevdCmd:\t"+com);
	    if(com.arguments != null)
	    {
		for(int i=0;i<com.arguments.length;i++)
		{
		    byte[] b;
		    if(com.arguments[i] instanceof java.lang.String ||
		       com.arguments[i] instanceof java.lang.Double)
			continue;
		    if(com.arguments[i] instanceof byte[])
		    {
			try{ b = (byte[]) com.arguments[i]; }
			catch(Exception e) 
			{
			    RlabDebugWriter.error("Unable to write byte array to .mat file" + e);
			    workerOn = false;
			    break;
			}
			String fpath = new String(this.node.getTemporaryPath() + java.io.File.separator + ".tmp-java-" + com.UID + "-" + i + "-incoming.mat");
			//RlabDebugWriter.write("Writing to file " + fpath );
			File f = new File(fpath);
			FileOutputStream fis;
			try
			{
			    fis = new FileOutputStream(f);
			    fis.write(b);
			    fis.close();
			}
			catch(Exception e) 
			{
			    RlabDebugWriter.error("Unable to write .mat file out\n" + e); 
			    workerOn = false;
			    break;
			}
			com.arguments[i] = (Object) f;
		    }
		}
	    }
	    //RlabDebugWriter.write("Done reading incoming message on worker");
	    // Let the parent node handle this particular command
	    node.handleIncomingCommand(com);
	    // Check if node is still alive
	    if(!this.checkAlive())
	    {
		RlabDebugWriter.error("Node timeout has expired for keep alive" );
		workerOn = false;
		break;
	    }
	    
	}
	try
	{
	    node.shutdown();
	    objIn.close();
	    in.close();
	    super.shutdown();
	}
	catch(Exception e)
	{
	    RlabDebugWriter.error("Unable to close cleanly in input worker" + e);
	}
	RlabDebugWriter.write("Closing input worker");
    }
}
