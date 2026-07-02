:Namespace FString   
⍝  Requires Dyalog 20 or later!
:Section CORE  
⍝ Env for ∆F code. Remember, user code is executed in CALLER space (⊃⎕RSI) 
  ⎕IO ⎕ML ⎕PP← 0 1 34     
⍝ Loader ∆F.dyalog shares transient namespace ⎕SE.∆F⍙Share, containing: 
⍝ - global variables in globals
⍝ - source for the library (£,`L) code as libsrc
⍝ 
⍝ [1] Save (as a global) the names of all the globals passed here for later use.
  GLOBALS← ⎕SE.∆F⍙Share.globals.⎕NL ¯2 ¯9  
⍝ [2] Merge the globals into this ns.
  ⎕THIS ⎕NS ⎕SE.∆F⍙Share.globals
⍝ Set char. rendering of ⎕THIS, so we can set ⎕THIS.⎕DF to something arbitrary.
  ∆THIS← ⍕⎕THIS                

   :Section   ∆F SOURCE
⍝ =======================================================================
⍝ ∆F Utility 
⍝ =======================================================================
⍝ ∆F: 
⍝    result← {opts←⍬|()} ∇ f-string [args]
⍝ See notes elsewhere on ∆F itself.
⍝ 
  ∇ result← {opts} ∆F args  
      :TRAP TRAP_ERRORS/0                                       
      ⍝ Phase I: Set options and normalise args! 
      ⍝          User option styles? kw=keyword-style, pos'l=positional-style        
        :If  900⌶0                                            ⍝ No opts
            opts← ⎕NS OPTS_DEFns                              ⍝ → Copy OPTS_DEFns                
        :ElseIf 9=⎕NC 'opts'                                  ⍝ opts references a namespace
            opts← ⎕NS OPTS_DEFns opts                         ⍝ → Copy OPTS_DEFns and kw user opts                        
        :ElseIf 11 83∊⍨ ⎕DR opts ⋄ :AndIf OPTS_KW ≥⍥≢ opts    ⍝ Ints / booleans, none trailing
            opts← OPTS_DEFns ⎕NS⍛⎕VSET (OPTS_KW↑⍨≢opts) opts  ⍝ → Copy OPTS_DEFns and pos'l user opts
        :Else                                                 ⍝ Kitchen sink 
            result← args Special opts ⋄ :Return               ⍝ → Help / other special or error
        :EndIf 
        args← ,⊆args  
      ⍝ Phase II: Execute!  **************                   
      ⍝ Determine output mode based on opts.dfn and execute.
        :Select opts.dfn  
      ⍝  0: Execute F-string    
        :Case  0              ⍝ Executed code string refs args (as ⍵), not just ⊃⍵.
            result← opts ((⊃⎕RSI){ ⍺⍺⍎ ⍺ ScanFStr ⊃⍵⊣ ⎕EX 'opts' 'args'}) args 
      ⍝  1: Generate dfn code 
        :Case  1       
            result← (⊃⎕RSI) ⍎ opts ScanFStr ⊃args
      ⍝  ¯1: Generate source code for dfn
        :Case ¯1                                    
            result← opts ScanFStr ⊃args  
      ⍝  Else: Run help or other special code           
        :Else          ⍝ 'help', etc. => Give help, etc.      
            result← Special opts  
        :EndSelect   
    :Else 
        ⎕SIGNAL ⊂⎕DMX.('EM' 'EN' 'Message' ,⍥⊂¨('∆F ',EM) EN Message) 
    :EndTrap 
  ⍝! (C) Copyright 2025, 2026 Sam the Cat Foundation
  ∇
   :EndSection   ∆F Utility 
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
      p= ≢⍵:  ⎕SIGNAL êBr                              ⍝ Missing "}" => Error. 
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
    ⍝ FUTURES: ⍥ Adam B's CircleDiaeresis (optional).    
    ⍝          … Adam B's Ellipsis (optional)    ⊇ Select / Sane Indexing.
      c∊ FUTURES: w ∇⍨ pfx, scCD scEl scSel c⊃⍨ cd el rsu⍳ c    
      ~c∊selfDoc: ⎕SIGNAL êCfLogic                     ⍝ If guard true, CFBrk leaked unknown char.
    ⍝ '→', '↓' or '%'. See if a "regular" char/shortcut or self-defining code field      
      ûsr.brC>1: w ∇⍨ pfx, c scA⊃⍨ c= pct              ⍝ internal dfn => not SDCF
        p← +/∧\' '=w
      rb≠ ⊃p↓w:  w ∇⍨ pfx, c scA⊃⍨ c= pct              ⍝ not CF-final '}' => not SDCF
    ⍝ SDCF: SELF-DEFINING CODE FIELD
        cfLit← AplQt ûsr.cfBeg↑⍨ ûsr.cfL+ p            ⍝ Put CF-literal in quotes
        fmtr← scA scM⊃⍨ c='→'                          ⍝ vert or horiz. SDCF?
        (cfLit, fmtr, CFDfn pfx) ((p+1)↓w)             ⍝ ==> RETURN!
    }   

⍝ ===========================================================================
⍝ ScanFStr executive begins here
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
⍝                 1 if INLINE_DEF is set to 1.
⍝   acache    ⍬   autoload cache char. vector of vectors  
⍝   nl        CR  newline: nl (CR) or nlVis (the visible newline '␤').  
⍝   fields    ⍬   global field list
⍝   omC       0   omega index counter: current index for omega shortcuts (`⍵, ⍹).
⍝                 Local to the current ∆F instance.
⍝   brC       -   running count of braces '{' lb, '}' rb. Set in dfn ScanAll.
⍝   cfL       -   code field running length (for SDCFs). Set in dfn ScanAll.
    ûsr← ⍺                                
  ⍝ Validate all options passed in ûsr (⍺).  dfn∊ ¯1 0 1; others ∊ 0 1.
  0∊ ûsr.(verbose box auto inline (|dfn))∊ 0 1: ⎕SIGNAL êOpt  
  ⍝ See if we have the fstr code in the fstr cache-- only if dfn=0  
  ⍝ If so, we are done!
    argK← ⍵, ⊂ûsr.( verbose box inline )               ⍝::ARG_CACHE
  0≠ ≢val← ûsr.dfn ArgCacheGet argK: val               ⍝::ARG_CACHE
  ⍝ Shortcuts used explicitly (not just via esc+alphabetic): 
  ⍝    See ⍙Load_Shortcuts 
    scA scCD scEl scÐ scF scM scSel← ûsr.inline⊃¨ (
      scA2 ⋄ scCD2 ⋄ scEl2 ⋄ scÐ2 ⋄ scF2 ⋄ scM2 ⋄ scSel2
    ) 
    ûsr.acache← ⍬                                      ⍝ £ibrary shortcut "autoload" cache...
    ûsr.nl← ûsr.verbose⊃ nl nlVis                      ⍝ A newline escape (`⋄) maps onto nlVis if verbose mode.
    ûsr.flds← ⍬                                        ⍝ output fields, each a CV (Char Vec)
    ûsr.omC←  0                                        ⍝ initialise omega counter to 0 (see `⍵)
    ûsr.auto∧← libUtils.pârms.auto                     ⍝ auto can usefully be 1 only if pârms.auto is 1.     
⍝   *** START THE SCAN ***                             ⍝ Start the scan (recursive).                    
    flds← '' ScanAll⊢ fstr← ∊⍵                         ⍝    fstr: char vec of vecs => char vec                     
⍝   *** SCAN COMPLETE ***                              ⍝ Scan complete. 
    VMsg← (⎕∘←)⍣(ûsr.(verbose∧¯1≠dfn))                 ⍝ Verbose option message                                        
  0= ≢flds: VMsg '(1 0⍴⍬)', '⍨'/⍨ ûsr.dfn≠0            ⍝ If there are no flds, return 1 by 0 matrix
    code← CFDfn (ûsr.box⊃ scM scÐ), OrderFlds flds     ⍝ Order fields R-to-L so they will be evaluated L-to-R in ∆F.           
    code← argK ArgCacheSet code                        ⍝::ARG_CACHE
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
⍝ ' '{  }  (  )  $   ⍹    →  ↓  %   £     ⍥  …  ⊇
  sp lb rb lp rp dol omUs ra da pct libra cd el rsu← ' {}()$⍹→↓%£⍥…⊇'  ⍝ rsu: right shoe underbar
⍝ Seq. `⋄ and `◇ (see dia2[0, 1]) map onto ⎕UCS 13.
⍝ dia2[0]: Dyalog stmt separator (⋄) 
⍝ dia2[1]: Alternative character (◇) that is easier to read in some web browsers. 
  dia2← ⎕UCS 8900 9671           ⍝ '⋄◇' <-- hope that clears things up ;-) 
⍝ Order "break" chars roughly by frequency, high to low. 
⍝ We take dq to be high freq, but other quotes as low.
⍝               "  `   {  }  $   ⍹    →  ↓  %   £      '« (default)
  cfBrkList←  ∪ dq esc lb rb dol omUs ra da pct libra, qtsL  
⍝ See defs of FUTURES, cd (⍥), el (…) rsu (⊇) 
  cfBrkList,← cd rsu el/⍨ cd rsu el ∊ FUTURES
  tfBrkList← esc lb                 
  lb_rb← lb rb ⋄ om_omUs← om omUs ⋄ sp_sq← sp sq ⋄   esc_lb_rb← esc lb rb  
⍝ self-doc code field chars →↓% (only on rhs of cf, ignoring blanks)
  selfDoc← ra da pct                                    

⍝ Error constants and fns  
    Ê← { ⍺←11 ⋄ ⊂'EN' ⍺,⍥⊂ 'Message' ⍵ }
  êBr←         Ê 'Unpaired brace "{"'
  êQt←         Ê 'Unpaired quote in code field' 
  êCfLogic←    Ê 'A logic error has occurred processing a code field'
  êOpt←        Ê 'Invalid option(s) in left argument. For help: ∆F⍨''help'''
  êScBad←      Ê {'Sequence "`',⍵,'" does not represent a valid shortcut.'}
               T1←{
                  t1← 'Sequence "`',⍵,'" not valid in code fields outside strings.'
                  t2← 'Did you mean "',⍵,'"?'
                  t1,nl,(17⍴''),t2 
               }
  êEsc←        Ê T1 ⋄ ⎕EX 'T1'  
               t1← 'Help file "',HELP_HTML_FI,'" not found in current directory (CD)'
               t2← 'CD: "','"',⍨⊃1 ⎕NPARTS ''
  êHelpFi←  22 Ê t1,(⎕UCS 13),(17⍴''),t2 
               ⎕EX 't1' 't2'
   :EndSection Constants

   :Section Argument Cache 
    argCache← ( kk: ⍬ ⋄ vv: ⍬ ⋄ max: ARG_CACHE_MAX ⋄ keep: ARG_CACHE_KEEP ) ⍝::ARG_CACHE
    ArgCacheSet← argCache. { (kk vv),← ⊂¨k v← ⍺ ⍵ ⋄ max≥ ≢kk: ⍵ ⋄ kk↑⍨← -keep ⋄ ⍵ }  ⍝::ARG_CACHE                         
    ArgCacheGet← argCache. { ⍺≠0: ⍬ ⋄ p←kk⍳ ⊂⍵ ⋄ kk≢⍛> p: p⊃ vv ⋄ ⍬ } ⍝::ARG_CACHE
   :EndSection Argument Cache 

   :Section Utilities (Must Have Zero Side Effects) 
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
⍝ Returns the current array of fields (CVV)
  TFProc← {0=≢⍵: ⍺.flds ⋄ ⍺.flds,← ⊂sp_sq, sq,⍨ ⍵/⍨ 1+ sq= ⍵ ⋄ ⍺.flds }  

⍝ CFEsc:  (code w)← ûsr ∇ fstr
⍝ Handle escapes  in Code Fields OUTSIDE of CF-Quotes.  
⍝ Returns code, the executable code, and w, the text of ⍵ remaining.                                 
  CFEsc← {                                    
    0= ≢⍵: esc 
      c w← (0⌷⍵) (1↓⍵) ⋄ ⍺.cfL+← 1   
    c∊ om_omUs: ⍺ CFOm w                               ⍝ Permissively allows `⍹ as equiv to `⍵ OR ⍹ 
    c='L': (⍺ libUtils.LibAuto w) w                    ⍝ Library shortcut: special (niladic) case
      p← sc.Map c                                      ⍝ Look for other shortcuts
    sc.nEsc> p: (⍺.inline p⊃ sc.tbl) w                 ⍝ Found? return code string.
    c∊⍥⎕C ⎕A: ⎕SIGNAL êScBad c                         ⍝ Nope: Unknown shortcut!
      ⎕SIGNAL êEsc c                                   ⍝ Nope: An escape foll. by non-alphabetic.
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
        p= ≢⍵: ⎕SIGNAL êQt 
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
⍝ ∆F called with this syntax, where ⍺ stands for the options listed below.
⍝       '⍺' ∆F anything  OR  ∆F⍨'⍺
⍝ Special options (⍺).  
⍝  Documented...
⍝    ∘ ∇⍨'help' | ∇⍨'help-w[ide]'
⍝      Displays the help information in standard (wide) format; returns (1 0⍴0).
⍝    ∘ ∇⍨'help-n[arrow]'
⍝      Displays the help information in narrow format; returns:  (1 0⍴⍬).
⍝    ∘ ∇⍨'parms'
⍝      Resets and returns parameters for £, `L shortcuts in multi-line form.
⍝    ∘ ∇⍨'parms-c'
⍝      Resets parameters and returns active parameters for £, `L options in compact form.
⍝  Undocumented...
⍝    ∘ ∇⍨'globals'
⍝      Returns all the std global variables with their values.
⍝    * ∇⍨'path'
⍝      Returns all the files and workspace directories used for £, `L shortcuts.
⍝    * 'get' ∇ 'parameter' value
⍝      Returns the current value of the named parameter. The parameter must be valid.
⍝    * 'set' ∇ 'parameter'  new_value
⍝      Sets the named parameter to a new value.
⍝      Returns the previous value. The parameter must be valid.
⍝ 
  Special← { 
    val← ⎕C ⍕⍵                                    ⍝ ⍺ is referenced for 'get' and 'set' only
  ⍝ pârms: Load any new pârms without a ]load. 
  ⍝        Returns display of default and user pârms (as mx) in alph order.
    2≠ ⎕NC 'val': ⎕SIGNAL êOpt  
  ⍝ LoadParms (isVerbose isCompact isRuntime)   
    'parms-c'≡   val: _← libUtils.LoadParms  (verbose: 1 ⋄ compact: 1 ⋄ runtime: 1)
    'parms'  ≡ 5↑val: _← libUtils.LoadParms  (verbose: 1 ⋄ compact: 0 ⋄ runtime: 1) 
    'path'   ≡   val: _← libUtils.ShowPath ⍬ 
  ⍝  globals
    'glo'    ≡ 3↑val: _← ShowGlobalsIf 1                 ⍝ list all "globals"
  ⍝  symbols 
    'sym'    ≡ 3↑val: _← ShowSymbols ⍬                   ⍝ special symbols
  ⍝  * = all of the above
    '*'      ≡   val: _← ShowAll⍬
  ⍝ If pfx of <val> not 'help', option error.
    'help'   ≢ 4↑val: ⎕SIGNAL êOpt 
  ⍝ help | help-n[arrow] | help-w[ide] 
      CLoadHtml← {   ⍝ Conditionally load help html file, i.e. if not already loaded...
        22:: ⎕SIGNAL êHelpFi 
        0= ⎕NC ⍵: ⊢⎕THIS.helpHtml← ⊃⎕NGET HELP_HTML_FI 
          ⎕THIS.helpHtml  
      }
      RenderHtml← {  ⍝ Fallback to Ride, if no HTMLRenderer...
        0::  16 ⎕SIGNAL⍨ 'NONCE ERROR: No renderer available to display HELP information'
        0::  ⍬⊣ 3500⌶ ⍺ 
          ⍬⊣ 'htmlObj' ⎕WC 'HTMLRenderer',⍥⊆ ⍵ 
      }  
      html← CLoadHtml 'helpHtml' 
    ⍝ Screen widths determined by help subtype (wide or narrow).
    ⍝ Is val 'help-n[arrow]' or 'help[-wide]' (wide is default). 
      s← (900 1000) (900 1350)⊃⍨ ~'-n'(1∘∊⍷)val   
      obj← ('HTML' html) (s,⍨ ⊂'Size') (15 35,⍨ ⊂'Posn') ('Coord' 'ScaledPixel')   
      1 0⍴⍬⊣ html RenderHtml obj    
  }  
  ShowSymbols← {
    ↑(
      ('  Special: "⍹£`"       ⍝ ⍹:omega-underscore, £:libra(ry), `:escape') 
      ('  Futures: "', FUTURES,'"')
    )
  } 
  ShowAll←{
      ⎕← 'Symbols:'
      ⎕← ShowSymbols⍬
      ⎕← 'Globals:'
      ⎕← ShowGlobalsIf 1
      ⎕← '(Library) Parms:'
      ⎕← '  ',,libUtils.LoadParms  (verbose: 1 ⋄ compact: 1 ⋄ runtime: 1)
      ⎕← '(Library) Path:'
      ⎕← '  ',libUtils.ShowPath ⍬
    1: _←⍬
  }      
  
:EndSection HELP AND ERROR SERVICES

⍝ ===================================================================================

⍝ ===================================================================================
:Section SKELETAL LIBRARY SERVICES 
⍝ See libUtils.LinkUserLib
⍝ userLibrary is the user library.
:Namespace userLibrary
  ⍝ Minimal contents, pending LoadLibAuto.
  ⍝ Inherit key sys vars from the # namespace.
    ⎕IO ⎕ML ⎕PW ⎕PP ⎕CT ⎕DCT ⎕FR← #.(⎕IO ⎕ML ⎕PW ⎕PP ⎕CT ⎕DCT ⎕FR)     
:EndNamespace

⍝ Utilities for "userLibrary" shortcut (£, `L) 
⍝ See LoadLibAuto 
:Namespace libUtils
⍝⍝⍝⍝⍝ This is a local stub, pending (optional, but expected) load of ∆FLibUtils below.
  ∇ {libNs}←  LibSimple libNs 
    ; ⍙readParms; auto
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

:Section Shortcut functions `A, `B, `C, etc.
⍝ Above
    A← {
      ⎕ML←1 ⋄ ⍺←⍬
      ⊃⍪/(⌈2÷⍨w-m)⌽¨f↑⍤1⍨¨m←⌈/w←⊃∘⌽⍤⍴¨f←⎕FMT¨⍺⍵
    } 
  ⍝ Box
    B← {
      ⎕ML←1 ⋄ d←|≡⍵ ⋄ ⍺←0
      ⍺ ⎕SE.Dyalog.Utils.disp⊂⍣(1≥d),⍣(0=d)⊢⍵
    }  
  ⍝ Commas - Inserts a separator s (default ",") every n (default 5) digits in
  ⍝          the integer part of each right argument string.
  ⍝          You may enter no left arg or a left arg of: n, s, n s, or s n, with
  ⍝          omitted elements (n or s) replaced by the defaults. 
  ⍝          Note: n is either an integer or a (character) digit.
  ⍝          These are the same:  "5_" and (5 "_").
  ⍝      Examples:
  ⍝          E.g.  { `C "123324"}     { 4 `C "123324"}     { 4 "_" `C "123324"}
  ⍝                { "_" `C "123324"} { "_" 4 `C "123324"}
  ⍝          Items omitted in the left arg will have their defaults: 3 ","
    C←{ 
      ⎕IO ⎕ML←0 1 ⋄ nd← ≢def← 3 ',' ⋄ ⍺← def 
      Opt← ⍕¨{                                          ⍝ Get options; def=defaults, o=options (⍺) 
        o←⍵ ⋄ isN← (⎕D∊⍨ ⊃o)∨ 0=⊃0⍴o                    ⍝ isN=1 if first option is <a number or digit>
        isN: o,(def↑⍨-0⌈nd-≢o) ⋄ (def↑⍨0⌈nd-≢o),⌽o    
      }  
      Esc← { ⍵≡⍥, '&': '\&' ⋄ ⍵/⍨1+ '\'= ⍵}             ⍝ Escapes. In case & or \ is the char separator
      n s← Opt ⍺
      src← '[.Ee]\d+',⍥⊂ '(?<=\d)(?=(\d{', n, '})+([-¯.Ee]|(?=\s|$)))'
      snk← '&',⍥⊂ '&',⍨ Esc s 
      w← src ⎕R snk⍤1 ⍕⍵
      ⊃⍣(1=≢⍵)⊢ w  
    } 
  ⍝ Date: See Time (below)
  ⍝ Display
    Ð← 0∘⎕SE.Dyalog.Utils.disp¯1∘↓
  ⍝ Format        
    F← ⎕FMT                 
  ⍝ Justify
    J← {
        ⎕PP←34⋄⍺←'L'⋄B←{+/∧\' '=⍵}
        w⌽⍨(1⎕C⍺) { o← ⊂⍺                               ⍝ Treat ⍺ as a scalar.
          o∊'L'¯1:B ⍵
          o∊'R' 1:-B⌽⍵ 
          o∊'C' 0: ⌈0.5×⍵-⍥B⌽⍵                          ⍝ If o is invalid, drop off ends of earth.
          ⎕SIGNAL ⊂ ('EN' 11) ('Message' 'Shortcut option (⍺) was invalid')
        } w←⎕FMT⍵
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
      ⍺← ''''               
      1<|≡⍵:⍺∘∇¨⍵                              
      (0=⍴⍴⍵)∧1=≡⍵:⍵                           
      (0≠≡⍵)∧326=⎕DR⍵:⍺∘∇¨⍵                 
      ⎕ML←1                                                                   
      ⍺{0=80|⎕DR⍵:⍺,⍺,⍨⍵/⍨ 1+⍺=⍵⋄⍵}⍤1⊢⍵        
    }
  ⍝ Serialise (display in APLAN)
    S← { 
      ⎕ML←1⋄11 16 6::⍵⋄⍺←0⋄     
      1=≢s←⍺⎕SE.Dyalog.Array.Serialise⍵:⊃s⋄
      ⍪s
    }
  ⍝ Time / Date   
    T← {
      ⎕ML←1 ⋄  ⍺←'%ISO%'
      ∊⍣(1=≡⍵)⊢⍺(1200⌶)⊢1⎕DT⊆⍵
    }
  ⍝ Wrap 
    W← {
      ⎕ML←1 ⋄ ⍺←⎕UCS 39
      1<|≡⍵: ⍺∘∇¨⍵
      L R←2⍴⍺⋄{L,R,⍨⍕⍵}⍤1⊢⍵
    }
  
  ⍝ Select (Sane Indexing):  ⊇
    selCodeStr← '(⊂⍛⌷)'                      ⍝ '(⌷⍤0 99)' if APL_VERSION< 20 

  ⍝ Futures
  ⍝ [1] CircleDiaeresis (op)
  ⍝ Adam B's "future" ⍥ with depth operator extension 
  ⍝ NOTE: This is the dfns version-- 
  ⍝    See the function below for details on variants.
  ⍝ [2]Ellipsis (fn) 
  ⍝ Adam B's future … enhancement to dfns fn ¨to¨.
  ⍝   2 … 10, 'a' … 'z', etc. 
    cdNm elNm← { 22:: '' ⋄ ⊃2 ⎕FIX 'file://∆F/Futures/',⍵}¨ 'CircleDiaeresis.aplo' 'Ellipsis.aplf'


:EndSection Shortcut functions 

⍝ LoadShortcutCalls:   sc← ∇     (niladic) 
⍝ At ⎕FIX time, load the run-time userLibrary names and code for user Shortcuts
⍝ and similar code (Ð, display, is used internally, so not a true user shortcut).
⍝ The userLibrary entries created in ∆Fapl are: 
⍝  ∘  for shortcuts:    A, B, C, F, Q, T, W     ⍝ T supports `T, `D
⍝  ∘  used internally:  M, Ð.
⍝ A (etc): a dfn
⍝ scA (etc): [0] local absolute name of dfn (with spaces), [1] its code              
⍝ Abbrev  Descript.       Valence     User Shortcuts   Notes
⍝ A       [⍺]ABOVE ⍵      ambi       `A, %             Center ⍺ above ⍵. ⍺←''.  Std sc is %
⍝ B       [⍺]BOX ⍵        ambi       `B                Put ⍵ in a box.
⍝ C       [⍺]COMMAS       ambi       `C                Add commas (⍺[1]) to numbers every 3 (⍺[0]) digits R-to-L
⍝ Ð       DISPLAY ⍵       dyadic                       Var Ð only used internally...
⍝ F       [⍺]FORMAT ⍵     ambi       `F, $             ⎕FMT.   Std is $
⍝ J       [⍺]JUSTIFY ⍵    ambi       `J                justify rows of ⍵. ⍺←'l'. ⍺∊'lcr' left/ctr/rght.
⍝ -       LIBRARY         niladic     £, `L            £.nm1 (etc) handled in line (ad hoc) 
⍝ M       [⍺]MERGE ⍵      ambi                         Var M only used internally...
⍝ Q       [⍺]QUOTE ⍵      ambi       `Q                Put only text in quotes. ⍺←''''
⍝ S       [⍺]SERIALISE ⍵  ambi       `S                Apl Array Notation Serialise
⍝ T       [⍺]DATE-TIME ⍵  ambi       `T, `D            Format ⍵, 1 or more timestamps, acc. to ⍺.
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
  ∇ {sc}← LoadShortcutCalls 
  ; cdFut; elFut; rsuFut; g; grps; scEscCodes; _ 
  ; CPublish ; Fn2Inline; In  
  ⍝:Extern cd; cdNm; el; elNm; rsu; selCodeStr; VERBOSE_LOADTIME

    CPublish← { 
        ⍺← 1 ⋄ alt (nm char)← ⍺ ⍵ 
      0≡alt: 2⍴ char
        (' ',' ',⍨ ∆THIS,'.',nm)  (alt Fn2Inline nm) nm 
    }
    Fn2Inline← {  
      0≠⊃0⍴ ⍺: ⍺
        s← 61 ⎕ATX ⍵                       ⍝ src in
        b←  (⊂f↓⍨ 2+'←'⍳⍨ f←⊃s), 1↓ s      ⍝ body
        src snk← ↓⍉↑(
          ('''[^'']*'''         '\0')       ⍝ Quotes
          ('\h*⍝.*'             '')         ⍝ comments
          ('^\h+|\h+$'          '')         ⍝ leading/trailing spaces
          ('\h*([←⋄⎕{}()]+)\h*' '\1')       ⍝ spaces before/after any of these "←⋄⎕{}()"
        )
        ib← src ⎕R snk⍠('Mode' 'M')⊣ b                  ⍝ inline form of body
      1= ≢ib: ⊃ib                          ⍝ single stmt; output as is.
        '{', 1↓ ¯1↓ ∊'⋄',⍨¨ ib             ⍝ multi-stmt ( add stmt sep "⋄", remove extra one.)
    } 
  ⍝ "Experimental" - future operators (from Adam B's github repository)
    cdFut elFut rsuFut←  cd el rsu { (⍺∊ FUTURES) ∧ 0≠≢⍵ } cdNm elNm 'rsu-dummy'
    grps← (
      cdFut 'CircleDiaeresis (⍥) Depth-Extension'  
      elFut  'Ellipsis (…) Extension of dfns ¨to¨'   
      rsuFut 'Right-Shoe Underscore (⊇) Select/Sane Indexing'  
    )
    :For g :In grps
       :IF VERBOSE_LOADTIME 
          _← '❌❌❌' '✅✅✅'⊃⍨ ⊃g
          ⎕← _, ' Future feature', (' not ' ' '⊃⍨ ⊃g), 'available: ',⊃⌽g
       :ENDIF 
    :EndFor 

  ⍝ User-callable functions:          A  B  C  D  F  J  Q  S  T  W 
  ⍝                                   L (handled ad hoc); D (synonym to T)
  ⍝ ∆F-internal (non-user) funtions:  Ð  M
  ⍝ Others: CircleDiaeresis, Select -- called only via symbol ⍥, ⊇ (if enabled)

  ⍝ These shortcuts are exported for use outside this function
  ⍝:Extern scA2 scB2; scC2; scCD2 cEl2 scJ2; scQ2; scS2; scF2; scM2; scT2; scW2; scÐ2; scSel2 
  scA2 scB2 scC2 scJ2 scM2 scQ2 scS2 scT2 scW2 ← CPublish¨ 'ABCJMQSTW' 
  scÐ2←   '0∘⎕SE.Dyalog.Utils.disp¯1∘↓' CPublish 'Ð'     
  scF2←   2⍴⊂ ' ⎕FMT ' 
  scCD2 scEl2←  cdFut elFut CPublish¨ (cdNm cd) (elNm el)    
  scSel2← 2⍴ ⊂rsu selCodeStr⊃⍨ rsuFut 
    
⍝ Using sc (shortcut) namespace in ∆F routines. Members: tbl, nEsc, Map 
  sc← (
     tbl: ↓⍉↑scA2 scB2 scC2 scT2 scF2 scJ2 scQ2 scS2 scT2 scW2 scÐ2 scM2 scCD2 scEl2 scSel2 
   ⍝ nEsc: # of user-accessible shortcuts via <esc><let>, i.e. `A, `B, etc.
     nEsc: ≢scEscCodes← 'ABCDFJQSTW' 
  )
  sc.Map← scEscCodes∘⍳
  ∇ 

  ∇ {ok}← LoadHelp hfi;e1; e2 
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
  ∇ {libActive}← LoadLibAuto (libFi libActive keepCm)
    ;how 
    how← ' from "',libFi,'" into "','"',⍨∆THIS 
    :If libActive=0
        ⎕←↑1⍴⊂'❗❗❗ WARNING: Library autoload services were not loaded',how
        ⎕←'✅✅✅ LIB_ACTIVE is set to ',(⍕libActive),' in ∆F/FString.dyalog'
        ⎕←'✅✅✅ £ and `L shortcuts are available without them, as if (auto: 0) is set.'
        :Return 
    :EndIf 
    :TRAP 22 
        ⎕FIX⍠ 'FixWithErrors' 0⊣ ⎕SE.∆F⍙Share.library
        :If VERBOSE_LOADTIME 
            ⎕←'✅✅✅ Loaded services for Library shortcut (£)',how  
        :EndIf 
    :Else
        libActive← 0 
        ⎕←↑1⍴⊂'❗❗❗ WARNING: Unable to load Library autoload services',how 
        ⎕←'✅✅✅ £ and `L shortcuts are available without autoload (auto: 0).'
    :EndTrap
  ∇
⍝ Show the following special globals in this namespace.
  ShowGlobalsIf←{  S← 1∘⎕SE.Dyalog.Array.Serialise
    ~⍵: _←1 0⍴0  
      vv← { 9= ⎕NC '⍵': ⊂⍕⍵ ⋄ S ⍵ }¨ ⎕VGET gg← ⊂∘⍋⍛⌷⍨GLOBALS 
      _← {((gg⍳⊂⍵)⊃vv)← ⊂ S ⎕VGET ⍵} 'QUOTE_STYLES'
    1: _← ↑'(', ')',⍨ vv {∊'  ',⍵ , ' ', ⍺}¨ (1+⌈/≢¨ gg)↑¨gg,¨ ':'  
  }
⍝ ====================================================================================
⍝ Execute the FIX-TIME Routines
⍝ ====================================================================================
  ∇ ok← Initialise ; fn_ns; Add2Path  
    :Trap ok← 0   
        :If APL_VERSION < 20
            ⎕←↑1⍴⊂'❌❌❌ This version of ∆F requires Dyalog 20 or later'
            ⎕SIGNAL 911 
        :EndIf   
        fn_ns← ⎕THIS 
      ⍝ Conditionally augment ⎕PATH, adding fn_ns to the BEGINNING of ⎕PATH.
        :IF ADD_∆F_TO_PATH  
            Add2Path←  {  
              R← ('(\s|^)',⍵,'(\s|$)') ⎕R ' '
              ⍵, ' ', R ⊣ ⍺
            }⍥('⎕se' '\s+' ⎕R'\u&' ' ' ⍠1)∘⍕ 
            ⎕PATH← ⎕PATH Add2Path fn_ns          ⍝ Add dest NS to ⎕PATH
        :ENDIf 
      ⍝ Only Export from FString namespace  is ∆F 
        0 1 ⎕EXPORT¨ (⎕NL ¯3 ¯4) (⊂'∆F')          
      ⍝ Sets sc: namespace with global shortcut table and related
        sc← LoadShortcutCalls
        LoadHelp HELP_HTML_FI
        LIB_ACTIVE← LoadLibAuto LIB_SRC_FI LIB_ACTIVE KEEP_SRC_CM   
        ShowGlobalsIf VERBOSE_RUNTIME
    :Else 
        ⎕← ↑⎕DMX.DM ⋄  ⎕←'Stack: ' ⋄ ⎕← 4{⍺≥≢⍵: '   ',⍵ ⋄ ⍺ ∇ ⍺↓⍵⊣ ⎕← '   ',⍺↑⍵} ⎕XSI  
        ⎕←↑1⍴⊂'❌❌❌ ∆F Initialisation has failed!'
    :EndTrap 
  ∇ 
  Initialise 
:EndSection FIX_TIME_ROUTINES 
⍝ === END OF CODE ================================================================================
⍝ (C) 2025 Sam the Cat Foundation
:EndNamespace 
