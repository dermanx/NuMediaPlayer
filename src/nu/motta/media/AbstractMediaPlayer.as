package nu.motta.media
{

	import nu.motta.media.events.MediaEvent;
	import nu.motta.media.utils.MediaStatus;

	import flash.display.Sprite;
	import flash.media.SoundTransform;

	/**
	 * ::name::
	 * ::description::
	 * 
	 * @author ::author::
	 * @since ::since::
	 * @version ::version::
	 */
	public class AbstractMediaPlayer extends Sprite
	{


		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _file : String;

		/**
		 * Status variables
		 */
		protected var _status : String = MediaStatus.STOPPED;

		protected var _buffering : Boolean = false;

		/**
		 * Volume Variables
		 */
		protected var _soundTransform : SoundTransform;

		protected var _pan : Number = 0;
				protected var _volume : Number = 1;

		protected var _volumeMuted : Number;

		protected var _muted : Boolean = false;

		/**
		 * Time Variables
		 */
		protected var _time : Number = 0;

		protected var _timeProgress : Number = 0;

		protected var _duration : Number = 0;

		protected var _bufferTime : Number;

		protected var _autoPlay : Boolean = false;

		protected var _loop : Boolean = false;

		/**
		 * Load Variables
		 */
		protected var _bytesLoaded : Number = 0;

		protected var _bytesTotal : Number = 0;

		protected var _loadProgress : Number = 0;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function AbstractMediaPlayer()
		{
			_soundTransform = new SoundTransform();
		}

		// ----------------------------------------------------
		// PROTECTED METHODS
		// ----------------------------------------------------
		protected function setStatus(value : String) : void
		{
			if(this.status == value)
			{
				return;
			}
			//
			_status = value;
			switch(value)
			{
				case MediaStatus.PLAYING:
					this.dispatchEvent(new MediaEvent(MediaEvent.PLAY));
					break;
				case MediaStatus.PAUSED:
					this.dispatchEvent(new MediaEvent(MediaEvent.PAUSE));
					break;
				case MediaStatus.STOPPED:
					this.dispatchEvent(new MediaEvent(MediaEvent.STOP));
					break;
			}
			//
			this.dispatchEvent(new MediaEvent(MediaEvent.STATUS_CHANGED));
		}

		protected function setBufferStatus(isBuffering : Boolean) : void
		{
			if(this.buffering == isBuffering)
				return;
			_buffering = isBuffering;

			this.dispatchEvent(new MediaEvent(this.buffering ? MediaEvent.BUFFERING : MediaEvent.BUFFERED));
		}

		protected function applySoundTransform() : void
		{
		}

		protected function formatTime(time : Number):String
		{
			var min : String = Math.floor(time / 60).toString();
			var sec : String = (Math.floor((time) % 60) < 10) ? "0" + Math.floor((time) % 60).toString() : Math.floor((time) % 60).toString();
			min = min.length > 1 ? min : "0" + min;
			sec = sec.length > 1 ? sec : "0" + sec;
			return min + ":" + sec;
		}

		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		/**
		 * Load a new media file
		 * 
		 * @param file					File URL
		 * @param bufferTime			Buffer time (in seconds)
		 */
		public function load(file : String, bufferTime : Number = 5) : void
		{
			_file = file;
			_bufferTime = bufferTime;
		}

		/**
		 * Play the Media
		 */
		public function play() : void
		{
			setStatus(MediaStatus.PLAYING);
		}

		/**
		 * Pause the Media
		 */
		public function pause() : void
		{
			setStatus(MediaStatus.PAUSED);
		}

		/**
		 * Toggle between play and pause
		 */
		public function togglePause() : void
		{
			this.status == MediaStatus.PLAYING ? pause() : play();
		}

		/**
		 * Stop the Media
		 */
		public function stop() : void
		{
			setStatus(MediaStatus.STOPPED);
		}

		/**
		 * Seek to a new position on the Media
		 * 
		 * @param time					Time in seconds to seek
		 * @see #seekPercent()
		 */
		public function seek(time : Number) : void
		{
		}

		/**
		 * Seek to a new position on the Media based on a percentage
		 * 
		 * @param percentage			A number on a range of <strong>0 to 1</strong>
		 * 
		 * @see #seek()
		 * @see #duration
		 */
		public function seekPercent(percentage : Number) : void
		{
			this.seek(this.duration * percentage);
		}

		/**
		 * Mute the sound
		 * 
		 * @see #unmute()
		 * @see #toggleMute()
		 * @see #muted
		 */
		public function mute() : void
		{
			if(_muted)
				return;

			_volumeMuted = _volume;
			_muted = true;

			this.volume = 0;
		}

		/**
		 * Unmute the sound
		 * 
		 * @see #mute()
		 * @see #toggleMute()
		 * @see #muted
		 */
		public function unmute() : void
		{
			if(!_muted)
			{
				return;
			}
			//
			_muted = false;

			this.volume = isNaN(_volumeMuted) ? 1 : _volumeMuted;
		}

		/**
		 * Toggle between mute and unmute
		 * 
		 * @see #mute()
		 * @see #unmute()
		 * @see #muted
		 */
		public function toggleMute() : void
		{
			_muted ? unmute() : mute();
		}
		
		/**
		 * Get a formatted time of a specified percentage of the media
		 * 
		 * @param percentage			A number on a range of <strong>0-1</strong>
		 */
		public function getFormattedTimeAt(percentage : Number) : String
		{
			return formatTime(this.duration * percentage);
		}

		/**
		 * Dispose the Media Player
		 */
		public function dispose() : void
		{
			if(_soundTransform)
			{
				_soundTransform = null;
			}
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		/**
		 * Set the volume on a range of <strong>0-1</strong>
		 */
		public function set volume(value : Number) : void
		{
			_volume = value;
			_soundTransform.volume = value;
			//
			applySoundTransform();
			//
			this.dispatchEvent(new MediaEvent(MediaEvent.VOLUME_CHANGED));
		}

		/**
		 * Get the current volume on a range of <strong>0-1</strong>
		 */
		public function get volume() : Number
		{
			return _volume;
		}
		
		/**
		 * Set the sound panning on a range of <strong>-1 to +1</strong>
		 */
		public function set pan(value : Number) : void
		{
			_pan = value;
			_soundTransform.pan = value;
			//
			applySoundTransform();
			//
			this.dispatchEvent(new MediaEvent(MediaEvent.VOLUME_CHANGED));
		}
		
		public function get pan() : Number
		{
			return _volume;
		}

		/**
		 * Return if the media is muted or not
		 */
		public function get muted() : Boolean
		{
			return _muted;
		}

		/**
		 * Return the current status of your media
		 */
		public function get status() : String
		{
			return _status;
		}

		/**
		 * Return if the video is buffering
		 */
		public function get buffering() : Boolean
		{
			return _buffering;
		}

		/**
		 * Set the video to auto play
		 */
		public function set autoPlay(value : Boolean) : void
		{
			_autoPlay = value;
		}

		public function get autoPlay() : Boolean
		{
			return _autoPlay;
		}

		/**
		 * Return the current time in seconds
		 */
		public function get time() : Number
		{
			return _time;
		}

		/**
		 * Return the current time, formatted in mm:ss
		 */
		public function get timeFormatted() : String
		{
			return formatTime(this.time);
		}

		/**
		 * Return the current time progress based on the duration, on a range of <strong>0 to 1</strong>
		 */
		public function get timeProgress() : Number
		{
			return this.time / this.duration;
		}

		/**
		 * Return the total duration
		 */
		public function get duration() : Number
		{
			return _duration;
		}

		/**
		 * Return the duration, formatted in mm:ss
		 */
		public function get durationFormatted() : String
		{
			return formatTime(this.duration);
		}

		/**
		 * Set if the media is going to loop or not
		 */
		public function get loop() : Boolean
		{
			return _loop;
		}

		public function set loop(value : Boolean) : void
		{
			_loop = value;
		}

		/**
		 * Bytes Loaded
		 */
		public function get bytesLoaded() : Number
		{
			return _bytesLoaded;
		}

		/**
		 * Bytes Total
		 */
		public function get bytesTotal() : Number
		{
			return _bytesTotal;
		}

		/**
		 * Return the load ratio on a range of <strong>0-1</strong>
		 */
		public function get loadProgress() : Number
		{
			return _loadProgress;
		}
	}
}
