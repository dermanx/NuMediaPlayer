package nu.motta.media.events
{

	import flash.events.Event;

	/**
	 * @author ::author::
	 * @since ::since::
	 * @version ::version::
	 */
	public class MediaEvent extends Event
	{

		
		/**
		 * The Media is played
		 */
		public static const PLAY : String = "play";
		
		/**
		 * The Media is paused
		 */		public static const PAUSE : String = "paused";
		
		/**
		 * The Media is stopped
		 */		public static const STOP : String = "stop";
		
		/**
		 * The Media is completed
		 */		public static const COMPLETED : String = "completed";
		
		/**
		 * Media Loop
		 */		public static const LOOP : String = "loop";
		
		/**
		 * Media is Buffering
		 */
		public static const BUFFERING : String = "buffering";
		
		/**
		 * Media is Buffered
		 */		public static const BUFFERED : String = "buffered";
		
		/**
		 * The Status has changed (playing, paused, stopped)
		 */		public static const STATUS_CHANGED : String = "statusChanged";
		
		/**
		 * The volume has changed
		 */		public static const VOLUME_CHANGED : String = "volumeChanged";
		
		/**
		 * Load Completed
		 */		public static const LOAD_COMPLETED : String = "loadCompleted";
		
		/**
		 * Load Progress
		 */		public static const LOAD_PROGRESS : String = "loadProgress";
		
		/**
		 * Load Error
		 */		public static const LOAD_ERROR : String = "loadError";

		
		/**
		 * @constructor
		 */
		public function MediaEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
