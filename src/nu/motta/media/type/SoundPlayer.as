package nu.motta.media.type
{

	import nu.motta.media.utils.PlayerStatus;
	import nu.motta.media.AbstractPlayer;
	import nu.motta.media.events.PlayerEvent;
	import flash.media.ID3Info;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;

	/**
	 * ::name::
	 * ::description::
	 * 
	 * @author ::author::
	 * @since ::since::
	 * @version ::version::
	 */
	public class SoundPlayer extends AbstractPlayer
	{


		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _sound : Sound;

		protected var _channel : SoundChannel;

		protected var _pausedPosition : Number = 0;

		protected var _checkingBuffer : Boolean;

		protected var _id3 : ID3Info;
		
		protected var _userDuration : Number;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function SoundPlayer()
		{
			setupSound();
		}

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		protected function setupSound() : void
		{
			_sound = new Sound();
			_sound.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_sound.addEventListener(Event.COMPLETE, onLoadCompleted);
			_sound.addEventListener(Event.ID3, onID3Received);
		}
		
		protected function playSound(startTime : Number = 0, forceStop : Boolean = false) : void
		{
			if(_channel)
			{
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, onPlayCompleted);
				_channel = null;
			}
			_channel = _sound.play(startTime, 0, _soundTransform);
			_channel.addEventListener(Event.SOUND_COMPLETE, onPlayCompleted);
			
			if(forceStop)
			{
				_channel.stop();
			}
		}

		protected function startSound() : void
		{
			_sound.load(new URLRequest(_file), new SoundLoaderContext(_bufferTime));
			//
			this.autoPlay ? play() : stop();
			//
			setBufferStatus(true);
			startBufferCheck();
			//
			applySoundTransform();
		}

		protected function startBufferCheck() : void
		{
			if(!_checkingBuffer)
			{
				_checkingBuffer = true;
				this.addEventListener(Event.ENTER_FRAME, onUpdateBuffer);
			}
		}

		protected function stopBufferCheck() : void
		{
			if(_checkingBuffer)
			{
				_checkingBuffer = false;
				this.removeEventListener(Event.ENTER_FRAME, onUpdateBuffer);
			}
		}

		protected function soundCompleted() : void
		{
			if(this.loop)
			{
				_pausedPosition = 0;
				playSound(_pausedPosition);
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
			if(Boolean(_channel))
			{
				_channel.soundTransform = _soundTransform;
			}
		}

		// ----------------------------------------------------
		// EVENT HANDLERS
		// ----------------------------------------------------
		private function onUpdateBuffer(e : Event) : void
		{
			setBufferStatus(_sound.isBuffering);
		}

		private function onPlayCompleted(e : Event) : void
		{
			soundCompleted();
		}

		private function onID3Received(e : Event) : void
		{
			_id3 = _sound.id3;
			//
			this.dispatchEvent(new PlayerEvent(PlayerEvent.ID3_RECEIVED));
		}

		private function onLoadCompleted(e : Event) : void
		{
			stopBufferCheck();
			//
			this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_COMPLETED));
		}

		private function onLoadProgress(e : ProgressEvent) : void
		{
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
			_loadProgress = _bytesLoaded / _bytesTotal;
			//
			this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_PROGRESS));
		}

		private function onLoadError(e : IOErrorEvent) : void
		{
			this.dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_ERROR));
		}

		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		override public function load(file : String, bufferTime : Number = 5, manualDuration : Number = undefined) : void
		{
			super.load(file, bufferTime, manualDuration * 1000);

			startSound();
		}

		override public function play() : void
		{
			if(this.status == PlayerStatus.PLAYING)
			{
				return;
			}

			if(this.status == PlayerStatus.STOPPED)
			{
				_pausedPosition = 0;
			}
			playSound(_pausedPosition);
			//
			super.play();
		}

		override public function pause() : void
		{
			if(this.status == PlayerStatus.PAUSED)
			{
				return;
			}

			_pausedPosition = _channel.position;
			if(Boolean(_channel))
			{
				_channel.stop();
			}
			//
			super.pause();
		}

		override public function stop() : void
		{
			if(this.status == PlayerStatus.STOPPED)
			{
				return;
			}

			_pausedPosition = 0;
			if(Boolean(_channel))
			{
				playSound(_pausedPosition);
				_channel.stop();
			}
			//
			super.stop();
		}

		override public function seek(time : Number) : void
		{
			time *= 1000;
			
			playSound(time);
			
			super.seek(time);
		}

		override public function dispose() : void
		{
			// Sound Channel
			if(_channel)
			{
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, onPlayCompleted);
				_channel = null;
			}
			// Sound
			if(_sound)
			{
				_sound.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				_sound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				_sound.removeEventListener(Event.COMPLETE, onLoadCompleted);
				_sound.removeEventListener(Event.SOUND_COMPLETE, onPlayCompleted);
				_sound.removeEventListener(Event.ID3, onID3Received);
				if(_sound.bytesLoaded > 0)
				{
					_sound.close();
				}
				_sound = null;
			}
			// Buffer Enter Frame
			stopBufferCheck();
			//
			super.dispose();
		}

		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		override public function get duration() : Number
		{
			// Check the ID3 First
			if(Boolean(_id3))
			{
				if(_id3.hasOwnProperty("TLEN"))
				{
					return parseFloat(_id3["TLEN"]) / 1000;
				}
			}
			// Try the Manual Duration
			if(!isNaN(_manualDuration))
			{
				return _manualDuration / 1000;
			}
			// Get the sound length
			return _sound.length / 1000;
		}

		override public function get time() : Number
		{
			return Boolean(_channel) ? _channel.position / 1000 : 0;
		}

		override public function get timeProgress() : Number
		{
			return Boolean(_channel) ? this.time / this.duration : 0;
		}
		
		/**
		 * Return the ID3 Information
		 */
		public function get id3() : ID3Info
		{
			return _id3;
		}
	}
}
