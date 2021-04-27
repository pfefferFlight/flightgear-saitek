# This file contains data allowing an input device to
# access in a standard way the generic autopilot.
# It is processed by input_adapter.nas


var instr_ap_generic = {
	"ap/generic": {
		parents: [],
		existenceTester: func(num=0) {return ( getprop("/autopilot/settings/heading-bug-deg") != nil ); }, 
		functions: {"ap": 0}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			# LEDs
			"ap/led_rev":    {propGetter: func(num=0) {return ["/instrumentation/nav[" ~ num ~ "]/back-course-btn"]; }, formatGetter: func(num) {return "R%3u";} }, # Todo: move this to vor/radio-nav?
			
			# numbers
			"ap/target_hdg":    {propGetter: func() {return ["/autopilot/settings/heading-bug-deg"];                         }, formatGetter: func(num) {return "R%3u";} },
			"ap/target_ias":    {propGetter: func() {return ["/autopilot/settings/target-speed-kt"];                         }, formatGetter: func(num) {return "R%3u";} }, 
			"ap/target_nav":    {propGetter: func(num=0) {return ["/instrumentation/nav[" ~ num ~ "]/radials/selected-deg"]; }, formatGetter: func(num) {return "R%3u";} }, # Todo: move this to vor/radio-nav?
			"ap/target_vs_fpm" :    {propGetter: func() {return ["/autopilot/settings/vertical-speed-fpm"];                      }, formatGetter: func(num) {return "R%5i";} }
		},
		actions: {
			"ap/btn_ias_up":   { btnType: "biased", press: func() {setprop("/autopilot/settings/target-speed-kt",             getprop("/autopilot/settings/target-speed-kt") + 1);  return 1;}, release: func() {return 1;} },
			"ap/btn_ias_down": { btnType: "biased", press: func() {setprop("/autopilot/settings/target-speed-kt", math.max(0, getprop("/autopilot/settings/target-speed-kt") - 1));  return 1;}, release: func() {return 1;} },
			"ap/btn_vs_up":    { btnType: "biased", press: func() {setprop("/autopilot/settings/vertical-speed-fpm",          getprop("/autopilot/settings/vertical-speed-fpm") + 100);  return 1;}, release: func() {return 1;} },
			"ap/btn_vs_down":  { btnType: "biased", press: func() {setprop("/autopilot/settings/vertical-speed-fpm",          getprop("/autopilot/settings/vertical-speed-fpm") - 100);  return 1;}, release: func() {return 1;} },
			"ap/btn_rev":      { btnType: "biased", press: func(num) {propertyToggle("/instrumentation/nav[" ~ num ~ "]/back-course-btn"); return 1;}, release: func() {return 1;} }, # Todo: move this to radio-nav?
		}
	}
};
