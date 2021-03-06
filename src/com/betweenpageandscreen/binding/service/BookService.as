package com.betweenpageandscreen.binding.service
{

  import com.betweenpageandscreen.binding.events.BookEvent;
  import com.betweenpageandscreen.binding.models.CameraParams;
  import com.bradwearsglasses.utils.service.GenericService;
  import com.bradwearsglasses.utils.service.GenericServiceEvent;

  import flash.external.ExternalInterface;
  import flash.net.URLLoaderDataFormat;
  import flash.utils.ByteArray;

  import org.robotlegs.mvcs.Actor;

  //TODO: Remove this dependency on RobotLegs
  public class BookService extends Actor {

    [Inject]
    public var cameraParams:CameraParams;

    public function parse_cached_camera(cached:ByteArray):void {
      var e:GenericServiceEvent = new GenericServiceEvent(GenericServiceEvent.REQUEST_COMPLETE);
      cached.uncompress();
      e.data = cached;
      load_camera_complete(e);
    }

    public function load_camera(camera_path:String):void {
      var service:GenericService = new GenericService(URLLoaderDataFormat.BINARY);
      service.addEventListener(GenericServiceEvent.REQUEST_COMPLETE, load_camera_complete);
      service.addEventListener(GenericServiceEvent.REQUEST_FAIL, load_camera_fail);
      service.request(camera_path);
    }

    public function load_camera_complete(event:GenericServiceEvent):void {
      cameraParams.update(event.data as ByteArray);
      dispatch( new BookEvent(BookEvent.CAMERA_PARAMS_COMPLETE,"loaded"));
    }

    public function load_camera_fail(event:GenericServiceEvent):void {
      trace("Failed load camera");
      // TODO: Should dispatch special event - although in practice the camera
      // should always be cached.
      dispatch(event);
    }

    public static function log(message:String):void {
      javascript("console.log", [message]);
    }

    //TODO: This should just be a method on a helper.
    public static function javascript(method_name:String, args:Array=null):void {
      try {
        if (ExternalInterface.available) {
          if (!args) args=[];
          var js_args:Array = [method_name];
          js_args = js_args.concat(args);
          ExternalInterface.call.apply(ExternalInterface, js_args);
        }
      } catch (e:Error) {
        trace("Failed accessing javascript")
      }
    }
  }
}
