package nu.motta.media.events
{

	import flash.events.Event;

	/**
	 * @author ::author::
	 * @since ::since::
	 * @version ::version::
	 */
	public class PlayerEvent extends Event
	{

		
		/**
		 * The Media is played
		 */
		public static const PLAY : String = "play";
		
		/**
		 * The Media is paused
		 */
		
		/**
		 * The Media is stopped
		 */
		
		/**
		 * The Media is completed
		 */
		
		/**
		 * Media Loop
		 */
		
		/**
		 * Media is Buffering
		 */
		public static const BUFFERING : String = "buffering";
		
		/**
		 * Media is Buffered
		 */
		
		/**
		 * The Status has changed (playing, paused, stopped)
		 */
		
		/**
		 * The volume has changed
		 */
		
		/**
		 * Load Completed
		 */
		
		/**
		 * Load Progress
		 */
		
		/**
		 * Load Error
		 */

		
		/**
		 * @constructor
		 */
		public function PlayerEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}