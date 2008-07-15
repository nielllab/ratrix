package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public abstract class RlabNetworkWorker implements Runnable
{
    // Class Variables

    // Instance Variables
    protected boolean workerOn = false; // Whether worker should be running
    protected RlabNetworkNode node = null; // The node that this worker is attached to locally
    private Socket socket = null; // Socket used for communication with client

    // Class Constructors
    public RlabNetworkWorker(RlabNetworkNode node, Socket socket)
    {
	workerOn = true;
	this.socket = socket; // Set the socket
	this.node = node; // Set the local node	
    }
    
    public void run()
    {
	handleRequests();
    }

    // Implement this to handle incoming/outgoing requests
    abstract protected void handleRequests();    
    

    public void shutdown()
    {
	workerOn = false;
    }
    
}
