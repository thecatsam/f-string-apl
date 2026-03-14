:Namespace  ⍝ An unnamed ns 
⍝ ∆F Utility and Library Loader...
⍝ [*] Dyalog ≥20 Version!
⍝ Note: This is an UNNAMED namespace, so its name won't clutter the target namespace, 
⍝ while it loads (ns) ⍙FUtils and (fn) ∆F via, e.g.,
⍝    ]load ∆F [-target=⎕SE]     or     +⎕SE.⎕FIX '∆F.dyalog'
⍝ ⍙FUtils in turn loads other items...

  ⎕IO ⎕ML← 0 1

:Namespace ⍙FGlobals
⍝ =======================================================================
⍝ GENERAL GLOBAL VARIABLES:  
⍝ Exported to ∆FUtils via temp ns ⎕SE.⍙FGlobals.
⍝ ============                                                                      
⍝ ESCAPE_CHAR  FUTURES          HELP_HTML_FI    INLINE_UTILS        KEEP_SRC_CM 
⍝ LIB_ACTIVE   LIB_PARM_FI      LIB_SRC_FI      LIB_USER_FI         LIB_SRC_FI 
⍝ OPTS_DEFval  OPTS_KW          OPTS_N          QUOTES_SUPPLEMENTAL SIGNAL_LIB_ERRS    
⍝ TRAP_ERRORS  VERBOSE_LOADTIME VERBOSE_RUNTIME VERSION 
 
  SRC_FI←         '∆F/∆FUtils.dyalog'
  DEST_NS←         ⎕THIS.##.##                         ⍝ Typically, ⎕SE 
  ADD_∆F_TO_PATH← 1                                    ⍝ If 1, adds ∆F to Dyalog ⎕PATH.
 
  VERSION← 'v.0.2.1'          ⍝ Set/updated by ∆F_Publish.dyalog...
⍝ TRAP_ERRORS: If 0, turns off error trapping in ∆F.
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
⍝ SIGNAL_LIB_ERRS: Affects £.nm and `L.nm constructions. See ∆FLibUtils.dyalog.
⍝ - If SIGNAL_LIB_ERRS← 1
⍝   always ⎕SIGNAL any actual internal library search error (e.g. OBJECT NOT FOUND ON SEARCH PATH),
⍝   even if the ∆F code containing any missing or invalid object is not executed! 
⍝        |      (verbose:0)∆F'{0: £.pcox 12 ⋄ 3}'
⍝        |  ∆F DOMAIN ERROR: Object "pcox" not found on search path                       
⍝ - If SIGNAL_LIB_ERRS← 0
⍝   1a.  If (verbose: 1) or (VERBOSE_RUNTIME=1) 
⍝        report library (£) autoload errors ONLY as informational messages.  
⍝        |     (verbose:1)∆F'{0: £.pcox 12 ⋄ 3}'
⍝        |  ∆F DOMAIN ERROR: Object "pcox" not found on search path
⍝        | { ⎕SE.⍙FUtils.M ⌽⍬({0: (⎕SE.⍙FUtils.userLibrary).pcox 12 ⋄ 3}⍵)}⍵
⍝        |  3                                  ⍝ <== function string executed normally!
⍝   1b.  If (verbose: 0) and (VERBOSE_RUNTIME=0) 
⍝        no informational messages are generated.
⍝   2.   If the ∆F code containing any missing object is executed,
⍝        APL will signal the expected APL error (typically as a VALUE ERROR) 
⍝        |      (verbose:0)∆F'{0: £.pcox 12 ⋄ 3}'
⍝        |  3
  SIGNAL_LIB_ERRS←  0 
 
⍝ ESCAPE_CHAR: Allows an installation to use a non-standard "escape" char.
⍝ ESCAPE_CHAR must be a scalar.
⍝ If ESCAPE_CHAR is omitted or null, the default will be '`'.
⍝ Note ESCAPE_CHAR is a load-time variable, to take advantage of minor optimizations.
  ESCAPE_CHAR← '`'
⍝
⍝ Quote pairs, i.e. beyond double quotes and single quotes.
⍝ QUOTES_SUPPLEMENTAL must consist of 0 or more PAIRS of left AND right quotes.
⍝ You might consider any of these additions among others:
  QS_FR1← '«»'                         ⍝ Help doc shows only these.
  ⍝ QS_FR2 QS_FR3← '“”'  '‘’'       
  ⍝ QS_JP1 QS_JP2← '「」' '『』' 
  ⍝ QS_DE1 QS_DE2 QS_DE3← '»«' '„“' '‚‘'
  ⍝ QS_CH1 QS_CH2← '《》' '「」'
⍝ Note: The code can support all of these at the same time. 
  QUOTES_SUPPLEMENTAL← QS_FR1  

⍝ INLINE_UTILS. 
⍝ If 1, by default,
⍝     puts full definitions of internal utilities (shortcuts etc.) into the result.
⍝ If 0, by default,
⍝     refers to local copies of internal utilities in the result.
⍝ May be overridden by (inline: ⍵), where ⍵ is either 1 or 0.
⍝ There are occasions where INLINE_UTILS mode results in marginally faster code, but
⍝ in general with (verbose: 1), the code is very long and rather unreadable.
  INLINE_UTILS← 0 

⍝ HELP FILE          
⍝ File is loaded into ⍙FUtils at load-time for use by ∆F⍨'help'. 
  HELP_HTML_FI← '∆F/∆FHelp.html'                       

⍝ FUTURES
⍝ '⍥' ∊ FUTURES
⍝    Potential future implementation of circle diaeresis (⍥) to include the Depth operation,  
⍝      i.e. to select subarrays based on depth (just as ⍤ selects subarrays based on Rank).
⍝    - If not enabled, only the standard behaviours of ⍥ (in versions 19 and 20) are enabled.
⍝    See CircleDiaeresis.dyalog in directory ∆F for attribution and license.
⍝ '⊇' ∊ FUTURES
⍝    Potential future implementation of right shoe underbar (⊇) as Select (aka "sane indexing").
  FUTURES← '⍥⊇' 

⍝ =======================================================================
⍝ SESSION LIBRARY (£ or `L) VARIABLES
⍝ =======================================================================
⍝ Var     Setting  Do we want to use the SESSION LIBRARY (£, `L) autoload feature and
⍝                         allow the user to change user parameters (see LIB_USER_FI).
⍝ LIB_ACTIVE:  2   Yes.   Yes.  
⍝                  Load default (see LIB_PARM_FI below) AND user parameters (see LIB_USER_FI)
⍝              1   Yes.   No. 
⍝                  Load default parameters ONLY, never user's. Good for a demo environment!
⍝              0   No.    No.
⍝                  No autoload features should be available.
  LIB_ACTIVE←  2                                       ⍝ Full functionality
  LIB_PARM_FI← '∆F/∆FParmDefs.apla' 
  LIB_USER_FI← '.∆F'                                   ⍝ Relative to the session current dir.
  LIB_SRC_FI←  '∆F/∆FLibUtils.dyalog'                  ⍝ Library shortcuts (£,  `L) utilities.
  
⍝ ==================================================================================
⍝ VARIABLES FOR ∆F OPTIONS: Positional and keyword 
⍝ =======================================================================
  OPTS_KW←      ↑'dfn' 'verbose'        'box' 'auto' 'inline'          ⍝ In order 
  OPTS_DEFval←    0    VERBOSE_RUNTIME   0     1      INLINE_UTILS     ⍝ In order
  OPTS_N←       ≢OPTS_DEFval 

⍝ OPTS_DEFns: The defaults in namespace form. Treat as a read-only object.
⍝    i.e. OPTS_DEFns← ()⎕VSET OPTS_KW OPTS_DEFval    ⍝ (Dyalog 20 or later)  
⍝ Was: OPTS_DEFns←  (⎕NS⍬) {⍺⊣ ⍺.{⍎⍺,'←⊃⍵'}⍤1 0/⍵} OPTS_KW OPTS_DEFval
  OPTS_DEFns← ()⎕VSET OPTS_KW OPTS_DEFval

⍝ KEEP_SRC_CM: Are source comments maintained in runtime namespace ∆FUtils?
  KEEP_SRC_CM← 0 

⍝ Returns 20 if Dyalog 20, 19 if 19. (This version requires Dyalog 20 or later)
  APL_VERSION← ⊃⊃⌽'.'⎕VFI 1⊃'.' ⎕WG 'APLVersion'  
:EndNamespace ⍝ ⍙FGlobals

  
  ∇ {rc}← ⍙Load_∆FUtils 
    ; emsg; g; rc; src 
    ; Err22; ErrAll; ErrApl; PathAdd; ReportQ 

    g← ⍙FGlobals 
    ⎕SIGNAL 0 
    rc← 0
    :If g.APL_VERSION < 20
        ↑3⍴⊂'❌❌❌ ',_← '∆F Domain Error: Dyalog 20 or later is required'
        ⎕DF _  
        :Return 
    :EndIf                                          ⍝ Clear ⎕DMX 
  ⍝ ⎕DF val is returned by ⎕FIX or ]LOAD
    ⎕DF g.DEST_NS ⍕⍛{ ⍺,'.∆F (library: ''',⍺,'.⍙FUtils'' ⋄ version: ''', ⍵,''')' } g.VERSION

    ErrAll←   g.DEST_NS∘{1: ⎕←emsg, 'Unable to create fn="',(⍕⍺),'.∆F" and/or ns="',(⍕⍺),'.⍙FUtils"'}
    Err22←    ErrAll g.SRC_FI∘{ 1: ⎕←emsg, 'File "',⍺,'" does not exist!'}       ⍝ See Signal 22
    ErrApl←   ErrAll { 1: ⎕←'❌❌❌ APL ', ⍵.EM,': ',d1↑⍨ ' '⍳⍨ d1← 1⊃ ⍵.DM }  ⍝ ⍵ <= ⎕DMX 
    PathAdd←  {(1∊⍷)/ ' ',¨' ',⍨¨ ⍵ ⍺: '' ⋄ 0=≢ ⍺: ⍵ ⋄ ' ', ⍵ }⍥('⎕se' ⎕R'\u&' ⍠1)∘⍕ 
    ReportQ←  {⍺: ⎕←'✅✅✅ Created namespace "',⍵,'.⍙FUtils"' ⋄ 1: _←0 }∘⍕
    emsg←       '❌❌❌ Load Error: '

    :Trap 0 
        :If ~⎕NEXISTS g.SRC_FI
            Err22⍬ ⋄ :Return   
        :EndIf 
        src← g.KEEP_SRC_CM { ⍺: ⍵                          ⍝ Delete comments unless "⍝!.*"
          { ⍵/⍨ 0≠≢¨⍵ }'''[^'']*''' '\h*⍝(?!\!).*$' ⎕R '&' '' ⊢⍵  
        } ⊃⎕NGET g.SRC_FI 1 
        ⎕SE.⍙FGlobals← ⍙FGlobals                           ⍝ Make globals visible to ∆FUtils...
        g.DEST_NS.⎕FIX⍠ 'FixWithErrors' 0⊣ src             ⍝ We pass options via ⎕SE.⍙FTemp
        :If 9 3∨.≠ g.DEST_NS.⎕NC↑ '⍙FUtils' '∆F'           ⍝ Sanity check.  
            ErrAll⍬  
        :Else 
            g.VERBOSE_LOADTIME ReportQ g.DEST_NS 
            :If g.ADD_∆F_TO_PATH
                ⎕PATH,← ⎕PATH PathAdd g.DEST_NS 
            :EndIf 
            rc← 1  
        :EndIf 
    :Else
        ErrApl ⎕DMX 
    :EndTrap 
    ⎕EX '⎕SE.⍙FGlobals'                                 ⍝ Clean up 
  ∇


⍝ Load ∆FUtils, which will load other required libraries...
  ⍙Load_∆FUtils                 
:EndNamespace ⍝ Unnamed

