package rlab.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RlabNetworkClientKeepAliveSender implements Runnable
{
    RlabNetworkNode node;
    double keepAliveSend;
    boolean kaSenderOn = false;
    
    public RlabNetworkClientKeepAliveSender(RlabNetworkNode node, double keepAliveSend)
    {
	this.node = node;
	this.keepAliveSend = keepAliveSend;
    }


    protected void finalize() throws Throwable
    {
	try
	{
	    this.kaSenderOn = false;
	}
	finally
	{
	    super.finalize();
	}
    }

    public void run()
    {
	handleKeepAliveSending();
    }

    private void handleKeepAliveSending()
    {
	this.kaSenderOn=true;
	while(node.nodeOn() && kaSenderOn)
	{
	    RlabNetworkCommand kaCom = new 
		RlabNetworkCommand(this.node.getNextCommandUID(),this.node.getLocalNodeId(),this.node.getRemoteNodeId(),
				     RlabNetworkCommand.INTERNAL_MSG_PRIORITY,RlabNetworkCommand.C_KEEP_ALIVE_COMMAND);
	    try
	    {
		this.node.sendImmediately(kaCom);
	    }
	    catch(IOException e)
	    {
		RlabDebugWriter.error("RNCKAS: Error placing keep alive command on queue");
		kaSenderOn = false;
		break;
	    }
	    try
	    {
		Thread.sleep((int)(keepAliveSend*1000));
	    }
	    catch(Exception e)
	    {
		// Do nothing
	    }   
	}
    }


}