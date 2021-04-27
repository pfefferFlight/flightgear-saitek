# This file contains data allowing an input device to
# access in a standard way the generic communication radio.
# It is processed by input_adapter.nas

var instr_radio_comm_generic = {
	"radio_comm/generic": {
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/comm[" ~ num ~ "]/frequencies/standby-mhz")) != nil ); },
		functions: {"radio_comm": 0}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_comm/freq_active":    {propGetter: func(number = 0) {return ["/instrumentation/comm[" ~number ~ "]/frequencies/selected-mhz-fmt"]; }, formatGetter: func(num) {return "L%s";}},
			"radio_comm/freq_standby":   {propGetter: func(number = 0) {return ["/instrumentation/comm[" ~number ~ "]/frequencies/standby-mhz-fmt"];  }, formatGetter: func(num) {return "L%s";}}
		}, actions: {
			"radio_comm/btn_swap": {
				btnType: "biased", 
				press: func(num = 0) {
					swapProps("/instrumentation/comm[" ~num ~ "]/frequencies/standby-mhz", "/instrumentation/comm[" ~num ~ "]/frequencies/selected-mhz");
					return 1;
				}, 
				release: func() {return 1;}
			},
			"radio_comm/freq_standby_btn_adjust_small": {
				btnType: "biased", 
				press: func(num = 0, amount = 1) {
					commFreqAdjust(pathToInstrument: "/instrumentation/comm[" ~ num ~ "]", amount: amount, small: 1, smallChannelSpacing: 1, wrapKhz: 1, adjustActiveFreq: 0);
				}, 
				release: func() {}
			},
			"radio_comm/freq_standby_btn_adjust_large": {
				btnType: "biased", 
				press: func(num = 0, amount = 1) {
					commFreqAdjust(pathToInstrument: "/instrumentation/comm[" ~ num ~ "]", amount: amount, small: 0, adjustActiveFreq: 0);
				}, 
				release: func() {}
			}
		}
	}
};
