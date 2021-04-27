# This file contains data allowing an input device to
# access in a standard way the generic transponder radio.
# It is processed by input_adapter.nas

var instr_radio_transponder_generic = {
	"radio_transponder/generic": {
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/transponder[" ~ num ~ "]/id-code")) != nil ); },
		functions: {"radio_transponder": 0}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_transponder/code":    {propGetter: func(number = 0) {return ["/instrumentation/transponder/id-code"];      }, formatGetter: func(num) {return "R%5.4u" }}
		},
		actions: {
			"radio_transponder/btn_adjust_twoDigitsSeparate": {
				btnType: "biased", press: func(num = 0, amount = 1) {
					var cId = getValueForName("radio_transponder/code", num); 
					var newId = transpAdjustId(cId, amount, "twoDigitsSeparate");
					setprop("/instrumentation/transponder/id-code", newId);
					return 1;
				}, release: func() {}
			},
			"radio_transponder/btn_adjust_eachDigitSeparate": {
				btnType: "biased", press: func(num = 0, amount = 1) { # amount = 1/8/64/512 adjust first, second, third, fourth digit from right
					var cId = getValueForName("radio_transponder/code", num); 
					var newId = transpAdjustId(cId, amount, "eachDigitSeparate");
					setprop("/instrumentation/transponder/id-code", newId);
					return 1;
				}, release: func() {}
			},
			"radio_transponder/btn_ident": {
				btnType: "biased", 
				press:   func(num = 0) { setprop("/instrumentation/transponder[" ~ num ~"]/inputs/ident-btn", 1); }, 
				release: func(num = 0) { setprop("/instrumentation/transponder[" ~ num ~"]/inputs/ident-btn", 0); }
			},
			"radio_transponder/btn_set_mode": {
				btnType: "selector", 
				press:   func(num = 0, mode = 4) { # mode can be 0...5 or "off", "standby", "test", "ground", "on" or "alt"
					var mode_ = num(mode);
					if (mode_ == nil) { mode_ = mode2num[mode]; }
					print("radio_transponder/btn_set_mode, mode:" ~ debug.string(mode_));
					setprop("/instrumentation/transponder[" ~ num ~"]/inputs/knob-mode", mode_); 
				}, 
				release: func(num = 0) { }
			},
			"radio_transponder/btn_adjust_mode": {
				btnType: "biased", 
				press:   func(num = 0, dir = 1) { 
					var order = ["off", "standby", "on", "alt", "test", "ground"];
					var order = [ 0,     1,         4,    5,     2,      3]; # Todo: move this to "radio_transponder/kt76a"?
					var cur_mode = getprop("/instrumentation/transponder[" ~ num ~"]/inputs/knob-mode");
					print("cur_mode: " ~ debug.string(cur_mode));
					var selpos = order[cur_mode];
					print("selpos: " ~ debug.string(selpos));
					print("dir: " ~ debug.string(dir));
					var newselpos = selpos + dir;
					print("newpos: " ~ debug.string(newselpos));
					if (newselpos < 0) {newselpos = 0;};
#					if (newselpos >= size(order)-1) {newselpos = size(order)-1; } 
					if (newselpos >= 4) {newselpos = 4; } # Todo: move this to "radio_transponder/kt76a"
					var new_mode = order[newselpos];
					print("new_mode: " ~ debug.string(new_mode));
					setprop("/instrumentation/transponder[" ~ num ~"]/inputs/knob-mode", new_mode); 
				}, 
				release: func(num = 0) { }
			}
		},
		mode2num: {
			"off":     0,
			"standby": 1,
			"test":    2,
			"ground":  3,
			"on":      4,
			"alt":     5
		},
		num2mode: ["off", "standby", "test", "ground", "on", "alt"]

	}
};
