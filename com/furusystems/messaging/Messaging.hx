package com.furusystems.messaging;
import haxe.Timer;
/**
 * Static or instanced Message central allowing app-wide Message broadcast as a complement to the event framework
 * @author Andreas Rønning 
 */
using Lambda;
class Messaging
{
	//{ statics
	private static var _recipientsTable:Map<Message, Array<IMessageReceiver>> = new Map<Message, Array<IMessageReceiver>>();  //Table of vectors of recipients keyed by Message type
	private static var _callbacksTable:Map<Message, Array<MessageData->Void>> = new Map<Message,Array<MessageData->Void>>(); //Table of vectors of callbacks keyed by Message type
	private static var _messageQueue:Array<MessageQueueItem> = new Array<MessageQueueItem>(); //Queue of Messages not yet sent (if delayed and delayed Message is enabled)
	private static var _tempData:MessageData = new MessageData();
	/**
	 * Dispatch a Message to all listeners for that specific Message object
	 * @param	n 
	 * The Message to dispatch
	 * @param	origin 
	 * (optional) 
	 * The object that dispatched the Message
	 * @param	data 
	 * (optional) 
	 * Any payload to send along with the Message
	 * @param	delayMS 
	 * (optional, dependent on delayEnabled) The number of milliseconds before the Message will be dispatched
	 */
	public static function send(m:Message, data:Dynamic = null, origin:Dynamic = null, delaySeconds:Float = -1):Void
	{
		var q:MessageQueueItem = new MessageQueueItem();
		q.message = m;
		q.origin = origin;
		q.delaySeconds = delaySeconds;
		q.data = data;
		if (delaySeconds <= 0) { 
			processMessage(q);
			return;
		}
		_messageQueue.push(q);
		Timer.delay(checkQueue, cast q.delaySeconds * 1000);
		
	}
	/**
	 * Private handler for individual MessageQueueItems
	 * @param	queueItem
	 */
	
	private static function processMessage(queueItem:MessageQueueItem):Void {
		var m:Message = queueItem.message;
		var o:Dynamic = queueItem.origin;
		var d:Dynamic = queueItem.data;
		_tempData.message = m;
		_tempData.source = queueItem.origin;
		_tempData.data = queueItem.data;
		if (_recipientsTable.exists(m)) {
			var table = _recipientsTable.get(m);
			for(listener in table) {
				listener.onMessage(_tempData);
			}
		}
		if(_callbacksTable.exists(m)){
			var table = _callbacksTable.get(m);
			for (cb in table) {
				cb(_tempData);
			}
		}
	}
	/**
	 * Private handler for frame events, handling delayed items
	 * @param	e
	 */
	private static function checkQueue():Void {
		if (_messageQueue.length == 0) return;
		var time:Float = Timer.stamp();
		for (n in _messageQueue) 
		{
			if (n.delaySeconds <= time) {
				processMessage(n);
				_messageQueue.remove(n);
			}
		}
	}
	/**
	 * Remove an IMessageReceiver from the receivers list for a specific Message
	 * @param	receiver 
	 * The IMessageReceiver that shouldn't receive the Message anymore
	 * @param	Message 
	 * The Message type the receiver shouldn't receive anymore
	 */
	public static function removeReceiver(receiver : IMessageReceiver, m : Message) :Void 
	{
		if (!_recipientsTable.exists(m)) return;
		_recipientsTable.get(m).remove(receiver);
	}
	/**
	 * Add an IMessageReceiver to the receivers list for a specific Message
	 * @param	receiver 
	 * The IMessageReceiver that should receive the Message
	 * @param	Message 
	 * The Message type the receiver should receive
	 * @parem ...rest
	 * More messages to receiver...
	 */
	public static function addReceiver(receiver : IMessageReceiver, messages : Array<Message>) :Void 
	{
		for(m in messages) {
			appendReceiver(receiver, m);
		}
	}
	private static function appendReceiver(receiver:IMessageReceiver, m:Message):Void {
		var table:Array<IMessageReceiver>;
		if (_recipientsTable.exists(m)) {
			table = _recipientsTable.get(m);
		}else {
			_recipientsTable.set(m, table = new Array<IMessageReceiver>());
		}
		if (table.indexOf(receiver) > -1) return;
		table.push(receiver);
	}
	/**
	 * Adds a callback to be executed when a specific notofication is sent
	 * @param	Message
	 * The Message to respond to
	 * @param	callback
	 * The callback function, accepting either none or 1 argument ( an instance of MessageData)
	 * @param ...rest
	 * More messages to respond to with this callback...
	 */
	public static function addCallback(messages:Array<Message>, cb:Dynamic):Void {
		for(m in messages) {
			appendCallback(cb, m);
		}
	}
	private static function appendCallback(cb:Dynamic, m:Message):Void {
		var table:Array<MessageData->Void>;
		if (_callbacksTable.exists(m)) {
			table = _callbacksTable.get(m);
		}else {
			_callbacksTable.set(m, table = new Array<MessageData->Void>());
		}
		if (table.indexOf(cb) > -1) return;
		table.push(cb);
	}
	/**
	 * Remove a callback from the execution list of a specific Message
	 * @param	callback
	 * The callback that should stop receiving the Message
	 * @param	m
	 * The Message that should stop triggering this callback
	 */
	public static function removeCallback(m:Message, cb:Dynamic):Void {
		if (!_callbacksTable.exists(m)) return;
		_callbacksTable.get(m).remove(cb);
	}
}