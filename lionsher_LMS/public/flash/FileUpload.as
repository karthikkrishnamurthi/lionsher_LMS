/* Plugin Developed @Kern-communications Pvt Ltd., by -- Banoth Rajesh Rathod -- INDIA */
package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.external.ExternalInterface;
	import fl.controls.Button;
	import flash.events.TimerEvent;
    import flash.events.Event;
		public class FileUpload extends Sprite {		
		private var _output:TextField = new TextField();
		private var _percent:TextField;		
		private var _elapse:TextField;
		private var _kb:TextField;
		private var _loaded:TextField;
		private var _remtime:TextField;
		private var test2 = 1;
		private var _fileReference:FileReference;
		var browseButton:Button = new Button();
		var uploadButton:Button = new Button();
		var cancelButton:Button = new Button();
		
		        // Time when upload started
		        var date = new Date();var start_time = date.getTime();
			
			    public function FileUpload(){
								
				/* import font from the library */
				var myFont = new Font1();
				
				/* Text Format of the TextFiled */
				var myFormat:TextFormat = new TextFormat();
				myFormat.size = 15;
				myFormat.font = myFont.fontName;
				
				
			/*Declaring Browse button and its position and label here*/				
			browseButton.move(10, 10);browseButton.buttonMode = true;browseButton.label = "Upload";browseButton.addEventListener(MouseEvent.CLICK, browseHandler);addChild(browseButton);
						
			/*Declaring Upload Button and it postion and label here*/
			//uploadButton.move(120, 10);uploadButton.buttonMode=true;uploadButton.label ="Upload";uploadButton.addEventListener(MouseEvent.CLICK, uploadHandler);uploadButton.visible = false;addChild(uploadButton);
						
			cancelButton.move(10, 10);cancelButton.buttonMode=true;cancelButton.label ="Cancel";cancelButton.addEventListener(MouseEvent.CLICK, cancelHandler);cancelButton.visible = false;addChild(cancelButton);
			
			/*Declaring Text Fields and its properties starts here*/
			_output = new TextField();_output.embedFonts = true;_output.defaultTextFormat = myFormat;_output.width = 450;_output.height =20;_output.y = 52;_output.x = 10;addChild(_output);
			_percent = new TextField();_percent.embedFonts = true;_percent.defaultTextFormat = myFormat;_percent.width = 400;_percent.height = 20;_percent.y = 33;_percent.x = 365;addChild(_percent);
			_elapse = new TextField();_elapse.width = 400;_elapse.height = 400;_elapse.y = 65;_elapse.x = 10;addChild(_elapse);
			_kb = new TextField();_kb.embedFonts = true;_kb.defaultTextFormat = myFormat;_kb.width = 400;_kb.height = 400;_kb.y = 52;_kb.x = 10;addChild(_kb);
			_loaded = new TextField();_loaded.embedFonts = true;_loaded.defaultTextFormat = myFormat;_loaded.width = 400;_loaded.height = 400;_loaded.y = 10;_loaded.x = 120;addChild(_loaded);
			_remtime = new TextField();_remtime.width = 400;_remtime.height = 400;_remtime.y = 110;_remtime.x = 10;addChild(_remtime);
			/*Declaring Text Fields and its properties ends here*/
			
			/*adding the declared event handlers to the file Reference starts Here*/
			_fileReference = new FileReference();
			_fileReference.addEventListener(Event.SELECT, selectHandler);
			_fileReference.addEventListener(Event.CANCEL, cancelHandler);
			_fileReference.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			_fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityHandler);
			_fileReference.addEventListener(Event.COMPLETE, completeHandler);}				
			/*adding the declared event handlers to the file Reference Ends Here*/
			private function browseHandler(event:MouseEvent):void {_fileReference.browse([new FileFilter("All Formats","*.*")]); _loaded.text="";_output.text = ""; _kb.text = ""; blocker.visible = true;}
			private function selectHandler(event:Event):void {browseButton.visible = false;_output.appendText(_fileReference.name);var tenant = ExternalInterface.call("gettenant");_fileReference.upload(new URLRequest("upload?tenant="+tenant)); cancelButton.visible = true; _loaded.appendText(_fileReference.name); }
			private function cancelHandler(event:Event):void {ExternalInterface.call("cancelupload");_fileReference.cancel();_kb.text= " ";_output.text = "";_loaded.text = ""; _loaded.text=" Upload Canceled"; cancelButton.visible = false;  browseButton.visible = true;blocker.visible = true;_percent.text = "";}
			//private function uploadHandler(event:MouseEvent):void {var tenant = ExternalInterface.call("gettenant");_fileReference.upload(new URLRequest("upload?tenant="+tenant)); }
			//("upload?tenant="+tenant)
			private function progressHandler(event:ProgressEvent):void {
			// we want our progress bar to be 200 pixels wide when done growing so we use 200*
			// Set any width using that number, and the bar will be limited to that when done growing
			progressbar.width = Math.ceil(350*(event.bytesLoaded/event.bytesTotal));var percent = Math.round(100*(event.bytesLoaded/event.bytesTotal));blocker.visible =false;browseButton.visible = false;uploadButton.visible = false;_percent.text = percent + " %" ;if(progressbar.width == 100){_output.text = "Processing File...";}
						
			/* Calculation of the Remaining Time of the upload process starts here */
			var start_time2 = (start_time/1000);
			var date2 = new Date();
			var current_time = date2.getTime();
			var current_time2 = (current_time/1000);
			var elapsed = (current_time2 - start_time2);
			var totalbytes = _fileReference.size;
			var totalkb = Math.round(totalbytes/1024);
			var loadedbytes = event.bytesLoaded;
			var loadedkb = Math.round(loadedbytes/1024);
			var rem = ((current_time2 - start_time2)*(100 - progressbar.width)/(progressbar.width));_output.text = " ";
			var rate = Math.round((loadedkb)/elapsed);
			var remaining_time = Math.round((totalkb - loadedkb)/rate);
			var hrs = remaining_time / 3600;
			var hours = Math.floor(hrs);
			var fractional_parth = hrs - hours;
			var mins = fractional_parth * 60;
			var minutes = Math.floor(mins);
			var fractional_partm = mins - minutes;
			var secs = fractional_partm * 60;
			var seconds = Math.floor(secs);
			/* TO get value of MB in 0.12 value (eg: 2.36 MB/s)*/
			var ratemb =Math.round((rate/1024)*100);
			var rate_mb2 = ratemb/100;
			
			/*When the transfer rate is more than 1024 bytes it shows the transfer rate in MB/s else KB/s*/
			if (rate_mb2 > 1){
			if (progressbar.width == 350)
			{_loaded.text  = "";cancelButton.visible = false; _kb.text = "Processing File...";}else{				
			if(seconds<10 && minutes <10){_kb.text = "Time Remaining: "+hours +":" + "0" + minutes + ":" +"0" +seconds +  ", Transfer Rate: " + rate_mb2 +" MB/s";}
			else if(minutes<10){_kb.text = "Time Remaining: "+hours +":"+ "0"+ minutes + ":" +seconds +  ", Transfer Rate: " + rate_mb2 +" MB/s";}
			else{_kb.text ="Time Remaining: "+hours +":" +  minutes + ":" +seconds +  ", Transfer Rate: " + rate_mb2 +" MB/s";}
			}}
			else{
			if (progressbar.width == 350)
			{_loaded.text  = "";cancelButton.visible = false;_kb.text = "Processing File...";}else{				
			if(seconds<10 && minutes <10){_kb.text = "Time Remaining: "+hours +":" + "0" + minutes + ":" +"0" +seconds +  ", Transfer Rate: " + rate +" KB/s";}
			else if(minutes<10){_kb.text = "Time Remaining: "+hours +":"+ "0"+ minutes + ":" +seconds +  ", Transfer Rate: " + rate +" KB/s";}
			else{_kb.text ="Time Remaining: "+hours +":" +  minutes + ":" +seconds +  ", Transfer Rate: " + rate +" KB/s";}
			}}}
			/* Calculation of the Remaining Time of the upload process Ends here */
			
			private function ioErrorHandler(event:IOErrorEvent):void {_kb.text = ""; _output.text =  _fileReference.name + " uploaded successfully ";_output.text = "Processing File..."; ExternalInterface.call("submitform")}
			private function securityHandler(event:SecurityErrorEvent):void {_output.text = "a security error occurred";}
			private function completeHandler(event:Event):void {blocker.visible = true;uploadButton.visible = false;browseButton.visible = false;_percent.text = "";_kb.text = "";
			
			var error_stat = ExternalInterface.call("get_error_status");
			if (error_stat == "true")
			{
				_output.text = _fileReference.name + " uploaded successfully.";ExternalInterface.call("submitform")
			}
			else if (error_stat == "nonscorm")
			{
				_output.text = _fileReference.name + " uploaded successfully.";ExternalInterface.call("submitform")
				
			}
			else if (error_stat == "false")
			{
				_output.text = " Unsupported file format. Upload a .zip SCORM, ppt, video or audio" ;browseButton.visible = true
			}					
			else if (error_stat == "virus")
			{
				_output.text = " Virus infected file. Disinfect file using antivirus and upload again." ;browseButton.visible = true
			}
			else if (error_stat == "pptx")
			{
				_output.text = " Unsupported .pptx file format. 'Save As' .pptx to .ppt and upload again" ;browseButton.visible = true
			}
			else if (error_stat == "processing")
			{
				_output.text =" Unable to process file.";cancelButton.visible = false;browseButton.visible = true;
			}
			}
			} 
            }
			
			/* Plugin Developed @Kern-communications Pvt Ltd., by -- Banoth Rajesh Rathod -- INDIA */