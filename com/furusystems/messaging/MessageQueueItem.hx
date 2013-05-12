package com.furusystems.messaging;
/**
 * Message queue item used by PimpCentral to manage the message buffer
 * @author Andreas Rønning 
 */
class MessageQueueItem {
	
	public var message:Message; //The queued Message
	public var origin:Dynamic; //The notification origin
	public var data:Dynamic; //The notification payload
	public var delaySeconds:Float = -1; //The notification delay in milliseconds (only valid if PimpCentral.delayEnabled is true)
	public function new() {
		
	}
}