	var nilValue = -3213641684618484;


	# Converts an ascii string to bytes to be send to the saitek device. 
	# The string may consist of numbers 0 to 9, decimal dots and the minus sign.
	var ascii2saitek = func(string2display) {
		var ret = "";
		var addchar = "";
       		for (var i=0; i < size(string2display); i += 1) {
			if (string2display[i] == "-"[0]) {
         			addchar = chr(14); # chr(14) shows the minus sign
			} else {
				if (string2display[i] == " "[0]) {
	         			addchar = chr(10); # chr(255) switches the digit off (everycode between 10 and 15 does it)
				} else {
					addchar = chr(string2display[i] - 48);
				}
			}
			if ( (i+1 < size(string2display)) and (string2display[i+1] == "."[0]) ) { # 46 decimal point
	         		addchar = chr(addchar[0] +  0xd0); # adding d0 displays a decimal point after the digit
				i += 1;
			}
         		ret ~= addchar;
		}
	return ret;
       	}
	

var getFormatProp = func(propPath, format) {
		var val = getprop(propPath);
		return formatValue(val, format);

}
