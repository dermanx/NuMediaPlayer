package
{

	import nu.motta.media.utils.PlayerStatus;
	import nu.motta.media.events.PlayerEvent;

	import flash.events.Event;
	import flash.geom.Rectangle;

	import assets.AbstractController;

	import nu.motta.media.AbstractPlayer;

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
		protected var player : AbstractPlayer;

		protected var dragArea : Rectangle;
		
		protected var wasPlaying : Boolean;
		
		protected var seeking : Boolean;


		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function Controller(player : AbstractPlayer)
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
			this.player.addEventListener(PlayerEvent.STATUS_CHANGED, onStatusChanged);
			this.player.addEventListener(PlayerEvent.VOLUME_CHANGED, onVolumeChanged);
			this.player.addEventListener(PlayerEvent.LOAD_PROGRESS, onLoadProgress);
			this.player.addEventListener(PlayerEvent.BUFFERED, onBuffered);
			this.player.addEventListener(PlayerEvent.BUFFERING, onBuffering);
			this.player.addEventListener(PlayerEvent.COMPLETED, onMediaCompleted);			this.player.addEventListener(Event.ENTER_FRAME, onSeekUpdate);
		}

		protected function setupDisplay() : void
		{
			this.dragArea = new Rectangle(this.background.x, this.background.y, this.background.width, 0);
			
			this.buffering.stop();
			this.buffering.visible = false;
			this.playPause.gotoAndStop(1);
			this.sound.gotoAndStop(1);
			this.loaderMask.scaleX = 0;
			this.scrubBarMask.scaleX = 0;
			this.scrub.timeTxt.visible = false;
		}

		protected function setupEvents() : void
		{
			setButton(this.scrub);
			setButton(this.playPause, onPlayPauseClick);
			setButton(this.reset, onStopClick);			setButton(this.sound, onSoundClick);
			//
			this.scrubBar.mouseEnabled = false;
			this.loaderBar.mouseChildren = false;
			this.loaderBar.buttonMode = true;
			this.loaderBar.addEventListener(MouseEvent.MOUSE_DOWN, onScrubBarClick);			this.scrub.addEventListener(MouseEvent.MOUSE_DOWN, onScrubStartDrag);
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
			
			this.scrubBarMask.scaleX = (this.scrub.x - this.dragArea.x) / this.dragArea.width;
		}
		
		private function onStatusChanged(e : PlayerEvent) : void
		{
			switch(this.player.status)
			{
				case PlayerStatus.PLAYING :
					this.playPause.gotoAndStop(2);
					break;
				case PlayerStatus.PAUSED :
				case PlayerStatus.STOPPED :
					this.playPause.gotoAndStop(1);
			}
		}
		
		private function onVolumeChanged(e : PlayerEvent) : void
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
		
		private function onMediaCompleted(e : PlayerEvent) : void
		{
			this.player.stop();
			trace("video is completed");
		}
		
		private function onBuffering(e : PlayerEvent) : void
		{
			this.buffering.play();
			this.buffering.visible = true;
		}

		private function onBuffered(e : PlayerEvent) : void
		{
			this.buffering.stop();
			this.buffering.visible = false;
		}
		
		private function onLoadProgress(e : PlayerEvent) : void
		{
			this.loaderMask.scaleX = this.player.loadProgress;
		}
		
		private function onScrubBarClick(e : MouseEvent) : void
		{
			this.scrub.x = mouseX;
			onScrubStartDrag(null);
		}

		private function onScrubStartDrag(e : MouseEvent) : void
		{
			this.seeking = true;
			this.wasPlaying = this.player.status == PlayerStatus.PLAYING;
			//
			this.scrub.timeTxt.visible = true;
			//
			this.scrub.startDrag(false, this.dragArea);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrubStopDrag);
		}

		private function onScrubStopDrag(e : MouseEvent) : void
		{
			this.scrub.timeTxt.visible = false;
			this.scrub.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrubStopDrag);
			//
			this.player.seekPercent((this.scrub.x - this.dragArea.x) / this.dragArea.width);
			//
			this.wasPlaying ? this.player.play() : null;
			this.seeking = false;
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
