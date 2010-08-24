package
{

	import nu.motta.media.type.MediaVideo;

	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * @author Lucas Motta (lucasmotta.com)
	 * @since Aug 20, 2010
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="640", height="540")]
	public class VideoTest extends MovieClip
	{


		protected var player : MediaVideo;

		protected var controller : Controller;


		public function VideoTest()
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
			this.player.load("http://public.lucasmotta.com/files/mediaPlayer/video.flv?" + String(Math.random() * 1000), 5);
		}

		protected function setupVideo() : void
		{
			this.player = new MediaVideo(640, 480, false);
			this.player.autoPlay = true;
			this.player.loop = false;
			addChild(this.player);
		}

		protected function setupController() : void
		{
			this.controller = new Controller(this.player);
			this.controller.x = 25;
			this.controller.y = 480 + 23;
			addChild(this.controller);
		}

		protected function onAddedToStage(e : Event) : void
		{
			init();

			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
}
