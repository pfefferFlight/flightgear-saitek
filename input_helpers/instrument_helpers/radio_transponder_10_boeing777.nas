# This file contains data allowing an input device to
# access in a standard way the Boeing 777 transponder radio.
# It is processed by input_adapter.nas


var instr_radio_transponder_boeing777 = { # in boeing 777 (I do not know the correct model name of this instrument
	"radio_transponder/b777": { 
		parents: [instr_radio_transponder_generic["radio_transponder/generic"]],
		existenceTester: func(num=0) {return ( getprop("/instrumentation/transponder[" ~ num ~"]/mode-switch") != nil ); },
		functions: {"radio_transponder": 10}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {                                                                          #parents[0].displays["radio_comm/freq_active"].propGetter(num)
			"radio_transponder/code":    {
				watcher: func(num = 0) {
					var id_code = getprop("/instrumentation/transponder/id-code"); 
					print("watcher: id-code:" ~ debug.string(id_code));
					var digit0 = int(id_code/1000);
					var residual = (id_code - digit0 * 1000);
					print("watcher: DIGIT0:" ~ debug.string(id_code));
					print("watcher: residual:" ~ debug.string(residual));
					var digit0 = int(id_code/1000);
					var digit1 = int (residual / 100);
					residual = (residual - digit1 * 100);
					var digit2 = int (residual / 10);
					residual = (residual - digit2 * 10);
					var digit3 = residual;
					setprop("/instrumentation/transponder/id-code-digit0", digit0);
					setprop("/instrumentation/transponder/id-code-digit1", digit1);
					setprop("/instrumentation/transponder/id-code-digit2", digit2);
					setprop("/instrumentation/transponder/id-code-digit3", digit3);
				}
			}
		},
		actions: {
			"radio_transponder/btn_adjust_mode": {
				btnType: "biased", 
				press:   func(num = 0, dir = 1) { 
#					var order = ["standby", "off", "ALT RTTG", "TA only", "TARA" ];
#					var order = [ 1,         4,     5,          5,         5     ]; 
					var selpos = getprop("/instrumentation/transponder[" ~ num ~"]/mode-switch");
					var newselpos = selpos + dir;
					print("newpos: " ~ debug.string(newselpos));
					if (newselpos < 0) {newselpos = 0;}
					if (newselpos >= 4) {newselpos = 4; }
					setprop("/instrumentation/transponder[" ~ num ~"]/mode-switch", newselpos); 
				} 
			}
		}
	}
};
