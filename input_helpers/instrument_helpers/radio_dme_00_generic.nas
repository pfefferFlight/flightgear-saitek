# This file contains data allowing an input device to
# access in a standard way the generic DME radio.
# It is processed by input_adapter.nas

var instr_radio_dme_generic = {
	"radio_dme/generic": {
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/dme[" ~ num ~ "]/frequencies/selected-mhz")) != nil ); },
		functions: {"radio_dme": 0}, # number is the priority: if several instruments that provide the same function seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			"radio_dme/freq":            {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/frequencies/selected-mhz"]; }, formatGetter: func(num) {return "R%s" } }, # Todo: test the format
			"radio_dme/in_range":        {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/in-range"];                 }, formatGetter: func(num) {return "R%s" } }, # Todo: test the format
#			"radio/dme_ident":           {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/ident"];                    }, formatGetter: func(num) {return "R%s" } }, # Todo: test the format # I think, DMEs do not have a "ident" function
			"radio_dme/speed_kts":       {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/KDI572-574/kt"];}, formatGetter: func(num) {return "R%s" } }, # astonishingly the KDI572-574/ is part of the generic dme.cxx code
			"radio_dme/time_min":        {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/KDI572-574/min"];       }, formatGetter: func(num) {return "R%s" } },
			"radio_dme/dist_nm":	     {propGetter: func(number = 0) {return ["/instrumentation/dme[" ~number~ "]/KDI572-574/nm"];    }, formatGetter: func(num) {return "R%s" } }
		}
		# Todo: add action: frequency selector (NAV1, NAV2, HOLD)
	}
};
