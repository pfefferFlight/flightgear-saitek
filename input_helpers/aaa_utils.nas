var nilValue = -3213641684618484; # todo: a) use 1/0 or 0/0 instead? b) define it only once
# debug.dump(debug.isnan(1/0));
# debug.dump(0/0);
# setprop(basePath ~ "disp/disp", -1/0);


var propertyToggle = func(propPath) {
#print("ppppppppppppppppppppppppppppp");
#debug.dump(propPath);
#debug.dump(getprop(propPath));
	if (getprop(propPath)) {
		setprop(propPath, 0);
	} else {
		setprop(propPath, 1);
	}
};

# Not needed --> commented out
# find a needle in a vector
#var findInVector(needle, vect) {
#	for (var i = size(vect) -1; i >=0; i -=1 ) {
#		if (needle == vect[i]) { return i; }
#	}
#	return -1;
#};



	# returns true/1 iff the propPath exists
	var propPathExists = func(propPath) {
		var t = props.globals.getType(propPath);
#		print("propPathExists: >" ~ debug.string(propPath) ~"<");
#		debug.dump(t);
		return (t != nil);
	};

	# Adjust the standby or active frequency of a comm radio
	# pathToInstrument: property path to the instrument where the frequencies directorty reside in
	# amount: amount to adjust, negative to decrease the freq
	# small: true/1: adjust kHz part, else: adjust MHz part
	# smallChannelSpacing: in an 8.33 kHz radio: true/1: adjusting kHz: use 8.33 kHz steps (default)
	#                                           false/0: adjust in 25 kHz steps
	#					   in an old 25 khz radio: no effect
	# adjustActiveFreq: true/1:  adjust active/selected freq
	#                   false/0: adjust standby freq (default)
	# wrapKhz (only relevant if small is true/1): 
	#          true/1:  small does not ovgerflow into MHz part of freq (default)
	#          false/0: small adjust dows overflow into MHz part of freq
	var commFreqAdjust = func(pathToInstrument, amount, small, smallChannelSpacing = 1, wrapKhz = 1, adjustActiveFreq = 0) {
		if (propPathExists( pathToInstrument ~ "/frequencies/standby-channel") ) {
			# new 8.33 kHz radio
			var chname = "/frequencies/standby-channel";
			if (adjustActiveFreq) { chname = "/frequencies/selected-channel"; }
			var old = getprop( pathToInstrument ~ chname);
			if ( (old == nil) or (old == nilValue) ) { old = 0; }
			var realold = old;
			if (! small) {
				# adjust the MHz
				amount = amount * 160 ; # 160 = 4 (8.33 kHz channels per 25 kHz) * 40 (25 khz per MHz)
			}
			if (small and (!smallChannelSpacing) ) {
				# 8.33 kHz radio but the small button is pulled in order to set only 25 kHz freqs
				if (math.fmod(old, 4) != 0) { # 4 8.33 kHz channels form 1 25 kHz channel
					# we are currently not on a 25 kHz channel --> first tune there
					if (amount > 0) {
						# tune to the next higher 25 kHz channel
						old = math.ceil(old / 4) * 4;
					} else {
						# tune to the next lower 25 kHz channel
						old = math.floor(old / 4) * 4;
					}
					# consume 1 amount for tuning from 8.33kHz to the next 25 kHz channel
					amount = math.sgn(amount) * (math.abs(amount) - 1);
				}
				# just add 4 to get to the next 25kHz channel
				amount = amount * 4;
			}
			if (small and wrapKhz) {
				#wrap at MHz  = avoid overflow into MHz
				amount = amount - math.floor((old + amount)/160)*160 + math.floor(realold/160)*160; 
			}
			setprop(pathToInstrument ~ chname, old + amount);
		} else {
			# an old 25 kHz radio
			var chname = "/frequencies/standby-mhz";
			if (adjustActiveFreq) { chname = "/frequencies/selected-mhz"; }
			var old = getprop(pathToInstrument ~ chname);
			
			if ( (old == nil) or (old == nilValue) ) { old = 118; }
			if (small) {
				print("commFreqAdjust: old 25 kHz: small");
				amount = amount * 0.025;
				# avoid overflow into MHz # + 0.0001 is a work-around for problems of 0.1 being
				# a periodic number in binary
				debug.dump(old);
				debug.dump(amount);
				if (wrapKhz) {
					amount = amount - math.floor( math.floor(old + amount + 0.0001) - math.floor(old + 0.0001) );
				}
				debug.dump(amount);
			}
			# wrapping (the old 25 kHz frequencyformatter does not wrap automatically at freq boundaries (it clips them instead) - see frequencyformatter.hxx)
			var newFreq = ((old + amount) > 137) ? (old + amount - 19) : (   ((old + amount) < 118) ? (old + amount + 19) : (old + amount)   );
			setprop(pathToInstrument ~ chname, newFreq);
		}
	};


	# Get the new frequency from the current/old for VORs
	# Small = 1/true: adjust the kHz part of the freq. 
	# Small = 0/false: adjust the MHz part of the freq.
	var navFreqAdjust = func(old, amount, small) {
		if ((old == nil) or (old == nilValue) ) { old = 108; }
		if (small) {
			var factor = 0.025;
			amount = amount * factor;
			# avoid overflow into MHz # + 0.0001 is a work-around for problems of 0.1 being
			# a periodic number in binary
			amount = amount - math.floor( math.floor(old + amount + 0.0001) - math.floor(old + 0.0001) );
		}
		var newVal = ((old + amount) > 118) ? (old + amount - 10) : (   ((old + amount) < 108) ? (old + amount +10) : (old + amount)   );
		return newVal;
	};

	# Get the new frequency from the current/old for ADF
	# small = 1/true means adjusting the kHz. 
	# small = 0/false adjusts the 100 kHz.
	var adfFreqAdjust = func(old, amount, small) {
		if ((old == nil) or (old == nilValue) ) { old = 200; }
		if (small) {
			# avoid overflow into kHz # + 0.0001 is a work-around for problems of 0.1 being
			# a periodic number in binary
			amount = amount - 100 * math.floor( math.floor((old + amount + 0.0001)/100) - math.floor((old + 0.0001)/100) );
		} else {
			amount = amount * 100;
		}
		var newVal = ((old + amount) > 1799) ? (old + amount - (1800-200)) : (   ((old + amount) < 200) ? (old + amount + 1800-200) : (old + amount)   );
		return newVal;
	};

	# Swaps the value of two props	
	var swapProps = func(propPath1, propPath2) {
		var tmp = getprop(propPath1);
		setprop(propPath1, getprop(propPath2));
		setprop(propPath2, tmp);
	};

# Adjust the sqauwk ID.
# old:   decimal encoded squak ID.
# modus: "set": just set the code given in amount (as decimal encoded octal number)
# modus: "eachDigitSeparate": there is no overflow from one digit to another
# modus: "twoDigitsSeparate": two digits left and two digits right overflow
#amount: 1 to add 1 to the first digit from right,
#			   8 to add 1 to the second digit from right, 
#			 64 to add 1 to the 3rd digit from right and
#          512 to add 1 to the first digit from left.
var transpAdjustId = func(old, amount, modus) {
	if (modus == "set") {return amount; }
	
	# every digit solo --> no overflow
	if ( modus == "eachDigitSeparate" ) {
		var addDigits = func(old, ch) {
			var lowOld = math.fmod(math.floor(old), 10);
			var lowCh = math.fmod(math.floor(math.abs(ch)), 8) * math.sgn(ch);
			var lowNew = math.fmod(lowOld + lowCh, 8);
			if (lowNew < 0) { lowNew = lowNew + 8; }
			return lowNew;
		};
		var digit1 = addDigits(old, amount);
		var digit2 = addDigits(old/10, amount/8, 10) * 10;
		var digit3 = addDigits(old/100, amount/64, 10) * 100;
		var digit4 = addDigits(old/1000, amount/512, 10) * 1000;
		return digit1 + digit2 + digit3 + digit4;
	}
	
	# two digits together --> overflow between the last and the before last digit
	if ( modus = "twoDigitsSeparate" ) {

		# accepts two digits in old as decimal encoded octal, 
		# add: decimal number of steps to add
		# return two digits decimal encoded octal 
		var addTwoDigits = func(old, add) {
			var decimalNum = math.floor(old / 10) * 8 + math.fmod(old, 10);
			var newDecimal = decimalNum + add;
			if (newDecimal <0) {newDecimal = newDecimal + 8 * 8; }
			newDecimal = math.fmod(newDecimal, 64);
			var newDecimalEncodedOctal = math.fmod(newDecimal, 8) + math.floor(newDecimal/8)*10;
			return newDecimalEncodedOctal;
		};

		# the two higher digits
		var twoDigitsOld = math.floor(old/100);
		var twoDigitsAmount = math.floor(	math.abs(amount/64)) * math.sgn(amount);
		var hi = addTwoDigits(twoDigitsOld, twoDigitsAmount) * 100;
		
		# the two lower digits
		var twoDigitsOld = math.fmod(old, 100);
		var twoDigitsAmount = math.fmod(amount, 64);
		var low = addTwoDigits(twoDigitsOld, twoDigitsAmount);
		
		return low + hi;
	}
	print ("input_adapter: transpAdjustId: WARNING: modus: >" ~ debug.string(modus) ~ "< not supported.");
};
