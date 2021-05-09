# This file contains data allowing an input device to
# access in a standard way the autopilot KAP140 
# in the Cessna 172.
# It is processed by input_adapter.nas

var instr_ap_kap140 = {
	"ap/kap140": {
		parents: [instr_ap_generic["ap/generic"]],
		existenceTester: func(num=0) {return input_helpers.propPathExists("/autopilot/KAP140/annunciators/vs-number"); }, # settings/target-pressure-rate-fpm-fmt") != nil );  # Todo: target-pressure-rate-fpm is only available in c172p as it is defined in Aircraft/c172p/Systems/KAP140.xml which is included by c172p-set.xml
		functions: {"ap": 10}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			# binary, LEDs annunciators etc.
			"ap/led_ap":  {
				propGetter: func() {
					return [    
						"/autopilot/KAP140/annunciators/ap/state", 
						"/autopilot/KAP140/locks/alt-hold", 
						"/autopilot/KAP140/locks/apr-hold", 
						"/autopilot/KAP140/locks/gs-hold", 
						"/autopilot/KAP140/locks/hdg-hold", 
					    "/autopilot/KAP140/locks/nav-hold", 
					    "/autopilot/KAP140/locks/pitch-axis", 
   					    "/autopilot/KAP140/locks/rev-hold", 
					    "/autopilot/KAP140/locks/roll-axis"];
				},
				getValue: func() {
					# if there is one lock active, show ap led on.
					# if ap led ist blinking (because it is switching off), keep blinking
					var running = 0;
					var status = 0;
					var props_ = getInstrumentPropForName("ap/led_ap", "propGetter", " ")(); # returns the vector given in propGetter TODO direct access to propGetter function like me.propGetter(); (I do not know how)
					for (var i=1; i<size(props_); i += 1) {
						status = getprop(props_[i]);
						if ( (status == nil) or (status == "") or (status == "false") or (status == 0) ) continue;
						if (status != 0) { running = 1; break; }
					}
					blinking = getprop(props_[0]);
					if ( (blinking != nil) and (blinking != 0) )
						{ return 1; } 
					return running;
				}
			},
			"ap/led_hdg":     ["/autopilot/KAP140/annunciators/hdg/state"], # state: false=ROL, true=HDG, you cannot disable entirely roll control in the KAP140
			"ap/led_nav":     ["/autopilot/KAP140/annunciators/nav"],
			"ap/led_alt-arm": ["/autopilot/KAP140/annunciators/alt-arm"], 
			"ap/led_alt":     ["/autopilot/KAP140/annunciators/alt"], 
			"ap/led_vs":      ["/autopilot/KAP140/annunciators/vs"],  
			"ap/led_apr":     ["/autopilot/KAP140/annunciators/apr"], 
			"ap/led_rev":     ["/autopilot/KAP140/annunciators/rev"],
			# numbers
			"ap/target_alt_ft": {
				propGetter: func() {
					return [
						"/autopilot/KAP140/settings/target-alt-ft",
						# "/autopilot/KAP140/settings/target-pressure-rate-fpm-fmt",
						"/autopilot/KAP140/annunciators/alt-number"
						];
				},
				getValue: func() {
				# kap140 has only 1 line to display a number - so it displays either the armed alt or target-vs.
					if (getprop("/autopilot/KAP140/annunciators/alt-number") ) {
						var ret = getprop("/autopilot/KAP140/settings/target-alt-ft");
#						print("ap/target_alt_ft, target-alt-ft: " ~ debug.string(ret));
						return ret;
					} else {
						return nil;
					}
				},
				formatGetter: func(num) {return "R%5i" }
			},
			"ap/target_vs_fpm": {
				propGetter: func() {
					return [ "/autopilot/KAP140/settings/target-pressure-rate-fpm", # without "-fmt" changes very fast in ALT mode
					"/autopilot/KAP140/annunciators/vs-number"]
				},
				getValue: func() {
				# kap140 has only 1 line to display a number - so it displays either the armed alt or target-vs.
					if (getprop("/autopilot/KAP140/annunciators/vs-number") ) { # convert pressure rate to fpm = pressure_rate*-58000 see Aircraft/c172p/Systems/KAP140.xml
						var ret = getprop("/autopilot/KAP140/settings/target-pressure-rate-fpm");
							# only without -fmt relevant: if ( (ret >= -1) and (ret < 1) ) { return nil; } # see Aircraft/c172p/Models/Interior/Panel/Instruments/kap140/KAP140TwoAxisAlt.xml
						return ret;
					} else {
						return nil;
					}
				},
				formatGetter: func(num) {return "R%5i"; }
			},
			"ap/baro": {
				propGetter: func() {
					return [ "/autopilot/KAP140/annunciators/bs-inhg-number", "/autopilot/KAP140/settings/baro-setting-inhg",
					         "/autopilot/KAP140/annunciators/bs-hpa-number" , "/autopilot/KAP140/settings/baro-setting-hpa"]
				},
				getValue: func() {
				# kap140 has only 1 line to display a number - so it displays either the armed alt or target-vs or the baro setting.
					if (getprop("/autopilot/KAP140/annunciators/bs-inhg-number") ) { # showing the baro setting in inhg
						var ret = getprop("/autopilot/KAP140/settings/baro-setting-inhg");
						return ret;
					}
					if (getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) { # showing the baro setting in hpa
						var ret = getprop("/autopilot/KAP140/settings/baro-setting-hpa") * 1000;
						return ret;
					}
					return nil; # baro setting is not shown at the moment
				},
				formatGetter: func(num) {
					if (getprop("/autopilot/KAP140/annunciators/bs-inhg-number") )
					{     return "R%2.2f"; } # showing the baro setting in inhg
					else {return "R%5u";} # showing the baro setting in hpa
				}
			},		

			# "ap/target_hdg":    inherited from ap_generic
			"ap/target_ias":    {propGetter: func() {return ["/instrumentation/airspeed-indicator/indicated-speed-kt"];}, formatGetter: func(num) {return "R%3u";} }, # kap140 cannot controll speed, so display the current ias instead
			# "ap/target_nav":    inherited from ap_generic
		},
		actions: {
			# push-buttons
			"ap/btn_on_off": {aniProp: "/instrumentation/ap-btn",   btnType: "biased", press: func() {kap140.apButton();  return 1;}, release: func() {return 1;} },
			"ap/btn_hdg":    {aniProp: "/instrumentation/hdg-btn",  btnType: "biased", press: func() {kap140.hdgButton(); return 1;}, release: func() {return 1;} },
			"ap/btn_nav":    {aniProp: "/instrumentation/nav-btn",  btnType: "biased", press: func() {kap140.navButton(); return 1;}, release: func() {return 1;} },
#			"ap/btn_ias":    {aniProp: "/instrumentation/ias-btn",  btnType: "biased", press: func() {kap140.apButton();  return 0;}, release: func() {return 1;} },
			"ap/btn_alt":    {aniProp: "/instrumentation/alt-btn",  btnType: "biased", press: func() {kap140.altButton(); return 1;}, release: func() {return 1;} },
#			"ap/btn_vs":     {aniProp: "/instrumentation/vs-btn",   btnType: "biased", press: func() {kap140.vsButton();  return 0;}, release: func() {return 1;} },
			"ap/btn_apr":    {aniProp: "/instrumentation/apr-btn",  btnType: "biased", press: func() {kap140.aprButton(); return 1;}, release: func() {return 1;} },
			"ap/btn_rev":    {aniProp: "/instrumentation/rev-btn",  btnType: "biased", press: func() {kap140.revButton(); return 1;}, release: func() {return 1;} },
			"ap/btn_alt-arm":{aniProp: "/instrumentation/arm-btn",  btnType: "biased", press: func() {kap140.armButton(); return 1;}, release: func() {return 1;} },
			"ap/btn_baro":	 {aniProp: "/instrumentation/baro-btn", btnType: "biased", press: func() {kap140.baroButtonPress(); return 1;}, release: func() {kap140.baroButtonRelease(); return 1;} },
			# knob turns / adjust buttons
			"ap/btn_vs_up"  :{ # Todo for saitek multi panel: interpolate(property-to-adjust, target-value, time-to-get-there-in-seconds)
				aniProp: "/instrumentation/up-btn",  
				btnType: "biased", 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/vs") ) {
						kap140.upButton();
						return 1; # 1 = true: animate the button
					} else {
						print("WARNING: input_adapter: >ap/btn_vs_up< only possible in vs mode on autopilot KAP140");
						return 0; # 0 = false: do not animate the button
					};
				}, release: func() {} 
			},
			"ap/btn_vs_down":{aniProp: "/instrumentation/dn-btn", btnType: "biased", 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/vs") ) {
						kap140.downButton();
						return 1;
					} else {
						print("WARNING: input_adapter: >ap/btn_vs_down< only possible in vs mode on autopilot KAP140");
						return 0;
					};
				}, release: func() {} 
			},
			"ap/btn_alt-up"  :{
				aniProp: "/instrumentation/up-btn", 
				btnType: "biased", 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/alt") ) {
						kap140.upButton();
						return 1;
					} else {
						print("WARNING: input_adapter: >ap/btn_alt-up< only possible in alt mode on autopilot KAP140");
						return 0;
					};
				}, release: func() {} 
			},
			"ap/btn_alt-down":{
				aniProp: "/instrumentation/dn-btn", 
				btnType: "biased", 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/alt") ) {
						kap140.downButton();
						return 1;
					} else {
						print("WARNING: input_adapter: >ap/btn_alt-down< only possible in alt mode on autopilot KAP140"); # Todo: as gui.popupTip()?
						return 0;
					};
				}, release: func() {} 
			},
			"ap/btn_alt-arm-up":  {
				btnType: "biased", 
				aniProp: "/autopilot/KAP140/settings/dial-10-ft", 
				aniStep: 3, 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") or getprop("/autopilot/KAP140/annunciators/vs-number") ) {
						print("WARNUNG: input_adapter: >ap/btn_alt-arm-up< not possible in the autopilot KAP140 if the baro or vertical speed setting is displayed, because the same knob is used for that");
						return 0;
					} else {
						kap140.knobSmallUp();   
						return 1;
					}
				}, 
				release: func() {} 
			},
			"ap/btn_alt-arm-down":  {
				btnType: "biased", 
				aniProp: "/autopilot/KAP140/settings/dial-10-ft", 
				aniStep:  -3, 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") or getprop("/autopilot/KAP140/annunciators/vs-number") ) {
						print("WARNUNG: input_adapter: >ap/btn_alt-arm-down< not possible in the autopilot KAP140 if the baro or vertical speed setting is displayed, because the same knob is used for that");
						return 0;
					} else {
						kap140.knobSmallDown();   
						return 1;
					}
				}, 
				release: func() {} 
			},
			"ap/btn_baro_up"  :{ # Todo for saitek multi panel: interpolate(property-to-adjust, target-value, time-to-get-there-in-seconds)
				btnType: "biased", 
				aniProp: "/autopilot/KAP140/settings/dial-10-ft",  
				aniStep:  3, 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
						kap140.knobSmallUp();   
						return 1; # 1 = true: animate the button
					} else {
						print("WARNING: input_adapter: >ap/btn_vs_up< only possible in vs mode on autopilot KAP140");
						return 0; # 0 = false: do not animate the button
					};
				}, release: func() {} 
			},
			"ap/btn_baro_down":{
				aniProp: "/autopilot/KAP140/settings/dial-10-ft",  
				btnType: "biased", 
				aniStep:  -3, 
				press: func() {
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
						kap140.knobSmallDown();
						return 1;
					} else {
						print("WARNING: input_adapter: >ap/btn_vs_down< only possible in vs mode on autopilot KAP140");
						return 0;
					};
				}, release: func() {} 
			}
#			"ap/btn_ias_up"  :{aniProp: "/autopilot/KAP140/settings/dial-10-ft", aniStep:  3, btnType: "biased", press: func() {kap140.knobSmallUp();   return 1;}, release: func() {} },
#			"ap/btn_ias_down":{aniProp: "/autopilot/KAP140/settings/dial-10-ft", aniStep: -3, btnType: "biased", press: func() {kap140.knobSmallDown(); return 1;}, release: func() {} },
		}
	}
};

# It is better to use the property, if available, then functions like these:
#var apButtonOnOff = func() {

	# logical function
 #     	kap140.apButton(); 
	# sound
	# c172p.click("kap140")</script>
	# animation
      propertyToggle("/instrumentation/ap-btn");
#};

# assuming biased push-button
#var apButtonRev = func() {
	# logical function
#	kap140.revButton();
	# sound
#	c172p.click("kap140");
	# animation on the screen
#};
