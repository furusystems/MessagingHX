package com.furusystems.messaging;
/**
 * Basic marker Message type. May be swapped out for string or int pointers later
 * if we don't wind up adding any properties to it.
 * @author Andreas Rønning 
 */
class Message
{
	private static var idPool:Int = 0;
	public var id:Int;
	public function new() {
		id = idPool++;
	}
}