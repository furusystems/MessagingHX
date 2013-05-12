package com.furusystems.messaging;
/**
 * Describes a message receiver that can add itself to PimpCentral as a listener for a specific message type
 */
interface IMessageReceiver 
{
	/**
	 * Called by PimpCentral when the message is dispatched
	 * @param	messageData 
	 * data object containing message details
	 */
	function onMessage(messageData:MessageData):Void;
}