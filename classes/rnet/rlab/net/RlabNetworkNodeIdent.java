package rlab.net;
import java.io.Serializable;

public class RlabNetworkNodeIdent implements Serializable
{
    public String id;

    public RlabNetworkNodeIdent(String id)
    {
	this.id = id;
    }
    public boolean equals(Object a)
    {
	RlabNetworkNodeIdent castA;
	if(a==this){ return true;}
	if( a == null || (a.getClass() != this.getClass()) ) return false; // instanceOf should work and is preferred...oh well
	castA = (RlabNetworkNodeIdent) a;
	if(this.id.equals(castA.id)) return true;
	else return false;
    }

    public String toString()
    {
	return id;
    }

}
