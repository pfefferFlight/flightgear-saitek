# This file contains data allowing an input device to
# access the generic adf radio in a standard way.
# It is processed by input_adapter.nas

var instr_radio_adf_generic = {
	"radio_adf/generic": {
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/adf[" ~num~ "]/frequencies/selected-khz")) != nil ); },
		functions: {"radio_adf": 0}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_adf/freq_active":     {propGetter: func(number = 0) {return ["/instrumentation/adf[" ~number~ "]/frequencies/selected-khz"];   }, formatGetter: func(num) {return "L%5.0f"; }},
			"radio_adf/freq_standby":    {propGetter: func(number = 0) {return ["/instrumentation/adf[" ~number~ "]/frequencies/standby-khz"];    }, formatGetter: func(num) {return "L%5.0f"; }},
			},
		actions: {
			"radio_adf/btn_swap": {
				btnType: "biased", press: func(num = 0) {
					swapProps("/instrumentation/adf[" ~num ~ "]/frequencies/standby-khz", "/instrumentation/adf[" ~num ~ "]/frequencies/selected-khz");
					return 1;
				}, release: func() {return 1;}, 
				aniProp: func(num = 0) { return "/instrumentation/adf[" ~ num ~ "]/frq-btn"}
			},
			"radio_adf/freq_standby_btn_adjust_small": {
				btnType: "biased", press: func(num = 0, amount = 1) {
					var cFreq = getValueForName("radio_adf/freq_standby", num); 
					var newFreq = adfFreqAdjust(cFreq, amount, 1);
					setprop("/instrumentation/adf[" ~num ~ "]/frequencies/standby-khz", newFreq);
					return 1;
				}, release: func() {}, 
				aniProp: func(num) { return "/instrumentation/adf[" ~ num ~ "]/frequencies/dial-1-khz";}, 
				aniStep:  4
			},
			"radio_adf/freq_standby_btn_adjust_large": {
				btnType: "biased", press: func(num = 0, amount = 1) {
					var cFreq = getValueForName("radio_adf/freq_standby", num); 
					var newFreq = adfFreqAdjust(cFreq, amount, 0);
					setprop("/instrumentation/adf[" ~num ~ "]/frequencies/standby-khz", newFreq);
					return 1;
				}, release: func() {}, 
				aniProp: func(num) { return "/instrumentation/adf[" ~ num ~ "]/frequencies/dial-100-khz";}, 
				aniStep:  4
			},
		}
	}
};

