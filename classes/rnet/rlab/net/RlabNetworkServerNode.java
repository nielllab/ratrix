package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RlabNetworkServerNode extends RlabNetworkNode
{
    // Class Variables
    // Instance Variables
    private long lastKeepAlive = 0;
    private boolean receivedConnectCom = false;
    private volatile boolean reconnectDirtyState = false; // Whether a reconnect has occurred since the last time this has been reset
    private RlabNetworkServer server = null;

    // Class Constructors
    public RlabNetworkServerNode(RlabNetworkServer server, Socket socket, double keepAliveTimeout) throws InstantiationException
    {
	// This opens the input and output workers on the socket
	super(socket,server.getLocalNodeId(),(RlabNetworkNodeIdent)null);
	setupWorkers(keepAliveTimeout);
	setConnected(true);
	setNodeOn(true);
	this.server = server; // Set the server parent
	receivedConnectCom = false;
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
            RlabDebugWriter.write("RlabNetworkServerNode garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }

    // Override this method, for a server node, the RlabNetworkServer.getNextCommandUID should be called
    public int getNextCommandUID()
    {
	return server.getNextCommandUID();
    }

    // Override this method, for a server node, the RlabNetworkServer.getTemporaryPath should be called
    public String getTemporaryPath()
    {
	return server.getTemporaryPath();
    }

    public void shutdown()
    {
	try
	{
	    super.shutdown();
	}
	finally
	{
	    server = null;
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
    
    protected void respondKeepAlive() throws IOException
    {
	RlabNetworkCommand com = new RlabNetworkCommand(getNextCommandUID(),
							getLocalNodeId(),getRemoteNodeId(),
							    RlabNetworkCommand.INTERNAL_MSG_PRIORITY,
							    RlabNetworkCommand.S_KEEP_ALIVE_ACK_COMMAND);
	// Reply to the keep alive with an acknowledgement
	//putOutgoingCommand(com);
	sendImmediately(com);
    }

    protected void respondConnectAck() throws IOException
    {
	RlabNetworkCommand com = new RlabNetworkCommand(getNextCommandUID(),
							getLocalNodeId(),getRemoteNodeId(),
							    RlabNetworkCommand.INTERNAL_MSG_PRIORITY,
							    RlabNetworkCommand.S_CONNECT_ACK_COMMAND);
	// Reply to the keep alive with an acknowledgement
	//putOutgoingCommand(com);
	sendImmediately(com);
    }

    protected void handleIncomingCommand(RlabNetworkCommand com)
    {
	if(!receivedConnectCom)
	{
	    RlabDebugWriter.write("Server Node (client id " + com.sendingNode.id + ")");
	    // Check that this command is in fact a connection request
	    if(com.command != com.C_CONNECT_COMMAND)
	    {
		RlabDebugWriter.error("First command recieved from client is not connect! (com " + com.command + ")\n");
		this.shutdown();
		return;
	    }
	    remoteNodeId = com.sendingNode; // Determine client identity
	    // Determine if a worker already exists for this client id
	
	    // Register this worker object with the server object
	    RlabNetworkCommand[] cList = server.addNode(remoteNodeId,this);
	    // Put the old commands from that old worker into the command list
	    if(cList != null)
	    {
		for(int i=0;i<cList.length;i++)
		{
		    RlabDebugWriter.write("RNSW OLD CMD put on queue for: [" + remoteNodeId + "]"+cList[i]);
		    iWorker.putIncomingCommand(cList[i]);
		}
	    }
	    try
	    {
		respondConnectAck();
	    }
	    catch(IOException e)
	    {
		RlabDebugWriter.error("Unable to send connect ack\n"); 
		this.shutdown();
	    }
	    receivedConnectCom = true;
	}
	else
	{
	    switch(com.command)
	    {
	    case RlabNetworkCommand.C_SERVER_RESET_COMMAND:
		// If this is a reset command -- notify server
		server.requestReset();
		// This command does not get added to the queue
		RlabDebugWriter.write("Server Reset received");
		break;
	    case RlabNetworkCommand.C_DISCONNECT_COMMAND:
		// If this is a disconnect command -- get ready for shutdown		
		RlabDebugWriter.write("Server input worker got a disconnect request from client " + com.sendingNode.id);
		this.shutdown();
		break;
	    case RlabNetworkCommand.C_KEEP_ALIVE_COMMAND:
		iWorker.resetKeepAlive();
		try
		{
		    respondKeepAlive();
		}
		catch(IOException e)
		{
		    RlabDebugWriter.error("Unable to send keep alive ack\n"); 
		    this.shutdown();
		}
		break;
	    case RlabNetworkCommand.C_CONNECT_COMMAND:
		// If state was screwed up this might happen
		RlabDebugWriter.error("ServerNode->InputWorker: C_CONNECT_COMMAND occurred outside of the first command ");
		this.shutdown();
		break;
	    case RlabNetworkCommand.S_KEEP_ALIVE_ACK_COMMAND:
	    case RlabNetworkCommand.S_CONNECT_ACK_COMMAND:
		// Under no circumstances should we ever receive these commands
		RlabDebugWriter.error("ServerNode->InputWorker: A command that should be sent only by a server (S_* commands) was received by the server [com :" + com.command + "]");
		this.shutdown();
		break;
	    default:
		putIncomingCommand(com);
	    }
	}
    }
}
