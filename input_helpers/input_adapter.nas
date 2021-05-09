####################
# The input adapter provides an easy API for mapping input events to instruments in the current airplane
# and providing information for the displays on the device.
####################
# First of all, you need to call input_helpers.input_adapter_init(); (only once).
# In order to do an action, just call 
#    input_helpers.buttonPressedMatchName(inputDeviceName, buttonName, btnType, num = 0, param = nil) resp.
#    input_helpers.buttonReleasedMatchName() with the same parameters:
#      inputDeviceName: The name of the input device used in the file "zz_instruments_devices_standard_deviations.nas", e.g. "saitek-radio"
#      buttonName:      The name of the button to be pressed/released. The names can be found in the corresponding instrument's nas file, e.g. "radio_comm_generic.nas"
#      btnType:         "toggle", "biased" or "selector". If the device has a biased button and the instrument has a toggle, the adapter will automatically adapt for that
#      num (optional):  Index of the instrument if several are installed (e.g. navigation radio 0 or navigation radio 1)
#      param (optional):Some buttons require a parameter, e.g. the amount the frequency should be adjusted (usually +1 or -1).
#
# In order to display something, 
# (1) add a watcher like this:
# 	input_helpers.watchMatchName(inputDeviceName, name, propPath, type, numDigits, decimalDotExtra) where the parameters mean:
#		inputDeviceName:         The name of the input device used in the file "zz_instruments_devices_standard_deviations.nas", e.g. "saitek-radio"
#		name: 			         The name of the display/LED/annunciator. The names can be found in the corresponding instrument's nas file, e.g. "radio_dme/time_min" in "radio_comm_generic.nas".
#		propPath:                The path to the property that shall be created, e.g. "/input/saitek-radio/leds/ias"
#		type:			         "BOOL" for LEDs/annunciators or "STRING" otherwise. It is used to create the property. Given that numbers are converted to a strings, give "STRING" here, also for numbers.
#		numDigits (optional):    The number of digits the display can display. The created property will always have exact this number of digits. Numbers are padded or truncated accordingly. How this is done, is determined by the instrument's member "formatGetter".
#		decimalDotExtra (opt.):  1/true (default) = decimal dots do not count when counting digits, false = decimal dots count as digits
# (2) add a <report> section in the xml file and watch for the propPath that you provided in calling watchMatchName().
# See saitek-radio.xml for an example.

# After input_adapter_init(), this contains a hash with the all instrument functions as keys and
# the corresponding instrument name that is installed in the current aircraft.
var installedInstruments = {};

# Load the *.nas files in instrument_helpers (into the (my) namespace "input_helpers")
var loadInstrumentHelpers = func() {
	var path = getprop("/sim/fg-root") ~ "/Nasal/input_helpers/instrument_helpers";
#	debug.dump(path);
	var dir = directory(path);
#	debug.dump(dir);
	if ( dir == nil ) { return; }
	foreach(var file; sort(dir, cmp)) {
#	debug.dump(file);
		if(size(file) > 4 and substr(file, -4) == ".nas")
			{ io.load_nasal(path ~ "/" ~ file, "input_helpers"); } # namespace from filename: substr(file, 0, size(file) - 4)); 
	}
};


var getInstalledInstrument = func(desiredFunction) {
	print("getInstalledInstrument, desiredFunction: >" ~ debug.string(desiredFunction) ~ "<");
	var iter = IteratorInheritance.new(instrumentsProps);
	var ret = nil;
	for(var cur_instr = iter.getNext(); cur_instr != nil; cur_instr = iter.getNext()) {
		debug.dump(cur_instr.key);
		if (! contains(cur_instr.value, "functions") ) { print("input_adapter: getInstalledInstrument: Ignoring error: instrument >" ~ debug.string(cur_instr.key) ~ "< does not have a >functions< member"); continue; }
		if (! contains(cur_instr.value.functions, desiredFunction) ) { continue; } # print("not contained"); debug.dump(cur_instr.value.functions); debug.dump(desiredFunction); debug.dump(contains(desiredFunction, cur_instr.value.functions));
		if (! contains(cur_instr.value, "existenceTester") ) { print("input_adapter: getInstalledInstrument: Ignoring error: instrument >" ~ debug.string(cur_instr.key) ~ "< does not have a function >existenceTester<"); continue; }
		if (typeof(cur_instr.value.existenceTester) != "func") { print("input_adapter: getInstalledInstrument: Ignoring error: instrument >" ~ debug.string(cur_instr.key) ~ "< the member >existenceTester< must be a function"); continue; }
		if (! cur_instr.value.existenceTester() ) { print("instrument not installed"); continue; }
		if (ret == nil) { 
			ret = cur_instr;
		} else {
			print("another matching instrument found. Compare the priority.");
			print("Old instrument: >" ~ debug.string(ret.key) ~ "<, priority: ");
			debug.dump(ret.value.functions[desiredFunction]);
			print("Old instrument: >" ~ debug.string(cur_instr.key) ~ "<, priority: ");
			debug.dump(cur_instr.value.functions[desiredFunction]);
			if (ret.value.functions[desiredFunction] < cur_instr.value.functions[desiredFunction]) { # priority
				ret = cur_instr;
			}
		}
	}
	if (ret != nil) {
		ret = ret.key; 
		print("best installed instrument: >" ~ debug.string(ret) ~ "<");
		} else  {
			print("best installed instrument: no fitting instrument found for function>" ~ debug.string(desiredFunction) ~ "<");
		}
	
	return ret;
};

# In the input.xml you need to call this function
# in order to be able to use the function of the
# input adapter.
#
# Load the instrument informations in the sub dir "instrument_helpers" and 
# fill installedInstruments with the names of the instruments
# installed in the current airplane.
var input_adapter_init = func(forceRelaod = 1) {
	if ((installedInstruments["ap"] != nil) and (!forceRelaod) ) { return;  } # already initialized do not do anything, except if forceRelaod is true
	loadInstrumentHelpers();
	foreach (var f; intrumentFunctions) {
		installedInstruments[f] = getInstalledInstrument(f);
	}
	print("input_adapter_init done.");
};


# only for debugging purposes 
var input_adapter_reinit = func() {
	removeAllListeners();
	input_adapter_init(1);
};


	


# var togglePushBtnAdapterPath = "togglePushBtns/";
# todo: better use a property for this
# var togglePushBtnAdapterStatusList = {}; # std.Vector.new(); # btnName, btnStatus

# This function is used for adapting push-buttons on the external device
# to toggle-buttons on the in-aircraft instrument. 
# One press on the button will change the status to 1, the second will
# change it to zero (and so on).
# Todo: use aniProp instead of an own one
#var togglePushBtn = func(name) {
#	# add this button, if it does not exist in the list
#	if (!getprop(basPathAdapter ~ togglePushBtnAdapterPath ~ name)) {
#		props.globals.initNode(basPathAdapter ~ togglePushBtnAdapterPath ~ name, 1, "BOOL");
#	}
#	# toggle the button and return the new status
#	var newStatus = 1;
#	if (getprop(basPathAdapter ~ togglePushBtnAdapterPath ~ name)) {
#		newStatus = 0;
#	}	
#	setprop(basPathAdapter ~ togglePushBtnAdapterPath ~ name, newStatus);
#	return newStatus;
#};

#var getTogglePushBtnStatus = func(name) {
#	return getprop(basPathAdapter ~ togglePushBtnAdapterPath ~ name);
#};

var getInstalledInstrumentName = func(instrumentType_) {
		var instrumentType = ( (instrumentType_[0]=="$"[0]) ? substr(instrumentType_, 1) : (instrumentType_) );
		if (! contains(installedInstruments, instrumentType) ) {
		print("WARNING: inputAdapter: getInstalledInstrumentName: instrument type: >" ~ debug.string(instrumentType) ~ "< unkown.");
		print(substr("abcyyyyyyyyyyyyyyyyyyyyyyyy", 1));
		return "";
	}
	ret = installedInstruments[instrumentType];
	if (ret == nil) {
		print("Warning: getInstalledInstrumentName: no known instrument found for instrumentType: >" ~ debug.string(instrumentType) ~ "<");
	}
	return ret;
};


# Returns the best suitable annunciator/display/button name of the installed instrument
# for a given LED/display of a specific input device.
var matchName = func(inputdevice, name) {
	if ( (name == "") or (name == nil) ) {return "";}

	# if input device is not found: default to not changing the name
	if (! contains(nameDeviations, inputdevice) ) { return name;}
    print("matchName, name: " ~ debug.string(name));
	
	# if name start with "$", the definitions in zz_interumentes_devices_standard_deviations.nas should be called instead of the instrument's
	var use_deviations = (name[0]=="$"[0]);
	# in order to find the correct instrument, the "$" must be eliminated
	var name_ = ( (use_deviations) ? substr(name, 1) : (name) );

	var instrumentName = getInstrumentName(name_);

	# if no information is stored for deviation for a specific instrument, return default
	if ( (instrumentName == nil) or (instrumentName == "") ) {return name; }

	# if instrument name not in the list of deviations, return default
	if (! contains(nameDeviations[inputdevice], instrumentName) )
		{ return name;}

	# if no deviation is stored, return default
	if (! contains(nameDeviations[inputdevice][instrumentName], name) )
		{ return name;}
	else { 
		# there is a deviation in the led/display names between the installed autopilot/instrument
		# and the input device. 
		var newName = nameDeviations[inputdevice][instrumentName][name];
		if ( typeof(newName) == "func" ) {
 #debug.dump(newName);
			newName = newName();
		}
		return newName;
 	}
};

# Get a member (property) from an Instrument from the instrumensProps hash
# prop: if string: the member to get
# prop: if vector: the member to get
var getInstrumentPropForName = func(name, prop, inputDeviceName) {
	# if name start with "$", the definitions in zz_interumentes_devices_standard_deviations.nas should be called instead of the instrument's
	if ((name == "") or (name==nil)) return [""];
	var use_deviations = (name[0]=="$"[0]);
	# in order to find the correct instrument, the "$" must be eliminated
	var name_ = ( (use_deviations) ? substr(name, 1) : (name) );
	var instrument = getInstrumentName(name_);
print("getInstrumentPropForName, instrument: " ~ debug.string(instrument));
	if ( (instrument == nil) or (instrument == "") ) {
		print ("WARNING: input_adapter: getInstrumentPropForName: no matching installed instrument found for name: " ~ debug.string(name));
		return [""];
	}
	var whichprop = ( (use_deviations) ? [inputDeviceName, instrument, name] : [instrument, "displays", name] );
	if (typeof(prop) == "vector") {	whichprop = whichprop ~ prop; }
	else                          { append(whichprop, prop);      } # add a string to the vector
	print("whichprop: " ~ debug.string(whichprop));
	var look_in = (use_deviations) ? (nameDeviations) : (instrumentsProps);
	var ret = getMember(whichprop, look_in);
print("getInstrumentPropForName, ret: " ~ debug.string(ret));
	if ( (ret == nil) or (ret =="") ) {
		if (prop != "watcher" ) # watcher is optional, do not issue an ERROR
			{print("ERROR:  input_adapter: getInstrumentPropForName: stanard name or member not found: >" ~ debug.string(name) ~ "<, for instrument: >" ~ debug.string(instrument) ~ "<, looking for member: " ~ debug.string(prop));}
	}
print("getInstrumentPropForName, ret2: " ~ debug.string(ret));
	return ret;
};

# Todo: use a hash instead of an objectoriented vector
var removeAllListeners = func() {
	foreach(var cur_listener; myListeners.vector) {
	removelistener(cur_listener.id);
	}
	myListeners.clear();
};


# Todo: use a hash instead of an objectoriented vector
var myListeners = std.Vector.new();
var removeMyListeners = func(which) {
	if (size(myListeners) == 0) return;
	for(var i=0; i<size(myListeners.vector); i+=1) {
		if (myListeners.vector[i].listenFor == which) {
			removelistener(myListeners.vector[i].id);
			myListeners.pop(i);
		}
	}
	debug.dump(myListeners);
};

var watchMatchName = func(inputDeviceName, name, propPath, type, num = 0, numDigits = 0, decimalDotExtra = 1) {
		var matchedName = matchName(inputDeviceName, name);
		return watchName(matchedName, propPath, type, num, numDigits, decimalDotExtra, inputDeviceName);
};

# propPath will be created. Just use the name of the LEDs/display on
# your device, e.g. saitek-mp-led-hdg or a complete path like /input/saitek-mp/led-hdg (recommended). 
# If propPath starts with a "/" it is interpreted
# absolute, if it starts with anything else, it will be created under /input/input_adapter.
# returns the path to the created property (unchanged if the parameter's first char was "/").
# type of property, it can be "BOOL", "DOUBLE", "STRING" or "INT"
# num: which instrument number to watch (e.g. if there are more than 1 comm radios)
# numDigits: number of digits the device can display (only relevant if type = "DOUBLE")
# decimalPointExtra: decimal point does not count when counting the number of digits (only relevant if type = "DOUBLE")
var watchName = func(name, propPath, type, num = 0, numDigits = 0, decimalDotExtra = 1, inputDeviceName = '') {
	var propStr = propPath;
	if (propStr == nil) {print("WARNING: watchName, cannot create a property nil for name: " ~ debug.string(name)); return nil;}
#	if ( propPath[0] != "/"[0] ) 	{ propStr = basePathAdapter ~ propPath; }
debug.dump(propPath);
	removeMyListeners(propPath);				
	if ( (name == nil) or (name == "") ) {
		print("input_adapter: watchName: Info: called with nil or empty name to watch for. --> Watching for nothing.");
		props.globals.initNode(propStr, nilValue, type);
		setprop(propStr, getFormatedValueForName(name: name, num: num, value: nilValue, numDigits: numDigits, decimalDotExtra: decimalDotExtra, inputDeviceName: inputDeviceName));
		return name; 
	}
	var props_ = getInstrumentPropForName(name, [], inputDeviceName);
debug.dump(name);
debug.dump(num);
print("nnnnnnnnnnaaaaaaaaaaaaaaaaaaaaaa");
debug.dump(props_);
	if ( props_ == nil) { print ("WARNING: input_adapter: watchName: no properties found for name: " ~ debug.string(name)); return nil; }
	if ( typeof(props_) == "vector") {
		foreach (prop; props_) {
			if ( (prop != "") and (typeof(prop) == "scalar") ) { # "scalar" = string or number
debug.dump(prop);
var tmpNode = props.globals.getNode(prop);
debug.dump(tmpNode);
debug.dump(tmpNode.getAttribute("alias"));
debug.dump(tmpNode.getAttribute("listeners"));
					var listenerId = setlistener(prop, func(status) {
						watcher_(name: name, propStr: propStr, value: status, num:num, numDigits: numDigits, decimalDotExtra: decimalDotExtra, inputDeviceName: inputDeviceName); 
						}, 1, 0);
debug.dump(tmpNode.getAttribute("listeners"));
					myListeners.extend([{listenFor: propPath, listening: prop, id: listenerId}]);
debug.dump(myListeners);
			}
		}
	} else {
		if (typeof(props_) == "hash") {
			print("watchName lllllllllllllllllllll name: " ~ name);
			var propGetter_ = getInstrumentPropForName(name, ["propGetter"], inputDeviceName);
			if (propGetter_ != nil) {
				var props2watch = propGetter_(num);
				foreach (prop; props2watch) {
debug.dump(prop);
#debug.dump(props.Node.getAttribute(prop));
		                var listenerId = setlistener(prop, func(status) {
							watcher_(name: name, propStr: propStr, value: status, num:num, numDigits: numDigits, decimalDotExtra: decimalDotExtra, inputDeviceName: inputDeviceName); 
							}, 1, 0);
	    			    myListeners.extend([{listenFor: propPath, listening: prop, id: listenerId}]);
				}
			} else {
				print("input_adapter: watchName: The property is a hash, then it must contain a function called >propGetter< but this was not found for name: >" ~ debug.string(name) ~ "<");
				return nil;
			}
	    } else {
			print("input_adapter: watchName: The property must be a vector or a hash, problem was found for name: >" ~ debug.string(name) ~ "<");
			return nil;
	    }
	}
	value = getFormatedValueForName(name, num, numDigits, decimalDotExtra, inputDeviceName);
#	debug.dump(propStr);
#	debug.dump(value);
	if (value == nil)	{ value = nilValue;}
	else 			    { props.globals.initNode(propStr, value, type);}
	return propStr;
};

# This function is called when a watched property changes (and on creation)
var watcher_ = func(name, propStr, value, num, numDigits, decimalDotExtra, inputDeviceName) {
## fgcommand("profiler-start"); #, props.Node.new({"filename": "output.profile"})); # will be created in the dir fgfs was started from --> where fgfs resides in
## for (var i=0; i<100; i += 1) {
print("watcher called");
	debug.dump(name);
	debug.dump(propStr);
	debug.dump(value);
	debug.dump(num);

	var value = getFormatedValueForName(name, num, numDigits, decimalDotExtra, inputDeviceName);
#	print("new value: ");
#	debug.dump(value);
	if (value == nil)	{ value = nilValue;}
	if (value != getprop(propStr)) {setprop(propStr, value) };  # avoid IO-Operation (update of the created and by the according input-xml watched property only if there was a change in order to avoid unnecessary IO-Operations
	var instrumentWatcher = getInstrumentPropForName(name, "watcher", inputDeviceName);
	if (instrumentWatcher != nil) {
		print("Calling watcher of the instrument."); 
		instrumentWatcher(num);
	}
## if (name == "ap/btn_rev") { fgcommand("exit"); }
## }
## fgcommand("profiler-stop");
};


# if numDigits = 0, no formatting will be applied
var getFormatedValueForName = func(name, num, numDigits, decimalDotExtra, inputDeviceName) {
	var val = getValueForName(name, num, inputDeviceName);
	if (numDigits == 0) {
		return val;
	}
	var format = getFormatForName(name, num, inputDeviceName);
	var ret = formatValue(val, format, numDigits, decimalDotExtra);
	print("Formated value: ");
	debug.dump(ret);
	return ret;
};
	
var getFormatForName = func(name, num=0, inputDeviceName="") {
	if ( (name == "") or (name == nil) ) { return ""; }
	var formatGetter_ = getInstrumentPropForName(name, "formatGetter", inputDeviceName);
	if (formatGetter_ == nil) { print("ERROR: input_adapter: getFormatForName: could not find member >FormatGetter< for button/display name >" ~ debug.string(name) ~ "<"); }
	print("getFormatForName");
	debug.dump(name);
	debug.dump(num);
	debug.dump(formatGetter_);
	var format = formatGetter_(num);
	return format;
};

var getValueForName = func(name, num = 0, inputDeviceName="") {
	var props_ = getInstrumentPropForName(name, [], inputDeviceName);
	
	# I want the auto pilot LED on, if the autopilot is active
	# and I want it blinking if it switches off
  	# therefor the locks and the status must be combined

	# default
	var ret = nilValue;
	print("GetValue 1");
	debug.dump(props_);
	if ( typeof(props_) == "vector") {
		print("GetValue 2");
		# use the first element in the vector of property pathes as default		
		ret = getprop(props_[0]); 
		# if there are elements in the vector which are functions, use the last return value
		# of the last function.
		for (var i=1; i<size(props_); i += 1) { # the first one must be the property, so we start looking at the second value in the vector
			if ( typeof(props_[i]) == "func") {
			    ret = props_[i]();		
			}
		}
	} else {
		print("GetValue 3");
		# If it is a hash, use the getValue function (in case it exists)
		# or use the property which the propGetter function returns
		if ( typeof(props_) == "hash") {
			var getValue_ = getInstrumentPropForName(name, ["getValue"], inputDeviceName);
			if ( (getValue_ != nil) and (getValue_ != "")) {
				print("GetValue by function");
				ret = getValue_(num); 
			} else {
				var propGetter_ = getInstrumentPropForName(name, ["propGetter"], inputDeviceName);
				if (propGetter_ != nil) {
					ret = getprop(propGetter_(num)[0]); 
				} else {
					print("WARNING: input_adapter: getValueForName: If it is an hash, it must contain an >propGetter< or >getValue< element which is not present for name: >" ~ debug.string(name) ~ "<");
					return nilValue;
				}
			}
		}
	}
	return ret;
};

# format a value
# format: firstDigit must be "L" or "R" the rest is passed to sprintf
# format: firstDigit "L": left  cut off if the value has more chars then allowed by numDigits
# format: firstDigit "R": right cut off if the value has more chars then allowed by numDigits

# make sure that the correct number of digits is returned
# by padding resp. using the numDigits right digits only
# if decimalDotExtra is true=1, decimal dots will not be counted when
# calculating the length numDigits
var formatValue = func(value, format, numDigits, decimalDotExtra) {
	print("formatValue");
	var empty_ = substr("                                                                                                    ", 0, numDigits);
	debug.dump(value);
	debug.dump(nilValue);
	debug.dump(value == nilValue);
	debug.dump(format);
	if ( (value == nil) or (value == "") or (value == nilValue) ) return empty_;
	if ( size(format) < 0 ) {
			print("Error: input_adapter: formatValue: format must contain at least 1 char. format: >" ~ debug.string(format) ~ "<"); 
			return empty_;
	}
	tmp = sprintf(substr(format, 1), value);
	var	numdots = 0;
	if (decimalDotExtra) {
		# count the dots (as dots will not generate a byte to be send, 
		# so the ascii string has to be the length of (size + number of dots)
		for (var i=0; i<size(tmp); i += 1) {
			if (tmp[i] == "."[0]) { numdots += 1; }
		}
	}
	var ret = empty_;
	# always pad left
	if ( size(tmp) < (numDigits + numdots)) { tmp = substr(empty_ ~ tmp, - numDigits - numdots); }
	
	# cut off string if there are more chars than allowed
	if (format[0] == `L`) {
		ret = substr(empty_ ~ tmp, - numDigits - numdots); # this is the same as right(), but right() does not work
	} else if (format[0] == `R`) {
		ret = substr(tmp ~ empty_, 0, numDigits + numdots); # this is the same as left(), but left() does not work
	} else { 
		print("Error: input_adapter: formatValue: format must start with >L< or >R<, format: >" ~ debug.string(format) ~ "<"); 
		return empty_;
	}
	return ret;
	
	leftpad = size + numdots - size(tmp);
		
	# left pad with spaces if necessary
	# use only the last numDigits digits if more are given
	var ret = "";
	if (size(tmp) == numDigits + numdots) {
		ret = tmp;
	} else {
		for (var i=0; i < (numDigits + numdots); i += 1) {
			if (leftpad > 0) {
				if (i<leftpad) 	{ ret ~= " "; }
				else		{ ret ~= chr(tmp[i - leftpad]); }
			}
			else 		{ ret ~= chr(tmp[size(tmp) - numDigits - numdots + i]); }
		}
	}
	# sprintf("%*s", numDigits + numdots, tmp);
	# easier and I guess faster: ret = right(empty ~ tmp), numDigits + numdots); # Todo use this
	# debug.dump(ret);
	return ret;
};


var buttonPressedMatchName = func(inputDeviceName, buttonName, btnType, num = 0, param = nil) {
	return buttonPressedMatchName_(inputDeviceName, buttonName, btnType, "press", num, param);
};

var buttonReleasedMatchName = func(inputDeviceName, buttonName, btnType, num = 0, param = nil) {
	return buttonPressedMatchName_(inputDeviceName, buttonName, btnType, "release", num, param);
};


# translates the standard name of a button or display to
# the specfic standard name for the installed in-aircraf instrument
# using the deviation table. Calls buttonPressed() then
# with the new matched standard name.
# btnType can be "biased" or "toggle". If the instrument has a toggle
# button and the device a biased button, it will be automatically converted
# action = "press" or "release"
var buttonPressedMatchName_ = func(inputDeviceName, buttonName, btnType, action, num = 0, param = nil) {
	var machtedName = matchName(inputDeviceName, buttonName);
	if ( (machtedName == nil) or (machtedName == "") ) {
		print("WARNING: input_adapter: buttonPressedMatchName_: No match found / no action associated for button name >" ~ debug.string(buttonName) ~ "< for device >" ~ debug.string(inputDeviceName) ~ "<");
		return nil;
	}
	var instrumentName = getInstrumentName(machtedName);
	print("buttonPressedMatchName_, instrumentName: ");
	if ( (instrumentName == nil) or (instrumentName == "") ) { print("WARNING: buttonPressedMatchName_: no instrument found for button name >" ~ debug.string(buttonName) ~ "<"); return nil; }
	debug.dump(instrumentName);
	var ret = nil;
	var instrBtnType = getMember([instrumentName, "actions", machtedName, "btnType"], instrumentsProps);
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 1, instrBtnType: " ~ debug.string(instrBtnType));
	if (instrBtnType == nil) {print("WARNING: input_adapter: member >btnType< not defined for instrument >" ~ debug.string(instrumentName) ~ "<, for name >" ~ debug.string(machtedName) ~ "<"); return nil; }
print("machtedName: " ~ debug.string(machtedName));
	if (btnType !=  instrBtnType) {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 2");
		if ( (btnType == "biased") and (instrBtnType == "toggle")  ) {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 3");
			if (action == "press") { # do not do anything if a biased button was released in order to change a toggle button
				if ( getMember([instrumentName, "actions", machtedName, "aniProp"], instrumentsProps ) != nil) {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 4");
					ret = buttonPressed(machtedName, num, param);
				} else {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 5");
					ret = buttonReleased(machtedName, num, param);
				}
			}
		# note: the animation is done in buttonPressed() resp. buttonReleased()
		# that also toggles the button.
		} else {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 6");
			print("input_adapter: buttonPressedMatchName_: was not able to adapt button type from: >" ~ debug.string(btnType) ~ "< to: >" ~ debug.string(getMember([instrumentName, "actions", buttonName, "btnType"], instrumentsProps)) ~ "<");
		}
	} else {
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 7");
		ret = buttonPressed_(machtedName, action, num, param);
	}
print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjJ 8");
	return ret;
};

# returns the function part of the name
var getInstrumentName = func(buttonName) {
# debug.dump(buttonName);
	var instrumentTypeShort = split("/", buttonName);
# debug.dump(instrumentTypeShort);
	return getInstalledInstrumentName(instrumentTypeShort[0]);

# commted out the hierachial thing:
	# concanate elements of vector v into a string, separating each part by "/", for up to vector index max_index
#	var _concat = func(v, max_index) {
#		var ret = "";
#		for (var i=0; i <= max_index; i += 1) {
#			if( i == 0) ret = v[i];
#			else        ret = ret ~ "/" ~ v[i];
#		}
#		return ret;
#	};
	
#	instrumentName = "";
#	for(var i=size(instrumentTypeShort) -2; i>=0; i -= 1) { # -2: the last part is always the name - not part of the instrument function
#		var test_type = _concat(instrumentTypeShort, i);
#		var func_index = findInVector(test_type, intrumentFunctions);
#		if ( func_index >= 0) {
#			return getInstalledInstrumentName(intrumentFunctions[func_index]);
#		}
#	}
#	return "";
};

var animate = func(instrumentName, buttonName, num = 0, amount = 1) {
	print("animate called, instrumentName: " ~ debug.string(instrumentName));
	var aniProp = getMember([instrumentName, "actions", buttonName, "aniProp"], instrumentsProps); 
	print("aniProp");
	debug.dump(aniProp);
	if ( aniProp == nil ) { return; }
	var realAnipropPath = aniProp;
	if (typeof(realAnipropPath) == "func") {
		realAnipropPath = realAnipropPath(num);
	}
	var aniStep = getMember([instrumentName, "actions", buttonName, "aniStep"], instrumentsProps);
	print("aniStep");
	debug.dump(aniStep);
	if ( aniStep != nil ) {
		setprop(realAnipropPath, getprop(realAnipropPath) + aniStep * amount);
		} else {
		propertyToggle(realAnipropPath);
		}
};


var buttonPressed = func(buttonName, num = 0, param = nil) {
	return buttonPressed_(buttonName, "press", num, param);
	};

var buttonReleased = func(buttonName, num = 0, param = nil) {
	return buttonPressed_(buttonName, "release", num, param);
	};


# action = "press" or "release" 
var buttonPressed_ = func(buttonName, action, num = 0, param = nil) {
debug.dump(num);
debug.dump(param);
	if ( (buttonName == nil) or (buttonName == "") ) {
		print("WARNING: input_adapter: buttonPressed called with empty button name");
		return nil;
	}
	var instrumentName = getInstrumentName(buttonName);

	if ( (instrumentName == nil) or (instrumentName == "") ) {
		print("WARNING: input_adapter: buttonPressed: no instrument found for button name >" ~ debug.string(buttonName) ~ "<");
		return nil;
	}
 debug.dump(instrumentName);
 debug.dump(buttonName);
 # debug.dump(instrumentsProps[instrumentName]["actions"][buttonName]);
debug.dump(action);

	# do the action		
# debug.dump(instrumentsProps[instrumentName]["actions"][buttonName][action]);
	if ( getMember([instrumentName, "actions", buttonName, action], instrumentsProps) == nil) { 
		print("input_adapter: buttonPressed_: WARNING: no action: >" ~ debug.string(action) ~ "< not defined for instrument: >" ~ debug.string(instrumentName) ~ "< and button name: >" ~ debug.string(buttonName) ~ "<");
		return nil;
	}
	var success = getMember([instrumentName, "actions", buttonName, action], instrumentsProps)(num, param); 
	print("success: " ~ debug.string(success));

	# in a certain status of the instrument a requested action might not be possible, 
	# e.g. in the autopilot KAP140, increasing the altitude setting when in vs mode
	# is not possible, because the same button is used for it (the button "up"). 
	# Do not animate a button then.
	# the success return code determines wheather the knob/button should be animated
print("mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm 0");
# debug.dump(instrumentsProps[instrumentName]["actions"][buttonName]);

	# animate
	if (success) {
		animate(instrumentName, buttonName, num, param);
		# play the sound
		# Todo (till now, did not implement sound, because it mostly click sound caused by button press that is there on the external device anyway)
	}
};

#############################################
# Tests
##############

print("----------------------------------");

print("func test");

var test = getInstrumentPropForName("radio_comm/freq_active", "propGetter", "");
print("property:");
debug.dump(test);
