:Namespace  
⍝ ∆F Utility and Library Loader...
⍝ Note: This is an UNNAMED namespace, so its name won't clutter the target namespace, 
⍝ while it loads (ns) ⍙FUtils and (file) ∆F via ]load ∆F. 
  ⎕IO ⎕ML ⎕PW← 0 1 120 

  SRC_FI←         '∆F/∆FUtils.dyalog'
  DEST_NS←         ⎕THIS.##
  ADD_∆F_TO_PATH← 1                                           ⍝ If 1, adds ∆F to ⎕PATH.
  VERSION←        '0.1.1'

  ∇ {rc}← ⍙Load (srcFi destNs codeVersion add∆F2Path) 
    ; rc; w; CGood; Err22; ErrAll; ErrApl; PathAdd; ∆SE 
    Err22←  { 1: ⎕←'!!! Load error: file "',⍵,'" does not exist!'}
    ErrApl← { 1: ⎕←'!!! APL ',⍵.EM,': ',d1↑⍨ ' '⍳⍨ d1← 1⊃⍵.DM }
    ErrAll← { 1: ⎕← '!!! Load error: Could not create fn="',⍵,'.∆F" and/or ns="',⍵,'.⍙FUtils"'}⍕
    ∆SE←    '(?i)⎕se' ⎕R '⎕SE' 
    PathAdd← {s←' ' ⋄ (1∊⍷)/ s,¨s,⍨¨⍵ ⍺: '' ⋄ 0=≢ ⍺: ⍵ ⋄ s, ⍵ }⍥∆SE
    CGood←   {⍺: ⎕←'>>> Created namespace "',⍵,'.⍙FUtils"' ⋄ 1: _←0 }

    ⎕SIGNAL 0 ⍝ Clear ⎕DMX 
  ⍝ ⎕DF value is returned by ⎕FIX or ]LOAD
    w← ⍕destNs 
    ⎕DF w,'.∆F (library: ''',w,'.⍙FUtils'' ⋄ version: ''', codeVersion,''')'
    rc← 0 
    :Trap 0 
        :If ~⎕NEXISTS srcFi
            Err22 srcFi ⋄ ErrAll destNs ⋄ :Return   
        :EndIf 
        destNs.⎕FIX⍠'FixWithErrors' 0⊢ 'file://',srcFi                        
        :If 9 3∨.≠ destNs.⎕NC↑ '⍙FUtils' '∆F'                 ⍝ Sanity check.  
            ErrAll destNs ⋄ :Return   
        :EndIf 
        destNs.⍙FUtils.VERBOSE CGood ⍕destNs 
        :If add∆F2Path
            ⎕PATH,← ⎕PATH PathAdd ⍕destNs 
        :EndIf 
        rc← 1  
    :Else
        ErrApl ⎕DMX ⋄ ErrAll destNs ⋄ :Return 
    :EndTrap 
  ∇

  ⍙Load SRC_FI DEST_NS VERSION ADD_∆F_TO_PATH
:EndNamespace 
