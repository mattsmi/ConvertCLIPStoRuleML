;Output RuleML from CLIPS.
;
;;;   Execute this script by: 
;      (batch* "xConvertToRuleML.clp") 
; or 
;      (eval "(batch* \"xConvertToRuleML.clp\")") 
;.


(deffunction printFactSlots
    (?fName)
    ;This fact finds a fact in the list of facts with a given name.
    ;   It prints the name of the fact and then all slots and values.
   
    (progn$ (?f (get-fact-list))
        (if (eq (fact-relation ?f) ?fName) then
            ;print the name of the fact
            (printout t (fact-relation ?f) " -- " crlf)
            (progn$ (?s (fact-slot-names ?f))
                ;Print out the slot names and their values
                (printout t "   " ?s ": " (fact-slot-value ?f ?s) crlf)
            )
            (printout t crlf)
        )
    )
    
    TRUE
)
(deffunction convRuleMLfacts

    ()
   
    ;This function is executed as: (convRuleMLfacts)
   
    (progn$ (?f (get-fact-list)) 
        (printout outFile "<Atom>" crlf)
        (printout outFile "<opr><Rel>" (fact-relation ?f) "</Rel></opr>" crlf)
        (progn$ (?s (fact-slot-names ?f))
            (if (multifieldp ?s) then
                ;if I multi-slot, should become a Plex
                (printout outFile "<slot><Ind>" ?s "</Ind>" crlf)
                (printout outFile "  <Plex>" crlf)
                (progn$ (?mField (fact-slot-value ?f ?s))
                    (if (numberp ?mField) then
                        (printout outFile "      <Var>" ?mField "</Var>" crlf)
                    else
                        (printout outFile "      <Var>\"" ?mField "\"</Var>" crlf)
                    )
                )
                (printout outFile "  </Plex></slot>" crlf)
            else
                (if (eq (fact-slot-value ?f ?s) nil) then
                    ;Check for a nil value and output an empty field
                    (printout outFile "<slot><Ind>" ?s "</Ind><Ind /></slot>" crlf)
                else
                    (if (numberp (fact-slot-value ?f ?s)) then
                        ;if the value is numberic, then we don't need to surround it with double quotation marks.
                        (printout outFile "<slot><Ind>" ?s "</Ind><Ind>" (fact-slot-value ?f ?s) "</Ind></slot>" crlf)
                    else
                        (printout outFile "<slot><Ind>" ?s "</Ind><Ind>\"" (fact-slot-value ?f ?s) "\"</Ind></slot>" crlf)
                    )
                )
            )
        )
        (printout outFile "</Atom>" crlf)
    )
   
    TRUE
)
(deffunction convRuleMLglobals
 
    ()
    
    ;This function is executed as: (convRuleMLglobals)
    
    
    ;Write out the rule for assigning values to Global Variables.
    ;   From:
    (printout outFile "<Rule kind=\"conca\" ...>  <!--  conclusion-action rule> -->" crlf)
    (printout outFile "  <then>" crlf)
    (printout outFile "    <Atom>" crlf)
    (printout outFile "      <Rel per=\"effect\">assign</Rel>" crlf)
    (printout outFile "      <oid><Var>name</Var></oid>" crlf)
    (printout outFile "      <Var>newvalue</Var>" crlf)
    (printout outFile "    </Atom>" crlf)
    (printout outFile "  </then>" crlf)
    (printout outFile "  <do>" crlf)
    (printout outFile "    <And order=\"sequential\">" crlf)
    (printout outFile "      <Atom>" crlf)
    (printout outFile "        <Rel per=\"effect\" iri=\"rulemlb:retract\"/>" crlf)
    (printout outFile "        <Atom>" crlf)
    (printout outFile "          <oid><Var>name</Var></oid>" crlf)
    (printout outFile "          <Var>oldvalue</Var>" crlf)
    (printout outFile "        </Atom>" crlf)
    (printout outFile "      </Atom>" crlf)
    (printout outFile "      <Atom>" crlf)
    (printout outFile "        <Rel per=\"effect\" iri=\"rulemlb:assert\"/>" crlf)
    (printout outFile "        <Atom>" crlf)
    (printout outFile "          <oid><Var>name</Var></oid>" crlf)
    (printout outFile "          <Var>newvalue</Var>" crlf)
    (printout outFile "        </Atom>" crlf)
    (printout outFile "      </Atom>" crlf)
    (printout outFile "    </And>" crlf)
    (printout outFile "  </do>" crlf)
    (printout outFile "</Rule>" crlf)
    (printout outFile crlf)
    
    ;Now write out the Atom for each global variable
    (progn$ (?field (get-defglobal-list))
        (printout outFile "<Atom>" crlf)
        (printout outFile "  <Rel per=\"effect\">assign</Rel>" crlf)
        (printout outFile "  <oid><Ind>" ?field "</Ind></oid>" crlf)
        
        (if (multifieldp (eval (sym-cat "?*" ?field "*"))) then
            ;if I multi-slot, should become a Plex
            (printout outFile "  <Plex>" crlf)
            (progn$ (?mField (eval (sym-cat "?*" ?field "*")))
                (if (numberp ?mField) then
                    (printout outFile "      <Var>" ?mField "</Var>" crlf)
                else
                    (printout outFile "      <Var>\"" ?mField "\"</Var>" crlf)
                )
            )
            (printout outFile "  </Plex>" crlf)
        else
            (if (eq (eval (sym-cat "?*" ?field "*")) nil) then
                ;Check for a nil value and output an empty field
                (printout outFile "  <Ind />" crlf)
            else
                (if (numberp (eval (sym-cat "?*" ?field "*"))) then
                    ;if the value is numberic, then we don't need to surround it with double quotation marks.
                    (printout outFile "  <Ind>" (eval (sym-cat "?*" ?field "*")) "</Ind>" crlf)
                else
                    (printout outFile "  <Ind>\"" (eval (sym-cat "?*" ?field "*")) "\"</Ind>" crlf)
                )
            )
        )
        
        (printout outFile "</Atom>" crlf)
    )
    (printout outFile crlf)

    TRUE
)


;;;***Execution starts here.
(build "(defglobal ?*sFileName* = (str-cat \"outRuleML\" (random) \".txt\"))")
;Open file for output
(open ?*sFileName* outFile "w")

(printout outFile "<RuleML xmlns=\"http://ruleml.org/spec\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" " crlf)
(printout outFile "   xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " crlf)
(printout outFile "   xsi:schemaLocation=\"http://ruleml.org/spec " crlf)
(printout outFile "   http://deliberation.ruleml.org/1.01/xsd/folog.xsd\">" crlf)

;Convert global variables
(convRuleMLglobals)

;Convert facts
(convRuleMLfacts)

;Finalise file and close output
(printout outFile "</RuleML>" crlf)
(close outFile)


