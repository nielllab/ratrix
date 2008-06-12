package ratrix.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RatrixNetworkServerWorker implements Runnable
{
    // Class Variables
    // Instance Variables
    private List outgoingCommands; // Outgoing list of commands going to the client
    private List incomingCommands[]; // Incoming list of commands coming from the server
    private boolean workerOn = false; // Whether worker should be running
    private RatrixNetworkServer server = null; // Server this worker is attached to
    private Socket socket = null; // Socket used for communication with client
    private RatrixNetworkClientIdent clientId = null;
    private InputStream in = null;
    private ObjectInputStream objIn = null;
    private OutputStream out = null;
    private ObjectOutputStream objOut = null;
    private boolean connected = false;
    private long lastKeepAlive = 0;
    private volatile boolean reconnectDirtyState = false; // Whether a reconnect has occurred since the last time this has been reset

    // Class Constructors
    public RatrixNetworkServerWorker(RatrixNetworkServer serv, Socket sock) throws InstantiationException
    {
	workerOn = true;
	connected = true;
	socket = sock; // Set the client socket
	server = serv; // Set the server
	outgoingCommands = Collections.synchronizedList(new ArrayList());
	incomingCommands = new List[RatrixNetworkCommand.MAX_PRIORITIES+1];
	for(int i=0;i<incomingCommands.length;i++)
	    incomingCommands[i] = Collections.synchronizedList(new ArrayList());
	try
	{
	    in = socket.getInputStream(); // Assign the input stream
	    objIn = new ObjectInputStream(in);
	    out = socket.getOutputStream(); // Assign the output stream
	    objOut = new ObjectOutputStream(out);
	}
	catch (java.io.IOException e)
	{
	    throw new InstantiationException("Unable to open I/O streams on client socket in worker thread");
	}
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
            RatrixDebugWriter.write("RatrixNetworkServerWorker garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }

    // checkAndResetReconnectState() call to determine if a reconnect has occurred and if so acknowledge it
    // This must be done in a synchronized method all at once to prevent a race condition
    public boolean checkAndResetReconnectState()
    {
	return returnAndSetDirtyBit(false);
    }

    public boolean checkReconnectState()
    {
	return reconnectDirtyState;
    }

    // setJustReconnected() call when an existing client has reconnected
    protected void setJustReconnected()
    {
	returnAndSetDirtyBit(true);
    }

    protected synchronized boolean returnAndSetDirtyBit(boolean val)
    {
	boolean tmp = reconnectDirtyState;
	reconnectDirtyState = val;
	return tmp;
    }
    
    public void run()
    {
	handleRequests();
    }

    public void shutdown()
    {
	workerOn = false;
    }
    protected void putOutgoingCommand(RatrixNetworkCommand com)
    {
	outgoingCommands.add(com);
    }
    
    protected void putIncomingCommand(RatrixNetworkCommand com)
    {
	incomingCommands[com.priority].add(com);
    }

    protected void resetKeepAlive()
    {
	this.lastKeepAlive = System.currentTimeMillis();
    }

    protected void respondKeepAlive(RatrixNetworkClientIdent client) throws IOException
    {
	RatrixNetworkCommand com = new RatrixNetworkCommand(server.getNextCommandUID(),
							    client,
							    RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,
							    RatrixNetworkCommand.S_KEEP_ALIVE_ACK_COMMAND);
	// Reply to the keep alive with an acknowledgement
	//putOutgoingCommand(com);
	sendImmediately(com);
    }

    protected boolean checkAlive()
    {
	double secondsSince = (System.currentTimeMillis()-this.lastKeepAlive)/1000.0;
	if(secondsSince > this.server.getKeepAliveTimeout())
	    return false;
	else
	    return true;
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


    public RatrixNetworkCommand checkForSpecificCommand(int command,int priority)
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

    public RatrixNetworkCommand getNextCommand(int priority, int index)
    {
	RatrixNetworkCommand cmd;
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>index)
	{
	    RatrixNetworkClientIdent client = this.server.getNextClient();
	    RatrixNetworkServerWorker w = this.server.getWorkerForClient(client);
	    RatrixNetworkCommand oldestCmd = w.peekNextCommand();
	    cmd = (RatrixNetworkCommand) incomingCommands[priority].remove(index);
	    if(cmd != null)
	    {
		String oldest;
		if(oldestCmd == null)
		    oldest = new String("<null>");
		else
		    oldest = oldestCmd.toString();
		Date d = new Date();
		Double tm = new Double((d.getTime()-cmd.arrived.getTime())/1000.0);
		Integer avail = new Integer(this.server.incomingCommandsAvailable());
		RatrixDebugWriter.write("RNSWInQueueCmd("+avail+"):\t"+cmd+"\tpt: "+tm+"oldest["+w.clientId+"]:"+oldest);
	    }
	    return cmd;
	}
	return null; // No commands available
    }

    public RatrixNetworkCommand getNextCommand(int priority)
    {
	return getNextCommand(priority,0);
    }

    public RatrixNetworkCommand getNextCommand()
    {
	RatrixNetworkCommand cmd;
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

    public RatrixNetworkCommand peekNextCommand(int priority)
    {
	if(priority < 0 || priority >= incomingCommands.length)
	    return null;
	if(incomingCommands[priority].size()>0)
	{
	    return (RatrixNetworkCommand) incomingCommands[priority].get(0);
	}
	return null; // No commands available
    }

    public RatrixNetworkCommand peekNextCommand()
    {
	for(int i=0;i<incomingCommands.length;i++)
	{
	    if(incomingCommands[i].size()>0)
	    {
	    return (RatrixNetworkCommand) incomingCommands[i].get(0);
	    }
	}
	return null; // No commands available
    }

    public boolean connected()
    {
	return connected;
    }


    // Synchronous means of sending commands
    public synchronized void sendImmediately(RatrixNetworkCommand com) throws IOException
    {
	try
	{
	    objOut.writeObject(com);
	    objOut.flush();
	}
	catch(IOException e)
	{
	    shutdown();
	    RatrixDebugWriter.error("Unable to write the network command object to the socket in the server worker thread");
	    throw e;
	}
	if(com.command != RatrixNetworkCommand.C_KEEP_ALIVE_COMMAND)
	{
	    RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNSWSentCmd:\t"+com);
	}	
    }

    private void handleRequests()
    {
	RatrixNetworkCommand regCom;
	// Determine the client id of the incoming client
	try
	{
	    regCom = (RatrixNetworkCommand) objIn.readObject();
	}
	catch (Exception e)
	{
	    RatrixDebugWriter.error("Unable to read the network command object from the socket in the worker thread");
	    return;
	}
	RatrixDebugWriter.write("Begin server worker (client id " + regCom.client.id + ")");
	// Check that this command is in fact a connection request
	if(regCom.command != regCom.C_CONNECT_COMMAND)
	{
	    RatrixDebugWriter.error("First command recieved from client is not connect! (com " + regCom.command + ")\n");
	}
	clientId = regCom.client; // Determine client identity
	// Determine if a worker already exists for this client id
	
	// Register this worker object with the server object
	RatrixNetworkCommand[] cList = server.addWorker(clientId,this);
	// Put the old commands from that old worker into the command list
	if(cList != null)
	{
	    for(int i=0;i<cList.length;i++)
	    {
		RatrixDebugWriter.write("RNSW OLD CMD put on queue for: [" + clientId + "]"+cList[i]);
		putIncomingCommand(cList[i]);
	    }
	}

	RatrixNetworkCommand com;
	// Initialize the keep alive
	this.resetKeepAlive();
	//RatrixDebugWriter.write("Entering server loop with on status " + workerOn);	
	while(workerOn)
	{
	    // Try and write any commands out and read any new commands coming in
	    int numBytes;
	    try
	    {
		numBytes = in.available();
	    }
	    catch (IOException e)
	    {
		RatrixDebugWriter.error("Unable to read the number of bytes available from the socket in the server worker thread");
		workerOn = false;
		break;
	    }
	    if(numBytes > 0)
	    {
		//RatrixDebugWriter.write("About to read incoming message on worker");
		try
		{
		    com = (RatrixNetworkCommand) objIn.readObject();
		}
		catch (Exception e)
		{
		    RatrixDebugWriter.error("Unable to read the network command object from the socket in the server worker thread");
		    workerOn = false;
		    break;
		}
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
				workerOn = false;
				break;
			    }
			    String fpath = new String(this.server.tmpPath + java.io.File.separator + ".tmp-java-" + 
						      RatrixNetworkCommand.SERVER_TYPE + "-" + com.UID + "-" + i + "-incoming.mat");
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
				workerOn = false;
				break;
			    }
			    com.arguments[i] = (Object) f;
			}
		    }
		}
		com.setArrivalTime(); // Set the arrival time on the incoming command		
		//RatrixDebugWriter.write("Done reading incoming message on worker");
		if(com.command == RatrixNetworkCommand.C_KEEP_ALIVE_COMMAND)
		{    
		    resetKeepAlive();
		    try
		    {
			respondKeepAlive(clientId);
		    }
		    catch(IOException e)
		    {
			RatrixDebugWriter.error("Unable to send keep alive ack\n"); 
			workerOn = false;
			break;	
		    }
		}
		else // All commands but keep alives are put on the queue
	        {
		    RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNSWRecvdCmd:\t"+com);
		    putIncomingCommand(com);
		}
		// If this is a reset command -- notify server
		if(com.command == RatrixNetworkCommand.C_SERVER_RESET_COMMAND)
		{
		    server.requestReset();
		    // This command does not get added to the queue
		    RatrixDebugWriter.write("Server Reset received");
		    continue;
		}
		// If this is a disconnect command -- get ready for shutdown
		if(com.command == RatrixNetworkCommand.C_DISCONNECT_COMMAND)
		{
		    RatrixDebugWriter.write("Server worker got a disconnect request from client " + com.client.id);
		    workerOn = false;
		    break;
		}
		// Check if client is still alive
		if(!this.checkAlive())
		{
		    RatrixDebugWriter.write("Server timeout has expired for client " + clientId.id + " keep alive" );
		    workerOn = false;
		    break;
		}
	    }
	    if(outgoingCommands.size() > 0)
	    {
		com = (RatrixNetworkCommand) outgoingCommands.remove(0);
		try
		{
		    objOut.writeObject(com);
		    objOut.flush();
		    if(com.command != RatrixNetworkCommand.C_KEEP_ALIVE_COMMAND)
		    {
			RatrixDebugWriter.write(RatrixDebugWriter.MIN_LOG_LEVEL,"RNSWSentCmd:\t"+com);
		    }
		}
		catch (IOException e)
		{
		    RatrixDebugWriter.error("Unable to write the network command object to the socket in the server worker thread");
		    workerOn = false;
		    break;
		}
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
	try
	{
	    connected = false;
	    objOut.close();
	    objIn.close();
	    out.close();
	    in.close();
	    socket.close();
	}
	catch(Exception e)
	{
	    RatrixDebugWriter.error("Unable to close cleanly in server worker");
	}
	RatrixDebugWriter.write("Closing server worker connected is " + connected);
    }
}
