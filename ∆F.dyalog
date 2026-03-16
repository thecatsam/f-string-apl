:Namespace  ⍝ An unnamed ns 
⍝ ∆F Utility and Library Loader...
⍝ [*] Dyalog ≥20 Version!
⍝ Note: This is an UNNAMED namespace, so its name won't clutter the target namespace, 
⍝ while it loads (ns) ⍙FUtils and (fn) ∆F via, e.g.,
⍝    ]load ∆F [-target=⎕SE]     or     +⎕SE.⎕FIX '∆F.dyalog'
⍝ ⍙FUtils in turn loads other items...

  ⎕IO ⎕ML← 0 1
⍝ Where's the globals file? Everything else is defined there!
  GLOBALS_FI← '∆F/∆FGlobals.dyalog'   

⍝ Reporting on Success if Verbose 
  ReportQ←  {⍺: ⎕←'✅✅✅ Created namespace "',⍵,'.⍙FUtils"' ⋄ 1: _←0 }∘⍕
⍝ Error Reporting
  ErrAll←   { ⍺←⍕g.DEST_NS ⋄ ⎕DF emsg, 'Unable to create fn="',⍺,'.∆F" and/or ns="',⍺,'.⍙FUtils"'}
  Err22←    ErrAll { 1: ⎕←emsg, 'File "',g.SRC_FI,'" does not exist!'}       ⍝ See Signal 22
  ErrApl←   ErrAll { 1:  ⎕←'❌❌❌ APL ', ⍵.EM,': ',d1↑⍨ ' '⍳⍨ d1← 1⊃ ⍵.DM }  ⍝ ⍵ <= ⎕DMX 
  PathAdd←  {(1∊⍷)/ ' ',¨' ',⍨¨ ⍵ ⍺: '' ⋄ 0=≢ ⍺: ⍵ ⋄ ' ', ⍵ }⍥('⎕se' ⎕R'\u&' ⍠1)∘⍕ 
  emsg←       '❌❌❌ Load Error: '
⍝ Delete comments unless of form "⍝!.*"
  NoCm←     { ⍵/⍨ 0≠≢¨⍵ }'''[^'']*''' '\h*⍝(?!\!).*$' ⎕R '&' ''  

  ∇ {globFi}← ⍙Load_∆FUtils globFi
    ; g; ok; src 
    
  ⍝ Load into <g> the global variables (used at load and runtime)
    ok g← { 22:: 0 0 ⋄ 1,⊂ 0 ⎕FIX ⍵ } globFi  
    :If ~ok
        ⎕DF '❌❌❌ ∆F File Error: File "', globFi,'" does not exist'
        :Return 
  ⍝ This version requires Dyalog 20
    :ElseIf g.APL_VERSION< 20 
        ⎕DF '❌❌❌ ',_← '∆F Domain Error: Dyalog 20 or later is required'
        :Return 
    :EndIf                                         
 
    ⎕SIGNAL 0                                              ⍝ Clear ⎕DMX
    :Trap 0 
        :If ~⎕NEXISTS g.SRC_FI 
            Err22⍬ ⋄ :Return   
        :EndIf 
        src← ⊃⎕NGET g.SRC_FI 1  
        src← NoCm⍣(~g.KEEP_SRC_CM)⊢ src 
        ⎕SE.⍙⍙FGlobals← g                                  ⍝ Make globals <g> visible to <src> 
        g.DEST_NS.⎕FIX⍠ 'FixWithErrors' 0⊣ src             ⍝ <src> will copy them in for its use.
        :If 9 3∨.≠ g.DEST_NS.⎕NC↑'⍙FUtils' '∆F'            ⍝ Are expected ns's here? 
            ErrAll⍬                                        ⍝ No. Error & continue to cleanup 
        :Else 
            ReportQ/  g.( VERBOSE_LOADTIME DEST_NS )
            :If g.ADD_∆F_TO_PATH
                ⎕PATH,← ⎕PATH PathAdd g.DEST_NS 
            :EndIf 
          ⍝ ⎕DF val is returned by ⎕FIX or ]LOAD
            ⎕DF g.(DEST_NS⍕⍛,'.∆F [',VERSION,']')
        :EndIf 
    :Else
        ErrApl ⎕DMX                                      ⍝ APL error & continue to cleanup
    :EndTrap 
    ⎕EX '⎕SE.⍙⍙FGlobals'                                 ⍝ Clean up (outside trap)
  ∇

⍝ ============== EXECUTIVE ==============
⍝ Load ∆FUtils, which will load other required libraries...
⍝ Rt arg: global variable file...
  ⍙Load_∆FUtils GLOBALS_FI                
:EndNamespace ⍝ Unnamed

