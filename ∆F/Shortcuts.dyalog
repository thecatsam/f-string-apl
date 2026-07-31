:Section Shortcut Definitions
⍝ Shortcuts.dyalog 

⍝ Above    
⍝        a ∇ b: "obj a above obj b"
⍝          ∇ b: "blank line above obj b"
    A← {
      ⎕ML←1 ⋄ ⍺←⍬
      ⊃⍪/(⌈2÷⍨w-m)⌽¨f↑⍤1⍨¨m←⌈/w←⊃∘⌽⍤⍴¨f←⎕FMT¨⍺⍵
    } 
  ⍝ Box
  ⍝     ∇ b: "box obj b"
  ⍝   a ∇ b: "a box b, where a are the options to APL ¨disp¨."
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
      Opt← ⍕¨{                                                ⍝ Get options; def=defaults, o=options (⍺) 
        o←⍵ ⋄ isN← (⎕D∊⍨ ⊃o)∨ 0=⊃0⍴o                          ⍝ isN=1 if first option is <a number or digit>
        isN: o,(def↑⍨-0⌈nd-≢o) ⋄ (def↑⍨0⌈nd-≢o),⌽o    
      }  
      Esc← { ⍵≡⍥, '&': '\&' ⋄ ⍵/⍨1+ '\'= ⍵}                   ⍝ Escapes. In case & or \ is the char separator
      n s← Opt ⍺
      src← '[.Ee]\d+',⍥⊂ '(?<=\d)(?=(\d{', n, '})+([-¯.Ee]|(?=\s|$)))'
      snk← '&',⍥⊂ '&',⍨ Esc s 
      w← src ⎕R snk⍤1 ⍕⍵
      ⊃⍣(1=≢⍵)⊢ w  
    } 
  ⍝ Date: See Time (below)
  ⍝ Display
    Ð← {0∘⎕SE.Dyalog.Utils.disp¯1∘↓⍵}
  ⍝ Format        
    F← { ⍺←⊢ ⋄ ⍺ ⎕FMT ⍵} 
  ⍝ G: GetUrlText
  ⍝   lines@CVV ← [⍺←1] ∇ url 
  ⍝   Retrieve URL ⍵ (assumes default 'https://' prefix, if prefix is omitted)
  ⍝   If ⍺=1, remove all html and scripts and return lines as a vector of CVs.
  ⍝   Otherwise return lines raw.
    G←{  
          ⍺← 1 
    ⍝  Loads HttpCommand (creates namespace) when first used...
      LoadHttp← {  
        0:: ⎕SIGNAL ⊂(
          'EN' 11 ⋄ 'Message' 'Http Commands are unavailable'
        )      
          ⎕SE.SALT.Load 'HttpCommand' 
      } 
      pats repl←↓⍉↑(
          '<script[^>]*>.*?</script[^>]*>' ''
          '<style[^>]*>.*?</style[^>]*>'   ''
          '<!-{0,2}.*?-->'                 ''
          '<[^>]+>'   ''
          '&amp;'     '&'
          '&lt;'      '<'
          '&gt;'      '>'
          '&quot;'    '"'
          '&nbsp;'    ' '
      )
      _Opts←⍠('Mode' 'M')('DotAll' 1)
      GetRaw←{  
          FullUrl← { ⍵,⍨ 'https://'/⍨~1∊'://'⍷⍵ } 
        9≠ ⎕NC 'HttpCommand': ∇ ⍵ ⊣ LoadHttp⍬
          rec← HttpCommand.Get FullUrl ⍵
        rec.rc=  0: rec.Data 
        rec.rc= ¯1: ⎕SIGNAL ⊂('EN' 11)('Message' 'Invalid URL')
          ⎕SIGNAL ⊂('EN' 11)('Message' 'Unable to find URL')
      }
      Repl←pats ⎕R repl _Opts
      Split← (⎕UCS 10 13)∘((~∊⍨)⊆⊢)
      NoDup←'(\R\h*$)+'⎕R'\n'_Opts
      raw← GetRaw ⍵ 
    ⍺=0: raw ⋄ NoDup Split Repl raw 
  }             
  ⍝ Justify
    J← {
        ⎕PP←34 
        ⍺←'L'⋄B←{+/∧\' '=⍵}
        w⌽⍨(1⎕C⍺) { o← ⊂⍺                                     ⍝ Treat ⍺ as a scalar.
          o∊'L'¯1:B ⍵
          o∊'R' 1:-B⌽⍵ 
          o∊'C' 0: ⌈0.5×⍵-⍥B⌽⍵                                ⍝ If o is invalid, drop off ends of earth.
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
  ⍝      ∇ b: "Put single quotes around char. vectors/scalars in b"
  ⍝    a ∇ b: "Put our quotes around b as above, 
  ⍝            with (⊃a) as the left quote char and (⊃⌽a) as the right."                  
    Q←  {
      ⍺← ''''               
      1<|≡⍵:⍺∘∇¨⍵                              
      (0=⍴⍴⍵)∧1=≡⍵:⍵                           
      (0≠≡⍵)∧326=⎕DR⍵:⍺∘∇¨⍵                 
      ⎕ML←1                                                                   
      ⍺{l r← ⍺ ⋄ 0=80|⎕DR⍵:l, r,⍨ ⍵/⍨ 1+r= ⍵⋄⍵}⍤1⊢⍵        
    }
  ⍝ Serialise (display in APLAN)
    S← { 
      ⎕ML←1 ⋄ 11 16 6:: ⍵ ⋄ ⍺← 0     
      1=≢s←⍺⎕SE.Dyalog.Array.Serialise⍵: ⊃s
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
:EndSection Shortcut Definitions