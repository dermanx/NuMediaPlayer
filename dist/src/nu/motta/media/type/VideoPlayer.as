package nu.motta.media.type
{

	import nu.motta.media.utils.CuePointManager;
	import nu.motta.media.AbstractPlayer;
	import nu.motta.media.events.CuePointEvent;
	import nu.motta.media.events.PlayerEvent;
	import nu.motta.media.utils.CuePoint;
	import nu.motta.media.utils.PlayerStatus;

	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;

	/**
	 * NuMediaPlayer
	 * Media Player for Audio and Video
	 * 
	 * @author Lucas Motta (http://lucasmotta.com)
	 * @since Aug 23, 2010
	 * @version 1.0
	 */
	public class VideoPlayer extends AbstractPlayer
	{


		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _size : Rectangle;

		protected var _autoSize : Boolean;

		protected var _netStream : NetStream;

		protected var _netConnection : NetConnection;

		protected var _video : Video;

		protected var _smoothing : Boolean = true;

		protected var _timerLoad : Timer;

		protected var _flushed : Boolean;

		protected var _stopped : Boolean;

		protected var _metaData : Object;

		protected var _cuePointManager : CuePointManager;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function VideoPlayer(width : int, height : int, autoSize : Boolean = false)
		{
			_size = new Rectangle(0, 0, width, height);
			_autoSize = autoSize;
			//
			setupVideo();
			setupTimer();
		}

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		protected function setupConnection() : void
		{
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionEvent);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
			_netConnection.connect(null);
		}

		protected function setupNetStream() : void
		{
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamEvent);
			_netStream.client = this;
			//
			startLoad();
			//
			_video.attachNetStream(_netStream);
		}

		protected function setupVideo() : void
		{
			_video = new Video(_size.width, _size.height);
			_video.smoothing = this.smoothing;
			addChild(_video);
		}

		protected function setupTimer() : void
		{
			_timerLoad = new Timer(30);
			_timerLoad.addEventListener(TimerEvent.TIMER, onLoadProgress);
		}

		protected function startLoad() : void
		{
			// Reset Flushed and Stopped
			_flushed = false;
			_stopped = false;
			// Set the buffer time and load the file
			_netStream.bufferTime = _bufferTime;
			_netStream.play(_file);
			// Start the buffer
			setBufferStatus(true);
			// Apply the volume
			applySoundTransform();
			// Check if it's setted to auto play or not
			this.autoPlay ? play() : stop();
			// Reset timers
			resetTimer(_timerLoad, true);
		}

		protected function resetTimer(timer : Timer, autoStart : Boolean = false) : void
		{
			if(timer == null)
				return;
			if(timer.running)
			{
				timer.stop();
			}
			if(autoStart)
				timer.start();
		}

		protected function videoCompleted() : void
		{
			_flushed = false;
			_stopped = false;
			//
			if(this.loop)
			{
				_netStream.seek(0);
				_netStream.resume();
				//
				this.dispatchEvent(new PlayerEvent(PlayerEvent.LOOP));
				//
				return;
			}
			//
			this.dispatchEvent(new PlayerEvent(PlayerEvent.COMPLETED));
			//
			setStatus(PlayerStatus.STOPPED);
		}

		override protected function applySoundTransform() : void
		{
			if(Boolean(_netStream))
			{
				_netStream.soundTransform = _soundTransform;
			}
		}

		// ----------------------------------------------------
		// EVENT HANDLERS
		// ----------------------------------------------------
		/**
		 * @private
		 */
		protected function onNetConnectionEvent(e : NetStatusEvent) : void
		{
			switch (e.info["code"])
			{
				case "NetConnection.Connect.Success" :
					setupNetStream();
					break;
				case "NetConnection.Connect.Failed" :
				case "NetConnection.Connect.Success" :
					onLoadError(null);
					break;
			}
		}

		/**
		 * @private
		 */
		protected function onNetStreamEvent(e : NetStatusEvent) : void
		{
			switch (e.info["code"])
			{
				case "NetStream.Buffer.Full" :
					setBufferStatus(false);
					break;
				case "NetStream.Buffer.Empty" :
					setBufferStatus(true);
					break;
				case "NetStream.Buffer.Flush" :
					_flushed = true;
					break;
				case "NetStream.Play.Stop" :
					_stopped = true;
					break;
				case "NetStream.Play.StreamNotFound" :
				case "NetStream.Play.Failed" :
				case "NetStream.Play.StreamNotFound" :
				case "NetStream.Connect.Failed" :
				case "NetStream.Connect.Rejected" :
				case "NetStream.Connect.Closed" :
					onLoadError(null);
					break;
			}
			if(_flushed && _stopped)
			{
				videoCompleted();
			}
		}

		/**
		 * @private
		 */
		protected function onLoadError(e : Event) : void
		{
			this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_ERROR));
		}

		/**
		 * @private
		 */
		protected function onLoadProgress(e : TimerEvent) : void
		{
			_bytesLoaded = _netStream.bytesLoaded;
			_bytesTotal = _netStream.bytesTotal;
			_loadProgress = _bytesLoaded / _bytesTotal;

			this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_PROGRESS));

			if(_loadProgress == 1)
			{
				this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_COMPLETED));

				resetTimer(_timerLoad, false);
				return;
			}
		}

		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		override public function load(file : String, bufferTime : Number = 5, manualDuration : Number = undefined) : void
		{
			super.load(file, bufferTime, manualDuration);

			Boolean(_netConnection) ? startLoad() : setupConnection();
		}

		override public function play() : void
		{
			if(this.status == PlayerStatus.PLAYING)
			{
				return;
			}
			if(this.status == PlayerStatus.STOPPED)
			{
				_netStream.seek(0);
			}
			_netStream.resume();

			super.play();
		}

		override public function pause() : void
		{
			if(this.status == PlayerStatus.PAUSED)
			{
				return;
			}
			//
			_netStream.pause();
			//
			super.pause();
		}

		override public function stop() : void
		{
			if(this.status == PlayerStatus.STOPPED)
			{
				return;
			}

			_netStream.seek(0);
			_netStream.pause();

			super.stop();
		}

		override public function seek(time : Number) : void
		{
			if(this.status == PlayerStatus.STOPPED)
			{
				setStatus(PlayerStatus.PAUSED);
			}
			_netStream.seek(time);

			super.seek(time);
		}

		override public function dispose() : void
		{
			// Remove NetStream
			if(_netStream)
			{
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStreamEvent);
				_netStream.pause();
				if(_netStream.bytesLoaded > 0)
				{
					_netStream.close();
				}
				_netStream = null;
			}
			// Remove NetConnection
			if(_netConnection)
			{
				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetConnectionEvent);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);
				if(_netConnection.connected)
				{
					_netConnection.close();
				}
				_netConnection = null;
			}
			// Remove Timer
			if(_timerLoad)
			{
				if(_timerLoad.running)
				{
					_timerLoad.stop();
				}
				_timerLoad.removeEventListener(TimerEvent.TIMER, onLoadProgress);
				_timerLoad = null;
			}
			//
			super.dispose();
		}
		
		/**
		 * Seek to the next cue point if it's available
		 */
		public function nextCuePoint() : void
		{
			if(Boolean(_cuePointManager))
			{
				seek(_cuePointManager.getNextCuePoint(this.time).time);
			}
		}
		
		/**
		 * Seek to the previous cue point if it's available
		 */
		public function previousCuePoint() : void
		{
			if(Boolean(_cuePointManager))
			{
				seek(_cuePointManager.getPreviousCuePoint(this.time).time);
			}
		}
		
		/**
		 * Seek to a specific cue point
		 */
		public function gotoCuePoint(cuePointName : String) : void
		{
			if(Boolean(_cuePointManager))
			{
				seek(_cuePointManager.getCuePointByName(cuePointName).time);
			}
		}

		/**
		 * @private
		 * @excludeInherit
		 * @exclude
		 */
		public function onMetaData(info : Object):void
		{
			_metaData = info;

			if(info.hasOwnProperty("duration"))
			{
				_duration = info["duration"];
			}
			if(info.hasOwnProperty("width") && info.hasOwnProperty("height"))
			{
				if(_autoSize)
				{
					_size = new Rectangle(0, 0, info["width"], info["height"]);
					_video.width = _size.width;
					_video.height = _size.height;
				}
			}
			//
			this.dispatchEvent(new PlayerEvent(PlayerEvent.METADATA_RECEIVED));
		}

		/**
		 * @private
		 * @excludeInherit
		 * @exclude
		 */
		public function onCuePoint(info : Object):void
		{
			this.dispatchEvent(new CuePointEvent(CuePointEvent.CUE_POINT_RECEIVED, false, false, new CuePoint(info)));
		}

		/**
		 * @private
		 * @excludeInherit
		 * @exclude
		 */
		public function onXMPData(info : Object):void
		{
			_cuePointManager = new CuePointManager(info);
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		override public function get duration() : Number
		{
			if(_metaData)
			{
				if(_metaData.hasOwnProperty("duration"))
				{
					return _metaData["duration"];
				}
			}
			if(!isNaN(_manualDuration))
			{
				return _manualDuration;
			}
			return _duration;
		}

		override public function get time() : Number
		{
			return _netStream.time;
		}

		public function get metaData() : Object
		{
			return _metaData;
		}

		/**
		 * Smooth the Video
		 */
		public function get smoothing() : Boolean
		{
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void
		{
			_smoothing = value;
			if(Boolean(_video))
			{
				_video.smoothing = _smoothing;
			}
		}
	}
}