conn = 

    host: '132.239.158.177'
    port: '1521'

 
ans =
 
oracle.jdbc.driver.T4CConnection@1db0c7e
 

ans =

132.239.158.154


rackIDs =

     1


ans =

match!


rackID =

     1


ans =

132.239.158.155


rackIDs =

     3


ans =

132.239.158.156


rackIDs =

     2     3

??? Error using ==> getRackIDFromIP at 29
found multiple rack ids for one server ip

Error in ==> getRatLayout at 3
rack = getRackIDFromIP;

Error in ==> reportSettings at 12
    [heats stations subjects]=getRatLayout();