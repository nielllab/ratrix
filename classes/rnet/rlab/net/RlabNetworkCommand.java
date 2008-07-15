package rlab.net;
import java.io.Serializable;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.util.Date;

public class RlabNetworkCommand implements Serializable
{
//     public static final int PROTOCOL_VERSION = 1;
    public static final int SERVER_TYPE = 1;
    public static final int CLIENT_TYPE = 2;
    // Internal messages have highest priority at 0, all higher commands must have higher priority
    public static final int MAX_PRIORITIES = 5;
    public static final int INTERNAL_MSG_PRIORITY = 0;
    public static final int MIN_PRIORITY = 4;
    public static final int MAX_PRIORITY = 0;
    // All internal commands/priorities to this level are negative, and invisible to the higher level 
    //   matlab based command system
    public static final int C_CONNECT_COMMAND = -1;
    public static final int C_DISCONNECT_COMMAND = -2;
    public static final int S_CONNECT_ACK_COMMAND = -3;
    public static final int C_SERVER_RESET_COMMAND = -4;
    public static final int C_KEEP_ALIVE_COMMAND = -5;
    public static final int S_KEEP_ALIVE_ACK_COMMAND = -6;
//     public static final int C_VALVE_OPENED_COMMAND = 4;
//     public static final int C_VALVE_CLOSED_COMMAND = 5;
//     public static final int C_PUMP_INFUSE_COMMAND = 6;
//     public static final int C_TRIAL_DATA_COMMAND = 7;
//     public static final int C_SEND_OBJECT_COMMAND = 8;
//     public static final int C_PRIME_PUMP_COMMAND = 9;
//     public static final int C_RESET_PUMP_POSITION_COMMAND = 10;
//     public static final int S_DISCONNECT_COMMAND = 100;
//     public static final int S_OPEN_VALVE_COMMAND = 101;
//     public static final int S_CLOSE_VALVE_COMMAND = 102;
//     public static final int S_SEND_OBJECT_COMMAND = 103;
    public int UID;
    public int command;
    public RlabNetworkNodeIdent sendingNode;
    public RlabNetworkNodeIdent receivingNode;
    public Date arrived;
    public Date sent;
    public Object arguments[];
    public int priority;


    public RlabNetworkCommand(int UID, RlabNetworkNodeIdent sendingNode, RlabNetworkNodeIdent receivingNode, int priority, int command)
    {
	this(UID,sendingNode,receivingNode,priority,command,null);
    }

    public RlabNetworkCommand(int UID, RlabNetworkNodeIdent sendingNode, RlabNetworkNodeIdent receivingNode, int priority, int command, Object arguments[])
    {
	this.UID = UID;
	this.sendingNode = sendingNode;
	this.receivingNode = receivingNode;
	this.priority = priority;
	this.command = command;
	this.arguments = arguments;
	this.arrived = null;
	this.sent = null;
    }

    public String toString()
    {

	String timeString = "";
	if(this.sent != null)
	{
	    timeString = timeString + ",\tsent:" + this.sent;
	}
	if(this.arrived != null)
	{
	    timeString = timeString + ",\tarr:" + this.arrived;
	}
	switch(command)
	{
	case C_KEEP_ALIVE_COMMAND:
	    return "Keep Alive FROM:" + this.sendingNode + timeString;
	case S_KEEP_ALIVE_ACK_COMMAND:
	    return "Keep Alick ACK" + timeString;
	default:
	    return "RNetCom(UID:" + this.UID + ",\tFR:" + this.sendingNode + ",\tTO:" + this.receivingNode + ",\tCOM:" + this.command + "\tPR:" + this.priority + timeString + ")";
	}
    }

    public int getCommand()
    {
	return command;
    }

    public int getUID()
    {
	return UID;
    }

    public Object[] getArguments()
    {
	return arguments;
    }

    public void setByteArrayArgument(int index, byte b[])
    {
	if(index >= this.arguments.length)
	{
	    System.err.println("Argument index out of range");
	}
	else
	{
	    this.arguments[index] = (Object) b;
	}
    }

    public void setArguments(Object arguments[])
    {
	this.arguments = arguments;
    }

    public void setArrivalTime()
    {
	arrived = new Date();
    }

    public Date getArrivalTime()
    {
	return arrived;
    }

    public void setDepartureTime()
    {
	sent = new Date();
    }

    public Date getDepartureTime()
    {
	return sent;
    }

    public void writeObjectToFile(byte fBytes[], String path)
    {
	File f;
	FileOutputStream fs;
	try
	{
	    f = new File(path);
	    fs = new FileOutputStream(f);
	    fs.write(fBytes);
	}
	catch(java.io.FileNotFoundException err)
	{
	    System.err.println("File not found");
	}
	catch(java.io.IOException err)
	{
	    System.err.println("Unable to write object out to file");
	}
    }

    // Load in a file as an array of bytes into an object
    public Object loadObjectFromFile(String path)
    {
	Object obj=null;
	File f;
	FileInputStream fs;
	byte fBytes[];
	int curIndex = 0;
	int len = 0;
	f = new File(path);
	try
	{
	    fs = new FileInputStream(f);
	    if(f.length() > Integer.MAX_VALUE)
	    {
		System.err.println("File exceeds max integer size bytes, cannot send over network");
		return null;
	    }
	    int fileLength = (int) f.length();
	    fBytes = new byte[fileLength];
	    while(curIndex<f.length())
	    {
		len = fs.available();
		if(len > 0)
		{
		    fs.read(fBytes,curIndex,len);
		}
		else
		{
		    Thread.sleep(100);
		}
		curIndex += len;
	    }
	obj = (Object) fBytes;
	}
	catch(java.io.FileNotFoundException err)
	{
	    System.err.println("File not found");
	}
	catch(java.io.IOException err)
	{
	    System.err.println("Unable to read object in from file");
	}
	catch(java.lang.InterruptedException err)
	{
	    System.err.println("Object loading from file interrupted");
	}
	return obj;
    }

    public void removeObjectFromArgumentListToFile(String path,int argIndex)
    {
	byte fBytes[];
	fBytes = (byte[]) this.arguments[argIndex];
	this.writeObjectToFile(fBytes,path);
    }

    public void addObjectFromFileToArgumentList(String path)
    {
	Object obj;
	Object ar[];
	obj = this.loadObjectFromFile(path);
	if(this.arguments == null)
	{
	    this.arguments = new Object[1];
	    this.arguments[0] = obj;
	} 
	else
	{
	    ar = new Object[this.arguments.length+1];
	    for(int i=0;i<this.arguments.length;i++)
	    {
		ar[i] = this.arguments[i];
	    }
	    ar[ar.length-1] = obj;
	}
    }
}

