package
{

	import nu.motta.media.utils.MediaStatus;
	import nu.motta.media.events.MediaEvent;

	import flash.events.Event;
	import flash.geom.Rectangle;

	import assets.AbstractController;

	import nu.motta.media.AbstractMediaPlayer;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 24, 2010
	 */
	public class Controller extends AbstractController
	{


		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var player : AbstractMediaPlayer;

		protected var dragArea : Rectangle;
		
		protected var wasPlaying : Boolean;
		
		protected var seeking : Boolean;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function Controller(player : AbstractMediaPlayer)
		{
			this.player = player;

			setupDisplay();
			setupPlayer();
			setupEvents();
		}

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		protected function setupPlayer() : void
		{
			this.player.addEventListener(MediaEvent.STATUS_CHANGED, onStatusChanged);
			this.player.addEventListener(MediaEvent.VOLUME_CHANGED, onVolumeChanged);
			this.player.addEventListener(MediaEvent.LOAD_PROGRESS, onLoadProgress);
			this.player.addEventListener(MediaEvent.BUFFERED, onBuffered);			this.player.addEventListener(MediaEvent.BUFFERING, onBuffering);			this.player.addEventListener(Event.ENTER_FRAME, onSeekUpdate);
		}

		protected function setupDisplay() : void
		{
			this.dragArea = new Rectangle(this.background.x, this.background.y, this.background.width, 0);
			
			this.buffering.stop();
			this.buffering.visible = false;
			this.playPause.gotoAndStop(1);
			this.sound.gotoAndStop(1);
			this.loaderMask.scaleX = 0;
			this.scrub.timeTxt.visible = false;
		}

		protected function setupEvents() : void
		{
			setButton(this.scrub);
			setButton(this.playPause, onPlayPauseClick);
			setButton(this.reset, onStopClick);			setButton(this.sound, onSoundClick);
			//
			this.scrub.addEventListener(MouseEvent.MOUSE_DOWN, onScrubStartDrag);
		}
		
		protected function setButton(mc : MovieClip, clickHandler : Function = null) : void
		{
			mc.buttonMode = true;
			mc.mouseChildren = false;
			if(Boolean(clickHandler))
			{
				mc.addEventListener(MouseEvent.CLICK, clickHandler);
			}
		}

		// ----------------------------------------------------
		// EVENT HANDLERS
		// ----------------------------------------------------
		private function onSeekUpdate(e : Event) : void
		{
			this.timeTxt.text = this.player.timeFormatted;
			this.durationTxt.text = this.player.durationFormatted;
			
			if(!this.seeking)
			{
				this.scrub.x = this.dragArea.x + int(this.dragArea.width * this.player.timeProgress);
			}
			else
			{
				this.scrub.timeTxt.text = this.player.getFormattedTimeAt((this.scrub.x - this.dragArea.x) / this.dragArea.width);
			}
		}
		
		private function onStatusChanged(e : MediaEvent) : void
		{
			switch(this.player.status)
			{
				case MediaStatus.PLAYING :
					this.playPause.gotoAndStop(2);
					break;
				case MediaStatus.PAUSED :
				case MediaStatus.STOPPED :
					this.playPause.gotoAndStop(1);
			}
		}
		
		private function onVolumeChanged(e : MediaEvent) : void
		{
			if(this.player.volume >= .6)
			{
				this.sound.gotoAndStop(1);
			}
			else if(this.player.volume < .6 && this.player.volume > 0)
			{
				this.sound.gotoAndStop(2);
			}
			else
			{
				this.sound.gotoAndStop(3);
			}
		}
		
		private function onBuffering(e : MediaEvent) : void
		{
			this.buffering.play();
			this.buffering.visible = true;
		}

		private function onBuffered(e : MediaEvent) : void
		{
			this.buffering.stop();
			this.buffering.visible = false;
		}
		
		private function onLoadProgress(e : MediaEvent) : void
		{
			this.loaderMask.scaleX = this.player.loadProgress;
		}

		private function onScrubStartDrag(e : MouseEvent) : void
		{
			this.seeking = true;
			this.wasPlaying = this.player.status == MediaStatus.PLAYING;
			//
			this.scrub.timeTxt.visible = true;
			//
			this.scrub.startDrag(false, this.dragArea);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrubStopDrag);
		}

		private function onScrubStopDrag(e : MouseEvent) : void
		{
			this.player.seekPercent((this.scrub.x - this.dragArea.x) / this.dragArea.width);
			//
			this.seeking = false;
			this.wasPlaying ? this.player.play() : null;
			//
			this.scrub.timeTxt.visible = false;
			//
			this.scrub.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrubStopDrag);
		}

		private function onPlayPauseClick(e : MouseEvent) : void
		{
			this.player.togglePause();
		}
		
		private function onStopClick(e : MouseEvent) : void
		{
			this.player.stop();
		}

		private function onSoundClick(e : MouseEvent) : void
		{
			switch(this.sound.currentFrame)
			{
				case 1:
					this.player.volume = .3;
					break;
				case 2:
					this.player.volume = 0;
					break;
				case 3:
					this.player.volume = 1;
					break;
				default:
			}
		}
		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		
		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
	}
}
