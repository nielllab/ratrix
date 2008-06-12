package ratrix.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RatrixNetworkClient implements Runnable
{
    // Class Variables
    // Instance Variables
    public static final double KEEP_ALIVE_SEND_FREQUENCY_DEFAULT = 1.0;
    public static final double KEEP_ALIVE_TIMEOUT_DEFAULT = 4.0;
    private List outgoingCommands; // Outgoing list of commands going to the server
    private List incomingCommands[]; // Incoming list of commands coming from the server
    private boolean clientOn = false; // Whether worker should be running
    private boolean connected = false; // Whether client is currently connected
    private Socket socket = null; // Socket used for communication with server
    private RatrixNetworkClientIdent clientId = null;
    private InputStream in = null;
    private ObjectInputStream objIn = null;
    private OutputStream out = null;
    private ObjectOutputStream objOut = null;
    private int nextCommandUID = 1;
    private String connectHost; // Host to connect to
    private int connectPort; // Port to connect to
    private boolean shutdownComplete = false; // Whether shutdown has completed and a reconnect is allowed
    private long lastKeepAlive;
    private double keepAliveSend = KEEP_ALIVE_SEND_FREQUENCY_DEFAULT; // How often to send a keep alive
    private double keepAliveAckTimeout=KEEP_ALIVE_TIMEOUT_DEFAULT; // Restart server connection if keep alive ack not sent in time (seconds)

    public boolean debug=false; // Whether debug mode is turned on
    public String tmpPath = null;
    public static final int MAX_COMMAND_UID = 999;

    // Class Constructors
    public RatrixNetworkClient(String id, String host, int port) throws InstantiationException
    {
	this(id,host,port,true);
    }

    public RatrixNetworkClient(String id, String host, int port, boolean debugMode) throws InstantiationException
    {
	this(id,host,port,debugMode,KEEP_ALIVE_SEND_FREQUENCY_DEFAULT,KEEP_ALIVE_TIMEOUT_DEFAULT);
    }

    public RatrixNetworkClient(String id, String host, int port, boolean debugMode, double keepAliveSend, double keepAliveAckTimeout) 
	throws InstantiationException
    {
	clientId = new RatrixNetworkClientIdent(id);
	this.debug = debugMode;
	this.keepAliveSend = keepAliveSend;
	this.keepAliveAckTimeout = keepAliveAckTimeout;
	if(debugMode)
	{
	    try
	    {
		RatrixDebugWriter.initWriter("." + File.separator + "RNetClientLog.txt",true,RatrixDebugWriter.MIN_LOG_LEVEL);
	    }
	    catch(Exception e)
	    {
		throw new InstantiationException("Unable to open debug file for writing in RatrixNetworkClient");
	    }
	}
	connectHost = host;
	connectPort = port;
	clientOn = true;
	nextCommandUID = 1;
	incomingCommands = new List[RatrixNetworkCommand.MAX_PRIORITIES+1];
	for(int i=0;i<incomingCommands.length;i++)
	    incomingCommands[i] = Collections.synchronizedList(new ArrayList());
	outgoingCommands = Collections.synchronizedList(new ArrayList());
	connect();
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
            if(this.objIn != null)
                objIn.close();
            if(this.objOut != null)
                objOut.close();
            if(this.in != null)
                in.close();
            if(this.out != null)
                out.close();
            RatrixDebugWriter.write("RatrixNetworkClient garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
    
    private void connect() throws InstantiationException
    {
	try
	{
        RatrixDebugWriter.write("calling Socket()");
	    socket = new Socket(connectHost,connectPort);
	    socket.setTcpNoDelay(true);
	    socket.setSendBufferSize(65536);
	    socket.setReceiveBufferSize(65536);
	    socket.setKeepAlive(true);
	    in = socket.getInputStream(); // Assign the input stream
	    out = socket.getOutputStream(); // Assign the output stream
	    objOut = new ObjectOutputStream(out);
        RatrixDebugWriter.write("Completed Socket Init, sending connect message()");
	}
	catch (java.io.IOException e)
	{
	    throw new InstantiationException("Unable to open I/O streams on server socket in client thread");
	}
	// Put the connect command on the outgoing list
	RatrixNetworkCommand regCom = new RatrixNetworkCommand(getNextCommandUID(),clientId,RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,RatrixNetworkCommand.C_CONNECT_COMMAND);
	try
	{
	    objOut.writeObject(regCom);  // Can't put it on the queue, because this send how we detect the socket is not functional
	    objOut.flush();
        RatrixDebugWriter.write("remoteAddress:" + socket.getRemoteSocketAddress().toString() + "isBound:" + socket.isBound() + "isClosed:" + socket.isClosed());
        RatrixDebugWriter.write("isConnected:" + socket.isConnected() + "isInputShutdown:" + socket.isInputShutdown() "isOutputShutdown:" + socket.isOutputShutdown());
	}
	catch(IOException e)
	{
	    throw new InstantiationException("Unable to send connection message in RatrixNetworkClient constructor");
	}
	RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNCSentCmd:\t"+regCom);
	connected = true;
    }

    public boolean isConnected()
    {
	return connected;
    }

    public void reconnect() throws InstantiationException
    {
	reconnect(0);
    }

    // timeout - in milliseconds
    public void reconnect(int timeout) throws InstantiationException
    {
	shutdown();
	long start=System.currentTimeMillis();
	while(!shutdownComplete && (System.currentTimeMillis()-start < timeout || timeout == 0))
	{
	    try
	    {
		Thread.sleep(500); // Let other things run while waiting
	    }
	    catch (InterruptedException e)
	    {
		// Do nothing
	    }
	}
	objIn = null; // Make sure the input object is null
	connect();
    }

    protected void resetKeepAlive()
    {
	this.lastKeepAlive = System.currentTimeMillis();
    }

    protected boolean checkAlive()
    {
	double secondsSince = (System.currentTimeMillis()-this.lastKeepAlive)/1000.0;
	if(secondsSince > this.keepAliveAckTimeout)
	    return false;
	else
	    return true;
    }



    public synchronized int getNextCommandUID()
    {
	int retUID = 0;
	if(this.nextCommandUID > RatrixNetworkClient.MAX_COMMAND_UID)
	{
	    this.nextCommandUID = 1;
	}
	retUID = this.nextCommandUID;
	this.nextCommandUID++;
	return retUID;
    }

    public void run()
    {
	handleRequests();
    }

    public void shutdown()
    {
	clientOn = false;
    }

    public boolean isShutdown()
    {
	return shutdownComplete;
    }

    public boolean clientOn()
    {
	return clientOn;
    }


    public void setTemporaryPath(String tmpPath)
    {
	this.tmpPath = tmpPath;
    }


    // Synchronously send commands to the server
    public synchronized void sendCommandToServer(RatrixNetworkCommand com) throws IOException
    {
	try
	{
	    com = formatCommandForSend(com);
	    objOut.writeObject(com);
	    objOut.flush();
	}
	catch(IOException e)
	{
	    shutdown();
	    throw e;
	}
	RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNCMSentCmd:\t"+com);
    }

    // Asynchronously send commands to the server
    private void oldSendCommandToServer(RatrixNetworkCommand com) throws IOException
    {
	// Put a command going to the server on the outgoing commands list
	//RatrixDebugWriter.write("In send command to server\n");
	com = formatCommandForSend(com);
	outgoingCommands.add(com);
	RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNCMOutCmdQueued:\t"+com);

    }


    protected RatrixNetworkCommand formatCommandForSend(RatrixNetworkCommand com) throws IOException
    {
	if(com.arguments != null)
	{
	    for(int i=0;i<com.arguments.length;i++)
	    {
		if(com.arguments[i] instanceof java.io.File)
		{
		    File f = (java.io.File) com.arguments[i];
		    FileInputStream fis;
		    byte[] b;
		    try
		    { 
			fis = new FileInputStream(f);
			long len = f.length();
			RatrixDebugWriter.write("Java file length " + len);
			b = new byte[(int)len];
			fis.read(b);
			fis.close();
		    }
		    catch (Exception e)	
		    {
			RatrixDebugWriter.error("Unable to read .mat file in"); 
			throw new IOException("formatCommandForSend(): Unable to read .mat file in for outgoing command");
		    }
		    com.arguments[i] = (Object) b;
		    b = (byte []) com.arguments[i];
		    //RatrixDebugWriter.write("Java rewrite length " + b.length);
		}
	    }
	}
	return com;
    }

    public int commandsAvailable(int priority) throws ArrayIndexOutOfBoundsException
    {
	// Return the number of incoming commands available
	if(priority < 0 || priority >= incomingCommands.length)
	    throw new ArrayIndexOutOfBoundsException("Incoming Commands Array Indice Out of Bounds");
	return incomingCommands[priority].size();
    }

    public int commandsAvailable()
    {
	int avail=0;
	for(int i=0;i<incomingCommands.length;i++)
	{
	    avail+=incomingCommands[i].size();
	}
	return avail;
    }

    public RatrixNetworkClientIdent getClientId()
    {
	return clientId;
    }

    public RatrixNetworkClientIdent getClientIdent()
    {
	return clientId;
    }

    public RatrixNetworkCommand checkForSpecificCommand(int command, int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	for(int i=0;i<incomingCommands[priority].size();i++)
	{
	    RatrixNetworkCommand cmd = (RatrixNetworkCommand) incomingCommands[priority].get(i); 
	    if(cmd.command == command)
	    {
		return getNextCommand(priority,i);
	    }
	}
	return null;
    }

    public RatrixNetworkCommand checkForSpecificCommand(int command)
    {
	for(int i=0;i<incomingCommands.length;i++)
	{
	    for(int j=0;j<incomingCommands[i].size();j++)
	    {
		RatrixNetworkCommand cmd = (RatrixNetworkCommand) incomingCommands[i].get(j); 
		if(cmd.command == command)
		{
		    return getNextCommand(i,j);
		}
	    }
	}
	return null;
    }

    public RatrixNetworkCommand checkForSpecificPriority(int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>0)
	{
	    RatrixNetworkCommand cmd = (RatrixNetworkCommand) incomingCommands[priority].get(0); 
	    return (RatrixNetworkCommand) incomingCommands[priority].remove(0);
	}
	return null;
    }


    public RatrixNetworkCommand getNextCommand()
    {
	// Get the next available command, if any, coming from the server
	for(int i=0;i<incomingCommands.length;i++)
	{
	    if(incomingCommands[i].size() > 0)
	    {
		return getNextCommand(i,0);
	    }
	}
	return null; // No commands available
    }

    public RatrixNetworkCommand peekNextCommand()
    {
	// Get the next available command, if any, coming from the server
	for(int i=0;i<incomingCommands.length;i++)
	{
	    if(incomingCommands[i].size() > 0)
	    {
		return (RatrixNetworkCommand) incomingCommands[i].get(0); 
	    }
	}
	return null; // No commands available
    }

    public RatrixNetworkCommand getNextCommand(int priority, int index)
    {
	RatrixNetworkCommand com;
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size() > index)
	{
	    RatrixNetworkCommand oldestCmd;
	    oldestCmd=peekNextCommand();
	    com = (RatrixNetworkCommand) incomingCommands[priority].remove(index);
	    String oldest;
	    if(oldestCmd == null)
		oldest = new String("<null>");
	    else
		oldest = oldestCmd.toString();
	    Date d = new Date();
	    Double tm = new Double((d.getTime()-com.arrived.getTime())/1000.0);
	    Integer avail = new Integer(commandsAvailable());
	    RatrixDebugWriter.write("RNCInQueueCmd("+avail+"):\t"+com+"\tpt: "+tm+"oldest["+clientId+"]:"+oldest);
	    return com;
	}
	return null;
    }

    private void handleRequests()
    {
	RatrixNetworkCommand com;
	RatrixNetworkClientKeepAliveSender kaSend;
	int numBytes;
	// Create the keep alive sender class and start it
	kaSend = new RatrixNetworkClientKeepAliveSender(this,clientId,keepAliveSend);
	Thread k = new Thread(kaSend);
	shutdownComplete = false;
	k.start();
	resetKeepAlive();
	while(clientOn)
	{
	    // Check if there are new incoming commands
	    try
	    {
		numBytes = in.available();
	    }
	    catch (IOException e)
	    {
		RatrixDebugWriter.error("Unable to read the number of bytes available from the socket in the client thread");
		clientOn = false;
		break; // Exit the loop and shutdown
	    }
	    // Write out outgoing commands
	    if(outgoingCommands.size() > 0)
	    {
		com = (RatrixNetworkCommand) outgoingCommands.remove(0);
		//RatrixDebugWriter.write("About to write incoming message on worker of com " + com.command);
		try
		{
		    objOut.writeObject(com);
		    objOut.flush();
		    if(com.command != RatrixNetworkCommand.C_KEEP_ALIVE_COMMAND)
		    {
			RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNCSentCmd:\t"+com);
		    }
		}
		catch (IOException e)
		{
		    RatrixDebugWriter.error("Unable to write the network command object to the socket in the client thread");
		    clientOn = false;
		    break; // Exit the loop and shutdown
		}
	    }
	    // Read in commands
	    if(numBytes > 4)
	    {
		//RatrixDebugWriter.write("Reading network data on client worker");
		try
		{
		    // Initialize the input stream ... not done until there is data on the input line, because it blocks
		    if(objIn == null)
		    {
			objIn = new ObjectInputStream(in);
		    }			
		    com = (RatrixNetworkCommand) objIn.readObject();
		    com.setArrivalTime(); // Set the arrival time on the incoming command
		    RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNCRevdCmd:\t"+com);
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
				    RatrixDebugWriter.error("Unable to write byte array to .mat file");
				    clientOn = false;
				    break;  // Exit the loop and shutdown
				}
				String fpath = new String(tmpPath + java.io.File.separator + ".tmp-java-" + 
							  RatrixNetworkCommand.CLIENT_TYPE + "-" + com.UID + "-" + i + "-incoming.mat");
				//RatrixDebugWriter.write("Writing to file " + fpath );
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
				    RatrixDebugWriter.error("Unable to write .mat file out\n"); 
				    clientOn = false;
				    break;  // Exit the loop and shutdown
				}
				com.arguments[i] = (Object) f;
			    }

			}
		    }
		}
		catch (Exception e)
		{
		    RatrixDebugWriter.error("Unable to read the network command object from the socket in the client thread");
		    clientOn = false;
		    break;  // Exit the loop and shutdown
		}
		if(com.command == RatrixNetworkCommand.S_KEEP_ALIVE_ACK_COMMAND)
		{
		    resetKeepAlive();
		}
		else
		{
		    incomingCommands[com.priority].add(com);
		}
		//RatrixDebugWriter.write("Done reading network data on client worker");
	    }
	    // Check if server is still alive
	    if(!this.checkAlive())
	    {
		RatrixDebugWriter.write("Client timeout has expired for server keep alive" );
		connected = false;
		// Attempt to reconnect automatically if shutdown, until told to shutdown
		//while(clientOn && connected==false)
		//{
		//    try{   
		//	reconnect(); 
		//	Thread.sleep(500);
		//    } catch(Exception e) { } // Do nothing
		//}
		break;
	    }
	    try
	    {
		// Should be selecting, not polling here FIX ME!!!
		Thread.sleep(0);
	    }
	    catch (InterruptedException e)
	    {
		// Do nothing
	    }
	}
	RatrixDebugWriter.write("Client worker closing, sending disconnect message");
	// Write the disconnect command on the outgoing list
	RatrixNetworkCommand regCom = new RatrixNetworkCommand(this.getNextCommandUID(),clientId,RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,RatrixNetworkCommand.C_DISCONNECT_COMMAND);
	try
	{
	    objOut.writeObject(regCom);
	    objOut.flush();
	    // Close the i/o streams and the socket
	    if(objIn != null)
	    {
		objIn.close();
		objIn = null; // In case the object is reused, objIn must be null on startup
	    }
	    objOut.close();
	    in.close();
	    out.close();
	    outgoingCommands.clear();
	    for(int i=0;i<incomingCommands.length;i++)
		incomingCommands[i].clear();
	}
	catch (Exception e)
	{
	    // Do nothing, closing anyway
	    RatrixDebugWriter.error("Problem closing i/o streams or socket");
	}
	try
	{
	    socket.close();
	}
	catch(Exception e)
	{
	    // Do nothing
	}
	connected = false;
	RatrixDebugWriter.closeWriter();
	shutdownComplete = true; // Indicate to the other threads that shutdown is complete
    }

    // Debug main
    public static void main(String[] argv)
    {
	for(int i=0;i<1;i++)
	{
	    testMain();
	    // Must delay between attempts, otherwise the client could connect to the old server
	    //try{ Thread.sleep(5000); } catch (Exception e) {}
	}
    }
    public static void testMain()
    {
	String id = "Test";
	RatrixNetworkClient r;
	RatrixNetworkCommand com;
	Object args[];
	byte b[];
	int numBytes = 20;
	args = new Object[1];
	b = new byte[numBytes];
	for(int i=0;i<numBytes;i++)
	{
	    b[i] = Byte.parseByte("68");
	}
	args[0] = (Object) b;
	try
	{
	    r = new RatrixNetworkClient(id,"192.168.0.1",RatrixNetworkServer.SERVER_PORT);
	}
	catch (InstantiationException e)
	{
	    RatrixDebugWriter.error("Unable to create RatrixNetworkClient object in debug main");
	    return;
	}
	Thread t = new Thread(r);
	t.start();
	// Send/receive some commands over to the server
	RatrixNetworkCommand inCom = null;
	while(inCom == null)
	{
	    inCom = r.checkForSpecificCommand(1);
	}
	com = new RatrixNetworkCommand(r.getNextCommandUID(),r.getClientId(),RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,2);
	try
	{
	    r.sendCommandToServer(com);
	}
	catch(Exception e)
	{
	    System.err.println("Unexpected exception in testMain when sending command to server");
	}
	inCom = null;
	while(inCom == null)
	{
	    inCom = r.checkForSpecificCommand(3);
	}
	com = new RatrixNetworkCommand(r.getNextCommandUID(),r.getClientId(),RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,4);
	try
	{
	    r.sendCommandToServer(com);
	}
	catch(Exception e)
	{
	    System.err.println("Unexpected exception in testMain when sending command to server");
	}
	try
	{
	    t.sleep(1000);
	}
	catch(Exception e)
        {
	}
	r.shutdown();
	try
	{
	    t.join();
	}
	catch(InterruptedException e)
	{
	    // Do nothing
	    RatrixDebugWriter.error("Interrupted from join in client");
	}
	

    }
}
