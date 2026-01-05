⍝ ∆FLibUtils.dyalog      (UPDATE_TIME: '2026-01-04') 
:Namespace libUtils
⍝ This namespace handles Library (£ or `L) shortcut automatic loading...
⍝ ∘ See ⍙FUtils for fn ⍙LoadLibAuto, which loads this library.
⍝ ∘ See "Executive" at bottom of file, which calls
⍝   SetLibFull and LoadParms  
⍝ ∘ Local and External variables pointing to the "user" library userLibrary.
⍝   - userLib  -  the namespace ref itself, by default ⍙FUtils.userLibrary (##.userLibrary)
⍝   - userLibNm-  the name of userLib
⍝ ===================================================================================
⍝ LibAuto: libStr← ê ∇ str 
⍝    str str starts 1 char after '£' or '`L'. 
⍝    ê: namespace with (r/w:) ê.acache; (r/o:) ê.auto; (read in LoadObj:) ê.verbose 
⍝ Returns: userLibNmP, the library name surrounded by parens, no matter what.
⍝ ∘ Used by ∆F's scan process when it sees £ or `L. 
⍝   ∘ Called from the main scan routines CF_SF and CF_Esc. 
⍝   ∘ In turn calls fn LoadObj when a library name, nm, is being referenced 
⍝     (not set) for the first time.
⍝ Task:
⍝ ∘ find the name nm in £.nm...[[∘]←] (first token in a qua.lif.ied name)
⍝   and, if valid and not seen before,
⍝   ∘ If £. is followed by a dotted name nm1.nm2[...], then nm←nm1, the first one;
⍝     That entire namespace is loaded, if found.
⍝   ∘ (via LoadObj) get source code for it from a file or workspace in our path.
⍝ ∘ Does NOT affect the string ⍵ being scanned. 
⍝ ∘ Is only used for its ⎕CY or ⎕FIX side effect via LoadObj. 
⍝ Note: A name may be in the userLibrary w/o having been loaded, e.g. if it's
⍝   in a file with multiple objects (all may be loaded). So we add ANY valid 
⍝   name to the cache, once we see it. (We don't cache invalid names).
  LibAuto←{          
    ~⍺.auto: userLibNmP                               ⍝ Not auto: return.
        w← (+/∧\' '= ⍵)↓ ⍵                            ⍝     Skip blanks
    '.'≠ ⊃w: userLibNmP                               ⍝ No initial '.':   return.
        w← (+/∧\' '=w)↓ w← 1↓w                        ⍝     Skip some more blanks,
        nm← w↑⍨ p← w(⌊/⍳) ' .←∘('                     ⍝     Get the name  
    (⊂nm)∊ ⍺.acache: userLibNmP                       ⍝ Saw it before:    return.
    ¯1=nc← userLib.⎕NC nm: userLibNmP                 ⍝ Invalid name:     return.
        ⍺.acache,← ⊂nm                                ⍝     Mark as seen in autocache global.
    0≠ nc: userLibNmP                                 ⍝ In libuser:       return. 
    '←'= ⊃'∘ '~⍨p↓w: userLibNmP                       ⍝ Name to be set:   return.
        userLibNmP⊣ userLib ⍺ parms LoadObj nm        ⍝     Try to load obj def, then return.                                       
  }
  
  ⍝ ======================================================================================
  ⍝ LoadObj: Find nm in £.nm or `L.nm and try to load its definition into userLib from path.
  ⍝     (1|0)@B← userLib@ns verbose@B parms@ns ∇ nm@CVS 
  ⍝ Find <nm> in search directories (parms.path) and dfns workspace, according to parameters <parms>.
  ⍝ Called by ⍙Auto (above).
  ⍝    (1|0)← userLib verbose parms ∇ nm 
  ⍝ Returns SHY 1 (succ) or SHY 0 (fail), having established <nm> in userLib (ns) on success.
  LoadObj← { 
  ⍝ LoadObj utilities, followed by the executive...

    ⍝ SubScanFiles:    
    ⍝  ∇ files
    ⍝  extern: nm 
    ⍝ Search a list of full filenames <files> ending in simple name <nm> (before suffixes).
    ⍝ If a) it finds such a file
    ⍝    b) the ⎕FIX succeeds, and
    ⍝    c) the name ⍺ is among the names returned in the ⎕FIX, 
    ⍝ then it returns:
    ⍝    success: 1 ('file:', fi).
    ⍝ Otherwise, returns: rcNF (not found).
    ⍝ Notes:
    ⍝ ∘ The nameclass distinctions, based on suffixes, are currently NOT enforced for
    ⍝   the first three suffixes, but it's trivial to do.
    ⍝ ∘ When ⎕FIX is applied to the file found, <nm> must be among the names listed
    ⍝   as ⎕FIXed or an error (rcEN) is reported.
    ⍝ ∘ Other errors reported as rcER. 
      SubScanFiles← {   
        0= ≢⍵: rcNF ⍬ ⋄ 11 22:: rcER ⍬⊣ errSig⊢←⎕DMX 
        fi← ⊃⍵       
        ~⎕NEXISTS fi: ∇ 1↓⍵ 
        FixByType← { 
          sfx← ⊃⌽⎕NPARTS fi← ⍵  
          ⍝ When ⎕FIX is applied to ¨fi¨, ¨nm¨ must be among the names listed as ⎕FIXed.  
          '.aplf' '.aplo' '.apln'∊⍨ ⊂sfx: rcEN rcOK⊃⍨ (⊂nm)∊ 2 userLib.⎕FIX _FixOpts errFi⊢←fi 
          '.apla'≡ sfx: rcOK⊣ userLib ##.∆VSET ⊂nm (##.AN2Apl ⊃⎕NGET fi 1) 
          '.txt' ≡ sfx: rcOK⊣ userLib ##.∆VSET ⊂nm (⊃⎕NGET fi 1)                                     
          '.json'≡ sfx: rcOK⊣ userLib ##.∆VSET ⊂nm (⎕JSON _JOpts ⊃⎕NGET fi 0)  
          ⍝ All other suffixes, including .dyalog or a user-defined suffix.
          ⍝ When ⎕FIX is applied to ¨fi¨, ¨nm¨ must be among the names listed as ⎕FIXed. 
            rcEN rcOK⊃⍨ (⊂nm)∊ 2 userLib.⎕FIX _FixOpts errFi⊢← fi            
        }
        0≤ rc← FixByType fi: rc ('file:',fi) ⋄ rc ⍬ 
      } 
      _FixOpts← ⍠('FixWithErrors' 0)('Quiet' 1)    
      _JOpts← ⍠('Dialect' 'JSON5')('Compact' 0)('Null' ⎕NULL)     

    ⍝ SubScanWS:     
    ⍝ ret← path ∇ subpath
    ⍝    path:       ScanPath's current (outer) path 
    ⍝    subp:       the list of workspaces
    ⍝ extern: nm:  name to find     
    ⍝ ∘ May call ScanPath to recursively "return" to scanning the outer ¨path¨.   
    ⍝ Returns: 
    ⍝   a) (retcode ('ws:', wsname)), where retcode∊rcOK, rcNF, rcER, or
    ⍝   b) Returns result from recursive call to ScanPath
      SubScanWS← { path subp← ⍺ ⍵
        0=≢subp: ScanPath 1↓path 
        ⍝ FixFromWS: If nm is in workspace ⊃subP, copy it. Otherwise, keep looking.
          FixFromWS← { 11:: rcNF ⍬ ⋄ rcOK ('ws:',⍵)⊣ ⍺ userLib.⎕CY ⍵ }
          ret← nm FixFromWS ⊃subp
        rcNF≠⊃ret: ret ⋄ path ∇ 1↓subp 
      }

    ⍝ ScanPath:
    ⍝ rcOK@B where@S← ∇ path@NsV 
    ⍝ extern: nm  
    ⍝ Recursively scan the path for name ⍵ in each file or wsid 
    ⍝ spec in parms._fullPath   
    ⍝ ∘ If we see a array (with a single string), it's a workspace: 
    ⍝   call and return result from SubScanWS
    ⍝ ∘ Otherwise, 
    ⍝   call and return result from SubScanFiles
      ScanPath← {  
        0= ≢⍵: rcNF ⍬ ⋄ path← ⍵ ⋄ cur← ⊃path
        ⍝ If cur is a vector of (0 or more) char vectors, each is assumed to be a workspace id.
        ⍝ When done, having returned rcNF, recursively continue ScanPath.
        ⍝ Otherwise (rcOK or rcER), return from ScanPath.
        1< |≡cur: path SubScanWS cur                   ⍝ If VCV, => at least 1 workspace.        
          ff← ,(⊂cur)∘.,(⊂nm,'.')∘.,parms.suffix       ⍝ cur is a CV. Generate ff, list of files.  
        rcNF≠⊃ret← SubScanFiles ff: ret 
          ∇ 1↓path                       
      }

    ⍝ EndScan: Show optional action, then return.
    ⍝ rc← rc verbose dest ∇ srcFi destNs  
    ⍝ extern: nm 
    ⍝ 
    ⍝ If (~v), exit quietly, even if an error occur that we've anticpated.
    ⍝ Otherwise, simply print the errors and then continue normally.
    ⍝ This way, the user can trap errors relating to the missing objects. 
    ⍝ If you want errors to be ⎕SIGNALED, set signalOnErr← 1 at Executive
      EndScan←  { rc v libE← ⍺ 
       (~v)∧rc=rcOK: rc ⋄ (srcFi dest)← ⍵  
        Ê← { en message← ⍵ 
          libE: ⎕SIGNAL ⊂('EN' en) ('Message' message) 
          v: 0⊣ ⎕← ('∆F ',⎕EM en),': ',message 
          0
        }
      rc=rcOK: rc⊣ ⎕← '∆F: Copied "', nm, '" into £ibrary',(0≠ ≢srcFi)/ ' from ','"',srcFi,'"'
      rc=rcNF: rc⊣ Ê 11 ('Object "',nm,'" not found on search path')   
      rc=rcEN: rc⊣ Ê 11 ('Obj "',nm,'" not present in file "',srcFi,'"') 
               errSig.m1← 'Error loading "',nm,'" into user library '
               rc⊣ Ê errSig.(EN (m1,'(',Message,')'))
      }

      errSig← ⍬    ⍝ Used in EndScan only...
      errFi←''     ⍝ Used in EndScan only...
    ⍝ ===========================================================================
    ⍝ Executive for LoadObj 
    ⍝ ===========================================================================
      ⍝ nm: used in routines ScanPath (and descendants) and EndScan.
      userLib ê parms←⍺ ⋄ nm← ⍵                          
      ⍝ Return codes: 
      ⍝   rcOK, rcNF (not found), rcER (gen'l error), 
      ⍝   rcEN (file loaded fine, but <nm> wasn't one of the top-level objects) 
      rcOK rcNF rcER rcEN← 1 0 ¯1 ¯2     
      rc where← ScanPath parms._fullPath 
    1: _← rc (ê.verbose ∨ parms.verbose) ##.LIB_ERRORS EndScan where userLib  
  } ⍝ End LoadObj 
  
⍝ ============================================================================
⍝ LoadParmDefaults: Load-time routine
⍝   If successful, sets parameters 
⍝       ⍵.load, ⍵.auto, ⍵.verbose, ⍵.path, ⍵.prefix, ⍵.suffix, etc.
⍝   ⍵.load defaults to ##.AUTOLOAD (which must be 1 or 0).
⍝   If ⍵.load is set to 1 in the .∆F file, then the .∆F file is loaded.
⍝   If not,
⍝       then no more processing is done and Auto does nothing except return userLibNm (lib ns name).
⍝   If ⍵.path←⍬, 
⍝       no files or workspaces are checked. 
⍝   If ⍵.suffix←⍬, we will only check workspaces.
⍝ These are the default APL Array Notation settings: format ok whether Dyalog 20 or earlier.
⍝ User can override in ./.∆F, also in APLAN format. 
  LoadParmDefaults← { fi← ⍵ 
    LoadErr← {
      _← 'parms' ⎕NS ⍬   
      _← LibLoadFailure 'DEFAULT PARAMETER FILE "',fi,'" DOES NOT EXIST OR IS INVALID. AUTOLOAD IS NOT AVAILABLE!' 
      parms 
    }
  2:: LoadErr ⍬ ⋄ ~⎕NEXISTS fi:  LoadErr ⍬ 
    _← 'parms' ⎕NS ##.AN2Apl ⊃⎕NGET fi 1  
    parms⊣ parms._readParms← 1 0 
  }

⍝ LoadUserParms: Loadtime routine
⍝ Loads parameter file ⍵ (if it exists) into namespace ⍺
⍝ Note default parameters for special cases (sc) below
  LoadUserParms← {   
      runtime parmFi← ⍺ ⍵  
    ⍝ ReadUserParms: Update parameters from parm file.
      ReadUserParms← { 
        ~⎕NEXISTS ⍵: ⍬ 
        11 2/⍨ ~runtime:: {   
            ⎕← '>>> ∆F LOAD ERROR:   Unable to parse parameter file "',⍵,'".'
            ⎕← '>>> ∆F ',⎕DMX.EM,': ',⎕DMX.Message ⋄ ⍬ 
          } ⍵  
          _← 'parms' ⎕NS ##.AN2Apl ⊃⎕NGET ⍵ 1      ⍝ Merge parm file into internal defaults
          0⊣ parms._readParms[1]← 1 
      } 
    ⍝ GenFullPath:   _parms._fullPath← ∇ parms.path 
      GenFullPath← {
          ⍺←⍬ ⋄ 0=≢⍵: ⍺ ⋄ p← ⊂⊃⍵ 
        2<|≡p: (⍺, p) ∇ 1↓⍵                                         ⍝ workspace
          (⍺, ,p∘., '/'∘.,parms.prefix) ∇ 1↓⍵                       ⍝ file 
      } 
    ⍝ =========================================================================
    ⍝ LoadUserParms main ...
    ~parms._readParms[0]:  _← 0 
      _← ReadUserParms parmFi  
    ⍝ Handle special-case parameters: verbose, load, ..., suffix 
      sc←  ('verbose' ##.VERBOSE) ('load' ##.LIB_AUTO) ('prefix'(,⊂'')) 
      sc,← ('auto' 0)             ('path' ⍬)           ('suffix' ⍬)
    ⍝ If any parm in (⊃¨sc) has value ⎕NULL or ⍬, 
    ⍝ it is replaced by its default shown here in (⊃∘⌽¨sc)
        Val←    parms.⎕OR∘⊃
        IsNull← ⍬∘≡∨⎕NULL∘≡
      _← parms ##.∆VSET sc/⍨ IsNull∘Val¨ sc
    ⍝ If ~parms.load, Auto just returns the user userLibrary sans "auto" function.
    ~parms.load: _← 0⊣ LibLoadFailure ⍬
      parms._fullPath← GenFullPath parms.path 
      
    ⍝ If parms._fullPath is not empty, we're done!
    0< ≢parms._fullPath: _← 1 
    ⍝ If parms._fullPath is empty, then turn auto off, since there's nothing to search..
      _← 0⊣ LibLoadFailure parms.verbose/'Parameter file specifies (load: 1) but  the search path is empty!'
  } 
  ⍝ _CShow: 
  ⍝ ∘ Cond'lly show all APLAN parameters in 'parms' in alph order 
  ⍝   (⍺⍺=1) compactly, else (⍺⍺=0) multiline.
  ⍝   EXCEPT internal ones starting with '_'
  ⍝ ∘ If ⍺=1, force a display, even if parms.verbose=0.
  ⍝ ∘ Returns: a matrix of parms or (1 0⍴'')
  _CShow← { ⍺←0 ⋄ 0:: 1 0⍴⎕←'∆F: ∆F Load: Error displaying runtime parameters'
    (~⍺)∧~⍵.verbose: _← 1 0⍴''  
      _← ⊂'Library Runtime Parameters (default + user-set):'⊣ ⎕PW← 200
    1: _← ↑⍺⍺ ##.Apl2AN ⍵.(⎕NS {⍵/⍨ '_'≠⊃¨⍵} ⎕NL -2) 
  } 

⍝ ShowPath:  Called via 'path' call in ##.Special. 
  ShowPath← { ⊃1 ##.Apl2AN parms._fullPath } 

⍝ What to do if loading defaults or user parms fails.
⍝    ⍺ LibLoadFailure warning
⍝ Issues warning ⍵ if non-null a total of ⍺ times.
⍝ Sets LibAuto to a nop and sets auto and _readParms to ¯1.
  LibLoadFailure← { ⍺← 3 
      _← (⎕∘←)⍣(⍺×0≠≢⍵)⊣'>>> LIBRARY WARNING: ',⍵ 
      parms.(auto _readParms← 0 (0 0)) ⋄ ⎕THIS.⎕FX ,⊂'LibAuto←{userLibNm}'
  }

⍝ Load user parms
⍝     Load builtin parms? If loadDefaults=1 or 'parms' doesn't yet exist.
⍝     Load user parms?    If loadUserFi=1.
⍝     Show parms?         If isVerbose=1 or if parms.verbose=1
⍝     Show compactly?     If isCompact=1;
⍝ Used at EXECUTIVE below and via 'parms' call in ##.Special.
  ∇ {rc}← LoadParms ( loadDefaults loadUserFi isVerbose isCompact runtime  )   
    ; parmFi 
    :If  0=⎕NC 'parms'  
    :OrIf loadDefaults 
        parmFi← LoadParmDefaults ##.LIB_PARM_FI 
        :If ~rc← parmFi._readParms[0] 
            :Return 
        :EndIf 
    :EndIf 
    :If loadUserFi 
        runtime LoadUserParms '.∆F'  
    :EndIf         
    rc← isVerbose (isCompact _CShow) parms 
  ∇
⍝   SetLibFull: Point to (empty, but named) user library at load-time.
⍝      actual ref: ##.userLibrary, local ref (alias): userLib, local name: userLibNm.
⍝ external: 
⍝      userLib, userLibNm, Auto, parms, ShowPath, LoadParms   ⍝ loaded here...
  ∇ {libNs}← SetLibFull libNs
    ⍝ external: userLibNm userLib 
    libNs.⎕DF ⎕NULL                      ⍝ In case set...
    userLibNmP← '(',')',⍨ userLibNm← ⍕userLib← libNs 
    userLib.⎕DF '£=[',userLibNm,']'
  ∇

⍝ =========================================================================
⍝ EXECUTIVE
  SetLibFull ##.userLibrary
  LoadParms 1 1 0 0 0 
:EndNamespace   ⍝ libUtils
