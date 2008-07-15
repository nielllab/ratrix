package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RlabNetworkOutputWorker extends RlabNetworkWorker
{
    // Class Variables
    // Instance Variables
    private List outgoingCommands; // Outgoing list of commands going to the other side
    private OutputStream out = null;
    private ObjectOutputStream objOut = null;

    // Class Constructors
    public RlabNetworkOutputWorker(RlabNetworkNode node, Socket socket) throws InstantiationException
    {
	super(node,socket);

	outgoingCommands = Collections.synchronizedList(new ArrayList());
	try
	{
	    out = socket.getOutputStream(); // Assign the output stream
	    objOut = new ObjectOutputStream(out);
	}
	catch (java.io.IOException e)
	{
	    throw new InstantiationException("Unable to open output streams on socket in output worker thread" + e);
	}	
    }

    protected void finalize() throws Throwable
    {
        try
        {
            this.shutdown();
            if(this.objOut != null)
	    {
                objOut.close();
		objOut = null;
	    }
            if(this.out != null)
	    {
                out.close();
		out = null;
	    }
            RlabDebugWriter.write("RlabNetworkOutputWorker garbage collection");
        }
        finally
        {
           super.finalize();
        }
    }
        
    public synchronized void putOutgoingCommand(RlabNetworkCommand com)
    {
	// Add a command to the queue
	outgoingCommands.add(com);
	// Tell everyone about it
	notifyAll();
    }

    protected synchronized void waitForIncomingCommands()
    {
	while(workerOn && this.node.isConnected())
	{
	    try
	    {
		wait(500); // Every 500 milliseconds wake up and see if we're still on
	    }
	    catch (InterruptedException e)
	    {
		// Do nothing
	    }
	}   
    }


    protected RlabNetworkCommand formatCommandForSend(RlabNetworkCommand com) throws IOException
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
			RlabDebugWriter.write("Java file length " + len);
			b = new byte[(int)len];
			fis.read(b);
			fis.close();
		    }
		    catch (Exception e)	
		    {
			RlabDebugWriter.error("Unable to read .mat file in  " + e); 
			throw new IOException("formatCommandForSend(): Unable to read .mat file in for outgoing command  " + e);
		    }
		    com.arguments[i] = (Object) b;
		    b = (byte []) com.arguments[i];
		    //RlabDebugWriter.write("Java rewrite length " + b.length);
		}
	    }
	}
	return com;
    }

 
    // Synchronous means of sending commands
    public synchronized void sendImmediately(RlabNetworkCommand com) throws IOException
    {
	try
	{
	    com = formatCommandForSend(com);
	    com.setDepartureTime();
	    objOut.writeObject(com);
	    objOut.flush();
	}
	catch(IOException e)
	{
	    shutdown();
	    RlabDebugWriter.error("Unable to write the network command object to the socket in sendImmediately()  " + e);
	    throw e;
	}
	RlabDebugWriter.write(RlabDebugWriter.MIN_LOG_LEVEL,"RNOWSentCmd:\t" + com);
    }
    
    
    protected void handleRequests()
    {	
	RlabNetworkCommand com;
	
	while(workerOn && this.node.isConnected())
	{
	    waitForIncomingCommands();
	    if(outgoingCommands.size() > 0)
	    {
		com = (RlabNetworkCommand) outgoingCommands.remove(0);
		// Check the destination address is actually the other end of this socket
		if(!node.getRemoteNodeId().equals(com.receivingNode))
		{
		    RlabDebugWriter.error("Command is sent to remote address" + com.receivingNode +  " that is NOT the address at the end of this socket " + node.getRemoteNodeId());
		    workerOn = false;
		    break;
		}
		try
		{
		    sendImmediately(com);
		}
		catch (IOException e)
		{
		    RlabDebugWriter.error("Unable to write the network command object to the socket in the output worker thread  " + e);
		    workerOn = false;
		    break;
		}
	    }
	}
	try
	{
	    node.shutdown();
	    objOut.close();
	    out.close();
	    super.shutdown();
	}
	catch(Exception e)
	{
	    RlabDebugWriter.error("Unable to close cleanly in output worker" + e);
	}
	RlabDebugWriter.write("Closing output worker");
    }
}
