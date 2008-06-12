package ratrix.net;
import java.net.*;
import java.util.*;
import java.io.*;

public class RatrixNetworkClientKeepAliveSender implements Runnable
{
    RatrixNetworkClient client;
    RatrixNetworkClientIdent clientId;
    double keepAliveSend;
    boolean kaSenderOn = false;
    
    public RatrixNetworkClientKeepAliveSender(RatrixNetworkClient client, RatrixNetworkClientIdent clientId, double keepAliveSend)
    {
	this.client = client;
	this.clientId = clientId;
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
	while(client.clientOn() && kaSenderOn)
	{
	    RatrixNetworkCommand kaCom = new 
		RatrixNetworkCommand(this.client.getNextCommandUID(),clientId,
				     RatrixNetworkCommand.INTERNAL_MSG_PRIORITY,RatrixNetworkCommand.C_KEEP_ALIVE_COMMAND);
	    try
	    {
		this.client.sendCommandToServer(kaCom);
	    }
	    catch(IOException e)
	    {
		RatrixDebugWriter.error("RNCKAS: Error placing keep alive command on queue");
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