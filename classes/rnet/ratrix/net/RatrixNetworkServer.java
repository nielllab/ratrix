package ratrix.net;
import java.net.Socket;
import java.net.ServerSocket;
import java.util.*;
import java.io.*;

public class RatrixNetworkServer implements Runnable
{
    // Class Variables
    public static final int SERVER_PORT = 2020; // Default server port
    public static final double KEEP_ALIVE_TIMEOUT_DEFAULT = 4.0;
    public static Map managers = Collections.synchronizedMap(new HashMap() ); // List of currently running managers

    // Instance Variables
    private RatrixMap workers; // Map of current worker threads, hashed on client id
    private int serverPort; // Actual server port
    private ServerSocket s;  // Socket server is listening for connections on
    private volatile boolean serverOn = false; // Whether the server should be on or not
    private volatile boolean acceptNewConnections = false; // Whether the server should accept new connections or not
    private volatile boolean serverState = false; // True if server is on, false otherwise
    private volatile boolean resetRequested = false; // Whether a request has been requested
    private int nextCommandUID;
    private double keepAliveTimeout; // Shutdown connection to client if keep alive not sent in time (seconds)
    public String tmpPath = null;
    public static final int MAX_COMMAND_UID = 999;

    // Class Constructors
    public RatrixNetworkServer(int port) throws InstantiationException
    {
	this(port,true);
    }

    public RatrixNetworkServer(int port, boolean debugMode) throws InstantiationException
    {
	this(port,debugMode,KEEP_ALIVE_TIMEOUT_DEFAULT);
    }

    public RatrixNetworkServer(int port, boolean debugMode, double keepAliveTimeout) throws InstantiationException
    {
	serverPort = port;
	if(keepAliveTimeout < 0)
	{
	    throw new InstantiationException("Keep alive timeout must be positive or zero");
	}
	if(debugMode)
	{
	    try
	    {
		RatrixDebugWriter.initWriter("." + File.separator + "RNetServerLog.txt",true,RatrixDebugWriter.MIN_LOG_LEVEL);
	    }
	    catch(Exception e)
	    {
		throw new InstantiationException("Unable to open debug file for writing in RatrixNetworkServer");
	    }
	}
	this.keepAliveTimeout = keepAliveTimeout;
	nextCommandUID = 1;
	if(managers.containsKey(new Integer(port)))
	{
	    throw new InstantiationException("Server already exists on specified port " + port + ", exiting.");
	}
	managers.put(new Integer(serverPort),this); // Assign the manager to the given port
	workers = new RatrixMap(); //Collections.synchronizedMap(new HashMap()); // Create a new list of worker threads
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
	    long shutdownTimeout = 5000; // Let the server timeout on shutdown (milliseconds)
	    long startShutdown = System.currentTimeMillis();
	    while(this.serverState == true && System.currentTimeMillis()-startShutdown < shutdownTimeout)
	    {
		try{ Thread.sleep(10); } catch(Exception e) { } // Do nothing
	    }	    
	    if(System.currentTimeMillis()-startShutdown > shutdownTimeout)
		RatrixDebugWriter.write("RatrixNetworkServer finalize() timedout waiting for server to shutdown");
            RatrixDebugWriter.write("RatrixNetworkServer garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
    
    // Default Class Constructor
    public RatrixNetworkServer() throws InstantiationException
    {
	this(SERVER_PORT); // Use default port number if not specified
    }

    public boolean checkAndResetReconnectState(RatrixNetworkClientIdent clientId)
    {
    	RatrixNetworkServerWorker w = null;
	RatrixNetworkCommand[] cList = null;
	if(workers.containsKey(clientId))
	{
	    w = (RatrixNetworkServerWorker) workers.get(clientId);
	    // Determine if this socket has been reconnected since the last time this has been checked
	    return w.checkAndResetReconnectState();
	}
	return false;
    }

    public boolean checkReconnectState(RatrixNetworkClientIdent clientId)
    {
    	RatrixNetworkServerWorker w = null;
	RatrixNetworkCommand[] cList = null;
	if(workers.containsKey(clientId))
	{
	    w = (RatrixNetworkServerWorker) workers.get(clientId);
	    // Determine if this socket has been reconnected since the last time this has been checked
	    return w.checkReconnectState();
	}
	return false;
    }

    public synchronized int getNextCommandUID()
    {
	int retUID = 0;
	if(this.nextCommandUID > RatrixNetworkServer.MAX_COMMAND_UID)
	{
	    this.nextCommandUID = 1;
	}
	retUID = this.nextCommandUID;
	this.nextCommandUID++;
	return retUID;
    }

    public double getKeepAliveTimeout()
    {
	return keepAliveTimeout;
    }

    public void setTemporaryPath(String tmpPath)
    {
	this.tmpPath = tmpPath;
    }

    public static void shutdownManagerOnPort(int port)
    {
	if(managers.containsKey(new Integer(port)))
	{
	    RatrixNetworkServer m = (RatrixNetworkServer) managers.get(new Integer(port));
	    m.shutdown();
	    managers.remove(new Integer(port));
	}
	else
	{
	    RatrixDebugWriter.error("No server exists on specified port: " + port + "\n");
	}
    }

    public static void shutdownAll()
    {
	Set s = managers.keySet();
	Object o[] = s.toArray();
	for(int i=0;i<o.length;i++)
	{
	    RatrixNetworkServer rns = (RatrixNetworkServer) managers.get(o[i]);
	    rns.shutdown();
	    managers.remove(o[i]);	    
	}
    }

    public static void forceShutdownOnPort(int port)
    {
	if(managers.containsKey(new Integer(port)))
	{
	    RatrixNetworkServer m = (RatrixNetworkServer) managers.get(new Integer(port));
	    if(m.s != null)
	    {
		try
		{
		    m.s.close();
		}
		catch(Exception e)
		{
		    // Do nothing
		}
	    }
	}
	else
	{
	    RatrixDebugWriter.error("No server exists on specified port: " + port + "\n");
	}
    }

    public List listClients()
    {
	return new ArrayList(workers.keySet());
    }

    public boolean clientConnected(RatrixNetworkClientIdent client)
    {
	if(workers.containsKey(client))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.connected();
	}
	else
	{
	    return false;
	}
    }

    public void sendCommandToClient(RatrixNetworkCommand command) throws NoSuchFieldException, IOException
    {
	RatrixNetworkClientIdent clientId = command.client;
	if(command.arguments != null)
	{
	    for(int i=0;i<command.arguments.length;i++)
	    {
		if(command.arguments[i] instanceof java.io.File)
		{
		    File f = (java.io.File) command.arguments[i];
		    long len = f.length();
		    if(len >=0)
		    {
			FileInputStream fis;
			byte[] b;
			try
			{
			    fis = new FileInputStream(f);
			    b = new byte[(int)len];
			    fis.read(b);
			    fis.close();
			}
			catch(Exception e) 
			{ 
			    RatrixDebugWriter.error("Unable to read .mat file in\n"); 
			    throw new IOException("sendCommandToClient(): Unable to read .mat file in");
			}
			command.arguments[i] = (Object) b;
		    }
		}
	    }
	}
	if(workers.containsKey(clientId))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(clientId);
	    // Asynchronus way: w.putOutgoingCommand(command);
	    w.sendImmediately(command);
	    //RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNSOutgoingCommandQueued:"+command);
	}
	else
	{
	    throw new NoSuchFieldException("No worker exists that matches that client id");
	}
    }

    public int incomingCommandsAvailable()
    {
	int numCommands = 0;
	Object[] keys = workers.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(keys[i]);
	    numCommands += w.incomingCommandsAvailable();
	}
	return numCommands;
    }

    public int incomingCommandsAvailable(int priority)
    {
	int numCommands = 0;
	Object[] keys = workers.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(keys[i]);
	    numCommands += w.incomingCommandsAvailable(priority);
	}
	return numCommands;
    }

    public int incomingCommandsAvailable(RatrixNetworkClientIdent client)
    {
	if(workers.containsKey(client))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.incomingCommandsAvailable();
	}
	else
	{
	    return 0;
	}
    }

    public int incomingCommandsAvailable(RatrixNetworkClientIdent client, int priority)
    {
	if(workers.containsKey(client))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.incomingCommandsAvailable(priority);
	}
	else
	{
	    return 0;
	}
    }

    public RatrixNetworkServerWorker getWorkerForClient(RatrixNetworkClientIdent client)
    {
	if(workers.containsKey(client))
	{
	    return (RatrixNetworkServerWorker) workers.get(client);
	}
	return null;
    }

    public RatrixNetworkCommand checkForSpecificCommand(RatrixNetworkClientIdent client, int command, int priority)
    {
	RatrixNetworkServerWorker w;
	if(workers.containsKey(client))
	{
	    w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.checkForSpecificCommand(command,priority);
	}
	else
	{
	    return null;
	}
    }

    public RatrixNetworkCommand checkForSpecificCommand(RatrixNetworkClientIdent client, int command)
    {
	RatrixNetworkServerWorker w;
	if(workers.containsKey(client))
	{
	    w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.checkForSpecificCommand(command);
	}
	else
	{
	    return null;
	}
    }

    public RatrixNetworkCommand checkForSpecificPriority(RatrixNetworkClientIdent client, int priority)
    {
	RatrixNetworkServerWorker w;
	if(workers.containsKey(client))
	{
	    w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.getNextCommand(priority);
	}
	else
	{
	    return null;
	}
    }

    public RatrixNetworkCommand checkForSpecificPriority(int priority)
    {
	RatrixNetworkServerWorker w,oldestW;
	RatrixNetworkCommand cmd,oldestCmd;
	Object[] keys = workers.keySet().toArray();
	oldestW = null;
	oldestCmd = null;
	for(int i=0;i<keys.length;i++)
	{
	    w = (RatrixNetworkServerWorker) workers.get(keys[i]);
	    cmd = w.peekNextCommand(priority);
	    if(oldestCmd == null && cmd != null)
	    {
		oldestCmd = cmd;
		oldestW = w;
	    }
	    else if(cmd != null && oldestCmd != null)
	    {
    		if(cmd.arrived.compareTo(oldestCmd.arrived) < 0)
        	{
		    oldestCmd = cmd;
		    oldestW = w;
		}
	    }
	}
	if(oldestW != null)
	    return oldestW.getNextCommand(priority);
	else
	    return null;
    }

    public RatrixNetworkCommand getNextCommand()
    {
	return getNextCommand(getNextClient());
    }

    public RatrixNetworkCommand getNextCommand(RatrixNetworkClientIdent client)
    {
	RatrixNetworkServerWorker w;
	if(workers.containsKey(client))
	{
	    w = (RatrixNetworkServerWorker) workers.get(client);
	    return w.getNextCommand();
	}
	else
	{
	    return null;
	}
    }

    public RatrixNetworkClientIdent getNextClient()
    {
	RatrixNetworkClientIdent oldestClient = null;
	RatrixNetworkServerWorker oldestWorker = null;
	Object[] keys = workers.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(keys[i]);
	    if(w.incomingCommandsAvailable() > 0)
	    {
		if(oldestClient == null)
		{
		    // First command found is automatically the oldest
		    oldestClient = (RatrixNetworkClientIdent) keys[i];
		    oldestWorker = w;
		}
		else if(w.peekNextCommand().arrived.compareTo(oldestWorker.peekNextCommand().arrived) < 0)
		{
		    // If current command is older than recorded oldest command, update
		    oldestClient = (RatrixNetworkClientIdent) keys[i];
		    oldestWorker = w;
		}
	    }
	}	
	return oldestClient;
    }

    public void run() 
    {
	manageConnections();
    }

    public RatrixNetworkCommand[] addWorker(RatrixNetworkClientIdent clientId, RatrixNetworkServerWorker w)
    {
	RatrixNetworkServerWorker oldWorker = null;
	RatrixNetworkCommand[] cList = null;
	if(workers.containsKey(clientId))
	{
	    oldWorker = (RatrixNetworkServerWorker) workers.get(clientId);
	    if(oldWorker.connected())
	    {
		RatrixDebugWriter.error("Worker with identical client id already exists, disconnecting");
		cList = disconnectClient(clientId);
	    }
	    else
	    {
		RatrixDebugWriter.write("Removing identical client automatically");
		cList = disconnectClient(clientId);
	    }
	    // Flag this worker as a reconnect
	    w.setJustReconnected();
	}
	workers.put(clientId,w); // Add the given worker object to the hash of workers
	return cList;
    }

    public int getServerPort()
    {
	return serverPort;
    }

    public void stopAcceptingNewConnections()
    {
	// Stop listening for new connections
	acceptNewConnections = false;
	RatrixDebugWriter.write("RatrixNetworkServer: No longer accepting new client connections");
    }

    public void shutdown()
    {
	// Inform the manager thread to shutdown
	serverOn = false;
    }
    
    public RatrixNetworkCommand[] disconnectClient(RatrixNetworkClientIdent client)
    {
   	// This allows an acknowledgement of the client disconnection by the higher level program
	//  this will remove all incoming commands from that client that have not been checked
	RatrixNetworkCommand[] cList = null;
	if(workers.containsKey(client))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    // If the worker exists, remove all of the old commands
	    if(w != null)
	    {
		// Shutdown the worker (including the socket)
		w.shutdown();
		cList = new RatrixNetworkCommand[w.incomingCommandsAvailable()];
		// Get the old commands
		for(int i=0;i<cList.length;i++)
		{
		    cList[i] = getNextCommand();
		}
		// Remove the client from the list of workers
		workers.remove(client); // Remove the client
		RatrixDebugWriter.write("Removing client: " + client);
	    }
	}
	return cList;
    }

    public boolean clientIsConnected(RatrixNetworkClientIdent client)
    {
	if(workers.containsKey(client))
	{
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    if(w.connected())
	    {
		return true;
	    }
	}
	return false;
    }

    public boolean isShutdown()
    {
	// Return whether the network server has shutdown or not
	return !serverState;
    }

    public boolean resetRequested()
    {
	return resetRequested;
    }

    protected void requestReset()
    {
	resetRequested = true;
    }

    private void manageConnections()
    {
	Socket clientSocket=null;
        serverOn = true;
	acceptNewConnections = true;
	serverState = true;
	try {
	    s = new ServerSocket(serverPort); // Create a socket on the specified port
	    s.setSoTimeout(10); // Only wait 10 ms for a connection, and then check state
	    s.setReceiveBufferSize(65536);
	}
	catch ( java.net.SocketException e)
	{
	    RatrixDebugWriter.error("Server is unable to set socket timeout options");
	    serverOn = false;
	    try
	    {
		s.close();
	    }
	    catch (Exception e1)
	    {
		// Do nothing
	    }
	    return;
	} 
	catch ( java.io.IOException e)
	{
	    RatrixDebugWriter.error("Server is unable to bind to port " + serverPort + ", exiting");
	    return;
	}

	// Listen to incoming connections forever until told to stop
	while(serverOn)
	{
	    try
	    {
		// Wait for a connection from a new client
		if(acceptNewConnections)
		{
		    clientSocket = s.accept();
		    clientSocket.setTcpNoDelay(true);
		    clientSocket.setSendBufferSize(65536);
		    clientSocket.setReceiveBufferSize(65536);
		    RatrixDebugWriter.write("RatrixNetworkServer: New client is connected, after accept()");
		    // Create new worker object
		    RatrixNetworkServerWorker w = new RatrixNetworkServerWorker(this,clientSocket);
		    // Start up new worker thread
		    Thread t = new Thread(w);
		    t.start();
		}
		else
		{
		    Thread.sleep(10);
		}
	    }
	    catch(InterruptedException e)
	    {
		// Do nothing, socket timed out to allow the serverOn flag to be checked
	    }
	    catch(java.io.InterruptedIOException e)
	    {
		// Do nothing, socket timed out to allow the serverOn flag to be checked
	    }
	    catch(java.io.IOException e)
	    {
		// Turn server off
		RatrixDebugWriter.error("Unknown IO Error occurred in server, exiting [Caught Error: "+e.toString()+"]");
		// This is a client socket problem, should just shutdown that client
		//serverOn = false;
		try
		{
		    if(clientSocket != null)
			clientSocket.close();
		}
		catch(java.io.IOException ignore)
		{
		    // Ignore the client socket, we never added them
		}
	    }
	    catch(InstantiationException e)
	    {
		RatrixDebugWriter.error("Unable to create a worker object, exiting [Caught Error: "+e.toString()+"]");
		// This is a client socket problem, should just shutdown that client
		//serverOn = false;
		try
		{
		    if(clientSocket != null)
			clientSocket.close();
		}
		catch(java.io.IOException ignore)
		{
		    // Ignore the client socket, we never added them
		}
	    }
	}
	try
	{
	    s.close(); // Close server socket
	}
	catch(java.io.IOException e)
	{
	    // Ignore server socket closing error
	    RatrixDebugWriter.error("Problem closing server socket");
	}
	// Shutdown all of the worker threads
	while(workers.size()>0)
	{
	    // Find the next available worker
	    RatrixNetworkClientIdent client = (RatrixNetworkClientIdent) workers.keySet().toArray()[0];
	    RatrixNetworkServerWorker w = (RatrixNetworkServerWorker) workers.get(client);
	    // Shutdown the worker
	    w.shutdown();
	    // Remove the worker object from the list of active workers
	    workers.remove(client);
	    RatrixDebugWriter.write("Shutting down worker " + client);
	}
	managers.remove(new Integer(serverPort)); // Remove the manager from the list
	RatrixDebugWriter.closeWriter();
	serverState = false; // Set server to off
    }

    public static void main(String[] argv)
    {
	testMain();
    }
    public static void testMain()
    {
	RatrixNetworkCommand com;
	RatrixNetworkClientIdent client;
	RatrixNetworkServerWorker worker;
	RatrixNetworkServer r=null;
	int numClients =0;
	try
	{
	    r = new RatrixNetworkServer();
	    Thread t = new Thread(r);
	    t.start();
	    while(true)
	    {
		// Go through the clients and make sure none are disconnected
		List s = r.listClients();
		Iterator clients = s.iterator();
		while(clients.hasNext())
		{
		    client = (RatrixNetworkClientIdent) clients.next();
		    if(!r.clientIsConnected(client))
		    {
			// IMPORTANT! Here is the higher level program acknowledging a disconnection
			RatrixDebugWriter.write("Removing worker client object in testMain()");
			r.disconnectClient(client);
			numClients = 0;
		    }
		}
		// Wait until a client is connected
		while(r.listClients().size() < 1)
		{
		    Thread.sleep(100);
		}
		if(numClients == 0 && r.listClients().size() == 1)
		{
		    RatrixDebugWriter.write(r.listClients().size() + " client(s) connected");
		    // Send/receive commands over to the client
		    RatrixNetworkCommand inCom;
		    client = (RatrixNetworkClientIdent) r.listClients().get(0);
		    // Send a command to the first connected client
		    long start1Time, recv2Time, recv4Time;
		    start1Time= System.nanoTime();
		    com = new RatrixNetworkCommand(r.getNextCommandUID(),client,RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,1);
		    r.sendCommandToClient(com);
		    inCom = null;
		    while(inCom == null)
			{
			    inCom = r.checkForSpecificCommand(client,2);
			}
		    recv2Time = System.nanoTime();
		    com = new RatrixNetworkCommand(r.getNextCommandUID(),client,RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,3);
		    r.sendCommandToClient(com);
		    inCom = null;
		    while(inCom == null)
			{
			    inCom = r.checkForSpecificCommand(client,4);
			}
		    recv4Time = System.nanoTime();
		    RatrixDebugWriter.write("***** latency results: RT(1,2) " + (recv2Time-start1Time) + ", RT(3,4)  " + (recv4Time-recv2Time));
		}
		numClients = r.listClients().size();
	    }
	    //r.shutdown();
	    //t.join();
	}
	catch (Exception e)
	{
	    e.printStackTrace();
	    RatrixDebugWriter.error("Caught an exception in the debug main" + e);
	    try
	    {
		if(r!=null)
		    r.shutdown();
	    }
	    catch(Exception e1)
	    {
		// Do nothing, exiting anyway
	    }
	}
    }
}
