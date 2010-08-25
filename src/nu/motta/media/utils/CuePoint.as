package nu.motta.media.utils
{
	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 25, 2010
	 */
	public class CuePoint extends Object
	{


		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _name : String;

		protected var _time : Number;

		protected var _type : String;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function CuePoint(cuePointInfo : Object)
		{
			_name = cuePointInfo["name"];
			_time = cuePointInfo["time"];
			_type = cuePointInfo["type"];
		}
		
		public function toString() : String
		{
			return '[CuePoint name="' + this.name + '" time="' + this.time + '" type="' + this.type + '"]';
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		/**
		 * Cue point name
		 */
		public function get name(): String
		{
			return _name;
		}

		/**
		 * Cue point time
		 */
		public function get time() : Number
		{
			return _time;
		}

		/**
		 * Cue point type
		 */
		public function get type(): String
		{
			return _type;
		}
	}
}
