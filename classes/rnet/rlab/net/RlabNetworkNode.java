package rlab.net;
import java.net.Socket;
import java.util.*;
import java.io.*;

public class RlabNetworkNode
{
    public static final int MAX_COMMAND_UID = 999;

    protected int nextCommandUID = 1;
    protected boolean nodeOn = false; // Whether node should be running
    protected boolean connected = false; // Whether node is currently connected
    protected Socket socket = null; // Socket used for communication with server
    protected RlabNetworkNodeIdent localNodeId = null;  // Id of this node
    protected RlabNetworkNodeIdent remoteNodeId = null; // Id of the remote node
    protected RlabNetworkInputWorker iWorker = null;
    protected RlabNetworkOutputWorker oWorker = null;
    protected java.lang.Thread iWThread = null;
    protected java.lang.Thread oWThread = null;

    protected String tmpPath = null;
    public boolean debug=false; // Whether debug mode is turned on


    public RlabNetworkNode(Socket socket, RlabNetworkNodeIdent localNodeId, RlabNetworkNodeIdent remoteNodeId) 
	throws InstantiationException
    {
	nodeOn = true;
	connected = false;
	nextCommandUID = 1;
	this.socket = socket;
	this.localNodeId = localNodeId;
	this.remoteNodeId = remoteNodeId;
    }

    // Get the temporary path for file storage on this node
    public String getTemporaryPath()
    {
	return tmpPath;
    }

    public void setTemporaryPath(String tmpPath)
    {
	this.tmpPath = tmpPath;
    }

    public void setSocket(Socket socket)
    {
	this.socket = socket;
    }

    protected void setupWorkers(double keepAliveTimeout) throws InstantiationException
    {
	// READ ME!!!!!!
	// In order to prevent deadlock, the OutputObjectStream must be setup before the InputObjectStream
	// because the OutputObjectStream constructor sends header info over the stream that the InputObjectStream blocks on
	// The creation of the streams is done in the constructors of both worker classes, so simply following this order is enough
	// HOWEVER, if the ObjectStream creation were ever to be done in the Worker Threads, then the order of the creation would 
	// have to be explicitly controlled
	oWorker = new RlabNetworkOutputWorker(this,socket);
	iWorker = new RlabNetworkInputWorker(this,socket,keepAliveTimeout);
	oWThread = new java.lang.Thread(oWorker);
	oWThread.start();
	iWThread = new java.lang.Thread(iWorker);
	iWThread.start();

    }

    protected void finalize() throws Throwable
    {
	this.shutdown();
	RlabDebugWriter.write("RlabNetworkNode garbage collection");
    }

    public boolean isConnected()
    {
	return connected;
    }

    protected void setConnected(boolean conn)
    {
	connected = conn;
    }

    public boolean nodeOn()
    {
	return nodeOn;
    }

    protected void setNodeOn(boolean on)
    {
	nodeOn = on;
    }


    public RlabNetworkNodeIdent getLocalNodeId()
    {
	return localNodeId;
    }

    public RlabNetworkNodeIdent getRemoteNodeId()
    {
	return remoteNodeId;
    }

    public void putOutgoingCommand(RlabNetworkCommand com)
    {
	oWorker.putOutgoingCommand(com);
    }
    
    protected void putIncomingCommand(RlabNetworkCommand com)
    {
	iWorker.putIncomingCommand(com);
    }

    public RlabNetworkCommand waitForCommands(Integer possibleCommands[])
    {
	return iWorker.waitForCommands(possibleCommands);
    }
    public RlabNetworkCommand waitForCommands(Integer possibleCommands[], Integer priorities[])
    {
	return iWorker.waitForCommands(possibleCommands,priorities);
    }

    public RlabNetworkCommand waitForCommands(Integer possibleCommands[], Integer priorities[], double timeout)
    {
	return iWorker.waitForCommands(possibleCommands,priorities,timeout);
    }

    public int incomingCommandsAvailable(int priority)    
    {
	return iWorker.incomingCommandsAvailable(priority);
    }

    public int incomingCommandsAvailable()
    {
	return iWorker.incomingCommandsAvailable();
    }

    public RlabNetworkCommand checkForSpecificCommand(int command,int priority)
    {
	return iWorker.checkForSpecificCommand(command,priority);
    }

    public RlabNetworkCommand checkForSpecificCommand(int command)
    {
	return iWorker.checkForSpecificCommand(command);
    }

    public RlabNetworkCommand checkForSpecificPriority(int priority)
    {
	return iWorker.checkForSpecificPriority(priority);
    }

    public RlabNetworkCommand getNextCommand(int priority, int index)
    {
	return iWorker.getNextCommand(priority,index);
    }

    public RlabNetworkCommand getNextCommand(int priority)
    {
	return iWorker.getNextCommand(priority);
    }

    public RlabNetworkCommand getNextCommand()
    {
	return iWorker.getNextCommand();
    }

    public RlabNetworkCommand peekNextCommand(int priority)
    {
	return iWorker.peekNextCommand(priority);
    }

    public RlabNetworkCommand peekNextCommand()
    {
	return iWorker.peekNextCommand();
    }

    public synchronized int getNextCommandUID()
    {
	int retUID = 0;
	if(this.nextCommandUID > RlabNetworkClient.MAX_COMMAND_UID)
	{
	    this.nextCommandUID = 1;
	}
	retUID = this.nextCommandUID;
	this.nextCommandUID++;
	return retUID;
    }

    protected void handleIncomingCommand(RlabNetworkCommand com)
    {
	// This is a basic handler that does no actual work
	// All incoming commands are put on the queue unfiltered
	// Override this method to do something more fancy
	iWorker.putIncomingCommand(com);
    }

    // Synchronous means of sending commands
    public void sendImmediately(RlabNetworkCommand com) throws IOException
    {
	oWorker.sendImmediately(com);
    }    

    public synchronized void shutdown()
    {
	try
	{
	    if(iWorker != null)
	    {
		iWorker.shutdown();
	    }

	    if(oWorker != null)
	    {
		oWorker.shutdown();
	    }	   
	}
	finally
	{
	    nodeOn = false;
	    connected = false;
	    // Wait until the shutdowns are complete before closing the socket
	    if(socket != null)
	    {
		try
		{
		    socket.close();
		    socket = null;
		}
		catch(IOException e)
		{
		    RlabDebugWriter.write("Error closing socket in RlabNetworkNode: " + e);
		}
	    }
	}
    }


}