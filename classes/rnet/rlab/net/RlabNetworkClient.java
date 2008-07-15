package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RlabNetworkClient extends RlabNetworkNode
{
    // Class Variables
    public static final double KEEP_ALIVE_SEND_FREQUENCY_DEFAULT = 1.0;
    public static final double CONNECT_ACK_TIMEOUT_DEFAULT = 4.0;

    // Instance Variables
    private String connectHost; // Host to connect to
    private int connectPort; // Port to connect to
    private boolean shutdownComplete = false; // Whether shutdown has completed and a reconnect is allowed
    private volatile boolean receivedConnectAckCom = false;
    private double keepAliveSend = KEEP_ALIVE_SEND_FREQUENCY_DEFAULT; // How often to send a keep alive
    private double keepAliveTimeout = RlabNetworkInputWorker.KEEP_ALIVE_TIMEOUT_DEFAULT;
    private double connectAckTimeout = CONNECT_ACK_TIMEOUT_DEFAULT; // How long to wait for a connection acknowledgement

    // Class Constructors
    public RlabNetworkClient(String id, String host, int port) throws InstantiationException
    {
	this(id,host,port,true);
    }

    public RlabNetworkClient(String id, String host, int port, boolean debugMode) throws InstantiationException
    {
	this(id,host,port,debugMode,KEEP_ALIVE_SEND_FREQUENCY_DEFAULT,RlabNetworkInputWorker.KEEP_ALIVE_TIMEOUT_DEFAULT);
    }

    public RlabNetworkClient(String id, String host, int port, boolean debugMode, double keepAliveSend, double keepAliveTimeout) 
	throws InstantiationException
    {
	this(id,host,port,debugMode,keepAliveSend,keepAliveTimeout,CONNECT_ACK_TIMEOUT_DEFAULT);
    }

    public RlabNetworkClient(String id, String host, int port, boolean debugMode, double keepAliveSend, double keepAliveTimeout, double connectAckTimeout) 
	throws InstantiationException
    {	
	this(new RlabNetworkNodeIdent(id),new RlabNetworkNodeIdent(RlabNetworkServer.DEFAULT_SERVER_NAME),host,port,debugMode,keepAliveSend,keepAliveTimeout,connectAckTimeout);
    }

    public RlabNetworkClient(RlabNetworkNodeIdent localNode, RlabNetworkNodeIdent remoteNode, String host, int port, boolean debugMode, double keepAliveSend, double keepAliveTimeout, double connectAckTimeout) throws InstantiationException
    {
	super((Socket)null,localNode,remoteNode);
	this.keepAliveSend = keepAliveSend;
	this.keepAliveTimeout = keepAliveTimeout;
	this.connectAckTimeout = connectAckTimeout;
	receivedConnectAckCom = false;
	shutdownComplete = false;
	if(debugMode)
	{
	    try
	    {
		RlabDebugWriter.initWriter("." + File.separator + "RNetClientLog.txt",true,RlabDebugWriter.MIN_LOG_LEVEL);
	    }
	    catch(Exception e)
	    {
		throw new InstantiationException("Unable to open debug file for writing in RlabNetworkClient  " + e);
	    }
	}
	connectHost = host;
	connectPort = port;
	connect();
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
            RlabDebugWriter.write("RlabNetworkClient garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
    
    protected synchronized void connect() throws InstantiationException
    {
	try
	{  
	    RlabDebugWriter.write("calling Socket() with host:"+connectHost + " port:" + connectPort);
	    socket = new Socket(connectHost,connectPort);
	    socket.setTcpNoDelay(true);
	    socket.setSendBufferSize(65536);
	    socket.setReceiveBufferSize(65536);
	    socket.setKeepAlive(true);
	    setSocket(socket);
	}
	catch(IOException e)
	{
	    setSocket(null);
	    setConnected(false);
	    throw new InstantiationException("Unable to establish socket in RlabNetworkClient constructor  " + e);
	}
	// This opens the input and output workers on the socket
	setupWorkers(keepAliveTimeout);
	setNodeOn(true);
	setConnected(true);
	setupConnection();
    }

    // Use this function to force any threads to recheck the state of this object
    public synchronized void updateState()
    {
	notifyAll();
    }

    // Wait for some new state to become available
    public synchronized void waitForNewState(long timeout)
    {
	try
	{
	    wait(timeout);
	} catch(InterruptedException e) {}
    }


    protected void setupConnection() throws InstantiationException
    {
	try
	{
	    // Put the connect command on the outgoing list
	    RlabNetworkCommand regCom = new RlabNetworkCommand(getNextCommandUID(),getLocalNodeId(),getRemoteNodeId(),RlabNetworkCommand.INTERNAL_MSG_PRIORITY,RlabNetworkCommand.C_CONNECT_COMMAND);
	    oWorker.sendImmediately(regCom);
	    RlabDebugWriter.write(RlabDebugWriter.MIN_LOG_LEVEL,"RNCSentCmd:\t"+regCom);
	}
	catch (IOException e)
	{
	    setSocket(null);
	    setConnected(false);
	    throw new InstantiationException("Unable to send connection message in RlabNetworkClient constructor  " + e);
	}
	long startTime = System.currentTimeMillis();
	while(!receivedConnectAckCom)
	{
	    if(System.currentTimeMillis()-startTime > connectAckTimeout*1000)
	    {
		setSocket(null);
		setConnected(false);
		throw new InstantiationException("RlabNetworkClient: Timed out waiting for a connect acknowledgement");
	    }
	    if(!isConnected())
	    {
		setSocket(null);
		throw new InstantiationException("RlabNetworkClient: While waiting for connect acknowledgment, client is no longer connected");
	    }
	    waitForNewState(500);
	}
	setupKeepAliveSender();
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
	connect();
    }


    public boolean isShutdown()
    {
	return shutdownComplete;
    }

    public boolean connectionEstablished()
    {
	return receivedConnectAckCom && isConnected();
    }
    

    // Synchronously send commands to the server
    public void sendImmediately(RlabNetworkCommand com) throws IOException
    {	
	super.sendImmediately(com);
    }

    // Asynchronously send commands to the server
    public void sendCommandToServer(RlabNetworkCommand com) throws IOException
    {
	// Put a command going to the server on the outgoing commands list
	putOutgoingCommand(com);
	RlabDebugWriter.write(RlabDebugWriter.MIN_LOG_LEVEL,"RNCMOutCmdQueued:\t"+com);
    }

    private void setupKeepAliveSender()
    {
	RlabNetworkClientKeepAliveSender kaSend;
	// Create the keep alive sender class and start it
	kaSend = new RlabNetworkClientKeepAliveSender(this,keepAliveSend);
	Thread k = new Thread(kaSend);
	k.start();
    }

    protected void handleIncomingCommand(RlabNetworkCommand com)
    {
	if(!receivedConnectAckCom)
	{
	    RlabDebugWriter.write("Client (client id " + com.receivingNode.id + ")");
	    if(com.command != RlabNetworkCommand.S_CONNECT_ACK_COMMAND)
	    {
		RlabDebugWriter.error("First command recieved from server is not connect ack! (com " + com.command + ")\n");
		this.shutdown();
		return;
	    }
	    receivedConnectAckCom = true;
	}
	else
	{
	    switch(com.command)
	    {
	    case RlabNetworkCommand.S_KEEP_ALIVE_ACK_COMMAND:
		iWorker.resetKeepAlive();
		break;
	    case RlabNetworkCommand.S_CONNECT_ACK_COMMAND:
		// If state was screwed up this might happen
		RlabDebugWriter.error("Client->InputWorker: S_CONNECT_ACK_COMMAND occurred outside of the first command ");
		this.shutdown();
		break;
	    case RlabNetworkCommand.C_CONNECT_COMMAND:
	    case RlabNetworkCommand.C_KEEP_ALIVE_COMMAND:
	    case RlabNetworkCommand.C_DISCONNECT_COMMAND:
	    case RlabNetworkCommand.C_SERVER_RESET_COMMAND:
		// Under no circumstances should we ever receive these commands
		RlabDebugWriter.error("Client->InputWorker: A command that should be sent only by a client (C_* commands) was received by a client [com :" + com.command + "]");
		this.shutdown();
		break;
	    default:
		iWorker.putIncomingCommand(com);
	    }
	}
    }

    public synchronized void shutdown()
    {
	if(!shutdownComplete)
	{
	    if(socket != null)
	    {
		RlabDebugWriter.write("Client closing, sending disconnect message");
		// Write the disconnect command on the outgoing list
		RlabNetworkCommand regCom = new RlabNetworkCommand(this.getNextCommandUID(),getLocalNodeId(),getRemoteNodeId(),RlabNetworkCommand.INTERNAL_MSG_PRIORITY,RlabNetworkCommand.C_DISCONNECT_COMMAND);
		try
		{
		    sendImmediately(regCom);
		}
		catch (Exception e)
		{
		    // Do nothing, closing anyway
		    RlabDebugWriter.error("Failed attempting to send disconnect message to server  " + e);
		}
		RlabDebugWriter.closeWriter();
	    }
	    super.shutdown();
	    shutdownComplete = true; // Indicate to the other threads that shutdown is complete
	}
	else
	{
	    RlabDebugWriter.write("In shutdown(), client already shutdown");	    
	}
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
	RlabNetworkClient r;
	RlabNetworkCommand com;
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
	    r = new RlabNetworkClient(id,"192.168.10.100",RlabNetworkServer.SERVER_PORT);
	}
	catch (InstantiationException e)
	{
	    RlabDebugWriter.error("Unable to create RlabNetworkClient object in debug main" + e);
	    return;
	}
	// Send/receive some commands over to the server
	RlabNetworkCommand inCom = null;
	while(inCom == null)
	{
	    inCom = r.checkForSpecificCommand(1);
	}
	com = new RlabNetworkCommand(r.getNextCommandUID(),r.getLocalNodeId(),r.getRemoteNodeId(),RlabNetworkCommand.INTERNAL_MSG_PRIORITY,RlabNetworkCommand.C_CONNECT_COMMAND);
	try
	{
	    r.sendCommandToServer(com);
	}
	catch(Exception e)
	{
	    System.err.println("Unexpected exception in testMain when sending command to server" + e );
	}
	inCom = null;
	while(inCom == null)
	{
	    inCom = r.checkForSpecificCommand(3);
	}
	com = new RlabNetworkCommand(r.getNextCommandUID(),r.getLocalNodeId(),r.getRemoteNodeId(),RlabNetworkCommand.INTERNAL_MSG_PRIORITY,4);
	try
	{
	    r.sendCommandToServer(com);
	}
	catch(Exception e)
	{
	    System.err.println("Unexpected exception in testMain when sending command to server" + e);
	}
	try
	{
	    Thread.sleep(1000);
	}
	catch(InterruptedException e)
        {
	}
	r.shutdown();
	while(!r.isShutdown())
	{
	    try
	    {
		Thread.sleep(1000);
	    }
	    catch(InterruptedException e)
	    {
	    }
	}

    }
}
