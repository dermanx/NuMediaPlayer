package
{

	import nu.motta.media.type.SoundPlayer;

	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 20, 2010
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="80")]
	public class SoundTest extends MovieClip
	{


		protected var player : SoundPlayer;

		protected var controller : Controller;


		public function SoundTest()
		{
			stage ? init() : this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function init() : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//
			setupVideo();
			setupController();
			//
			this.player.load("http://public.lucasmotta.com/files/mediaPlayer/sparrows.mp3?" + String(Math.random() * 1000), 5, 171);
		}

		protected function setupVideo() : void
		{
			this.player = new SoundPlayer();
			this.player.autoPlay = true;
			this.player.loop = true;
			addChild(this.player);
		}

		protected function setupController() : void
		{
			this.controller = new Controller(this.player);
			this.controller.x = 25;
			this.controller.y = 35;
			addChild(this.controller);
		}
		
		protected function onAddedToStage(e : Event) : void
		{
			init();
			
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
}
