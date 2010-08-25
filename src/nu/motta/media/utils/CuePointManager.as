package nu.motta.media.utils
{
	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 25, 2010
	 */
	public class CuePointManager
	{


		private static const xmpDM : Namespace = new Namespace("http://ns.adobe.com/xmp/1.0/DynamicMedia/");

		private static const rdf : Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");

		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _info : Object;

		protected var _xml : XML;

		protected var _frameRate : Number;

		protected var _cuePoints : Array;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function CuePointManager(info : Object)
		{
			_info = info;
			_xml = new XML(_info["liveXML"]);

			getCuePoints();
		}

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		protected function getCuePoints() : void
		{
			var i : int;
			var cuePointList : XMLList = _xml..xmpDM::markers.rdf::Seq.rdf::li;
			var frameRateString : String = _xml..xmpDM::Tracks..rdf::Description.@xmpDM::frameRate;
			var length : int = cuePointList.length();
			var cueXML : XML;

			_frameRate = Number(frameRateString.substr(1, frameRateString.length));
			_cuePoints = [];

			for (i = 0; i < length; i++)
			{
				cueXML = cuePointList[i];
				_cuePoints[_cuePoints.length] = new CuePoint({ name:cueXML.@xmpDM::name, type:cueXML.@xmpDM::cuePointType, time:cueXML.@xmpDM::startTime / _frameRate });
			}
		}

		// ----------------------------------------------------
		// EVENT HANDLERS
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		/**
		 * Get the next CuePoint
		 */
		public function getNextCuePoint(currentTime : Number) : CuePoint
		{
			var i : int;
			var length : int = _cuePoints.length;
			var point : CuePoint;

			for(i = 0; i < length; i++)
			{
				point = _cuePoints[i];
				// get the first cue point that is higher then the current time
				if(point.time > currentTime)
				{
					return point;
				}
			}
			return _cuePoints[0];
		}

		/**
		 * Get the previous CuePoint
		 */
		public function getPreviousCuePoint(currentTime : Number) : CuePoint
		{
			var i : int;
			var length : int = _cuePoints.length;
			var point : CuePoint;

			for(i = length - 1; i >= 0; i--)
			{
				point = _cuePoints[i];
				// get the first cue point that is lower then the current time
				if(point.time < currentTime)
				{
					return point;
				}
			}
			return _cuePoints[_cuePoints.length - 1];
		}

		/**
		 * Get the Cue Point by name
		 */
		public function getCuePointByName(name : String) : CuePoint
		{
			var i : int;
			var length : int = _cuePoints.length;
			var point : CuePoint;

			for(i = 0; i < length; i++)
			{
				point = _cuePoints[i];
				if(point.name == name)
				{
					return point;
				}
			}
			return null;
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		public function get frameRate() : Number
		{
			return _frameRate;
		}
	}
}
