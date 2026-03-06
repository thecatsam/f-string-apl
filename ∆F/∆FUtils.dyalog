:Namespace ⍙FUtils   
⍝   ⍝ [*] Dyalog ≥20 Version!
:Section CORE 
⍝ Sys vars for ∆F code. Remember, user code is executed in CALLER space (⊃⎕RSI) 
  ⎕IO ⎕ML ⎕PP← 0 1 34     
⍝ Bringin "global" vars set via loader (∆F.dyalog)...
  ⎕THIS ⎕NS ⎕SE.⍙FGlobals       
⍝ Set char. rendering of ⎕THIS. We can set ⎕THIS.⎕DF later, but ∆THIS will remain as is. 
  ∆THIS← ⍕⎕THIS                

   :Section      ∆F SOURCE
⍝ =======================================================================
⍝ ∆F USER FUNCTION Source - See ⍙Export_∆F
⍝ =======================================================================
⍝ ∆FSrc:  ==>  ##.∆F
⍝    modified to become ##.∆F at ⍙Export_∆F.
⍝ ∆F: 
⍝    result← {opts←⍬} ∇ f-string [args]
⍝ See notes elsewhere on ∆F itself.
⍝ 
⍝ NB. Modify header names or constants __THIS__ or __OUTER__ at your peril.
⍝ 
  ∇ result← {opts} ∆FSrc args 
    :Trap __TRAP_ERRORS__
      :With __THIS__                                          
      ⍝ Phase I: Set options!  Be sure to copy OPTS_DEFns and change ONLY the copy.
      ⍝ Default options              
        :If  900⌶0                                          
            opts← ⎕NS OPTS_DEFns                     
        :ElseIf 9=__OUTER__.⎕NC 'opts'    
            opts← ⎕NS OPTS_DEFns __OUTER__.opts                  ⍝ v19: Emulate v.20 ⎕NS
      ⍝ Positional options-- integers/booleans         
        :ElseIf 11 83∊⍨ ⎕DR opts ⋄ :AndIf  OPTS_N≥ ≢opts 
            opts← (⎕NS OPTS_DEFns) ⎕VSET (OPTS_KW↑⍨≢opts)opts    ⍝ v19: Emulate ⎕VSET
      ⍝ Special options (like help and invalid options)
        :Else                                           
            result← Special opts ⋄ :Return                     
        :EndIf 
      ⍝ Phase II: Execute!
        args← ,⊆args                
      ⍝ Determine output mode based on opts.dfn and execute.
        :Select opts.dfn  
      ⍝ 0: Execute F-string    
        :Case  0        
            result← opts ((⊃⎕RSI){ ⍺⍺⍎ ⍺ ScanFStr ⊃⍵⊣ ⎕EX 'opts' 'args'}) args    
      ⍝ 1: Generate dfn code 
        :Case  1       
            result← (⊃⎕RSI)⍎ opts ScanFStr ⊃args
      ⍝ ¯1: Generate source code for dfn
        :Case ¯1                                    
            result← opts ScanFStr ⊃args  
      ⍝ Else: Run help or other special code           
        :Else          ⍝ 'help', etc. => Give help, etc.      
            result← Special opts 
        :EndSelect   
      :EndWith 
    :Else 
        ⎕SIGNAL ⊂⎕DMX.('EM' 'EN' 'Message' ,⍥⊂¨('∆F ',EM) EN Message) 
    :EndTrap 
  ⍝! (C) Copyright 2025, 2026 Sam the Cat Foundation
  ∇
   :EndSection   ∆F SOURCE
⍝ END ====================   ∆F (User Function)   ==============================  

   :Section ScanFStr ( Top-Level ∆F Service)
⍝ ============================   ScanFStr ( top-level routine )   ============================= ⍝
⍝ ScanFStr: 
⍝    result← [options|⍬] ∇ f_string
⍝ "Main" function called by ∆F above. See the Executive section below.
⍝ Calls Major Field Recursive Scanners: 
⍝ ∘ ScanAll:  text fields and space fields; 
⍝ ∘ ScanCF:   code fields; 
⍝ ∘ CFQS:     (code field) quoted strings
  ScanFStr← {  

  ⍝ ScanAll: Initiates scan of the f-string, checking for all fields.
  ⍝    Starts with a Text Field Scan.
  ⍝    If it sees an unescaped "{",
  ⍝       determines if Space Field (done internally) or Code Field (ScanCF).
  ⍝    Otherwise,
  ⍝       processes text field escapes and literals (if any).
  ⍝    ''←  accum ∇ str
  ⍝ ûsr: R/W objects for this ∆F ("user") call:
  ⍝   ûsr.cfBeg: start of field; 
  ⍝   ûsr.brC:   bracket count; 
  ⍝   ûsr.cfL:   length of code field string.
  ⍝   ûsr.flds:  the data fields.
  ⍝ If it sees a non-escaped '{', it checks to see if it's followed by a Space Field: /\s*\}/.
  ⍝ If not, it calls ScanCF to handle Code fields.
  ⍝ Returns (via TFProc) the "final" array of fields (processed and formatted)
    ScanAll← {  
        p← TFBrk ⍵                                     ⍝ (esc or lb) only. 
      p= ≢⍵: ûsr TFProc ⍺, ⍵                           ⍝ Nothing special. Process literals => return.
        pfx← p↑⍵ ⋄ c← p⌷⍵ ⋄ w← (p+1)↓⍵                 ⍝ Found something!
      c= esc: (⍺, pfx, ûsr.nl TFEsc w) ∇ 1↓ w          ⍝ char is esc. Process. => Continue
  ⍝   c= lb: We may have a SF or a CF. We complete this TF, then check SF vs CF.
  ⍝          If we have a SF, complete it here; Else, we recurse to Code Field processing
        _← ûsr TFProc ⍺, pfx                           ⍝ Update this text field and then...
        ûsr.cfBeg← w                                   ⍝ Mark possible CF start (see SDCF in ScanCF)
      rb= ⊃w: '' ∇ 1↓ w                                ⍝ SF 1. Null SF? Do nothing => Continue
        nSp← w↓⍨← +/∧\' '= w                           ⍝ Non-null SF?                         
      rb= ⊃w: '' ∇ 1↓ w ⊣ ûsr.flds,← ⊂SFCode nSp       ⍝ SF 2. Yes. Proc SF => Continue
        a w← '' ScanCF w ⊣  ûsr.(cfL brC)← nSp 1       ⍝ No. Get CF.
        ûsr.flds,← ⊂lp, a, rp                          ⍝     Process CF.
        '' ∇ w                                         ⍝ Continue scan.
    } ⍝ End Text Field Scan 
  
  ⍝ ScanCF - Scans a Code Field  
  ⍝      outStr remStr ← accum ∇ str
  ⍝ Modifies ûsr.cfL, ûsr.brC; calls CFQS and CFOm; modifies ûsr.omC and ûsr.cfL.  
  ⍝ Returns the output from the code field plus more string to scan (if any)
  ⍝ ScanCF will delete runs of leading and trailing blanks from output code; internal runs will remain.
    ScanCF← {     
        ûsr.cfL+← 1+ p← CFBrk ⍵                        ⍝ ûsr.cfL is set in ScanAll above.  1: '{'
      p= ≢⍵:  ⎕SIGNAL brÊ                              ⍝ Missing "}" => Error. 
        pfx← ⍺, p↑⍵ 
        c←   p⌷⍵
        w←   (p+1)↓⍵ 
     (c= rb)∧ ûsr.brC≤ 1: (CFDfn pfx) w                ⍝ Closing brace? Opt'lly Trim (CFDTrimR pfx) ==> and RETURN!!!
      c∊ lb_rb: (pfx, c) ∇ w⊣ ûsr.brC+← -/c= lb_rb     ⍝ Inc/dec ûsr.brC as appropriate
      c∊ qtsL:  (pfx, a) ∇ w⊣ a w← ûsr CFQS c w        ⍝ Process quoted string.
      c= dol:   (pfx, scF) ∇ w                         ⍝ $ => ⎕FMT 
      c= esc:   (pfx, a) ∇ w⊣ a w← ûsr CFEsc w         ⍝ `⍵, `⋄, `A, `B, etc.
      c= omUs:  (pfx, a) ∇ w⊣ a w← ûsr CFOm w          ⍝ ⍹, alias to `⍵ (see CFEsc).
      c= libra: (pfx, ûsr libUtils.LibAuto w) ∇ w      ⍝ £ library.
    ⍝ This next line will never be executed unless cd∊ FUTURES
      c= cd:  (pfx, scCD) ∇ w                          ⍝ Adam B's CircleDiaeresis (optional).
    ⍝ This next line will never be executed unless rsu∊ FUTURES
      c= rsu: (pfx, scSel) ∇ w                         ⍝ Select / Sane Indexing
      ~c∊selfDoc: ⎕SIGNAL cfLogicÊ                     ⍝ CFBrk leaked unknown char.
    ⍝ '→', '↓' or '%'. See if a "regular" char/shortcut or self-defining code field      
      ûsr.brC>1:    (pfx, c scA⊃⍨ c= pct) ∇ w          ⍝ internal dfn => not SDCF
        p← +/∧\' '=w
      rb≠ ⊃p↓w:  (pfx, c scA⊃⍨ c= pct) ∇ w             ⍝ not CF-final '}' => not SDCF
    ⍝ SDCF: SELF-DEFINING CODE FIELD
        cfLit← AplQt ûsr.cfBeg↑⍨ ûsr.cfL+ p            ⍝ Put CF-literal in quotes
        fmtr←  (scA scM⊃⍨ c='→')                       ⍝ vert or horiz. SDCF?
        (cfLit, fmtr, CFDfn pfx) ((p+1)↓w)             ⍝ ==> RETURN!
    }

⍝ ===========================================================================
⍝ ScanFStr main (executive) begins here
⍝    On entry: 
⍝        ⍺ is a namespace; 
⍝        ⍵ is the f-string, a possibly null char vector
⍝    Returns either a matrix:   ûsr.dfn=0
⍝    or a char. string:         ûsr.dfn∊ 1 ¯1
⍝ =========================================================================== 
⍝ Special namespaces used internally:
⍝ CALL-level (i.e. local to each ∆F call)
⍝    ûsr -    the "user" options passed in ∆F's left argument, as well as 
⍝             variables defined here (tracking internal scan state, etc.).
⍝ SESSION-level namespaces (shared across calls)
⍝    pârms -  the default parameters internally or from file ./.∆F.
⍝    ûLib -  contains variables stored in ⎕THIS.userLibrary.
⍝
⍝ ↓¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ User Options (U)
⍝ ↓ Name    Init  Descr
⍝ ¯ ¯¯¯¯¯¯¯ ¯¯¯¯  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
⍝ U dfn       0   Defines output format:
⍝                 0 (return ∆F mx output), 1 (return dfn), ¯1 (return dfn code string)   
⍝ U verbose   0*  runtime verbosity/debug flag. 
⍝             1*  1 if VERBOSE_RUNTIME global constant is 1.
⍝ U box       0   Display a box around each field, if set.
⍝ U auto      1   If 1, honors default/.∆F setting of pârms.auto∊ 0 1.
⍝ U inline    0   If 0, puts ref to ⍙Flib function.
⍝             1*  If 1, puts shortcut code defs right in output string; 
⍝                 1 if INLINE_UTILS is set to 1.
⍝   acache    ⍬   autoload cache char. vector of vectors  
⍝   nl        CR  newline: nl (CR) or nlVis (the visible newline '␤').  
⍝   fields    ⍬   global field list
⍝   omC       0   omega index counter: current index for omega shortcuts (`⍵, ⍹).
⍝                 Local to the current ∆F instance.
⍝   brC       -   running count of braces '{' lb, '}' rb. Set in dfn ScanAll.
⍝   cfL       -   code field running length (for SDCFs). Set in dfn ScanAll.
    ûsr← ⍺                                
  ⍝ Validate all options passed in ûsr (⍺). 
  ûsr.((|dfn),verbose box auto inline)(0∊∊)0 1: ⎕SIGNAL optÊ                             ⍝  
    VMsg← (⎕∘←)⍣(ûsr.(verbose∧¯1≠dfn))                 ⍝ Verbose option message 
  ⍝ Shortcuts: 
  ⍝    See ⍙Load_Shortcuts 
  ⍝ This must follow the ordering specified there EXACTLY.  
    (scA scB scC scD scF scJ scQ scS scT scW scÐ scM scCD scSel)← ûsr.inline⊃ scCodeTbl   
    
    ûsr.acache← ⍬                                      ⍝ £ibrary shortcut "autoload" cache...
    ûsr.nl← ûsr.verbose⊃ nl nlVis                      ⍝ A newline escape (`⋄) maps onto nlVis if verbose mode.
    ûsr.flds← ⍬                                        ⍝ output fields, each a CV (Char Vec)
    ûsr.omC←  0                                        ⍝ initialise omega counter to 0 (see `⍵)
    ûsr.auto∧← libUtils.pârms.auto                     ⍝ auto can usefully be 1 only if pârms.auto is 1.     
                                                       ⍝ Start the scan (recursive).                    
    flds← '' ScanAll⊢ fstr← ∊⍵                         ⍝    fstr: char vec of vecs => char vec                     
                                                       ⍝ Scan complete.                                        
  0= ≢flds: VMsg '(1 0⍴⍬)', '⍨'/⍨ ûsr.dfn≠0            ⍝ If there are no flds, return 1 by 0 matrix
    code← CFDfn (ûsr.box⊃ scM scÐ), OrderFlds flds     ⍝ Order fields R-to-L so they will be evaluated L-to-R in ∆F.           
  0=ûsr.dfn: VMsg code                                 ⍝ Emit code ready to execute
    fstrQ← ',⍨⊂', AplQt fstr                           ⍝ Is ûsr.dfn (1,¯1): add quoted fmt string (`⍵0)
    VMsg lb, code, fstrQ, rb                           ⍝ Emit ûsr.dfn-based str ready to cvt to ûsr.dfn in caller
  } ⍝ ScanFStr 
⍝ === End of ScanFStr ========================================================  

   :EndSection ScanFStr ( Top-Level ∆F Service)

   :Section Constants
⍝ ===========================================================================  
⍝ Constants (Generated at LOAD time)
⍝ ===========================================================================  
⍝ Simple char constants
  om← '⍵'                                              ⍝ ⍵ not in cfBrklist, since it is not special. (See `⍵).
  nl nlVis← ⎕UCS 13 9252                               ⍝ We use 13 (CR) for nl; 9252 (␤) for nlVis.
⍝ esc: Set value( always scalar) at LOAD time.
⍝ If global ESCAPE_CHAR is not present or is null, '`' is used.
  esc← '`' { 0=⎕NC ⍵: ⍺ ⋄ 0=≢e←⎕OR ⍵: ⍺ ⋄ ⍬⍴e } 'ESCAPE_CHAR' 
⍝ Basic quote chars
  dq sq← '"'''
⍝ qtsL qtsR:
⍝    Generate left and right quote pairs... Double-quote first for efficiency.
⍝    See QUOTES_SUPPLEMENTAL
  qtsL qtsR← (dq,¨2⍴sq) { 0=⎕NC ⍵: ⍺ ⋄ 0=≢v← ⎕OR ⍵: ⍺ ⋄ ⍺,¨ ↓⍉↑,⊆v } 'QUOTES_SUPPLEMENTAL'
⍝ Other basic characters
  sp lb rb lp rp dol omUs ra da pct libra cd rsu← ' {}()$⍹→↓%£⍥⊇'  ⍝ rsu: right shoe underbar
⍝ Seq. `⋄ OR `◇ (see dia2[0, 1]) map onto ⎕UCS 13.
⍝ dia2[0]: Dyalog stmt separator (⋄) 
⍝ dia2[1]: Alternative character (◇) that is easier to read in some web browsers. 
  dia2← ⎕UCS 8900 9671           ⍝ '⋄◇' <-- hope that clears things up ;-) 
⍝ Order "break" chars roughly by frequency, high to low. 
⍝ We take dq to be high freq, but other quotes as low.
⍝               "  `   {  }  $   ⍹    →  ↓  %   £      '« (default)
  cfBrkList←  ∪ dq esc lb rb dol omUs ra da pct libra, qtsL    
⍝ See defs of FUTURES, cd (⍥) and rsu (⊇) 
  cfBrkList,← cd rsu/⍨ cd rsu ∊ FUTURES
  tfBrkList← esc lb                 
  lb_rb← lb rb ⋄ om_omUs← om omUs ⋄ sp_sq← sp sq ⋄   esc_lb_rb← esc lb rb  
⍝ self-doc code field chars →↓%
  selfDoc← ra da pct                                    

⍝ Error constants and fns  
    Ê← { ⍺←11 ⋄ ⊂'EN' ⍺,⍥⊂ 'Message' ⍵ }
  brÊ←         Ê 'Unpaired brace "{"'
  qtÊ←         Ê 'Unpaired quote in code field' 
  cfLogicÊ←    Ê 'A logic error has occurred processing a code field'
  optÊ←        Ê 'Invalid option(s) in left argument. For help: ∆F⍨''help'''
  scBadÊ←      Ê {'Sequence "`',⍵,'" does not represent a valid shortcut.'}
               T1←{
                  t1← 'Sequence "`',⍵,'" not valid in code fields outside strings.'
                  t2← 'Did you mean "',⍵,'"?'
                  t1,nl,(17⍴''),t2 
               }
  EscÊ←        Ê T1 ⋄ ⎕EX 'T1'  
               t1← 'Help file "',HELP_HTML_FI,'" not found in current directory (CD)'
               t2← 'CD: "','"',⍨⊃1 ⎕NPARTS ''
  helpFiÊ←  22 Ê t1,(⎕UCS 13),(17⍴''),t2 ⋄ ⎕EX 't1' 't2'
   :EndSection Constants

   :Section Utilities (Zero Side Effects) 
⍝ ===================================================================================
⍝ Utilities (fns/ops) for ScanFStr above.
⍝ ∘ These must have zero side effects, except those reflected in ûsr-namespace objects.
⍝ ===================================================================================
⍝ See also CFSBrk.  
  TFBrk← ⌊/⍳∘tfBrkList
  CFBrk← ⌊/⍳∘cfBrkList
⍝ 
  TrimR← ⊢↓⍨-∘(⊥⍨sp=⊢)                                 ⍝ Trim spaces on right...            
⍝ SFCode: Generate a SF code string; ⍵ is a pos. integer. (Used in ScanAll above)
  SFCode← ('(',⊢ ⊢,∘'⍴'''')')⍕ 
⍝ (CFDfn 'xxx') => '{xxx}⍵'                            ⍝ Create literal code field dfn call
  CFDfn← lb∘, ,∘(rb,om)        

⍝ AplQt:  Created an APL-style single-quoted string.
  AplQt←  sq∘(⊣,⊣,⍨⊢⊢⍤/⍨1+=)   

⍝ TFEsc: esc_seq← nl ∇ fstr 
⍝    nl: current newline char;  fstr: starts with the char after the escape
⍝ Returns: the escape sequence.                        ⍝ *** No side effects ***
  TFEsc← { 0= ≢⍵: esc ⋄ c← 0⌷⍵ ⋄ c∊ dia2: ⍺ ⋄ c∊ esc_lb_rb: c ⋄ esc, c } 

⍝ TFProc:  flds@CVV← ûsr ∇ str
⍝ If a text field <str> is not 0-length, place in quotes and add it to ûsr.flds.
⍝ Ensure adjacent fields are sep by ≥1 blank.
  TFProc← {0=≢⍵: ⍺.flds ⋄ 0≠ ≢⍵: ⍺.flds,← ⊂sp_sq, sq,⍨ ⍵/⍨ 1+ sq= ⍵ ⋄ ⍺.flds }  

⍝ CFEsc:  (code w)← ûsr ∇ fstr
⍝ Handle escapes  in Code Fields OUTSIDE of CF-Quotes.  
⍝ Returns code, the executable code, and w, the text of ⍵ remaining.                                 
  CFEsc← {                                    
    0= ≢⍵: esc 
      c w← (0⌷⍵) (1↓⍵) ⋄ ⍺.cfL+← 1   
    c∊ om_omUs: ⍺ CFOm w                               ⍝ Permissively allows `⍹ as equiv to `⍵ OR ⍹ 
    c='L': (⍺ libUtils.LibAuto w) w                    ⍝ Library shortcut: special (niladic) case
      p← MapSC c                                       ⍝ Look for other shortcuts
    nSC> p: (⍺.inline p⊃ scCodeTbl) w                  ⍝ Found? return code string.
    c∊⍥⎕C ⎕A: ⎕SIGNAL scBadÊ c                         ⍝ Nope: Unknown shortcut!
      ⎕SIGNAL EscÊ c                                   ⍝ Nope: An escape foll. by non-alphabetic.
  } ⍝ End CFEsc 

 ⍝ CFQS: CF Quoted String scan
  ⍝        qS w←  ûsr ∇ qtL fstr 
  ⍝ ∘ qtL is the specific left-hand quote we saw in the caller.
  ⍝   We determine qtR internally.
  ⍝ ∘ fstr is the current format string, w/ the qtL removed, but end not determined..
  ⍝ ∘ For quotes with different starting and ending chars, e.g. « » (⎕UCS 171 187).
  ⍝   If « is the left qt, then the right qt » can be doubled in the APL style, 
  ⍝   and a non-doubled » terminates as expected.
  ⍝ ∘ Updates ûsr.cfL with length of actual quote string.
  ⍝ Returns: qS w
  ⍝    qS: the string at the start of ⍵; w: the rest of ⍵ 
  CFQS← { ûsr← ⍺ ⋄ qtL w← ⍵ 
      qtR← (qtsL⍳ qtL)⌷ qtsR               
      CFSBrk← ⌊/⍳∘(esc qtR)    
    ⍝ Recursive CF Quoted-String Scan. 
    ⍝    accum tL Scan ⍵
    ⍝ accum: accumulates the quoted string
    ⍝ lW:    the total length of w scanned SO FAR
    ⍝ Returns (quoted string, lW: total length of w scanned)
      Scan← {   
          a lW ←⍺       
        0= ≢⍵: ⍺  
          p← CFSBrk ⍵  
        p= ≢⍵: ⎕SIGNAL qtÊ 
          c c2← 2↑ p↓ ⍵ 
      ⍝ See CFQSEsc, below, for handling of escapes in CF quoted strings.
      ⍝ <skip> is how many characters were consumed...
        c= esc: (a, (p↑ ⍵), map) lW ∇ ⍵↓⍨ lW+← p+ skip⊣ map skip← ûsr.nl CFQSEsc c2 qtR             
      ⍝ Closing Quote: 
      ⍝ c= qtR:  
      ⍝   ∘ Now see if the NEXT char, c2, such that c2= qtR.
      ⍝     If so, it's a string-internal qtR. Only qtR need be doubled (i.e. '»»' => '»').
        c2= qtR:  (a, ⍵↑⍨ p+1) lW ∇ ⍵↓⍨ lW+← p+2       ⍝ Use APL rules for doubled ', ", or »
          (AplQt a, p↑⍵) (lW+ p)                       ⍝ Done... Return
      }
      qS lW← '' 1 Scan w          
      qS (w↓⍨ ûsr.cfL+← lW)                            ⍝ w is returned sans CF quoted string 
  } ⍝ End CF Quoted-String Scan

⍝ CFQSEsc:  (map len)← nl ∇ c2 qtR, where 
⍝           nl is the current newline char;
⍝           c2 is the char AFTER the escape char,
⍝           qtR  is the current right quote char.
⍝ c2= qt: esc+qtR is NOT treated as special-- this is APL, not C or HTML or ...
⍝ Returns (map len), where
⍝         map is whatever the escape seq or char maps onto (possibly itself), and
⍝         len is 1 if it consumed just the escape, and 2 if it ALSO consumed c2.
⍝ Side effect: none.       ⍝ pattern   =>  literal    consumes   notes
  CFQSEsc← { c2 qtR← ⍵     ⍝                          (# chars)
    c2∊ dia2: ⍺  2         ⍝ esc ⋄          newline       2   newline is here ⎕UCS 13 (cr)
    c2= qtR: esc 1         ⍝ esc qtR        esc           1   caller handles qtR next cycle.
    c2= esc: c2  2         ⍝ esc esc        esc           2   2 esc => 1 esc literal
       (esc, c2) 2         ⍝ esc <any>      esc <any>     2   esc is a literal
  } 

⍝ CFOm:   (omCode w)← ûsr ∇ ⍵ 
⍝ ⍵: /\d*/, i.e. optional digits starting right AFTER `⍵ or ⍹ symbols.
⍝ Updates ûsr.cfL, ûsr.omC to reflect the # of digits consumed and their value.  
⍝ Returns omCode w:
⍝    omCode: the emitted code for selecting from the ∆F right arg (⍵);
⍝    w:      ⍵, just past the matched omega expression digits.
⍝ IntOpt: See IntOpt, just below.
  CFOm← { 
      oLen oVal w← IntOpt ⍵
  ×oLen: ('(⍵⊃⍨',')',⍨ '⎕IO+', ⍕⍺.omC← oVal ) w⊣ ⍺.cfL+← oLen 
         ('(⍵⊃⍨',')',⍨ '⎕IO+', ⍕⍺.omC       ) w⊣ ⍺.omC+← 1
  }

⍝ IntOpt: Does ⍵ start with a valid sequence of digits (a non-neg integer)? 
⍝ Returns oLen oVal w:
⍝   oLen:  len of sequence of digits (pos integer) or 0, 
⍝   oVal:  the integer value of the digits found or 0, 
⍝   w:     ⍵ after skipping the prefix of digits, if any.
⍝ If oLen is 0, then there were no adjacent digits, i.e. (b) is 0 and (c) is ⍵ unchanged.
  IntOpt← { 
    wid← +/∧\ ⍵∊⎕D 
    wid (⊃⊃⌽⎕VFI wid↑ ⍵) (wid↓ ⍵) 
  }  

⍝ OrderFlds
⍝ ∘ User flds are effectively executed field-by-field L-to-R AND displayed in L-to-R order.
⍝ The process... 
⍝   ∘ ensures we reverse the order of fields, NOT the chars inside each field! 
⍝   ∘ reverses the ¨field¨ order now,
⍝      ∘  evaluates each field via APL ⍎ R-to-L, as normal, then 
⍝   ∘ reverses the ¨result¨ at execution time 
⍝ ... achieves apparent L-to-R field-by-field evaluation (but R-to-L within each field).
  OrderFlds← '⌽',(∊∘⌽,∘'⍬') 

   :EndSection Utilities (Zero Side Effects)

:EndSection CORE
⍝===================================================================================
:Section HELP AND ERROR SERVICES
⍝===================================================================================
⍝ Special: Provides help info and other special info. 
⍝ Called with this syntax, where ⍺ stands for the options listed below.
⍝       '⍺' ∆F anything  OR  ∆F⍨'⍺
⍝ Special options (⍺):
⍝       'help'  or variants 'help-n[arrow]', 'help-w[ide]'
⍝       'parms'
⍝ (1 0⍴⍬)← ∇ ⍵
⍝ 1. If ⍵ is not special (any case, truncating after key letters), an error is signaled.
⍝ 2. If helpHtml is not defined, HELP_HTML_FI will be read and copied into helpHtml. 
⍝ 3. Displays helpHtml.
  Special← { val← ⎕C⍵
  ⍝ pârms: Load any new pârms without a ]load. 
  ⍝        Returns display of default and user pârms (as mx) in alph order.
    2≠ ⎕NC 'val': ⎕SIGNAL optÊ  
  ⍝ LoadParms (isVerbose isCompact isRuntime)   
    'parms-c'≡ 7↑val: _← libUtils.LoadParms '-v -c -r'
    'parms'  ≡   val: _← libUtils.LoadParms '-v    -r'
    'path'   ≡   val: _← libUtils.ShowPath ⍬ 
    'globals'≡   val: _← ⍙ShowGlobalsIf 1 
    'help'   ≢ 4↑val: ⎕SIGNAL optÊ 
  ⍝ (Below) help, help-wide, or help-narrow?
      CLoadHtml← {   ⍝ Conditionally load help html file, i.e. if not already loaded...
        22:: ⎕SIGNAL helpFiÊ 
        0= ⎕NC ⍵: ⊢⎕THIS.helpHtml← ⊃⎕NGET HELP_HTML_FI 
          ⎕THIS.helpHtml  
      }
      RenderHtml← {  ⍝ Fallback to Ride, if no HTMLRenderer...
        0::  16 ⎕SIGNAL⍨ 'NONCE ERROR: No renderer available to display HELP information'
        0::  ⍬⊣ 3500⌶ ⍺ 
          ⍬⊣ 'htmlObj' ⎕WC 'HTMLRenderer',⍥⊆ ⍵ 
      }  
      html← CLoadHtml 'helpHtml' 
    ⍝ Screen widths correspond to 'help-narrow' vs 'help-wide'/'help' parameters in ⍵.
      s← (900 1000) (900 1350)⊃⍨ ~'-n'(1∘∊⍷)⍵   ⍝ ⍵ is 'help[-wide]' or 'help-narrow'
      obj← ('HTML'  html) (s,⍨ ⊂'Size') (15 35,⍨ ⊂'Posn') ('Coord' 'ScaledPixel')   
      1 0⍴⍬⊣ html RenderHtml obj    
  }        
  
:EndSection HELP AND ERROR SERVICES

⍝ ===================================================================================

⍝ ===================================================================================
:Section SKELETAL LIBRARY SERVICES 
⍝ See libUtils.LinkUserLib
⍝ userLibrary is the user library.
:Namespace userLibrary
  ⍝ Minimal contents, pending ⍙Load_LibAuto.
  ⍝ Inherit key sys vars from the # namespace.
    ⎕IO ⎕ML ⎕PW ⎕PP ⎕CT ⎕DCT ⎕FR← #.(⎕IO ⎕ML ⎕PW ⎕PP ⎕CT ⎕DCT ⎕FR)     
:EndNamespace

⍝ Utilities for "userLibrary" shortcut (£, `L) 
⍝ See ⍙Load_LibAuto 
:Namespace libUtils
⍝⍝⍝⍝⍝ This is a local stub, pending (optional, but expected) load of ∆FLibUtils below.
  ∇ {libNs}←  LibSimple libNs 
    ; _readParmFi 
    ⍝ external in the stub... 
    ⍝   libUser, Auto, ShowPath, LoadParms
    ⍝ external loaded from ∆FLibUtils.dyalog:
    ⍝   libUser, Auto, pârms, ShowPath, LoadParms 
      ⎕THIS.libUser← libNs
      libNs.⎕DF ⎕NULL                                  ⍝ Clear any prior ⎕DF.
      libNs.⎕DF '£=[',(⍕libNs),' ⋄ auto:0]'            ⍝ Now, set ours.
      Auto← (⍕libNs)⍨  
      'pârms' ⎕NS '⍙readParms' 'auto'⊣ ⍙readParms auto← (0 0) 0 
      ShowPath← '⍬'⍨        
      LoadParms← ⍬⍨       
  ∇
⍝ Set name and ref for userLibrary here
  LibSimple ##.userLibrary
:EndNamespace
:EndSection SKELETAL LIBRARY SERVICES 
⍝ ===================================================================================

⍝ ===================================================================================
:Section FIX_TIME_ROUTINES 
⍝ ===================================================================================

⍝ ⍙Export_∆F : rc← ∇ targNm destNs lockFn 
⍝ Used internally only at FIX-time:
⍝ On execution (default mode), ⍙Export_∆F creates ∆F in location specified as <destNs>.
⍝ If destNs is not namespace ⎕THIS, then we "promote the fn to target namespace,
⍝    ∘ obscure (mangle) local vars: ¨result¨ ¨opts¨ and ¨args¨
⍝    ∘ sets __OUTER__. to ##.
⍝    ∘ sets __THIS__ to refer to this namespace (i.e. ...⍙FUtils)
⍝ If destNs is the namespace ⎕THIS, then we:
⍝    ∘ set '__OUTER__.' to  ''
  ∇ {targNm}← ⍙Export_∆F (targNm destNs lockFn) 
    ; nm; outr; src; snk; trap 
    ; Fix; Freeze; QCom; NoEL; QLock 

    ⋄   outr← '##.' ''⊃⍨ destNs=⎕THIS
    ⋄   trap← ('⍬0'⊃⍨ TRAP_ERRORS), (¯40↑ '⍝! TRAP_ERRORS='), ⍕TRAP_ERRORS
    src snk← ↓⍉↑(
          '∆FSrc'              targNm 
          '__THIS__'           ∆THIS  
          '__OUTER__\.'        outr 
          '__TRAP_ERRORS__'    trap 
          'result'             'rësûlt∆F'
          'opts'               'öôpts∆F'
          'args'               'äârgs∆F'
    ) 

    Freeze← src ⎕R snk⍠ 'UCP' 1  
    NoEL←   { ⍵/⍨ 0≠≢¨⍵ }                             ⍝ NoEL: No Empty Lines  
    Fix←    destNs∘{11:: '' ⋄ ⊃2 ⍺.⎕FIX ⍵}
    QLock←  destNs.⎕LOCK⍣lockFn

    :If targNm≡ nm← Fix NoEL Freeze⊢ 62 ⎕ATX '∆FSrc' 
      {} QLock nm 
      {}(⎕∘←)⍣VERBOSE_LOADTIME⊢ '✅✅✅ Created function ',(⍕destNs),'.',targNm 
    :Else 
      11 ⎕SIGNAL⍨'❌❌❌ There was an error applying ⍙Export_∆F. Could not create "',(⍕destNs),'.',targNm  
    :EndIf 
  ∇

:Section Shortcut functions
⍝ Above
    A← {
      ⎕ML←1 ⋄ ⍺←⍬
      ⊃⍪/(⌈2÷⍨w-m)⌽¨f↑⍤1⍨¨m←⌈/w←⊃∘⌽⍤⍴¨f←⎕FMT¨⍺⍵
    } 
  ⍝ Box
    B← {⎕ML←1⋄d←|≡⍵⋄⍺←0⋄⍺⎕SE.Dyalog.Utils.disp⊂⍣(1≥d),⍣(0=d)⊢⍵}  
  ⍝ Commas (Numeric ~)
    C←{ 
      ⎕IO ⎕ML←0 1
      d←3','⋄⍺←d⋄n s←⍺,d↑⍨0⌊2-⍨≢⍺   ⍝ d: defaults, n: ndigits, s: separator  
      n←⍕n⋄s←{⍵≡⍥,'&':'\&'⋄⍵/⍨1+'\'=⍵}s 
      src←'[.Ee]\d+' ('(?<=\d)(?=(\d{',n,'})+([-¯.Ee]|(?=\s|$)))')
      snk←'&' (,s,'&')
      1=≢w←{src ⎕R snk⊢⍵}⍤1⍕⍵: ⊃w⋄w
    } 
  ⍝ Date: See Time (below)
  ⍝ Display
    Ð← 0∘⎕SE.Dyalog.Utils.disp¯1∘↓
  ⍝ Format        
    F← ⎕FMT                 
  ⍝ Justify
    J← {
        ⎕PP←34⋄⍺←'L'⋄B←{+/∧\' '=⍵}
        w⌽⍨(1⎕C⍺){ o←⊂⍺                   ⍝ Treat ⍺ as a scalar.
          o∊'L'¯1:B ⍵
          o∊'R' 1:-B⌽⍵ 
          ⌈0.5×⍵-⍥B⌽⍵                     ⍝ If invalid ⍺, assume 'C'.
        }w←⎕FMT⍵
    }
  ⍝ Library
  ⍝ £, `L: Not here-- handled ad hoc in code (it's niladic)...   
  ⍝ Merge  
    M←{
      ⎕ML←1
      ⍺←⊢⋄⊃,/((⌈/≢¨)↑¨⊢)⎕FMT¨⍺⍵
    } 
  ⍝ Quote                   
    Q←  {
      ⍺←⎕UCS 39            
      1<|≡⍵:⍺∘∇¨⍵                              
      (0=⍴⍴⍵)∧1=≡⍵:⍵                           
      (0≠≡⍵)∧326=⎕DR⍵:⍺∘∇¨⍵                 
      ⎕ML←1                                                                   
      ⍺{0=80|⎕DR⍵:⍺,⍺,⍨⍵/⍨ 1+⍺=⍵⋄⍵}⍤1⊢⍵        
    }
  ⍝ Serialise
    S← { 
      ⎕ML←1⋄11 16 6::⍵⋄⍺←0⋄     
      1=≢s←⍺⎕SE.Dyalog.Array.Serialise⍵:⊃s⋄
      ⍪s
    }
  ⍝ Time / Date   
    T← {
      ⎕ML←1
      ⍺←'%ISO%'
      ∊⍣(1=≡⍵)⊢⍺(1200⌶)⊢1⎕DT⊆⍵
    }
  ⍝ Wrap 
    W← {⎕ML←1⋄⍺←⎕UCS 39⋄ 1<|≡⍵: ⍺∘∇¨⍵⋄L R←2⍴⍺⋄{L,R,⍨⍕⍵}⍤1⊢⍵}
  
  ⍝ Select (Sane Indexing):  ⊇
    selCodeStr← '(⊂⍛⌷)' '(⌷⍤0 99)' ⊃⍨ APL_VERSION< 20 

  ⍝ CircleDiaeresis
  ⍝ Adam B's "future" ⍥ with depth operator extension 
    cdNm← { 22:: '' ⋄ ⊃2 ⎕FIX ⍵} 'file://∆F/CircleDiaeresis.dyalog'

:EndSection Shortcut functions 

⍝ ⍙Load_Shortcut_Calls:   ∇     (niladic) 
⍝ At ⎕FIX time, load the run-time userLibrary names and code for user Shortcuts
⍝ and similar code (Ð, display, is used internally, so not a true user shortcut).
⍝ The userLibrary entries created in ∆Fapl are: 
⍝  ∘  for shortcuts:    A, B, C, F, Q, T, W     ⍝ T supports `T, `D
⍝  ∘  used internally:  M, Ð.
⍝ A (etc): a dfn
⍝ scA (etc): [0] local absolute name of dfn (with spaces), [1] its code              
⍝ Abbrev  Descript.       Valence     User Shortcuts   Notes
⍝ A       [⍺]ABOVE ⍵      ambi       `A, %             Center ⍺ above ⍵. ⍺←''.  Std sc is %
⍝ B       BOX ⍵           ambi       `B                Put ⍵ in a box.
⍝ C       COMMAS          monadic    `C                Add commas to numbers every 3 digits R-to-L
⍝ Ð       DISPLAY ⍵       dyadic                       Var Ð only used internally...
⍝ F       [⍺]FORMAT ⍵     ambi       `F, $             ⎕FMT.   Std is $
⍝ J       [⍺] JUSTIFY ⍵   ambi       `J                justify rows of ⍵. ⍺←'l'. ⍺∊'lcr' left/ctr/rght.
⍝ -       [⍺] LIBRARY ⍵   niladic     £, `L            *** handled in line (ad hoc) ***
⍝ M       MERGE[⍺] ⍵      ambi                         Var M only used internally...
⍝ Q       QUOTE ⍵         ambi       `Q                Put only text in quotes. ⍺←''''
⍝ S       [⍺]SERIALISE ⍵  ambi       `S                Apl Array Notation Serialise
⍝ T       ⍺ DATE-TIME ⍵   dyadic     `T, `D            Format ⍵, 1 or more timestamps, acc. to ⍺.
⍝ W       [⍺1 ⍺2]WRAP ⍵   ambi       `W                Wrap ⍵ in decorators, ⍺1 ⍺2.  ⍺←''''. See doc.
⍝
⍝ For A, B, C, D, F, J, M, Q, T, W; all like A example shown here:
⍝     A← an executable dfn in this namespace (⎕THIS).
⍝     scA2← name codeString, where
⍝           name is ∆THIS,'.A'
⍝           codeString is the executable dfn in string form.
⍝ At runtime, we'll generate shortcut code "pointers" scA, scB etc. based on flag ¨inline¨.
⍝ Warning: Be sure these can run in user env with any ⎕IO and ⎕ML: Localize them where needed.
⍝ NOTE: We are creating multiline objects using the old method for compatibility with Dyalog 19 etc.
  ∇ {ok}← ⍙Load_Shortcut_Calls 
    ; scUser
    ; scA2; scB2; scC2; scD2; scÐ2; scF2; scJ2
    ; scM2; scQ2; scS2; scT2; scW2; scCD2; scSel2  
    ; Inline; Publish 
    Publish←{ ⍺← Inline ⍵    
      1: _← (' ',' ',⍨ ∆THIS,'.',⍵) ⍺
    }
    Inline← {  
        bdy←  (⊂f↓⍨ 2+'←'⍳⍨ f←⊃bdy), 1↓ bdy← 62 ⎕ATX ⍵ 
        i o← ↓⍉↑('''[^'']*''' '\0') ('\h*⍝.*' '')  ('^\h+|\h+$' '')  ('\h*([⋄⎕{}()])\h*' '\1')  
      1= ≢bdy← i ⎕R o⊣ bdy: ⊃bdy  
        '{','}',⍨ ¯1↓∊'⋄',⍨¨ 1↓¯1↓ bdy  
    } 
  ⍝ "Experimental" - future ⍥ operator, adding Depth operation.
    ⎕SHADOW 'cdFut' 'rsuFut' 'Note' 
    Note← { f v←⍵ ⋄ ~v: _← ⍬ 
      _←' Future Feature', (f⊃' not ' ' '), 'available: ', ⍺
      ⎕← (f⊃ '❌❌❌' '✅✅✅'), _
    } 
    cdFut←  (cd∊ FUTURES) ∧ 0≠≢cdNm 
    rsuFut← rsu∊ FUTURES 
    'CircleDiaeresis (⍥) Depth-Extension' Note cdFut VERBOSE_LOADTIME
    'Right-Shoe Underscore (⊇) Select/Sane Indexing' Note rsuFut VERBOSE_LOADTIME

  ⍝ User-callable functions:          A  B  C  D  F  J  Q  S  T  W 
  ⍝                                   L (handled ad hoc); D (synonym to T)
  ⍝ ∆F-internal (non-user) funtions:  Ð  M
  ⍝ Others: CircleDiaeresis, Select -- called only via symbol ⍥, ⊇ (if enabled)

  scA2 scB2 scC2 scJ2 scM2 scQ2 scS2 scT2 scW2 ← Publish¨ 'A'  'B' 'C' 'J' 'M' 'Q' 'S'  'T'  'W' 
  scÐ2←   '0∘⎕SE.Dyalog.Utils.disp¯1∘↓' Publish 'Ð'     
  scF2←   2⍴⊂' ⎕FMT ' 
  scCD2←  cdNm { ⍵: Publish ⍺ ⋄ 2⍴ cd } cdFut
  scSel2← 2⍴ ⊂rsu selCodeStr⊃⍨ rsuFut 
  
  ⍝ Do not change order without adjusting runtime code
  ⍝    scA scB... ← ûsr.inline⊃ scCodeTbl   
  scCodeTbl← ↓⍉↑scA2 scB2 scC2 scT2 scF2 scJ2 scQ2 scS2 scT2 scW2 scÐ2 scM2 scCD2 scSel2 
  nSC← ≢scUser←  'A    B    C    D    F    J    Q    S    T    W'~ ' '
  MapSC← scUser∘⍳
  ok← 1 
  ∇ 

  ∇ {ok}← ⍙Load_Help hfi;e1; e2 
  ⍝ Loading the help html file...
    :Trap 22 
        ⎕THIS.helpHtml← ⊃⎕NGET hfi
        :IF VERBOSE_LOADTIME ⋄ ⎕← '✅✅✅ Loaded Help Html File "',hfi,'"' ⋄ :EndIf  
        ok← 1 
    :Else 
        e1← '❗❗❗ WARNING: When loading ∆Fapl, the help file "',hfi,'" was not found in current directory.'
        e2← '❗❗❗ WARNING: ∆F help will not be available without user intervention.'
        e1,(⎕UCS 13),e2
        ok← 0 
    :EndTrap 
  ∇
  ∇ {libActive}← ⍙Load_LibAuto (libFi libActive keepCm)
    ; how 
    how← ' from "',libFi,'" into "','"',⍨∆THIS 
    :If libActive=0
        ⎕←↑3⍴⊂'❗❗❗ WARNING: Library autoload services were not loaded',how
        ⎕←'✅✅✅ LIB_ACTIVE is set to ',(⍕libActive),' in ∆F/∆FUtils.dyalog'
        ⎕←'✅✅✅ £ and `L shortcuts are available without them, as if (auto: 0) is set.'
        :Return 
    :EndIf 
    :TRAP 22 
        :If keepCm 
           ⎕FIX 'file://',libFi
        :Else 
           ⎕FIX⍠ 'FixWithErrors' 0⊣{ ⍵/⍨ 0≠≢¨⍵ } '''[^'']*''' '\h*⍝(?!\!).*$' ⎕R '&' ''⊢ ⊃⎕NGET libFi 1 
        :EndIf 
        :If VERBOSE_LOADTIME 
            ⎕←'✅✅✅ Loaded services for Library shortcut (£)',how  
        :EndIf 
    :Else
        libActive← 0 
        ⎕←↑3⍴⊂'❗❗❗ WARNING: Unable to load Library autoload services',how 
        ⎕←'✅✅✅ £ and `L shortcuts are available without autoload (auto: 0).'
    :EndTrap
  ∇
⍝ Show the following special globals in this namespace.
  ⍙ShowGlobalsIf←{  
    ~⍵: _←1 0⍴0  
      gg← ⊃,/(
        'ESCAPE_CHAR'         'HELP_HTML_FI'    'INLINE_UTILS' 
        'LIB_ACTIVE'          'SIGNAL_LIB_ERRS' 'LIB_PARM_FI'  
        'LIB_USER_FI'         'LIB_SRC_FI'      
        'OPTS_KW'             'OPTS_DEFval'        
        'QUOTES_SUPPLEMENTAL' 'TRAP_ERRORS'     'KEEP_SRC_CM'  
        'VERBOSE_LOADTIME'    'VERBOSE_RUNTIME' 'VERSION' 'FUTURES'
      ) 
      vv← 1∘⎕SE.Dyalog.Array.Serialise¨ ⎕VGET gg← ⊂∘⍋⍛⌷⍨gg  
    1: _← ↑  '(', ')',⍨ vv {'  ',⍵ , ⍺}¨ (1+⌈/≢¨ gg)↑¨gg,¨ ':'  
  }
⍝ ====================================================================================
⍝ Execute the FIX-TIME Routines
⍝ ====================================================================================
  ∇ ok← Initialise 
    :Trap ok← 0   
        :If APL_VERSION < 20
            ⎕←↑3⍴⊂'❌❌❌ This version of ∆F requires Dyalog 20 or later'
            ⎕SIGNAL 911 
        :EndIf  
        ⍙Export_∆F '∆F' ## 0          ⍝ Keep comments? (0→NO); lock? (0→NO).
        ⍙Load_Shortcut_Calls
        ⍙Load_Help HELP_HTML_FI
        LIB_ACTIVE← ⍙Load_LibAuto LIB_SRC_FI LIB_ACTIVE KEEP_SRC_CM   
        ⍙ShowGlobalsIf VERBOSE_RUNTIME
    :Else 
        ⎕← ↑⎕DMX.DM ⋄  ⎕←'Stack: ' ⋄ ⎕← 4{⍺≥≢⍵: '   ',⍵ ⋄ ⍺ ∇ ⍺↓⍵⊣ ⎕← '   ',⍺↑⍵} ⎕XSI  
        ⎕←↑3⍴⊂'❌❌❌ ∆F Initialisation has failed!'
    :EndTrap 
  ∇ 
  Initialise 
:EndSection FIX_TIME_ROUTINES 
⍝ === END OF CODE ================================================================================
:EndNamespace 

⍝ (C) 2025 Sam the Cat Foundation
