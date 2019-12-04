
class Slideshow
{

/*-------------------------------------------------------------
  CLASS
  -----
    Slideshow()
    
    Builds and runs an image slideshow
    (thanks to Rune Kaagaard)
  -----------------------------------------------------------*/


// Create instance vars
  private var container_mc:MovieClip;         // the Main movieClip to hold all movieClips
  private var imageLoader:MovieClipLoader;    // the MovieClipLoader instance that loads the images
  private var imgNumTotal:Number;               // =imgs_array.length, number of images in imgs_array
  private var imgInterval:Number;             // var to hold the imgInterval
  private var capInterval:Number;             // var to hold the imgInterval
  private var xFadeInterval:Number;           // var to hold the xFadeInterval
  private var waitInterval:Number;            // var to hold the waitInterval
  private var checkLoadStatusInterval:Number; // var to hold the checkLoadStatus
  private var isRunning:Boolean=false;        // true when slides are running, false when not

// Vars to control slides
  private var currentImageNum:Number=0;       // the current image number shown
  private var fadeInNum:Number;               // the image number to fade in
  private var fadeInClip:MovieClip;           // the movieclip to fade in
  private var fadeOutNum:Number;              // the image number to fade out
  private var fadeOutClip:MovieClip;          // the movieclip to fade out
  private var stepTime:Number;                // the time between alpha value changes in images
  private var imgCurrentStep:Number=0;        // the current alpha value step (image fading)
  private var capCurrentStep:Number=0;        // the current alpha value step (caption fading)
  private var deltaAlpha:Number;              // the amount to change alpha value in each step
  private var capXspeed:Number=0;
  private var capYspeed:Number=0;

// Vars to control captions
  private var cda:TextField;
  private var cdaFormat:TextFormat;

// Instance vars used in constructor function
  private var target_mc:MovieClip;
  private var depth:Number;
  private var xMain:Number;
  private var yMain:Number;
  private var imgTimeBetween:Number;
  private var fadeTime:Number;
  private var fadeSteps:Number;
  private var imgs_array:Array;

//--------------------

//Constructor Function
  public function Slideshow(Target:MovieClip, 
                Depth:Number,
                xfeed:XMLfeed)
  {
  // setup default incase no XML
    var XMain = 0;
    var YMain = 0;
    var between = 4000; 
    var FadeTime = 2000;
    var FadeSteps = 50;
 
  // Set control parameters passed from swf
    target_mc = Target;
    depth = Depth;
    xMain = XMain;
    yMain = YMain;
    imgTimeBetween = between;
    fadeTime = FadeTime;

    fadeSteps = FadeSteps;
    imgs_array = xfeed.imgs_array;
    imgNumTotal = imgs_array.length;
    
    trace("xfeed imgs: "+xfeed.imgs_array);

  // Create new MovieClipLoader and register this instance to receive events from the imageLoader instance
    imageLoader = new MovieClipLoader();
    imageLoader.addListener(this);

    createMainContainer();
    createImageClips();
    initImageClips();
    loadImage(0);
  }

  public function begin ()
  {
    if (isRunning==false)
    {
      startSlideShow();
      isRunning=true;
    }     
  }

  // Private functions

  private function createMainContainer():Void
  {
    container_mc = target_mc.createEmptyMovieClip("container_mc"+1, depth);
    container_mc._x = xMain;
    container_mc._y = yMain;
    // attach click event listener to top level container
    container_mc.onPress = function(){
      trace("Linking (main area) to "+this.link);
      getURL(this.link, "_top");
    }
  }
  
  private function createImageClips():Void
  {
    for (var i:Number = 0; i<imgNumTotal; i++)
    {
      container_mc.createEmptyMovieClip("image_mc"+i, i+depth+1);
      container_mc.createEmptyMovieClip("text_mc"+i, i+depth+101);
    }
  }
  
  private function loadImages():Void
  {
    for (var i:Number = 0; i<imgNumTotal; i++)
    {
      loadImage(i);
    }
  }
  
  private function loadImage( i:Number):Void {
    var image:SlideImage = imgs_array[i];
    container_mc.link = image.link;
    if (i == 0)
    {
      // could show progress bar on first image load only
      image.load(imageLoader, container_mc["image_mc"+i]);
    } else {
      trace("LOAD: loading image: "+i);
      image.load(imageLoader, container_mc["image_mc"+i]);
    }
  }

  private function unloadPrevImage():Void {
    var i:Number = currentImageNum - 1;
    if (i < 0)
      i = imgNumTotal - 1;
    // skip frame 0
    if (i == 0)
      return;
    var image:SlideImage = imgs_array[i];
    trace("LOAD: unloading image: "+i);
    image.unload();
  }


  private function initImageClips():Void {
    for (var i:Number = 0; i<imgNumTotal; i++) {
      var image = container_mc["image_mc"+i];

    //Show the first image and hide the others
      if (i==0) {
        image._alpha=100;
      } else {
        image._alpha=0;
      }
    }
  }


  // functions in execution order
  private function startSlideShow():Void {
    stepTime = fadeTime/fadeSteps;
    deltaAlpha = 100 / fadeSteps;
    captionCreate(imgs_array[currentImageNum]);
  }

  private function captionCreate( img:SlideImage):Void {
    cdaFormat = new TextFormat();
    cdaFormat.font = "Arial";
    cdaFormat.color = Number(img.textcolour);
    cdaFormat.size = img.textsize;
    cdaFormat.underline = false;
    cdaFormat.bold = false;

    var current_mc:MovieClip = target_mc;
    current_mc.createTextField("caption", current_mc.getNextHighestDepth(), img.textstartx, img.textstarty, 700, 80);
    cda = current_mc.caption;
    cda.multiline = true;
    cda.wordWrap = true;
    cda.embedFonts = true;
    cda.html = true;
    cda.htmlText = "<a href=\""+img.link+"\" target=\"_top\">"+img.caption+"</a>";
    cda.setTextFormat(cdaFormat);
    cda._alpha = 0;
    
    capXspeed = img.textspeedx;
    capYspeed = img.textspeedy;
    imgInterval = setInterval(this, "captionFadeIn" ,stepTime)
    capInterval = setInterval(this, "captionMove" ,stepTime);
  }
  
  private function captionFadeIn():Void
  {
    capCurrentStep++;
    cda._alpha = deltaAlpha*capCurrentStep;
    if (capCurrentStep == fadeSteps)
    {
      clearIntervals();
      imgInterval = setInterval(this, "captionSetupFadeOut" ,imgTimeBetween)
    }
  }

  private function captionMove():Void
  {
    cda._x+=capXspeed;
    cda._y+=capYspeed;
  }

  private function captionSetupFadeOut():Void
  {
    clearIntervals();
    imgInterval = setInterval(this, "captionFadeOut" ,stepTime)
  }

  private function captionFadeOut():Void
  {
    capCurrentStep-=2;
    cda._alpha = deltaAlpha*capCurrentStep;
    if (capCurrentStep <= 0)
    {
      captionDestroy();
    }
  }

  private function captionDestroy():Void {
    clearInterval(capInterval);
    capCurrentStep = 0;
    cda._alpha = 0;
    cda.removeTextField();
    img_slideToNext();
  }

  private function img_slideToNext() {
    clearIntervals();
    getNextImage();
    loadImage(currentImageNum);
    checkLoadStatus();
  }
  
  
  private function checkLoadStatus() {
    clearIntervals();
    if (fadeInClip.onLoadErrored==true)
    {
      trace("SHOW: image load failed!: "+imgs_array[fadeInNum]);
      img_slideToNext();
    } else if (fadeInClip.onLoadCompleted==true) {
      xFadeInterval = setInterval(this, "xFade", stepTime)
      trace("SHOW: display new image:"+imgs_array[fadeInNum])
    } else {
      checkLoadStatusInterval = setInterval(this, "checkLoadStatus",500)
      trace("SHOW: too soon to display new image:"+imgs_array[fadeInNum]);      
    }
  }
  
  private function xFade () {
    imgCurrentStep++;
    fadeInClip._alpha = deltaAlpha*imgCurrentStep;
    fadeOutClip._alpha = 100-deltaAlpha*imgCurrentStep;

    if (imgCurrentStep==fadeSteps) {
      imgCurrentStep=0;
      clearIntervals();
      unloadPrevImage();
      captionCreate(imgs_array[currentImageNum]);
    }
  }
  
  //Clears the intervals used to display images
  private function clearIntervals() {
    clearInterval(imgInterval)
    clearInterval(checkLoadStatusInterval)
    clearInterval(xFadeInterval);
  }
  
  private function getNextImage() {
  //Get the number in imgs_array to crossfade
    fadeOutNum = currentImageNum;
    fadeInNum = nextImageNum();
  //Get the clips to crossfade
    fadeOutClip = container_mc["image_mc"+fadeOutNum];
    fadeInClip = container_mc["image_mc"+fadeInNum];
  }
  
  //Gets the number of the next image
  private function nextImageNum():Number {
    currentImageNum++
  //Wrap i to the number of images
    if (currentImageNum==imgNumTotal) {
      currentImageNum=1;
    }
    return (currentImageNum);
  }
  
  //Listens to and sets flags for loaded movieclips
  private function onLoadInit(target:MovieClip):Void {
    target.onLoadInited=true
    trace("SHOWMcLOAD: onLoadInit receives: "+target+".onLoadInited = "+target.onLoadInited);
  }
  private function onLoadComplete(target:MovieClip):Void {
    target.onLoadCompleted=true
    trace("SHOWMcLOAD: onLoadComplete receives: "+target+".onLoadCompleted = "+target.onLoadCompleted);
  }
  private function onLoadError(target:MovieClip):Void {
    target.onLoadErrored=true
    trace("SHOWMcLOAD: onLoadError receives: "+target+".onLoadErrored = "+target.onLoadError);
  }
}