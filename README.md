MessagingHX
===========

Simple cross plat global messaging/event broadcast, with a few optional data fields and delayed dispatch.

```
package;
import com.furusystems.messaging.Message;
import com.furusystems.messaging.MessageData;
import com.furusystems.messaging.Messaging;
class Tests 
{
  	static var myMessage:Message = new Message(); //predefined message type
		public function new() 
		{
			
			Messaging.addCallback([myMessage], myMessageCallback); //create a listener for a message type
			Messaging.send(myMessage, "foo", this, 2); //In two seconds, send a message of the type myMessage, with the data "foo", with a pointer to this
		}
		
		function myMessageCallback(m:MessageData):Void 
		{
			trace("Message received");
			m.message; //the message type (useful for switches)
			m.data; //The message data (in this example, "foo")
			m.source; //The message origin (in this example, "this")
		}
}
```
