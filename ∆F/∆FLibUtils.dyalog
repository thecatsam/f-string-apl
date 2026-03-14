⍝ ∆FLibUtils.dyalog      (UPDATE_TIME: '2026-03-13') 
:Namespace libUtils
⍝ ===================================================================================
⍝ This namespace handles Library (£ or `L) shortcut automatic loading
⍝ *** It handles NOTHING ELSE ***
⍝ It has RUNTIME routines (services used when an £ or `L is seen in the user's code field) and
⍝ LOADTIME routines (setting up the active library services). 
⍝ ∘ See ⍙FUtils for fn ⍙Load_LibAuto, which loads this library.
⍝ ∘ See "Executive" at bottom of file, which calls
⍝   - LibComplete 
⍝   - LoadParms  
⍝ ∘ Local and External variables pointing to the "user" library userLibrary.
⍝   - ûLib  -  the namespace ref itself, by default ⍙FUtils.userLibrary (##.userLibrary)
⍝   - ûLibNm-  the name of ûLib

  :Section  Runtime Routines 
⍝ ===================================================================================
⍝ RUN TIME ROUTINES
⍝ ===================================================================================
⍝ LibAuto: libStr← ûsr ∇ str 
⍝    str: str starts 1 char after '£' or '`L'. 
⍝    ûsr: namespace with (r/w:) ûsr.acache; (r/o:) êauto; (read in LoadObj:) êverbose 
⍝ Returns: ûLibNmP, the library name surrounded by parens, no matter what.
⍝ ∘ Used by ∆F's scan process when it sees £ or `L. 
⍝   ∘ Called from the main scan routines CF_SF and CF_Esc. 
⍝   ∘ In turn calls fn LoadObj when a library name, nm, is being referenced 
⍝     (not set) for the first time.
⍝ Task:
⍝ 1. find the name nm in £.nm...[[∘]←] (first token in a qua.lif.ied name), and
⍝ 2. If valid and not seen before:
⍝   - If £. is followed by a dotted name nm1.nm2[...], then nm←nm1, the first one.
⍝     That entire namespace is loaded, if found. In this case, that's 'nm1'; then
⍝   - (via LoadObj) get source code for 'nm1' from a file or workspace in the 
⍝     path (pârms.⍙fullPath).
⍝ ∘ Does NOT affect the string ⍵ being scanned. 
⍝   - That's left to the scanner that called LibAuto.
⍝   - Is only used for its ⎕CY or ⎕FIX side effect via LoadObj. 
⍝   - We add <name> to the cache, once we see it.  
⍝ ∘ A name may be in the user library w/o having been loaded directly, e.g. 
⍝   - if a file in the domain of ⎕FIX contains multiple objects, all may be loaded,
⍝     as long as <name> is included.
⍝ ∘ No attempt is made to load (⎕CY/⎕FIX) invalid names or those already in ûLib.
  LibNoAuto← {ûLibNmP} 
  LibAuto←{      
    ~⍺.auto:                 ûLibNmP                ⍝ Not auto? →Return.
        w← NoLB ⍵                                   ⍝     Skip blanks
    '.'≠ ⊃w:                 ûLibNmP                ⍝ No initial period? →Return.
        w← NoLB 1↓w                                 ⍝     Skip more blanks,
        nm← w↑⍨ len← NmSpan w                       ⍝     Get the (apparent) simple name and length.  
    (⊂nm)∊ ⍺.acache:         ûLibNmP                ⍝ Saw it before? →Return.
        ⍺.acache,← ⊂nm                              ⍝     Mark as seen (even if invalid)
    0≠ ûLib.⎕NC nm:          ûLibNmP                ⍝ In libuser (>1) or invalid name (-1)? →Return. 
    '←'= ⊃'∘ '~⍨ len↓w:      ûLibNmP                ⍝ Setting name? →Return.
        _← ⍺ LoadObj nm                             ⍝ Try to load obj definition
                             ûLibNmP                ⍝ →Return.                                       
  }
  ⍝ Support Fns: NoLB, NmSpan
    NoLB← {(∨\' '≠⍵)/⍵}                             ⍝ Fast Idiom. 
    ⍝ NmSpan: Find longest left-anchored span of symbols valid in APL simple user names.
    ⍝         We ensure the sequence is a valid name in a later step (see above).
      nmSym← { ⍺← ⎕D ⋄ 0=≢⍵: ⍺~'⍺⍵∇' ⋄ ¯1=⎕NC f←⊃⍵: ⍺ ∇ 1↓⍵ ⋄ (⍺,f) ∇ 1↓⍵ } ⎕AV   
    NmSpan← 0⍳⍨∊∘nmSym
 
  ⍝ ======================================================================================
  ⍝ LoadObj: Find êNm in £.êNm or `L.êNm and try to load its definition into ûLib from path.
  ⍝     (1|0)@B← ûLib@ns verbose@B pârms@ns ∇ êNm@CVS 
  ⍝ Semi-globals: êNm, êNms, êVerbose, êErrFi, êDMX set in the LoadObj executive and used in children.
  ⍝ Find <êNm> in search directories (pârms.path) and dfns workspace, according to parameters <pârms>.
  ⍝ Called by LibAuto (above).
  ⍝    (1|0)← ûLib verbose pârms ∇ êNm 
  ⍝ Returns SHY 1 (succ) or SHY 0 (fail).
  ⍝   - êNm is always exactly one name (segment), which must be both an object name AND
  ⍝     the name of a file (with case respected) OR a workspace object (else the load simply returns SHY 0).
  ⍝   - When complete successfully, êNms may contain just the original ⊂êNm or, if
  ⍝     additional names were created by, e.g., ⎕FIX, those names as well. 
  ⍝   - êNm is ALWAYS the first name in êNms.
  LoadObj← { 
  ⍝ LoadObj utilities are shown first, followed by the executive/main for LoadObj.
  ⍝ LoadObj
  ⍝   SubScanFiles (R)
  ⍝   SubScanWS (R)
  ⍝     ScanPath (R)
  ⍝   EndScan
  ⍝   ScanPath (R) 
  ⍝     SubScanWS (R)
  ⍝     SubScanFiles (R)
  ⍝ -----
  ⍝ (R): Calls itself or sub-fn recursively
  
    ⍝ SubScanFiles:    
    ⍝  ∇ files
    ⍝  extern: êNm 
    ⍝ Search a list of full filenames <files> ending in simple name <êNm> (before suffixes).
    ⍝ If a) it finds such a file
    ⍝    b) the ⎕FIX succeeds, and
    ⍝    c) the name ⍺ is among the names returned in the ⎕FIX, 
    ⍝ then it returns:
    ⍝    success: 1 ('"file:"', fi,'"').
    ⍝ Otherwise, returns: rcNF (not found).
    ⍝ Notes:
    ⍝ ∘ The nameclass distinctions, based on suffixes, are currently NOT enforced for
    ⍝   the first three suffixes, but it's trivial to do.
    ⍝ ∘ When ⎕FIX is applied to the file found, <êNm> must be among the names listed
    ⍝   as ⎕FIXed or an error (rcEN) is reported.
    ⍝ ∘ Other errors reported as rcER. 
    ⍝ ∘ aplv - char vec with newlines, aplvv or txt - vec of char vecs, aplm - char mx
      SubScanFiles← {   
        0= ≢⍵: rcNF ⍬ ⋄ 22 11:: rcER ⍬⊣ êDMX⊢←⎕DMX      ⍝ 22: FILE NAME ERROR
        fi← ⊃⍵       
        ~⎕NEXISTS fi: ∇ 1↓⍵ 
        FixByType← { 
          sfx← ⊂⊃⌽⎕NPARTS fi← ⍵  
          ⍝ When ⎕FIX is applied to ¨fi¨, ¨êNm¨ must be among the names listed as ⎕FIXed.  
          IfF sfx:  rcEN rcOK⊃⍨ êNm⊂⍛∊ êNms⊢← 2 ûLib.⎕FIX _FOpts êErrFi⊢←fi    ⍝ aplf/o/n, dyalog
          IfA sfx:  rcOK⊣ ûLib ⎕VSET ⊂êNm (AN2Apl ⊃⎕NGET fi 1)                 ⍝ apla
          IfJ sfx:  rcOK⊣ ûLib ⎕VSET ⊂êNm (⎕JSON _JOpts ⊃⎕NGET fi 0)           ⍝ json
          IfT sfx:  rcOK⊣ ûLib ⎕VSET ⊂êNm ⊃⎕NGET fi (OptT sfx)                 ⍝ aplv, txt, aplvv, aplm
                    rcEN rcOK⊃⍨ êNm⊂⍛∊ êNms⊢← êNm FixOrAssign fi               ⍝ Any other suffix                    
        }
        (FixByType fi) ('file:"',fi,'"')         
      } 
    ⍝ IfF, etc.: Type tests for FixByType (above); OptT: Option for ⎕NGET for type <t>
      IfF←    ∊∘'.aplf' '.aplo' '.apln' '.dyalog'      ⍝ ⎕FIXable obj.
      IfA←    ≡∘(⊂'.apla')                             ⍝ APLAN obj.
      IfJ←    ≡∘(⊂'.json')                             ⍝ JSON obj
      IfT←    ∊∘(st←'.aplv' '.txt' '.aplvv' '.aplm')   ⍝ char. obj  
      OptT←   ⌷∘0 1 1 2(st∘⍳)                          ⍝ ⎕NGET as target type
      _FOpts← ⍠('FixWithErrors' 0)('Quiet' 1)    
      _JOpts← ⍠('Dialect' 'JSON5')('Compact' 0)('Null' ⎕NULL)  

    ⍝ FixOrAssign:    nms← nm ∇ fi  
    ⍝ Try to ⎕FIX file <fi> inside ûLib. 
    ⍝ If it fails due to 19/11, try reading <fi> as an array notation object, assigning its value to <nm>.
      ⍝ 19: FILE ACCESS ERROR (⎕FIX/⎕NGET). 11: ERROR ⎕FIXING object contents.
      FixOrAssign← { 
        19 11:: (⊂⍺)⊣ ûLib ⎕VSET ⊂⍺ (AN2Apl ⊃⎕NGET ⍵ 1)         ⍝ Array Notation? Assign value to ⍺.
          2 ûLib.⎕FIX _FOpts êErrFi⊢← ⍵                         ⍝ Fixable object? Return what ⎕FIX returns.
      }
      
    ⍝ SubScanWS:     
    ⍝ ret← path ∇ subpath
    ⍝    path:       ScanPath's current (outer) path 
    ⍝    subp:       the list of workspaces
    ⍝ extern: êNm:  name to find     
    ⍝ ∘ May call ScanPath to recursively "return" to scanning the outer ¨path¨.   
    ⍝ Returns: 
    ⍝   a) (retcode ('ws:', wsname)), where retcode∊ (rcOK, rcNF, rcER), or
    ⍝   b) Returns retcode from recursive call to ScanPath  
      ⍝ FixFromWS: If êNm is in workspace ⊃subP, copy it. Otherwise, keep looking.
      SubScanWS← { path subp← ⍺ ⍵
        0=≢subp: ScanPath 1↓path 
          FixFromWS← { 11:: rcNF ⍬ ⋄ rcOK ('ws:"',⍵,'"')⊣ ⍺ ûLib.⎕CY ⍵ }
          ret← êNm FixFromWS ⊃subp
        rcNF≠⊃ret: ret ⋄ path ∇ 1↓subp 
      }

    ⍝ ScanPath:
    ⍝ rcOK@B where@S← ∇ path@NsV 
    ⍝ extern: êNm  
    ⍝ Recursively scan the path for name ⍵ in each file OR wsid 
    ⍝ spec in pârms.⍙fullPath   
    ⍝ ∘ If we see a array (with a single string), it's a workspace: 
    ⍝   call and return result from SubScanWS
    ⍝ ∘ Otherwise, 
    ⍝   call and return result from SubScanFiles
      ⍝ If cur is a vector of (0 or more) char vectors, each is assumed to be a workspace id.
      ⍝ When done, having returned rcNF, recursively continue ScanPath.
      ⍝ Otherwise (rcOK or rcER), return from ScanPath.
      ScanPath← {  
        0= ≢⍵: rcNF ⍬ ⋄ path← ⍵ ⋄ cur← ⊃path
        1< |≡cur: path SubScanWS cur                   ⍝ If VCV, => at least 1 workspace.    
          ff← ,(⊂cur)∘.,(⊂êNm),¨pârms.suffix           ⍝ cur is a CV. Generate ff, list of files.  
          rcNF≠⊃ret← SubScanFiles ff: ret 
          ∇ 1↓path                       
      }

    ⍝ EndScan: Carry out option-based action, then return.
    ⍝ rc← rc  dest ∇ srcFi destNs  
    ⍝ extern: êNm, êNms, êDMX 
    ⍝ 
    ⍝ If (~v), exit quietly, even if an error occur that we've anticpated.
    ⍝ Otherwise, simply print the errors and then continue normally.
    ⍝ This way, the user can trap errors relating to the missing objects. 
    ⍝ If you want errors to be ⎕SIGNALED, set signalOnErr← 1 at Executive
      ⍝ rc=rcER: ⍝ a trapped APL Error i) loading or ii) converting on load ONLY,  
      ⍝ êDMX: An external diagnostic message set *ONLY* in SubScanFiles.
      EndScan←  { rc libE← ⍺ 
        (~êVerbose)∧ rc= rcOK: rc ⋄ (srcFi dest)← ⍵  
          qNms← '"',⍨ 3↓ ∊(êNm⊂⍛, êNms~ ⊂êNm),⍨¨⊂'", "' 
        rc=rcOK: rc⊣ ⎕← '∆F: Copied ', qNms, ' into £ibrary',(0≠ ≢srcFi)/ ' from ',srcFi
          Ê← rc∘{  ⍝ Error msgs, either signaled or simply reported.
            en message← ⍵ 
            libE: ⎕SIGNAL ⊂('EN' en) ('Message' message) 
            ~êVerbose: ⍺ ⋄ ⍺⊣ ⎕← ('∆F ',⎕EM en),': ',message   
          }
        rc=rcNF: Ê 11 ('Object "',êNm,'" not found on search path')   
        rc=rcEN: Ê 11 ('Obj "',êNm,'" not present in ',srcFi) 
      ⍝ rc=rcER: ↓↓↓.
                 Ê êDMX.EN,⍥⊂ 'Error loading ',êNms,' into user library (',êDMX.Message,')'
      }
    ⍝   ===========================================================================
    ⍝   Executive for LoadObj 
    ⍝   ===========================================================================
    ⍝ extern: ûLib, pârms.
      ûsr← ⍺                  ⍝ ûsr - From the ∆F runtime code. => ns.  
      êNms← ,⊂êNm← ⍵          ⍝ êNm - always => CV. êNms - always => VCV, initialliy ,⊂êNm.  See ScanPath.
      êDMX← ⍬                 ⍝ Set in SubScanFiles; ref'd in EndScan only. => ⍬|ns
      êErrFi← ''              ⍝ Referenced in EndScan only...   => CV.
      êVerbose← ∨/ (ûsr pârms).verbose  
      ⍝ Return codes: 
      ⍝   rcOK (êNm found and loaded), 
      ⍝   rcNF (êNm file or w/s not found), 
      ⍝   rcER (specific APL errors, typically a failure to load), 
      ⍝   rcEN (file loaded fine, but êNm wasn't one of the top-level objects, which we reject) 
      rcOK rcNF rcER rcEN← 1 0 ¯1 ¯2   
    ⍝ êVerbose: READ in SubScanFiles and EndScan 
      rc where← ScanPath pârms.⍙fullPath 
    1: _← rc ##.SIGNAL_LIB_ERRS EndScan where ûLib  
  } ⍝ End LoadObj 

:EndSection Runtime Routines 

⍝ ==========================================================================================================================
:Section Loadtime Routines
⍝ ===================================================================================
⍝ LOAD TIME ROUTINES
⍝ ===================================================================================

⍝   LibComplete: Point to (empty, but named) user library at load-time.
⍝      actual ref: ##.userLibrary, local ref (alias): ûLib, local name: ûLibNm.
⍝ external: 
⍝      ûLib, ûLibNm, ûLibNmP
  ∇ {libRef}← LibComplete libRef
    libRef.⎕DF ⎕NULL                      ⍝ Clear, if set...
    ûLibNmP← '(',')',⍨ ûLibNm← ⍕ûLib← libRef 
    ûLib.⎕DF '£=[',ûLibNm,']'
  ∇

⍝ LoadParms: Load default and user pârms for Library processing. (A .∆F LOAD TIME utility)
⍝   rc← ∇ opts
⍝   opts: '[-v] [-c] [-r]'
⍝ ∘ If called more than once, we reload everything so that any user pârms loaded
⍝   reflect changes to the initial, built-in state.
⍝     Load default pârms? If LIB_ACTIVE≥1
⍝     Load user pârms?    If LIB_ACTIVE=2
⍝     Show pârms?         If '-v' in opts or pârms.verbose
⍝     Show compactly?     If '-c' in opts 
⍝     Is this runtime?    If '-r' in opts
⍝ Used at EXECUTIVE below and via 'parms' call in ##.Special.
⍝ *** All LoadParms routines reference the external (global) namespace 'pârms', set in SetBaseParms 
⍝
⍝ LoadParms
⍝   SetBaseParms
⍝   LoadDefaultParms
⍝      LoadErr
⍝   LoadUserParms
⍝      ReadUserParms 
⍝         LoadErr
⍝      ParmsSpecial
⍝   GenFullPath
⍝   LoadErr 
⍝   _CShow 
  ∇ {rc}← LoadParms opts   
    ; isV; isC; isR 
    isV isC isR← (1∊⍷∘opts)¨ '-v' '-c' '-r'  
    rc← 1 0⍴⍬ 
    SetBaseParms ⍬
    :If ##.LIB_ACTIVE≥ 1 
        LoadDefaultParms ##.LIB_PARM_FI 
        :If ##.LIB_ACTIVE= 2
        :AndIf rc← pârms.⍙readParms[0]                 ⍝ Did we read the defaults? If so, continue...
          isR LoadUserParms  ##.LIB_USER_FI        
        :EndIf
      ⍝ If pârms.⍙fullPath is empty, then turn auto off, since there's nowhere to search..
        :If ~0∊ ≢¨pârms.(prefix path)
            pârms.⍙fullPath← GenFullPath pârms  
        :Else 
            pârms.⍙fullPath← ⍬
            isV LoadErr 'The user parameter file generates an empty search path.'
        :EndIf 
        rc← isV (isC _CShow) pârms 
    :EndIf 
  ∇
  ⍝ LoadDefaultParms: Load-time routine
  ⍝   If successful, sets parameters 
  ⍝       ⍵.auto, ⍵.verbose, ⍵.path, ⍵.prefix, ⍵.suffix, etc.
  ⍝   If not,
  ⍝       then no more processing is done, auto←0, and no autoload searching is done (fast). 
  ⍝   If ⍵.path←⍬, 
  ⍝       no files or workspaces are checked.  No autoload searching is done (fast).
  ⍝   If ⍵.suffix←⍬, we will only check workspaces.
  ⍝ These are the default APL Array Notation settings: format ok whether Dyalog 20 or earlier.
  ⍝ User can override in  ##.LIB_USER_FI (.∆F), also in APLAN format. 
    LoadDefaultParms← { fi← ⍵ 
      2 6 11:: _← pârms ⊣ 0 LoadErr 'Default parameter file "',fi,'" has errors'
      ~⎕NEXISTS fi: fi Err 'does not exist'
          _← 'pârms' ⎕NS AN2Apl ⊃⎕NGET fi 1  
          pârms.verbose← (⍬ ⎕NULL∊⍨ ⊂pârms.verbose)⊃ pârms.verbose ##.VERBOSE_RUNTIME 
      1: _← pârms⊣ pârms.⍙readParms← 1 0 
    }  
    ⍝ Set baseline pârms in case we are directed NOT to read the default pârms or if it's corrupted...
      SetBaseParms←{
          ⍙readParms auto path prefix suffix verbose← (0 0) 0 ⍬ ⍬ ⍬ (##.VERBOSE_RUNTIME) 
          'pârms' ⎕NS '⍙readParms' 'auto' 'path' 'prefix' 'suffix' 'verbose' 
      }
    ⍝ What to do if loading defaults or user pârms fails.
    ⍝    ⍺ LoadErr warning
    ⍝ Issues warning ⍵ if ⍵ is non-null  
    ⍝ Sets LibAuto to a nop and sets auto and ⍙readParms to ¯1.
    ⍝ isUsrP=1: error loading USER parameters (.∆F file); 
    ⍝ isUsrP=0: error loading DEFAULT parameters
      LoadErr← { isUsrP← ⍺        
          warn← '❗❗❗ ∆F LIB. WARNING: ' 
          amsg← (⊂'Library Autoload is '),¨ 'not available' 'available',¨'' ' with default parameters.'
          _← { 0=≢⍵: ⍬ ⋄ ⊢⎕← warn, ⍵ }¨ ⍵ ⎕DMX.Message (isUsrP⊃ amsg)    
          ⎕THIS.(LibAuto← LibNoAuto)                  ⍝ No Auto function!
          pârms.(auto ⍙readParms← 0 (0 0))  
        1: _← 0 
      }

  ⍝ LoadUserParms: Loadtime routine
  ⍝ Loads parameter file ⍵ (if it exists) into namespace ⍺
  ⍝ Note default parameters for special cases (sc) below.
  ⍝ If load is 0, the user parameters are NOT loaded, 
  ⍝ but any default parameters already loaded are honored.
  ⍝ Extern: pârms 
    LoadUserParms← {  runtime parmFi← ⍺ ⍵  
      ~pârms.⍙readParms[0]:  _← 0 
        _← runtime ReadUserParms parmFi  
        _← ParmsSpecial pârms
    }  

    ⍝ ReadUserParms: Update parameters from user parm file.
    ⍝ Extern: pârms
      ReadUserParms← { 
        ~⎕NEXISTS ⍵: ⍬ 
        0:: '∆F ReadUser Parms Failed, but error was not trapped' ⎕SIGNAL 911
        2 6 11/⍨ ~⍺:: _← 1 LoadErr 'User parameter file "', ⍵,'" has errors'
          _← 'pârms' ⎕NS AN2Apl ⊃⎕NGET ⍵ 1          ⍝ Merge parm file into internal defaults
          0⊣ pârms.⍙readParms[1]← 1 
      } 
    ⍝ Handle special-case values for  verbose, prefix, auto, path, suffix
    ⍝ ∘ If any parm in namespace ⍵ found in (⊃¨⍺) has value ⎕NULL or ⍬, 
    ⍝   it is replaced in ⍵ by its corresponding default in (⊃∘⌽¨⍺)
      ParmsSpecial←{ 
        ⍺← ('verbose' ##.VERBOSE_RUNTIME) ('prefix'(,⊂'')) ('auto' 0) ('path' ⍬) ('suffix' ⍬) 
        ⍵ ⎕VSET ⍺/⍨ (⍬∘≡∨⎕NULL∘≡)∘⍵.⎕OR∘⊃¨ ⍺
      }
    ⍝ GenFullPath:   pârms.⍙fullPath← ∇ pârms 
      GenFullPath←{
        pfx pth← ⍵.(prefix path)
        ⍬{
          0=≢⍵: ⍺ ⋄ p← ⊂⊃⍵ 
        2<|≡p: (⍺, p) ∇ 1↓⍵                            ⍝ workspace
          (⍺, ,p∘., '/'∘., pfx) ∇ 1↓⍵                  ⍝ file 
        } pth  
      } 
   
    ⍝ _CShow: 
    ⍝ ∘ Cond'lly show all APLAN parameters in 'pârms' in alph order 
    ⍝   (⍺⍺=1) compactly, else (⍺⍺=0) multiline.
    ⍝   EXCEPT internal ones starting with '_'
    ⍝ ∘ If ⍺=1, force a display, even if pârms.verbose=0.
    ⍝ ∘ Returns: a matrix of pârms or (1 0⍴'') 
      _CShow← { ⍺←0 
        0:: 1 0⍴⎕←'❌❌❌ ∆F Load: Error displaying runtime parameters'
        (~⍺)∧ ~⍵.verbose: _← 1 0⍴''  
        0= ≢nl← ⍵.⎕NL ¯2: _←1 0⍴'' 
        1: _← ↑⍺⍺ Apl2AN ⍵.{⎕NS {⍵/⍨ '_'≠⊃¨⍵}⍵} nl
      } 
    ⍝ ShowPath:  Called via 'path' call in ##.Special. 
      ShowPath← { ⊃1 Apl2AN pârms.⍙fullPath } 

      AN2Apl← ⎕SE.Dyalog.Array.Deserialise   
      Apl2AN← ⎕SE.Dyalog.Array.Serialise   

⍝ =========================================================================
⍝ EXECUTIVE
  LibComplete ##.userLibrary
  LoadParms  ''
:EndSection Loadtime Routines
:EndNamespace   ⍝ libUtils
