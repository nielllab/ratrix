package rlab.net;
import java.net.Socket;
import java.net.ServerSocket;
import java.util.*;
import java.io.*;

public class RlabNetworkServer implements Runnable
{
    // Class Variables
    public static final int SERVER_PORT = 2020; // Default server port
    public static final double KEEP_ALIVE_TIMEOUT_DEFAULT = 4.0;
    public static final String DEFAULT_SERVER_NAME = "SERVER";
    public static Map managers = Collections.synchronizedMap(new HashMap() ); // List of currently running managers

    // Instance Variables
    private RlabMap nodes; // Map of current nodes, hashed on client id
    private int serverPort; // Actual server port
    private ServerSocket s;  // Socket server is listening for connections on
    private RlabNetworkNodeIdent localNodeId = null;
    private volatile boolean serverOn = false; // Whether the server should be on or not
    private volatile boolean acceptNewConnections = false; // Whether the server should accept new connections or not
    private volatile boolean serverState = false; // True if server is on, false otherwise
    private volatile boolean resetRequested = false; // Whether a request has been requested
    private int nextCommandUID=1;
    private double keepAliveTimeout; // Shutdown connection to client if keep alive not sent in time (seconds)
    public String tmpPath = null;
    public static final int MAX_COMMAND_UID = 999;

    // Class Constructors
    public RlabNetworkServer() throws InstantiationException
    {
	this(SERVER_PORT);
    }

    public RlabNetworkServer(int port) throws InstantiationException
    {
	this(port,true);
    }

    public RlabNetworkServer(int port, boolean debugMode) throws InstantiationException
    {
	this(port,debugMode,KEEP_ALIVE_TIMEOUT_DEFAULT);
    }

    public RlabNetworkServer(int port, boolean debugMode, double keepAliveTimeout) throws InstantiationException
    {
	this(port,debugMode,keepAliveTimeout,DEFAULT_SERVER_NAME);
    }

    public RlabNetworkServer(int port, boolean debugMode, double keepAliveTimeout, String serverName) throws InstantiationException
    {
	serverPort = port;
	localNodeId = new RlabNetworkNodeIdent(serverName);
	if(keepAliveTimeout < 0)
	{
	    throw new InstantiationException("Keep alive timeout must be positive or zero");
	}
	if(debugMode)
	{
	    try
	    {
		RlabDebugWriter.initWriter("." + File.separator + "RNetServerLog.txt",true,RlabDebugWriter.MIN_LOG_LEVEL);
	    }
	    catch(Exception e)
	    {
		throw new InstantiationException("Unable to open debug file for writing in RlabNetworkServer");
	    }
	}
	this.keepAliveTimeout = keepAliveTimeout;
	nextCommandUID = 1;
	if(managers.containsKey(new Integer(port)))
	{
	    throw new InstantiationException("Server already exists on specified port " + port + ", exiting.");
	}
	managers.put(new Integer(serverPort),this); // Assign the manager to the given port
	nodes = new RlabMap(); //Collections.synchronizedMap(new HashMap()); // Create a new list of nodes
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
		RlabDebugWriter.write("RlabNetworkServer finalize() timedout waiting for server to shutdown");
            RlabDebugWriter.write("RlabNetworkServer garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
    

    public RlabNetworkNodeIdent getLocalNodeId()
    {
	return localNodeId;
    }

    public boolean checkAndResetReconnectState(RlabNetworkNodeIdent clientId)
    {
    	RlabNetworkServerNode n = null;
	RlabNetworkCommand[] cList = null;
	if(nodes.containsKey(clientId))
	{
	    n = (RlabNetworkServerNode) nodes.get(clientId);
	    // Determine if this socket has been reconnected since the last time this has been checked
	    return n.checkAndResetReconnectState();
	}
	return false;
    }

    public boolean checkReconnectState(RlabNetworkNodeIdent clientId)
    {
    	RlabNetworkServerNode n = null;
	RlabNetworkCommand[] cList = null;
	if(nodes.containsKey(clientId))
	{
	    n = (RlabNetworkServerNode) nodes.get(clientId);
	    // Determine if this socket has been reconnected since the last time this has been checked
	    return n.checkReconnectState();
	}
	return false;
    }

    public synchronized int getNextCommandUID()
    {
	int retUID = 0;
	if(this.nextCommandUID > RlabNetworkServer.MAX_COMMAND_UID)
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

    public String getTemporaryPath()
    {
	return tmpPath;
    }

    public static void shutdownManagerOnPort(int port)
    {
	if(managers.containsKey(new Integer(port)))
	{
	    RlabNetworkServer m = (RlabNetworkServer) managers.get(new Integer(port));
	    m.shutdown();
	    managers.remove(new Integer(port));
	}
	else
	{
	    RlabDebugWriter.error("No server exists on specified port: " + port + "\n");
	}
    }

    public static void shutdownAll()
    {
	Set s = managers.keySet();
	Object o[] = s.toArray();
	for(int i=0;i<o.length;i++)
	{
	    RlabNetworkServer rns = (RlabNetworkServer) managers.get(o[i]);
	    rns.shutdown();
	    managers.remove(o[i]);	    
	}
    }

    public static void forceShutdownOnPort(int port)
    {
	if(managers.containsKey(new Integer(port)))
	{
	    RlabNetworkServer m = (RlabNetworkServer) managers.get(new Integer(port));
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
	    RlabDebugWriter.error("No server exists on specified port: " + port + "\n");
	}
    }

    public List listClients()
    {
	return new ArrayList(nodes.keySet());
    }

    public boolean clientConnected(RlabNetworkNodeIdent client)
    {
	if(nodes.containsKey(client))
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(client);
	    return n.isConnected();
	}
	else
	{
	    return false;
	}
    }

    public void sendImmediately(RlabNetworkCommand command) throws NoSuchFieldException, IOException
    {
	RlabNetworkNodeIdent client = command.receivingNode;
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
			    RlabDebugWriter.error("Unable to read .mat file in\n"); 
			    throw new IOException("sendCommandToClient(): Unable to read .mat file in");
			}
			command.arguments[i] = (Object) b;
		    }
		}
	    }
	}
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    n.sendImmediately(command);
	}
	else
	{
	    throw new NoSuchFieldException("No node exists that matches that client id");
	}
    }

    public RlabNetworkCommand waitForCommands(RlabNetworkNodeIdent client, Integer possibleCommands[], Integer priorities[], double timeout) throws IOException
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if( n != null)
	{
	    return n.waitForCommands(possibleCommands,priorities,timeout);
	}
	else
	{
	    RlabDebugWriter.error("Waiting for commands on invalid client [" + client + "]!");
	    throw new IOException("Waiting on commands from invalid client");
	}
    }
    
    public int incomingCommandsAvailable()
    {
	int numCommands = 0;
	Object[] keys = nodes.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(keys[i]);
	    numCommands += n.incomingCommandsAvailable();
	}
	return numCommands;
    }

    public int incomingCommandsAvailable(int priority)
    {
	int numCommands = 0;
	Object[] keys = nodes.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(keys[i]);
	    numCommands += n.incomingCommandsAvailable(priority);
	}
	return numCommands;
    }

    public int incomingCommandsAvailable(RlabNetworkNodeIdent client)
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    return n.incomingCommandsAvailable();
	}
	else
	{
	    return 0;
	}
    }

    public int incomingCommandsAvailable(RlabNetworkNodeIdent client, int priority)
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    return n.incomingCommandsAvailable(priority);
	}
	else
	{
	    return 0;
	}
    }

    public RlabNetworkServerNode getNodeForClient(RlabNetworkNodeIdent client)
    {
	if(nodes.containsKey(client))
	{
	    return (RlabNetworkServerNode) nodes.get(client);
	}
	return null;
    }

    public RlabNetworkCommand checkForSpecificCommand(RlabNetworkNodeIdent client, int command, int priority)
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    return n.checkForSpecificCommand(command,priority);
	}
	else
	{
	    return null;
	}
    }

    public RlabNetworkCommand checkForSpecificCommand(RlabNetworkNodeIdent client, int command)
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    return n.checkForSpecificCommand(command);
	}
	else
	{
	    return null;
	}
    }

    public RlabNetworkCommand checkForSpecificPriority(RlabNetworkNodeIdent client, int priority)
    {
	RlabNetworkServerNode n = getNodeForClient(client);
	if(n != null)
	{
	    return n.getNextCommand(priority);
	}
	else
	{
	    return null;
	}
    }

    public RlabNetworkCommand checkForSpecificPriority(int priority)
    {
	RlabNetworkServerNode n,oldestN;
	RlabNetworkCommand cmd,oldestCmd;
	Object[] keys = nodes.keySet().toArray();
	oldestN = null;
	oldestCmd = null;
	for(int i=0;i<keys.length;i++)
	{
	    n = (RlabNetworkServerNode) nodes.get(keys[i]);
	    cmd = n.peekNextCommand(priority);
	    if(oldestCmd == null && cmd != null)
	    {
		oldestCmd = cmd;
		oldestN = n;
	    }
	    else if(cmd != null && oldestCmd != null)
	    {
    		if(cmd.arrived.compareTo(oldestCmd.arrived) < 0)
        	{
		    oldestCmd = cmd;
		    oldestN = n;
		}
	    }
	}
	if(oldestN != null)
	    return oldestN.getNextCommand(priority);
	else
	    return null;
    }

    public RlabNetworkCommand getNextCommand()
    {
	return getNextCommand(getNextClient());
    }

    public RlabNetworkCommand getNextCommand(RlabNetworkNodeIdent client)
    {
	RlabNetworkServerNode n;
	if(nodes.containsKey(client))
	{
	    n = (RlabNetworkServerNode) nodes.get(client);
	    return n.getNextCommand();
	}
	else
	{
	    return null;
	}
    }

    public RlabNetworkNodeIdent getNextClient()
    {
	RlabNetworkNodeIdent oldestClient = null;
	RlabNetworkServerNode oldestNode = null;
	Object[] keys = nodes.keySet().toArray();
	for(int i=0;i<keys.length;i++)
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(keys[i]);
	    if(n.incomingCommandsAvailable() > 0)
	    {
		if(oldestClient == null)
		{
		    // First command found is automatically the oldest
		    oldestClient = (RlabNetworkNodeIdent) keys[i];
		    oldestNode = n;
		}
		else if(n.peekNextCommand().arrived.compareTo(oldestNode.peekNextCommand().arrived) < 0)
		{
		    // If current command is older than recorded oldest command, update
		    oldestClient = (RlabNetworkNodeIdent) keys[i];
		    oldestNode = n;
		}
	    }
	}	
	return oldestClient;
    }

    public void run() 
    {
	manageConnections();
    }

    public RlabNetworkCommand[] addNode(RlabNetworkNodeIdent clientId, RlabNetworkServerNode n)
    {
	RlabNetworkServerNode oldNode = null;
	RlabNetworkCommand[] cList = null;
	if(nodes.containsKey(clientId))
	{
	    oldNode = (RlabNetworkServerNode) nodes.get(clientId);
	    if(oldNode.isConnected())
	    {
		RlabDebugWriter.error("Node with identical client id already exists, disconnecting");
		cList = disconnectClient(clientId);
	    }
	    else
	    {
		RlabDebugWriter.write("Removing identical client automatically");
		cList = disconnectClient(clientId);
	    }
	    // Flag this node as a reconnect
	    n.setJustReconnected();
	}
	nodes.put(clientId,n); // Add the given node object to the hash of nodes
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
	RlabDebugWriter.write("RlabNetworkServer: No longer accepting new client connections");
    }

    public void shutdown()
    {
	// Inform the manager thread to shutdown
	serverOn = false;
    }
    
    public RlabNetworkCommand[] disconnectClient(RlabNetworkNodeIdent client)
    {
   	// This allows an acknowledgement of the client disconnection by the higher level program
	//  this will remove all incoming commands from that client that have not been checked
	RlabNetworkCommand[] cList = null;
	if(nodes.containsKey(client))
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(client);
	    // If the node exists, remove all of the old commands
	    if(n != null)
	    {
		// Shutdown the node (including the socket)
		n.shutdown();
		cList = new RlabNetworkCommand[n.incomingCommandsAvailable()];
		// Get the old commands
		for(int i=0;i<cList.length;i++)
		{
		    cList[i] = getNextCommand();
		}
		// Remove the client from the list of nodes
		nodes.remove(client); // Remove the client
		RlabDebugWriter.write("Removing client: " + client);
	    }
	}
	return cList;
    }

    public boolean clientIsConnected(RlabNetworkNodeIdent client)
    {
	if(nodes.containsKey(client))
	{
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(client);
	    if(n.isConnected())
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
	    RlabDebugWriter.error("Server is unable to set socket timeout options");
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
	    RlabDebugWriter.error("Server is unable to bind to port " + serverPort + ", exiting");
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
		    RlabDebugWriter.write("RlabNetworkServer: New client is connected, after accept()");
		    // Create new node object
		    RlabNetworkServerNode n = new RlabNetworkServerNode(this,clientSocket,keepAliveTimeout);
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
		RlabDebugWriter.error("Unknown IO Error occurred in server, exiting [Caught Error: "+e.toString()+"]");
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
		RlabDebugWriter.error("Unable to create a node object, exiting [Caught Error: "+e.toString()+"]");
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
	    RlabDebugWriter.error("Problem closing server socket");
	}
	// Shutdown all of the nodes
	while(nodes.size()>0)
	{
	    // Find the next available node
	    RlabNetworkNodeIdent client = (RlabNetworkNodeIdent) nodes.keySet().toArray()[0];
	    RlabNetworkServerNode n = (RlabNetworkServerNode) nodes.get(client);
	    // Shutdown the node
	    n.shutdown();
	    // Remove the node object from the list of active nodes
	    nodes.remove(client);
	    RlabDebugWriter.write("Shutting down node " + client);
	}
	managers.remove(new Integer(serverPort)); // Remove the manager from the list
	RlabDebugWriter.closeWriter();
	serverState = false; // Set server to off
    }

    public static void main(String[] argv)
    {
	testMain();
    }
    public static void testMain()
    {
	RlabNetworkCommand com;
	RlabNetworkNodeIdent client;
	RlabNetworkServerNode node;
	RlabNetworkServer r=null;
	int numClients =0;
	try
	{
	    System.out.println("In test main()");
	    r = new RlabNetworkServer(RlabNetworkServer.SERVER_PORT,true);
	    Thread t = new Thread(r);
	    t.start();
	    System.out.println("Server started");
	    RlabDebugWriter.write("Server started");
	    while(true)
	    {
		// Go through the clients and make sure none are disconnected
		List s = r.listClients();
		Iterator clients = s.iterator();
		while(clients.hasNext())
		{
		    client = (RlabNetworkNodeIdent) clients.next();
		    if(!r.clientIsConnected(client))
		    {
			// IMPORTANT! Here is the higher level program acknowledging a disconnection
			RlabDebugWriter.write("Removing node object in testMain()");
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
		    RlabDebugWriter.write(r.listClients().size() + " client(s) connected");
		    // Send/receive commands over to the client
		    RlabNetworkCommand inCom;
		    client = (RlabNetworkNodeIdent) r.listClients().get(0);
		    // Send a command to the first connected client
		    long start1Time, recv2Time, recv4Time;
		    start1Time= System.nanoTime();
		    com = new RlabNetworkCommand(r.getNextCommandUID(),r.getLocalNodeId(),client,RlabNetworkCommand.INTERNAL_MSG_PRIORITY,1);
		    r.sendImmediately(com);
		    inCom = null;
		    while(inCom == null)
			{
			    inCom = r.checkForSpecificCommand(client,2);
			}
		    recv2Time = System.nanoTime();
		    com = new RlabNetworkCommand(r.getNextCommandUID(),r.getLocalNodeId(),client,RlabNetworkCommand.INTERNAL_MSG_PRIORITY,3);
		    r.sendImmediately(com);
		    inCom = null;
		    while(inCom == null)
			{
			    inCom = r.checkForSpecificCommand(client,4);
			}
		    recv4Time = System.nanoTime();
		    RlabDebugWriter.write("***** latency results: RT(1,2) " + (recv2Time-start1Time) + ", RT(3,4)  " + (recv4Time-recv2Time));
		}
		numClients = r.listClients().size();
	    }
	    //r.shutdown();
	    //t.join();
	}
	catch (Exception e)
	{
	    e.printStackTrace();
	    RlabDebugWriter.error("Caught an exception in the debug main" + e);
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
