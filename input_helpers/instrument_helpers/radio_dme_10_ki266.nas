# This file contains data allowing an input device to
# access in a standard way the DME KI266 radio
# which is installed in the Cessna 172.
# It is processed by input_adapter.nas

var instr_radio_dme_ki266 = {
	"radio_dme/ki266": {
		parents: [instr_radio_dme_generic["radio_dme/generic"]], 
		existenceTester: func(num=0) {return ( getprop("/instrumentation/dme[" ~ num ~ "]/miles-display") != nil ); },
		functions: {"radio_dme": 10}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_dme/dist_nm":	     { # overwrites the one inherited from dme-generic
				propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/miles-display"];    }, 
				formatGetter: func(num) {return "R%s" }, 
				getValue: func(num = 0) {
					var miles_display = getprop("/instrumentation/dme[" ~num~ "]/miles-display");
					if ( (miles_display == nil) or (miles_display == 0 ) ) {return nilValue;}
						print("DME: " ~ getprop("/instrumentation/dme[" ~num~ "]/miles-display"));
						var ret = sprintf("%5.2u", getprop("/instrumentation/dme[" ~num~ "]/miles-display"));
						if (getprop("/instrumentation/dme[" ~num~ "]/left-dot")) {
							ret = sprintf("%5.1f", getprop("/instrumentation/dme[" ~num~ "]/miles-display")/10);
							#ret = substr(ret, 0, -1) ~ "." ~ substr(ret, -1, 1);
						}
						return ret;
				}
			},
			"radio_dme/min_kts": {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/min-kts-display"];            }, formatGetter: func(num) {return "L%5.0f"; }},
		},
		actions: {
			"radio_dme/btn_disp_swap": {
				btnType: "toggle", press: func(num = 0) {return 1;}, release: func() {return 1;}, # the change in /instrumentation/dme/switch-min-kts will cause /instrumentation/dme/min-kts-display to display minutes instead of kntos
				aniProp: "/instrumentation/dme/switch-min-kts" 
			},
		}
	}
};
# ki266			
# ki266			"radio_dme/dist_nm":	     {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/miles-display"];}, formatGetter: func(num) {return "R%s" }, 
