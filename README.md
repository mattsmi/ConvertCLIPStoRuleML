# Convert CLIPS Facts and Global Variables to RuleML

This is a CLIPS script, which calls two CLIPS functions to convert CLIPS Global Variables and CLIPS Facts respectively to RuleML.

It assumes that the CLIPS Facts are supported by a `deftemplate` construct — i.e. a template for non-ordered facts.

Execute the script once there are facts or global variables in CLIPS memory, by: 
 `(eval "(batch* \"xConvertToRuleML.clp\")")` .
