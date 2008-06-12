package ratrix.net;
import java.io.Serializable;

public class RatrixNetworkClientIdent implements Serializable
{
    public String id;
    public RatrixNetworkClientIdent(String id)
    {
	this.id = id;
    }
    public boolean equals(Object a)
    {
	RatrixNetworkClientIdent castA;
	if(a==this){ return true;}
	if( a == null || (a.getClass() != this.getClass()) ) return false; // instanceOf should work and is preferred...oh well
	castA = (RatrixNetworkClientIdent) a;
	if(this.id.equals(castA.id)) return true;
	else return false;
    }
}
