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

  ∇ {globFi}← ⍙Load_∆FUtils globFi
    ; g; ok; src 
    ⎕SIGNAL 0                                            ⍝ Clear ⎕DMX
    :Trap 0 
    ⍝ Load into <g> the global variables (used at load and runtime)
      :If ~⎕NEXISTS globFi 
          FailGlob ErrNoFi globFi ⋄ :Return 
      :EndIf 
      g← 0 ⎕FIX globFi                                   ⍝ Load globals into temp <g>
      :If g.APL_VERSION< 20                              ⍝ This version requires Dyalog 20                                        
          FailLoad ErrVersn ⍬ ⋄ :Return 
      :ElseIf ~⎕NEXISTS g.SRC_FI
          FailLoad ErrNoFi g.SRC_FI ⋄ :Return   
      :EndIf 
      src← NoCmX⍣(~g.KEEP_SRC_CM) ⊃⎕NGET g.SRC_FI 1  
    ⍝ Prepare to load <SRC_FI>'s source code
      ⎕SE.⍙⍙FGlobals← g                                  ⍝ Make globals <g> visible to <src> 
      g.DEST_NS.⎕FIX⍠ 'FixWithErrors' 1⊣ src             ⍝ ... <src> will copy them in for its use.
      :If 9 3∨.≠ g.DEST_NS.⎕NC↑'⍙FUtils' '∆F'            ⍝ Are expected ns & fi here? 
          FailLoad⍬                                       ⍝ ... No. Error & continue to cleanup 
      :Else 
          :If g.ADD_∆F_TO_PATH
              ⎕PATH,← ⎕PATH PathAdd g.DEST_NS 
          :EndIf 
          Succeed ⍬
      :EndIf 
    :Else
        FailLoad ErrApl⍬                                  ⍝ APL error & continue to cleanup
    :EndTrap 
    ⎕EX '⎕SE.⍙⍙FGlobals'                                 ⍝ Clean up (outside trap)
  ∇
  ⍝ ⎕DF val is returned/displayed by ⎕FIX or ]LOAD
  Succeed_←  {⎕DF g.(DEST_NS⍕⍛,'.∆F [',VERSION,']')}
⍝ Reporting on success if Verbose 
  ReportQ_←  {g.VERBOSE_LOADTIME: ⎕←'✅✅✅ Created namespace "',g.DEST_NS⍕⍛,'.⍙FUtils"' ⋄ 1: _←0 }
  Succeed←   Succeed_ ReportQ_
⍝ Error Reporting
  FailGlob← { ⎕DF emsg, 'Unable to find global variables needed to load ∆F or libraries' }
  FailLoad← { ⎕DF emsg, 'Unable to load ∆F or associated ns (library) in ',⍕g.DEST_NS  }
  ErrNoFi←  { 1: ⎕←emsg, 'File "', ⍵,'" does not exist!'}       ⍝ See Signal 22  
  ErrVersn← { 1: ⎕← '❌❌❌ ∆F Domain Error: Dyalog 20 or later is required'}
  ErrApl←   { 1: ⎕← '❌❌❌ APL ', ⎕DMX.EM,': ',d1↑⍨ ' '⍳⍨ d1← 1⊃ ⎕DMX.DM }   
  PathAdd←  {(1∊⍷)/ ' ',¨' ',⍨¨ ⍵ ⍺: '' ⋄ 0=≢ ⍺: ⍵ ⋄ ' ', ⍵ }⍥('⎕se' ⎕R'\u&' ⍠1)∘⍕ 
  emsg←     '❌❌❌ Load Error: '
⍝ Delete comments unless of form "⍝!.*"
  NoCmX←    { ⍵/⍨ 0≠≢¨⍵ }'''[^'']*''' '\h*⍝(?!\!).*$' ⎕R '&' ''  

⍝ ============== EXECUTIVE ==============
⍝ Load ∆FUtils, which will load other required libraries...
⍝ Rt arg: global variable file...
  ⍙Load_∆FUtils GLOBALS_FI                
:EndNamespace ⍝ Unnamed

