package rlab.net;
import java.util.Vector;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;

class RlabMap
{
    private Vector keys;
    private Vector values;

    public RlabMap()
    {
	keys = new Vector();
	values = new Vector();
    }

    public void clear()
    {
	keys.clear();
	values.clear();
    }

    public boolean containsKey(Object key)
    {
	if(key == null)
	    return false;
	for(int i=0;i<keys.size();i++)
	{
	    if(keys.elementAt(i).equals(key))
		return true;
	}
	return false;
    }

    public boolean containsValue(Object value)
    {
	if(value == null)
	    return false;
	for(int i=0;i<values.size();i++)
	{
	    if(values.elementAt(i).equals(value))
		return true;
	}
	return false;
    }
    
    public Object get(Object key)
    {
	if(key == null)
	    return null;
	for(int i=0;i<keys.size();i++)
	{
	    if(keys.elementAt(i).equals(key))
		return values.elementAt(i);
	}
	return null;
    }

    public boolean isEmpty()
    {
	if(keys.size() == 0)
	    return true;
	else
	    return false;
    }

    public Set keySet()
    {
	Set k = new HashSet();
	for(int i=0;i<keys.size();i++)
	{
	    k.add(keys.elementAt(i));
	}
	return k;
    }

    public synchronized Object put(Object key, Object value)
    {
	Object oldValue;
	if(key==null)
	    return null;
	for(int i=0;i<keys.size();i++)
	{
	    if(keys.elementAt(i).equals(key))
	    {
		oldValue = values.elementAt(i);
		values.set(i,value);
		return oldValue;
	    }	    
	}
	keys.add(key);
	values.add(value);
	return null;
    }

    public synchronized Object remove(Object key)
    {
	for(int i=0;i<keys.size();i++)
	{
	    if(keys.elementAt(i).equals(key))
	    {
		keys.remove(i);
		return values.remove(i);
	    }	    
	}	
	return null;
    }

    public int size()
    {
	return keys.size();
    }
	
}
