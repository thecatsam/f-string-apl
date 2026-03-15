:Namespace  ⍝ An unnamed ns 
⍝ ∆F Utility and Library Loader...
⍝ [*] Dyalog ≥20 Version!
⍝ Note: This is an UNNAMED namespace, so its name won't clutter the target namespace, 
⍝ while it loads (ns) ⍙FUtils and (fn) ∆F via, e.g.,
⍝    ]load ∆F [-target=⎕SE]     or     +⎕SE.⎕FIX '∆F.dyalog'
⍝ ⍙FUtils in turn loads other items...

  ⎕IO ⎕ML← 0 1
  
  ∇ {rc}← ⍙Load_∆FUtils globalFi 
    ; emsg; g; rc; src 
    ; Err22; ErrAll; ErrApl; PathAdd; ReportQ 
    
  ⍝ Load global variables used at load and runtime
    :Trap 22 
        g← 0 ⎕FIX globalFi
    :Else 
        ⎕← ↑3⍴⊂'❌❌❌ ∆F File Error: File "', globalFi,'" does not exist'  
        ⎕SIGNAL ⎕EN 
    :EndTrap 
    ⎕SIGNAL rc← 0  
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
        ⎕SE.⍙FGlobals← g                                   ⍝ Make globals visible to ∆FUtils...
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
⍝ Rt arg: global variable file...
  ⍙Load_∆FUtils '∆F/∆FGlobals.dyalog'                 
:EndNamespace ⍝ Unnamed

