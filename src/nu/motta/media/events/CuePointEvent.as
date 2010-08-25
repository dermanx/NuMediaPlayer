package nu.motta.media.events
{

	import nu.motta.media.utils.CuePoint;

	import flash.events.Event;

	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 25, 2010
	 */
	public class CuePointEvent extends Event
	{


		public static const CUE_POINT_RECEIVED : String = "onCuePoint";

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _cuePoint : CuePoint;

		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function CuePointEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false, cuePoint : CuePoint = null)
		{
			_cuePoint = cuePoint;

			super(type, bubbles, cancelable);
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		public function get cuePoint() : CuePoint
		{
			return _cuePoint;
		}
	}
}
