:Namespace              ⍝ Unnamed NS.  Won't clutter destination ns.                 
⍝ ∆F Utility and Library Loader (Dyalog ≥20 Version!).
⍝ Does minimal loading itself; makes globals available to FString, which does rest of loading.
⍝ Load gFi
⍝ - gFi: a file with global variables: '∆F/∆FGlobals.aplns' ==> g (a local namespace)
⍝ - From g, gets name of the source for ∆F and its library,  g.SRC_FI (typically FString.dyalog) 
⍝   as FString  
⍝ - From g, gets name of the "library £" file libSrc
⍝ - Creates temporary namespace ⎕SE.⍙FShare to share the globals and the contents of <libSrc>
⍝   establishes function ∆F in the dest ns.
⍝ - Establishes FString
⍝ THen FString, in turn, 
⍝ - establishes FString.libUtils
⍝ - loads other items needed based on the global variables passed.
⍝ --------------
⍝ To use: 
⍝     ]load ∆F [-target=⎕SE]     or     ⊢⎕SE.⎕FIX '∆F.dyalog'
⍝ ---------------------------------------------

∇ {ok}← Load gFi 
  ;dest ; fs; g ; in; out; lib; main; DE; NY; Note  
  ⎕IO ⎕ML← 0 1 
  dest← ⎕THIS.##                                          ⍝ The <main> ns goes to our parent, not us
  DE← ,∘(⊃∘'DISABLED' 'ENABLED')  
  NY← ,∘(⊃∘'NO' 'YES')
  :Trap 0
      g← 0 ⎕FIX  gFi                                      ⍝ Load globals from file into namespace <g>
    ⍝ Make sure key files g.(SRC_FI LIB_SRC_FI) exist and load their contents (or '' if they don't exist).
      main lib← { 
          ~⎕NEXISTS ⍵: ⎕SIGNAL ⊂('EN' 22)('Message',⍥⊂'No such file or directory: "',⍵,'"') 
          ⊃⎕NGET ⍵ 1
      }¨ g.( SRC_FI LIB_SRC_FI ) 
      :If g.VERBOSE_LOADTIME
          ⎕← '∆F ✅✅✅ Note: Global variables in "',gFi,'" may be customised (for all users)' 
          ⎕← '∆F ✅✅✅ Verbose at load time (VERBOSE_LOADTIME): ENABLED'
          ⎕← '∆F ✅✅✅ Verbose at run time (VERBOSE_RUNTIME):' DE g.VERBOSE_RUNTIME 
          ⎕← '∆F ✅✅✅ Fstring cache: (FS_CACHE_ENABLED)' DE g.FS_CACHE_ENABLED 
          ⎕← '∆F ✅✅✅ Keep source comments and blank lines (KEEP_SRC_CM): ' NY g.KEEP_SRC_CM 
      :EndIf 
      :If ~g.KEEP_SRC_CM                                
          main lib← { 
            in out← ↓⍉↑( 
              '''[^'']*'''    '&'                         ⍝ Ignore quoted strings
              '\h*⍝(?!\!).*'  ''                          ⍝ Remove comments and prior spaces (keep ⍝! comments)
              '^\h*$'         ''                          ⍝ Blank lines => empty lines
            )
            t/⍨ 0≠ ≢¨t← in ⎕R out⊢ ⍵                      ⍝ Remove empty lines
          }¨ main lib 
      :EndIf 
    ⍝ Share globals and lib with <main> as it is fixed...
      ⎕SE.∆F⍙Share← (globals: g ⋄ library: lib)           ⍝ lib ⎕FIXed in FString...
      fs← ⍕dest.⎕FIX⍠ 'FixWithErrors' 0 ⊣ main            ⍝ ⎕FIX main in <dest>
      ⎕DF fs,' [',g.VERSION,']'                           ⍝ Report ∆F info via ⎕DF
  :Else                                                     
      ⎕DF ∊⎕DMX.(                                         ⍝ Report error via ⎕DF
        '∆F ❗❗❗ ERROR LOADING ∆F: '
        EM, ': '/⍨0≠≢Message
        Message 
      )  
  :EndTrap 
⍝ Unshare globals (on success or failure)
  ok← ⎕EX '⎕SE.∆F⍙Share'                                
∇
  Load '∆F/Globals.aplns'
            
:EndNamespace ⍝ Unnamed
