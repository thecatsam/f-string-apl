:Namespace ⍙FUtils   
:Section CORE 
   :Section      INITIALIZATION
  VERSION←     'v.0.1.2'          ⍝ Set/updated by ∆F_Publish.dyalog...
  ⎕IO ⎕ML ⎕PP ⎕PW←0 1 34 256    ⍝ Namespace scope. User code is executed in CALLER space (⊃⎕RSI)  
⍝ =======================================================================
⍝ GENERAL GLOBAL VARIABLES (for debugging and exploration) 
⍝ =======================================================================
⍝
⍝ TRAP_ERRORS: If 0, turns off error trapping in ∆F
  TRAP_ERRORS← 1              
⍝
⍝ VERBOSE_RUNTIME: Run-time verbosity flag
⍝ (verbose: 1) is ∆F-settable (user) run-time verbosity flag-- which
⍝ also changes `⋄ to ␤ instead of an actual new line (⎕UCS 13, for us).
⍝ Determines the "default" for user parm ¨verbose¨.
  VERBOSE_RUNTIME← 0

⍝ VERBOSE_LOADTIME: Load (Fix)-Time verbosity flag
  VERBOSE_LOADTIME← 0
⍝              
⍝ SHOW_LIB_ERRS:  
⍝ - If 0, only report library autoload errors when searching (as messages) 
⍝   if (verbose: 1) or (VERBOSE_RUNTIME=1) 
⍝   Let APL handle the resulting missing object (typically as a VALUE ERROR) when user code is executed.
⍝ - If 1, always ⎕SIGNAL the actual internal error (e.g. OBJECT NOT FOUND ON SEARCH PATH).                             
  SHOW_LIB_ERRS←  0 
⍝
⍝ ESCAPE_CHAR: Allows an installation to use a non-standard "escape" char.
⍝ ESCAPE_CHAR must be a scalar.
⍝ If ESCAPE_CHAR is omitted, the default will be '`'.
⍝ Note ESCAPE_CHAR is a load-time variable, to take advantage of minor optimizations.
  ESCAPE_CHAR← '`'
⍝
⍝ Quote pairs, i.e. beyond double quotes and single quotes.
⍝ QUOTES_SUPPLEMENTAL must consist of 0 or more PAIRS of left AND right quotes.
⍝ Note: The code can support all of these at the same time.
  QS_FR1← '«»'  
  ⍝ QS_FR2 QS_FR3← '“”'  '‘’'       
  ⍝ QS_JP1 QS_JP2← '「」' '『』' 
  ⍝ QS_DE1 QS_DE2 QS_DE3← '»«' '„“' '‚‘'
  ⍝ QS_CH1 QS_CH2← '《》' '「」'
  QUOTES_SUPPLEMENTAL← QS_FR1  

⍝ INLINE_UTILS. 
⍝ If 1, puts full definitions of internal utilities (shortcuts etc.) into the result.
⍝ If 0, refers to local copies of internal utilities in the result.
  INLINE_UTILS← 0   
⍝            
⍝ =======================================================================
⍝ SESSION LIBRARY (£ or `L) VARIABLES
⍝ =======================================================================
⍝ Var     Setting  Do we want to use the SESSION LIBRARY autoload feature?
⍝ LIB_ACTIVE:  2     Yes. Load default (LIB_PARM_FI below) and user parameters (LIB_USER_FI below)
⍝              1     Yes. Load default parameters ONLY. Good for a demo environment!
⍝              0     No.  No autoload features should be available.
  LIB_ACTIVE←  2     
  LIB_PARM_FI←  '∆F/∆FParmDefs.apla' 
  LIB_USER_FI←  '.∆F' 
  LIB_SRC_FI←   '∆F/∆FLibUtils.dyalog'                 ⍝ Library shortcuts (£,  `L) utilities.
⍝ HELP FILE          
  HELP_HTML_FI← '∆F/∆FHelp.html'                       ⍝ Called from 'help' option. Globally set here              
⍝ ==================================================================================
⍝ VARIABLES FOR ∆F OPTIONS: Positional and keyword 
⍝ =======================================================================
  OPTS_KW←      ↑'dfn' 'verbose'        'box' 'auto' 'inline'          ⍝ In order 
  OPTS_DEFval←    0    VERBOSE_RUNTIME   0     1      INLINE_UTILS   ⍝ In order
  OPTS_N←       ≢OPTS_DEFval 
⍝ OPTS_DEFns: The defaults in namespace form. Treat as a read-only object.
⍝ Requires ⍙Gen_LegacyAplAN to define ∆VSET, so is defined after it.
⍝     OPTS_DEFns← (⎕NS⍬)∆VSET OPTS_KW OPTS_DEFval   
⍝ after calling ⍙Gen_LegacyAplAN.
⍝ Set char. rendering of ⎕THIS. We may set ⎕THIS.⎕DF later, but ∆THIS will remain as is.
  ∆THIS← ⍕⎕THIS                

   :EndSection   INITIALIZATION

   :Section      ∆F SOURCE
⍝ =======================================================================
⍝ ∆F USER FUNCTION Source - See ⍙Export_∆F
⍝ =======================================================================
⍝ ∆FSrc:
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
            opts← ∆NS OPTS_DEFns __OUTER__.opts                  ⍝ v19: Emulate v.20 ⎕NS
        ⍝ Positional options-- integers/booleans         
          :ElseIf 11 83∊⍨ ⎕DR opts ⋄ :AndIf  OPTS_N≥ ≢opts 
            opts← (⎕NS OPTS_DEFns) ∆VSET (OPTS_KW↑⍨≢opts)opts    ⍝ v19: Emulate ⎕VSET
        ⍝ Special options (like help and invalid options)
          :Else                                           
            result← Special opts ⋄ :Return                     
          :EndIf 
      ⍝ Phase II: Execute!
        ⍝ Flatten multiline f-string (v.20 VCV), if present.
          (⊃args)← ∊⊃args← ,⊆args                              
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
  ⍝ êxt: R/W externs:
  ⍝   êxt.cfBeg: start of field; 
  ⍝   êxt.brC:   bracket count; 
  ⍝   êxt.cfL:   length of code field string.
  ⍝   êxt.flds:  the data fields.
  ⍝ If it sees a non-escaped '{', it checks to see if it's followed by a Space Field: /\s*\}/.
  ⍝ If not, it calls ScanCF to handle Code fields.
  ⍝ Returns (via TFProc) the "final" array of fields (processed and formatted)
    ScanAll← {  
        p← TFBrk ⍵                                     ⍝ (esc or lb) only. 
      p= ≢⍵: êxt TFProc ⍺, ⍵                           ⍝ Nothing special. Process literals => return.
        pfx← p↑⍵ ⋄ c← p⌷⍵ ⋄ w← (p+1)↓⍵                 ⍝ Found something!
      c= esc: (⍺, pfx, êxt.nl TFEsc w) ∇ 1↓ w          ⍝ char is esc. Process. => Continue
  ⍝   c= lb: We may have a SF or a CF. We complete this TF, then check SF vs CF.
  ⍝          If we have a SF, complete it here; Else, we recurse to Code Field processing
        _← êxt TFProc ⍺, pfx                           ⍝ Update this text field and then...
        êxt.cfBeg← w                                   ⍝ Mark possible CF start (see SDCF in ScanCF)
      rb= ⊃w: '' ∇ 1↓ w                                ⍝ SF 1. Null SF? Do nothing => Continue
        nSp← w↓⍨← +/∧\' '= w                           ⍝ Non-null SF?                         
      rb= ⊃w: '' ∇ 1↓ w ⊣ êxt.flds,← ⊂SFCode nSp       ⍝ SF 2. Yes. Proc SF => Continue
        a w← '' ScanCF w ⊣  êxt.(cfL brC)← nSp 1       ⍝ No. Get CF.
        êxt.flds,← ⊂lp, a, rp                          ⍝     Process CF.
        '' ∇ w                                         ⍝ Continue scan.
    } ⍝ End Text Field Scan 
  
  ⍝ ScanCF - Scans a Code Field  
  ⍝      outStr remStr ← accum ∇ str
  ⍝ Modifies êxt.cfL, êxt.brC; calls CFQS and CFOm; modifies êxt.omC and êxt.cfL.  
  ⍝ Returns the output from the code field plus more string to scan (if any)
  ⍝ ScanCF will delete runs of leading and trailing blanks from output code; internal runs will remain.
    ScanCF← {     
        êxt.cfL+← 1+ p← CFBrk ⍵                        ⍝ êxt.cfL is set in ScanAll above.  1: '{'
      p= ≢⍵:  ⎕SIGNAL brÊ                              ⍝ Missing "}" => Error. 
        pfx← ⍺, p↑⍵ 
        c←   p⌷⍵
        w←   (p+1)↓⍵ 
     (c= rb)∧ êxt.brC≤ 1: (CFDfn pfx) w                ⍝ Closing brace? Opt'lly Trim (CFDTrimR pfx) ==> and RETURN!!!
      c∊ lb_rb: (pfx, c) ∇ w⊣ êxt.brC+← -/c= lb_rb     ⍝ Inc/dec êxt.brC as appropriate
      c∊ qtsL:  (pfx, a) ∇ w⊣ a w← êxt CFQS c w        ⍝ Process quoted string.
      c= dol:   (pfx, scF) ∇ w                         ⍝ $ => ⎕FMT 
      c= esc:   (pfx, a) ∇ w⊣ a w← êxt CFEsc w         ⍝ `⍵, `⋄, `A, `B, etc.
      c= omUs:  (pfx, a) ∇ w⊣ a w← êxt CFOm w          ⍝ ⍹, alias to `⍵ (see CFEsc).
      c= libra: (pfx, êxt libUtils.LibAuto w) ∇ w      ⍝ £ library.
      ~c∊sdcfCh: ⎕SIGNAL cfLogicÊ                      ⍝ CFBrk leaked unknown char.
    ⍝ '→', '↓' or '%'. See if a "regular" char/shortcut or self-defining code field      
      êxt.brC>1:    (pfx, c scA⊃⍨ c= pct) ∇ w          ⍝ internal dfn => not SDCF
        p← +/∧\' '=w
      rb≠ ⊃p↓w:  (pfx, c scA⊃⍨ c= pct) ∇ w             ⍝ not CF-final '}' => not SDCF
    ⍝ SDCF: SELF-DEFINING CODE FIELD
        cfLit← AplQt êxt.cfBeg↑⍨ êxt.cfL+ p            ⍝ Put CF-literal in quotes
        fmtr←  (scA scM⊃⍨ c='→')                       ⍝ vert or horiz. SDCF?
        (cfLit, fmtr, CFDfn pfx) ((p+1)↓w)             ⍝ ==> RETURN!
    }

⍝ ===========================================================================
⍝ ScanFStr main (executive) begins here
⍝    On entry: 
⍝        ⍺ is a namespace; 
⍝        ⍵ is the f-string, a possibly null char vector
⍝    Returns either a matrix:   êxt.dfn=0
⍝    or a char. string:         êxt.dfn∊ 1 ¯1
⍝ =========================================================================== 
⍝ êxt: A set of external ("global") objects, including options and variables passed
⍝    to utility functions that are outside the scope of ScanFStr (above).
⍝    The êxt namespace is passed in with the options only (noted below)
⍝    The rest are initialized below.
⍝ Note that there are two other (specialised) namespaces: 
⍝    parms and uLibÑ (which refers to namespace ⎕THIS.userLibrary).
⍝
⍝ ↓¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ User Options (U)
⍝ ↓ Name    Init  Descr
⍝ ¯ ¯¯¯¯¯¯¯ ¯¯¯¯  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
⍝ U dfn       0   Defines output format:
⍝                 0 (return ∆F mx output), 1 (return dfn), ¯1 (return dfn code string)   
⍝ U verbose   0*  runtime verbosity/debug flag. 
⍝             1*  1 if VERBOSE_RUNTIME global constant is 1.
⍝ U box       0   Display a box around each field, if set.
⍝ U auto      1   If 1, honors default/.∆F setting of parms.auto∊ 0 1.
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
    êxt fstr← ⍺ ⍵                                 
  ⍝ Validate options passed in êxt (⍺). dfn in (¯1 0 1), others in (0 1).
  êxt.((|dfn),verbose box auto inline)(0∊∊)0 1: ⎕SIGNAL optÊ                             ⍝  
    VMsg← (⎕∘←)⍣(êxt.(verbose∧¯1≠dfn))                 ⍝ Verbose option message 
  ⍝ Shortcuts: 
  ⍝    See ⍙Load_Shortcuts.
  ⍝ This must follow the ordering specified there EXACTLY.  
    (scA scB scC scD scF scJ scQ scS scT scW scÐ scM)← êxt.inline⊃ scCodeTbl   
    êxt.acache← ⍬                                      ⍝ £ibrary shortcut "autoload" cache...
    êxt.nl← êxt.verbose⊃ nl nlVis                      ⍝ A newline escape (`⋄) maps onto nlVis if verbose mode.
    êxt.flds← ⍬                                        ⍝ output fields, each a CV (Char Vec)
    êxt.omC←  0                                        ⍝ initialise omega counter to 0 (see `⍵)
    êxt.auto∧← libUtils.parms.auto                     ⍝ auto can usefully be 1 only if parms.auto is 1.     
                                                       ⍝ Start the scan (recursive).                    
    flds← '' ScanAll fstr                              ⍝ ...                          
                                                       ⍝ Scan complete.                                        
  0= ≢flds: VMsg '(1 0⍴⍬)', '⍨'/⍨ êxt.dfn≠0            ⍝ If there are no flds, return 1 by 0 matrix
    code← CFDfn (êxt.box⊃ scM scÐ), OrderFlds flds     ⍝ Order fields R-to-L so they will be evaluated L-to-R in ∆F.           
  0=êxt.dfn: VMsg code                                 ⍝ Emit code ready to execute
    fstrQ← ',⍨⊂', AplQt fstr                           ⍝ Is êxt.dfn (1,¯1): add quoted fmt string (`⍵0)
    VMsg lb, code, fstrQ, rb                           ⍝ Emit êxt.dfn-based str ready to cvt to êxt.dfn in caller
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
⍝ If global ESCAPE_CHAR is not present, '`' is used.
  esc← '`' {0=⎕NC ⍵: ⍺ ⋄ ⍬⍴⎕OR ⍵ } 'ESCAPE_CHAR' 
⍝ Basic quote chars
  dq sq← '"'''
⍝ qtsL qtsR:
⍝    Generate left and right quote pairs... Double-quote first for efficiency.
⍝    See QUOTES_SUPPLEMENTAL
  qtsL qtsR← (dq,¨2⍴sq) { 0=⎕NC ⍵: ⍺ ⋄ 0=≢v← ⎕OR ⍵: ⍺ ⋄ ⍺,¨ ↓⍉↑,⊆v } 'QUOTES_SUPPLEMENTAL'
⍝ Other basic characters
  sp lb rb lp rp dol omUs ra da pct libra← ' {}()$⍹→↓%£' 
⍝ Seq. `⋄ OR `◇ (see dia2[0, 1]) map onto ⎕UCS 13.
⍝ dia2[0]: Dyalog stmt separator (⋄) 
⍝ dia2[1]: Alternative character (◇) that is easier to read in some web browsers. 
  dia2← ⎕UCS 8900 9671   
⍝ Order brklist chars roughly by frequency, high to low. 
  cfBrkList← dq sq esc lb rb dol omUs ra da pct libra, ∊qtsL 
  tfBrkList← esc lb                 
  lb_rb← lb rb ⋄ om_omUs← om omUs ⋄ sp_sq← sp sq ⋄   esc_lb_rb← esc lb rb  
⍝ self-doc code field chars →↓%
  sdcfCh← ra da pct                                    

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
⍝ ∘ These must have zero side effects, except those reflected in êxt-namespace objects.
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

⍝ TFProc:  flds@CVV← êxt ∇ str
⍝ If a text field <str> is not 0-length, place in quotes and add it to êxt.flds.
⍝ Ensure adjacent fields are sep by ≥1 blank.
  TFProc← {0=≢⍵: ⍺.flds ⋄ 0≠ ≢⍵: ⍺.flds,← ⊂sp_sq, sq,⍨ ⍵/⍨ 1+ sq= ⍵ ⋄ ⍺.flds }  

⍝ CFEsc:  (code w)← êxt ∇ fstr
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
  ⍝        qS w←  êxt ∇ qtL fstr 
  ⍝ ∘ qtL is the specific left-hand quote we saw in the caller.
  ⍝   We determine qtR internally.
  ⍝ ∘ fstr is the current format string, w/ the qtL removed, but end not determined..
  ⍝ ∘ For quotes with different starting and ending chars, e.g. « » (⎕UCS 171 187).
  ⍝   If « is the left qt, then the right qt » can be doubled in the APL style, 
  ⍝   and a non-doubled » terminates as expected.
  ⍝ ∘ Updates êxt.cfL with length of actual quote string.
  ⍝ Returns: qS w
  ⍝    qS: the string at the start of ⍵; w: the rest of ⍵ 
  CFQS← { êxt← ⍺ ⋄ qtL w← ⍵ 
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
        c= esc: (a, (p↑ ⍵), map) lW ∇ ⍵↓⍨ lW+← p+ skip⊣ map skip← êxt.nl CFQSEsc c2 qtR             
      ⍝ Closing Quote: 
      ⍝ c= qtR:  
      ⍝   ∘ Now see if the NEXT char, c2, such that c2= qtR.
      ⍝     If so, it's a string-internal qtR. Only qtR need be doubled (i.e. '»»' => '»').
        c2= qtR:  (a, ⍵↑⍨ p+1) lW ∇ ⍵↓⍨ lW+← p+2       ⍝ Use APL rules for doubled ', ", or »
          (AplQt a, p↑⍵) (lW+ p)                       ⍝ Done... Return
      }
      qS lW← '' 1 Scan w          
      qS (w↓⍨ êxt.cfL+← lW)                            ⍝ w is returned sans CF quoted string 
  } ⍝ End CF Quoted-String Scan

⍝ CFQSEsc:  (map len)← nl ∇ c2 qtR, where 
⍝           nl is the current newline char;
⍝           c2 is the char AFTER the escape char,
⍝           qtR  is the current right quote char.
⍝ c2= qt: esc+qtR is NOT treated as special-- this is APL, not C or HTML or ...
⍝ Returns (map len), where
⍝         map is whatever the escape seq or char maps onto (possibly itself), and
⍝         len is 1 if it consumed just the escape, and 2 if it ALSO consumed c2.
⍝ Side effect: none.       ⍝ pattern   =>  literal  consumes   notes
  CFQSEsc← { c2 qtR← ⍵ 
    c2∊ dia2: ⍺  2         ⍝ esc-⋄          newline     2 
    c2= qtR: esc 1         ⍝ escape-quote   esc         1   caller handles qtR next cycle.
    c2= esc: c2  2         ⍝ esc-esc        esc         2   
       (esc, c2) 2         ⍝ esc <any>      esc <any>   2   esc taken literally. 
  } 

⍝ CFOm:   (omCode w)← êxt ∇ ⍵ 
⍝ ⍵: /\d*/, i.e. optional digits starting right AFTER `⍵ or ⍹ symbols.
⍝ Updates êxt.cfL, êxt.omC to reflect the # of digits consumed and their value.  
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
⍝ The process:
⍝   ∘ ensure we reverse the order of fields, NOT the chars inside each field! 
⍝   ∘ reverse the ¨field¨ order now,
⍝      ∘  evaluate each field via APL ⍎ R-to-L, as normal, then 
⍝   ∘ reverse the ¨result¨  at execution time to achieve apparent L-to-R field-by-field evaluation.
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
  ⍝ parms: Load any new parms without a ]load. 
  ⍝        Returns display of default and user parms (as mx) in alph order.
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
    ⍝   libUser, Auto, parms, ShowPath, LoadParms 
      ⎕THIS.libUser← libNs
      libNs.⎕DF ⎕NULL                                  ⍝ Clear any prior ⎕DF.
      libNs.⎕DF '£=[',(⍕libNs),' ⋄ auto:0]'            ⍝ Now, set ours.
      Auto← (⍕libNs)⍨  
      'parms' ⎕NS '⍙readParms' 'auto'⊣ ⍙readParms auto← (0 0) 0 
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

⍝⍝⍝ Code for emulating Dyalog 20 services in Dyalog 19...
⍝⍝⍝ WARNING! These do only what we need internally, not the entire service domain.
⍝⍝⍝ If we are on Dyalog version 20, we just use those, of course.
⍝ ∆VGET, ∆VSET, AN2Apl, (same for both so far:) Apl2AN
  ∇ {aplVersion}← ⍙Gen_LegacyAplAN aplVersion ; whoops  
    :IF aplVersion< 20                         ⍝ Are we on Dyalog version 20 or later?
      ∆VGET← { (↓⊃⍵) ⍺.{ 0≠⎕NC ⍺: ⎕OR ⍺ ⋄ ⍵ }¨ ⊃⌽⍵ }
      ∆VSET←{ 
        ⍺←⊃⎕RSI ⋄ êxt← ⍺.{ ⍎⍺,'←⍵' } 
        2=⍴⍴⊃⍵: ⍺⊣ êxt⍤1 0/ ⍵ ⋄ ⍺⊣ êxt/¨⍵
      }
      ∆NS← { n1 n2← ⍵ ⋄ nl← n2.⎕NL ¯2    
        (⎕NS n1) ∆VSET (↑nl) (n2.⎕OR¨nl)
      }
      :IF VERBOSE_LOADTIME
          ⎕←59⍴'+'
          ⎕←'+ ∆F: Emulating ⎕VSET, ⎕VGET, and related on Dyalog v.','. +',⍨⍕aplVersion 
          ⎕←59⍴'+'
      :EndIf 
    :ELSE 
       ∆VGET← ⎕VGET
       ∆VSET← ⎕VSET
       ∆NS←   ⎕NS 
    :EndIf 
    AN2Apl← ⎕SE.Dyalog.Array.Deserialise   
    Apl2AN← ⎕SE.Dyalog.Array.Serialise                 ⍝ Apl2AN: Same for both versions
  ∇  

⍝ ⍙Export_∆F : rc← ∇ destNs keepCm lockFn 
⍝ Used internally only at FIX-time:
⍝ On execution (default mode), ⍙Export_∆F creates ∆F in location specified as <destNs>.
⍝ If keepCm, maintains comments in ∆F at destination.
⍝ If destNs is not namespace ⎕THIS, then we "promote the fn to target namespace,
⍝    ∘ obscure (mangle) local vars: ¨result¨ ¨opts¨ and ¨args¨
⍝    ∘ sets __OUTER__. to ##.
⍝    ∘ sets __THIS__ to refer to this namespace (i.e. ...⍙FUtils)
⍝ If destNs is the namespace ⎕THIS, then we:
⍝    ∘ set '__OUTER__.' to  ''
⍝ In both cases, if keepCm=0,
⍝    ∘ we remove comments and comment lines.
  ∇ fixedOk← ⍙Export_∆F (destNs keepCm lockFn) 
    ; nm; s; src; snk; t; Apply2; Cm ; CpyR; NoBL  
    s←  ⊂'∆FSrc'             '∆F'   
    s,← ⊂'__THIS__'           ∆THIS  
    s,← ⊂'__OUTER__\.'        ('##.' ''⊃⍨ destNs=⎕THIS) 
      t← ¯40↑ '⍝ TRAP_ERRORS='
    s,← ⊂'__TRAP_ERRORS__'    (('⍬0'⊃⍨ TRAP_ERRORS), t, ⍕TRAP_ERRORS)
    s,← ⊂'result'             'rësûlt∆F'
    s,← ⊂'opts'               'öôpts∆F'
    s,← ⊂'args'               'äârgs∆F'
  ⍝ 
    Apply2← { src snk← ↓⍉↑⍺ ⋄ src ⎕R snk⍠ 'UCP' 1 ⊢ ⍵} 
    Cm←     {⍺: ⍵ ⋄ '''[^'']*''' '(^\s*)?⍝.*$' ⎕R '\0' ''⊢ ⍵ }    
    CpyR←   ,∘(⊂'⍝ (C) 2025 Sam the Cat Foundation.  Version: ',VERSION)
    NoEmpty←   {⍵/⍨ 0≠≢¨⍵}    ⍝ Delete empty lines.

    nm← destNs.⎕FX CpyR NoEmpty s∘Apply2 keepCm∘Cm ⎕NR '∆FSrc' 
    :If fixedOk← 0≠1↑0⍴ nm 
      (⎕∘←)⍣VERBOSE_LOADTIME⊢ '>>> Created function ',(⍕destNs),'.',nm 
    :Else 
      ⎕←'>>> There was an error applying ⍙Export_∆F. Could not create "',(⍕destNs),'.∆F"' 
    :EndIf 
  ∇

⍝ ⍙Load_Shortcuts:   ∇     (niladic) 
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
  ∇ {ok}← ⍙Load_Shortcuts 
    ; scUser; scA2; scB2; scC2; scD2; scÐ2; scF2; scJ2; scM2; scQ2; scS2; scT2; scW2 
    ; XR ;HT 
    XR← ⎕THIS.⍎⊃∘⌽                                   ⍝ XR: Execute the right-hand expression
    HT← '⎕THIS' ⎕R ∆THIS                             ⍝ HT: "Hardwire" value of ⎕THIS. 
  ⍝ Above
    A← XR scA2← HT   ' ⎕THIS.A ' '{⎕ML←1⋄⍺←⍬⋄⊃⍪/(⌈2÷⍨w-m)⌽¨f↑⍤1⍨¨m←⌈/w←⊃∘⌽⍤⍴¨f←⎕FMT¨⍺⍵}' 
  ⍝ Box
    B← XR scB2← HT   ' ⎕THIS.B ' '{⎕ML←1⋄⍺←0⋄⍺⎕SE.Dyalog.Utils.disp⊂⍣(1≥≡⍵),⍣(0=≡⍵)⊢⍵}' 
  ⍝ Commas (Numeric ~)
      ⎕SHADOW 'cCod'  
      cCod←  '{'
      cCod,←   '⎕IO ⎕ML←0 1⋄'
      cCod,←   'd←3'',''⋄⍺←d⋄n s←⍺,d↑⍨0⌊2-⍨≢⍺⋄'   ⍝ d: defaults, n: ndigits, s: separator  
      cCod,←   'n←⍕n⋄s←{⍵≡⍥,''&'':''\&''⋄⍵/⍨1+''\''=⍵}s⋄' 
      cCod,←   'src←''[.Ee]\d+'' (''(?<=\d)(?=(\d{'',n,''})+([-¯.Ee]|(?=\s|$)))'')⋄'
      cCod,←   'snk←''&'' ('''',s,''&'')⋄'
      cCod,←   '1=≢w←{src ⎕R snk⊢⍵}⍤1⍕⍵: ⊃w⋄w'
      cCod,← '}'
    C← XR scC2← HT   ' ⎕THIS.C ' cCod 
  ⍝ Date: See Time (below)
  ⍝ Display
    Ð← XR scÐ2← HT   ' ⎕THIS.Ð ' ' 0∘⎕SE.Dyalog.Utils.disp¯1∘↓'    
  ⍝ Format                       
    F← XR scF2←      ' ⎕FMT '    ' ⎕FMT ' 
  ⍝ Justify
      ⎕SHADOW 'jCod' 
      jCod← '{'
      jCod,←   '⎕PP←34⋄⍺←''L''⋄B←{+/∧\'' ''=⍵}⋄'
      jCod,←   'w⌽⍨(1⎕C⍺){o←⊂⍺⋄'                ⍝ Treat ⍺ as a scalar.
      jCod,←         'o∊''L''¯1:B ⍵⋄'
      jCod,←         'o∊''R'' 1:-B⌽⍵⋄'
      jCod,←                   '⌈0.5×⍵-⍥B⌽⍵⋄'   ⍝ If invalid ⍺, assume 'C'.
      jCod,←   '}w←⎕FMT⍵'
      jCod,← '}' 
    J← XR scJ2← HT   ' ⎕THIS.J '   jCod  
  ⍝ Library
  ⍝ £, `L: Not here-- handled ad hoc in code (it's niladic)...   
  ⍝ Merge  
    M← XR scM2← HT   ' ⎕THIS.M '   '{⎕ML←1⋄⍺←⊢⋄⊃,/((⌈/≢¨)↑¨⊢)⎕FMT¨⍺⍵}'  
  ⍝ Quote                   
      ⎕SHADOW 'qCod'
      qCod←  '{'
      qCod,←   '⍺←⎕UCS 39⋄'            
      qCod,←   '1<|≡⍵:⍺∘∇¨⍵⋄'                              
      qCod,←   '(0=⍴⍴⍵)∧1=≡⍵:⍵⋄'                           
      qCod,←   '(0≠≡⍵)∧326=⎕DR⍵:⍺∘∇¨⍵⋄'                 
      qCod,←   '⎕ML←1⋄'                                                                     
      qCod,←   '⍺{0=80|⎕DR⍵:⍺,⍺,⍨⍵/⍨ 1+⍺=⍵⋄⍵}⍤1⊢⍵'        
      qCod,← '}'
    Q← XR scQ2← HT   ' ⎕THIS.Q ' qCod 
  ⍝ Serialise
      ⎕SHADOW 'sCod'
      sCod←  '{'
      sCod,←   '⎕ML←1⋄11 16 6::⍵⋄⍺←0⋄'     
      sCod,←   '1=≢s←⍺⎕SE.Dyalog.Array.Serialise⍵:⊃s⋄'
      sCod,←   '⍪s'
      sCod,← '}'
    S← XR scS2← HT   ' ⎕THIS.S '  sCod 
  ⍝ Time  
    T← XR scT2← HT   ' ⎕THIS.T ' '{⎕ML←1⋄⍺←''%ISO%''⋄∊⍣(1=≡⍵)⊢⍺(1200⌶)⊢1⎕DT⊆⍵}' 
  ⍝ Date
          scD2← scT2                            ⍝ D is alias to T.               
  ⍝ Wrap 
    W← XR scW2← HT   ' ⎕THIS.W ' '{⎕ML←1⋄⍺←⎕UCS 39⋄ 1<|≡⍵: ⍺∘∇¨⍵⋄L R←2⍴⍺⋄{L,R,⍨⍕⍵}⍤1⊢⍵}'

  ⍝ User-callable functions:          A  B  C  D  F  J  Q  S  T  W 
  ⍝                                   L (handled ad hoc); D (synonym to T)
  ⍝ ∆F-internal (non-user) funtions:  Ð  M
    scCodeTbl← ↓⍉↑scA2 scB2 scC2 scD2 scF2 scJ2 scQ2 scS2 scT2  scW2   scÐ2 scM2
    nSC← ≢scUser←  'A    B    C    D    F    J    Q    S    T     W'~' '                          
    MapSC← scUser∘⍳ 
    ok← 1 
  ∇
  ∇ {ok}← ⍙Load_Help hfi;e1; e2 
  ⍝ Loading the help html file...
    :Trap 22 
        ⎕THIS.helpHtml← ⊃⎕NGET hfi
        :IF VERBOSE_LOADTIME ⋄ ⎕← '>>> Loaded Help Html File "',hfi,'"' ⋄ :EndIf  
        ok← 1 
    :Else 
        e1← '>>> WARNING: When loading ∆Fapl, the help file "',hfi,'" was not found in current directory.'
        e2← '>>> WARNING: ∆F help will not be available without user intervention.'
        e1,(⎕UCS 13),e2
        ok← 0 
    :EndTrap 
  ∇
  ∇ {loadLib}← ⍙Load_LibAuto (fi loadLib)
    ; how 
    how← ' from "',fi,'" into "','"',⍨∆THIS 
    :If loadLib=0
        ⎕←'>>> NOTE: Library autoload services were not loaded',how
        ⎕←'>>> NOTE: LIB_ACTIVE is set to ',(⍕LIB_ACTIVE),' in ∆F/∆FUtils.dyalog'
        ⎕←'>>> NOTE: £ and `L shortcuts are available without them, as if (auto: 0) is set.'
        :Return 
    :EndIf 
    :TRAP 22 
        ⎕FIX 'file://',fi
        :If VERBOSE_LOADTIME 
            ⎕←'>>> Loaded services for Library shortcut (£)',how  
        :EndIf 
    :Else
        loadLib← 0 
        ⎕← ⎕PW⍴'='
        ⎕←'>>> WARNING: Unable to load Library autoload services',how 
        ⎕←'>>> NOTE:    £ and `L shortcuts are available without them (auto: 0).'
        ⎕← ⎕PW⍴'='
    :EndTrap
  ∇
⍝ Show the following special globals in this namespace.
  ⍙ShowGlobalsIf←{
     These←  'ESCAPE_CHAR'  'HELP_HTML_FI' 'INLINE_UTILS' 
     These,← 'LIB_ACTIVE' 'SHOW_LIB_ERRS' 'LIB_PARM_FI'  
     These,← 'LIB_USER_FI' 'LIB_SRC_FI' 'OPTS_KW' 'QUOTES_SUPPLEMENTAL' 'TRAP_ERRORS'  
     These,← 'VERBOSE_LOADTIME' 'VERBOSE_RUNTIME' 'VERSION'
    ~⍵: _←1 0⍴0  
      vv← 1∘⎕SE.Dyalog.Array.Serialise∘⎕OR¨ kk← These[⍋These]
    1: _← ↑  '(', ')',⍨ vv {'  ',⍵ , ⍺}¨ (1+⌈/≢¨ kk)↑¨kk,¨ ':'  
  }
⍝ ====================================================================================
⍝ Execute the FIX-TIME Routines
⍝ ====================================================================================
  ⍝ ∆NS, ∆VGET, ∆VSET, AN2Apl, Apl2AN are version-aware.
    ⍙Gen_LegacyAplAN  ⊃⊃⌽'.'⎕VFI 1⊃'.' ⎕WG 'APLVersion'  
    OPTS_DEFns← (⎕NS⍬)∆VSET OPTS_KW OPTS_DEFval        ⍝ Generate default opts NS
    ⍙Export_∆F ##  0 1  
    ⍙Load_Shortcuts
    ⍙Load_Help HELP_HTML_FI
    ⍙Load_LibAuto LIB_SRC_FI LIB_ACTIVE
    ⍙ShowGlobalsIf VERBOSE_RUNTIME
:EndSection FIX_TIME_ROUTINES 
⍝ === END OF CODE ================================================================================
:EndNamespace 

⍝ (C) 2025 Sam the Cat Foundation
