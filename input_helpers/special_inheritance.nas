############################################################################
# Special inheritance
#
# The function getMember provides a special type of self-made inheritance:
# If a leave does not exist, it will be searched in the parents
# so that you can override a leave in a branch while keeping all other leaves
# in that branch inherited.
# (Normal inheritance would hide the parent's leaves if a branch gets 
# overwritten by a child.)
############################################################################


##########################
# getMember
##########################

# Get the member of an hash.
# member must be a vector.
# Gets only direct members of the hash
# (ignoring parents).
# Returns nil if the member does not exist.
# It does nothing more than chaining "[]" without throwing nasal 
# error if some element is nil/does not exist.
var getMemberDirect = func(whichMember, hash) {
# print("getMemberDirect");
# debug.dump(whichMember);
	var ret = nil;
	foreach (memb; whichMember) {
			if (typeof (hash[memb]) != nil) {
				if (ret == nil) {ret = hash[memb]; } # only true in the first circle
				else {
					if (typeof(ret) != "hash") {return nil; } # deeper property requested as available
					ret = ret[memb];  
				}
				# ret.append(memb);
				continue;
			}
			return nil;
	}
	return ret;
};

# var breakp = debug.Breakpoint.new("myLabel", 1);
# breakp.enable(00);

# Get the member of a hash.
# member must be a vector.
# Gets also members of parents if no member in the actual hash is found.
# Returns the more specialized member if there are several in different levels of parents.
# The parents in the same level are searched in the order of their vector.
# Returns nil, if no member found.
# This function is similar to "." bit it does keep all sub members of parents, replacing only
# the overwritten ones.
var getMember = func(whichMember, hash) {
	var direct = getMemberDirect(whichMember, hash);
	if (direct != nil) { return direct;}
	# look in the parents fields stepwise up the tree
	     # var sizeWhichMember = size(whichMember);
	var lookfor = [] ~ whichMember; # copy the vector
#	breakp.hit();
#	print("size whichmember: " ~ debug.string(whichMember));
	for (var j=size(whichMember)-1; j >= 0; j -=1) {
		lookfor[j] = "parents";
		setsize(lookfor, j+1);
#		print("durchlauf: " ~ j);
#		breakp.hit();
#		print("lookfor:" ~ debug.string(lookfor));
		parens = getMemberDirect(lookfor, hash);
		if (parens == nil) { 
			# no parents field --> go one step up the tree
			continue; 
		}
		# parents field is there
		foreach (p; parens) {
#			print("p: " ~ debug.string(p));
			ret = getMember(subvec(whichMember, j, 10000), p);
			if (ret != nil) {return ret; }
		}
	}
	return nil;
};
################
# Tests
################

# print("1");
# var gmd = getMemberDirect(["radio_comm/generic", "actions", "radio_comm/btn_swap", "btnType"], instr_radio_comm_generic);
# print("gmd:");
# debug.dump(gmd); # "biased"

# print("2");
# var gm = getMember(["radio_comm/generic", "actions", "radio_comm/btn_swap", "btnType"], instr_radio_comm_generic);
# print("gm:");
# debug.dump(gm); # "biased"

# print("3");
# var gm = getMember(["radio/kx165a", "actions", "radio_comm/btn_swap", "btnType"], instr_radio_kx165a);
# print("gm:");
# debug.dump(gm); # "biased"

# print("4");
# var gm = getMember(["radio/kx165a", "actions", "radio_comm/btn_swap", "aniProp"], instr_radio_kx165a);
# print("gm:");
# debug.dump(gm()); # "kx165a XXXXXXXXXXXXX /instrumentation/comm[" ~ num ~ "]/frq-swap-btn"

# print("5");
# var gm = getMember(["radio_comm/generic", "actions", "radio_comm/btn_swap", "aniProp"], instrumentsProps);
# print("gm:");
# debug.dump(gm);  # nil

# print("6");
# var gm = getMember(["radio/kx165a", "actions", "radio_comm/btn_swap", "aniProp"], instrumentsProps);
# print("gm:");
# debug.dump(gm());  # "kx165a XXXXXXXXXXXXX /instrumentation/comm[" ~ num ~ "]/frq-swap-btn"



##########################
# IteratorInheritance
# Allows enumeration of the first level of branches
# for the special inheritance
##########################

print ("");
print ("");
print ("");
print ("");
print ("");
print ("");
print ("");
print ("");
print ("");
var IteratorInheritance = {
	new: func(hash_) {
		return {
			parents: [IteratorInheritance],	
			hash:  hash_,
			keys_: keys(hash_),
			i:     -1,	
			pIt:   nil, 
			p_i:   -1
		};
	},

	getNext: func() {
#	print("Begin------");
		# iterate through the current parent
	#	debug.backtrace(1);
		if (me.pIt != nil) {
#			print("me.pIt != nil");
			var ret = me.pIt.getNext();
			if (ret != nil) {
				return ret;
			}
		}
		# in parents?
		if (me.p_i >= 0) {
#			print("me.p_i >=0");
			# are there more parents?
#			print("hash:");
#			debug.dump(me.hash);
			if ((me.p_i +1 )< size(me.hash["parents"]) ) {
				me.p_i += 1;
				var tmp = me.hash["parents"][me.p_i];
				me.pIt = IteratorInheritance.new(tmp);
				var ret = me.pIt.getNext();
				if (ret != nil) {
					return ret;
				}
			} else {
				# nor more parents
				me.pIt = nil;
				me.p_i = -1;
			}
		}
		me.i += 1;
		if (me.i < size(me.keys_)) {
			if (me.keys_[me.i] == "parents") {
#				print("me.keys_[me.i] == parents");
				me.p_i = 0;
				var tmp = me.hash["parents"][me.p_i];
#				print("tmp:");
#				debug.dump(tmp);
				me.pIt = IteratorInheritance.new(tmp);
#				print("child:");
#				debug.dump(me.pIt);
				var ret = me.pIt.getNext();
				if (ret != nil) {
					return ret;
				} else {
					return me.getNext();
				}
			}
#			print("direkt");
			return {key: me.keys_[me.i], value: me.hash[me.keys_[me.i]]};
		}
		return nil;
	}
};
############
# IteratorInheritance Tests
############


var iteratorTest1 = {a: "1", b: "2"};
var test1 = IteratorInheritance.new(iteratorTest1);
debug.dump(test1.getNext()); # a
debug.dump(test1.getNext()); # b
debug.dump(test1.getNext()); # nil

print("");
print("TEST 2:");
var iteratorTest2 = {parents: [iteratorTest1], c: "1", d: "2"};
var test2 = IteratorInheritance.new(iteratorTest2);
for(var i = test2.getNext(); i != nil; i = test2.getNext()) {
  debug.dump(i);
}
# excepted result (the order is arbitrary):
# { key: 'd', value: 2 }
# { key: 'a', value: 1 }
# { key: 'b', value: 2 }
# { key: 'c', value: 1 }


print("");
print("TEST 3:");
var iteratorTest3 = {parents: [iteratorTest1, iteratorTest2]};
var test3 = IteratorInheritance.new(iteratorTest3);
for(var i = test3.getNext(); i != nil; i = test3.getNext()) {
  debug.dump(i);
}
# excepted result (the order is arbitrary):
# { key: 'd', value: 2 }
# { key: 'a', value: 1 }
# { key: 'b', value: 2 }
# { key: 'c', value: 1 }

