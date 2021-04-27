# This file contains data allowing an input device to
# access in a standard way the ADF radio kr87 that is 
# installed e.g. in the Cessna 172.
# It is processed by input_adapter.nas


var instr_radio_adf_kr87 = {
	"radio_adf/kr85": {
		parents: [instr_radio_adf_generic["radio_adf/generic"]], 
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/adf[" ~ num ~ "]/frequencies/dial-1-khz")) != nil ); },
		functions: {"radio_adf": 10}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		actions: {
			"radio_adf/btn_swap": {
				aniProp: func(num = 0) { return "/instrumentation/adf[" ~ num ~ "]/frq-btn"}
			},
			"radio_adf/freq_standby_btn_adjust_small": {
				aniProp: func(num) { return "/instrumentation/adf[" ~ num ~ "]/frequencies/dial-1-khz";}, 
				aniStep:  4
			},
			"radio_adf/freq_standby_btn_adjust_large": {
				aniProp: func(num) { return "/instrumentation/adf[" ~ num ~ "]/frequencies/dial-100-khz";}, 
				aniStep:  4
			},
		}
	}
};
