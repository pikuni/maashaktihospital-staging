
class XMLfeed {
  
/*-------------------------------------------------------------
  CLASS
  -----
    XMLfeed()
    
    Draws down XML from server: parameters for slideshow
  -----------------------------------------------------------*/

  private var imgs_num:Number;
  
  public var imgs_array:Array;

  function XMLfeed( url:String) {
  	this.imgs_array = new Array();
  	this.imgs_num = 0;
  	
  	// dangerous precedent for clients
	// if (url == null)
	//	url="http://www.lightenna.com/themes/lightenna/flash/xml/frontSept06.xml";

	var slix:XML = new XML();
	slix.ignoreWhite = true;
	slix.onLoad = function(success:Boolean) {
		_root.debug.text="load["+success+"] ready:"+_root.xmlpush;
		trace("success: "+success);
		if (success)
		{
			_root.xmlfeed_c.parseRecurse(this.firstChild);
			_root.readygo();
		}
		// assume xml is 10% of total
		_root.progressBar.setProgress(10,100);
	};
	slix.load(url);
  }

  function parseRecurse( node:XMLNode)
  {
  	// trace("node: "+node);

  	if (node.hasChildNodes())
  	{
  		var p:Number;
  		processNodeBranch(node.nodeName);
  		for (p = 0; p < node.childNodes.length; p++)
  		{
  			parseRecurse(node.childNodes[p]);
  		}
  	} else {
  		processNodeTerminal(node.parentNode.nodeName, node.nodeValue);
  	}
  }
  
  function processNodeBranch( name)
  {
  	// trace("branch: "+name);
  	
  	switch(name)
  	{
  		case 'image':
  			this.imgs_array[this.imgs_num] = new SlideImage();
  			this.imgs_num++;
  			break;
  	}
  }
  
  function processNodeTerminal( name, value)
  {
	// trace("  leaf: "+name+" "+value);
	// trace("found image["+this.imgs_num+"]: "+value);
	// trace(this.imgs_array);

  	switch(name)
  	{
  		case 'src':
  			this.imgs_array[this.imgs_num-1].src = value;
  			break;
  		case 'link':
  			this.imgs_array[this.imgs_num-1].link = value;
  			break;
  		case 'caption':
  			this.imgs_array[this.imgs_num-1].caption = value;
  			break;
  		case 'size':
  			this.imgs_array[this.imgs_num-1].textsize = value;
  			break;
  		case 'startx':
  			this.imgs_array[this.imgs_num-1].textstartx = value;
  			break;
  		case 'starty':
  			this.imgs_array[this.imgs_num-1].textstarty = value;
  			break;
  		case 'speedx':
  			this.imgs_array[this.imgs_num-1].textspeedx = value;
  			break;
  		case 'speedy':
  			this.imgs_array[this.imgs_num-1].textspeedy = value;
  			break;
  		case 'colour':
  			this.imgs_array[this.imgs_num-1].textcolour = value;
  			break;
  	}
  }

  
}
