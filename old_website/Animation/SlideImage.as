
import mx.video.*;
import mx.controls.ProgressBar;

class SlideImage {

/*-------------------------------------------------------------
  CLASS
  -----
    SlideImage()
    
    An image and associated resources (res, cam move, caption)
  -----------------------------------------------------------*/

  public var caption:String="";
  public var link:String="";
  public var src:String;
  
  // setup with defaults
  public var textsize:Number=32;
  public var textstartx:Number=400;
  public var textstarty:Number=200;
  public var textspeedx:Number=0.5;
  public var textspeedy:Number=0;
  public var textcolour:String="0xFFFFFF";

  private var loaded:Boolean;
  private var load_success:Boolean;
  private var loader:MovieClipLoader;
  private var mc:MovieClip;
  private var flv_mc:MovieClip = null;
  private var flv_object:FLVPlayback = null;
  private var videoListener:Object = new Object();
  private var pbar:ProgressBar;
  private var pbar_init:Number;

  function SlideImage()
  {
    loaded = false;
    load_success = false;
  }

  public function load( p_loader:MovieClipLoader, p_mc:MovieClip):Void
  {
    if (!loaded)
    {
      loaded = true;
      loader = p_loader;
      mc = p_mc;
      var p_prog:ProgressBar = null;
      
      // show progress only if progress bar passed
      if (p_prog != null)
      {
        pbar = p_prog;
        pbar_init = pbar.percentComplete;
        var listener:Object = new Object();
        
      	listener.onLoadInit = function( target:MovieClip):Void
      	{
      	  p_prog.visible = true;
      	}
      	
      	listener.onLoadProgress = function( target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void
      	{
      	  p_prog.setProgress( (bytesLoaded/bytesTotal)*(100-pbar_init)+pbar_init, 100);
      	}
      	
      	listener.onLoadComplete = function(target_mc:MovieClip, httpStatus:Number):Void
      	{
      	  p_prog.visible = false;
      	}
        loader.addListener(listener);
      }
      
      // if video, attach to clip
      var lastDot:Number;
      var matched:Boolean = false;
      lastDot = this.src.lastIndexOf('.');
      if (lastDot != -1)
      {
      	var exten:String;
      	exten = this.src.substring(lastDot);
      	if (exten == '.flv')
      	{
      	  trace('IMAGE: loading video into '+mc);
      	  loadVideo(this.src);
      	  mc.onLoadCompleted = true;
      	  matched = true;
      	}
      }
      if (!matched)
      {
        trace('IMAGE: loading image into '+mc);
        loader.loadClip(this.src, mc);
      }
      
      // progress bar cleanup
      if (p_prog != null)
      {
        loader.removeListener(listener);
      }
    }
    
    if (load_success)
    {
    
    }
  }

  public function loadVideo( vname: String):Void {
    flv_mc = mc.attachMovie("FLVPlayback", "flv_object", mc.getNextHighestDepth(), {width:Stage.width, height:Stage.height, x:0, y:0});
    flv_mc.autoPlay = false;
    flv_mc.autoSize = true;
    flv_mc.contentPath = vname;
    trace("VIDEOEVENT: complete requested." + flv_mc);
    
    videoListener.canvas = this;
    videoListener.complete = function(eventObject:Object) {
      trace("VIDEOEVENT: complete fired." + this.canvas.flv_mc);
      this.canvas.flv_mc.play();
    }
    flv_mc.addEventListener("complete", videoListener);
    flv_mc.play();
  }

  public function unload():Void {
    if (flv_mc != null)
    {
      flv_mc.removeEventListener("complete", videoListener);
      trace("VIDEOEVENT: cleaned up." + flv_mc);
    }
  }


}
