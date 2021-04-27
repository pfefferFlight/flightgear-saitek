# This file contains data allowing an input device to
# access the generic nav radio in a standard way.
# it is processed by input_adapter.nas

var instr_radio_nav_generic = {
	"radio_nav/generic": {
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/nav[" ~ num ~ "]/frequencies/standby-mhz")) != nil ); },
		functions: {"radio_nav": 0}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_nav/freq_active":     {propGetter: func(number = 0) {return ["/instrumentation/nav[" ~number ~ "]/frequencies/selected-mhz"];  }, formatGetter: func(num) {return "L%4.2f"; }},
			"radio_nav/freq_standby":    {propGetter: func(number = 0) {return ["/instrumentation/nav[" ~number ~ "]/frequencies/standby-mhz"];   }, formatGetter: func(num) {return "L%4.2f"; }},
		},
		actions: {
			"radio_nav/freq_active": {
				btnType: "biased", press: func(num = 0) {
					swapProps("/instrumentation/nav[" ~num ~ "]/frequencies/standby-mhz", "/instrumentation/nav[" ~num ~ "]/frequencies/selected-mhz");
					return 1;
				}, release: func() {return 1;}
			},
			"radio_nav/freq_standby_btn_adjust_small": {
				btnType: "biased", press: func(num = 0, amount = 1) {
					var cFreq = getValueForName("radio_nav/freq_standby", num); 
					var newFreq = navFreqAdjust(cFreq, amount, 1);
					setprop("/instrumentation/nav[" ~num ~ "]/frequencies/standby-mhz", newFreq);
					return 1;
				}, release: func() {}
			},
			"radio_nav/freq_standby_btn_adjust_large": {
				btnType: "biased", press: func(num = 0, amount = 1) {
					var cFreq = getValueForName("radio_nav/freq_standby", num); 
					var newFreq = navFreqAdjust(cFreq, amount, 0);
					setprop("/instrumentation/nav[" ~num ~ "]/frequencies/standby-mhz", newFreq);
					return 1;
				}, release: func() {}
			},
			"radio_nav/btn_crs_up":  {btnType: "biased", press: func(num = 0, amount = 1) {var cNav = getprop("/instrumentation/nav[" ~ num ~ "]/radials/selected-deg"); if (cNav == nil) {cNav = 0;} setprop("/instrumentation/nav/radials/selected-deg", ( (cNav+amount) < 360 ) ? (cNav+amount) : (cNav+amount-360) );   return 1;}, release: func() {} },
			"radio_nav/btn_crs_down":{btnType: "biased", press: func(num = 0, amount = 1) {var cNav = getprop("/instrumentation/nav[" ~ num ~ "]/radials/selected-deg"); if (cNav == nil) {cNav = 0;} setprop("/instrumentation/nav/radials/selected-deg", ( (cNav-amount) >= 0  ) ? (cNav-amount) : (cNav-amount+360) );   return 1;}, release: func() {} }
		}
	}
};
