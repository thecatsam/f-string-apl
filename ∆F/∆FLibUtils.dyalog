⍝ ∆FLibUtils.dyalog      (UPDATE_TIME: '2026-01-14') 
:Namespace libUtils

⍝ ===================================================================================
⍝ RUN TIME ROUTINES
⍝ ===================================================================================

⍝ This namespace handles Library (£ or `L) shortcut automatic loading...
⍝ ∘ See ⍙FUtils for fn ⍙Load_LibAuto, which loads this library.
⍝ ∘ See "Executive" at bottom of file, which calls
⍝   - SetLibIDFull, and 
⍝   - LoadParms  
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
⍝   - If £. is followed by a dotted name nm1.nm2[...], then nm←nm1, the first one;
⍝     That entire namespace is loaded, if found. In this case, that's 'nm1'.
⍝   - (via LoadObj) get source code for it from a file or workspace in our path.
⍝ ∘ Does NOT affect the string ⍵ being scanned. 
⍝   - That's left to the scanner that called LibAuto.
⍝   - Is only used for its ⎕CY or ⎕FIX side effect via LoadObj. 
⍝ ∘ A name may be in the userLibrary w/o having been loaded directly, e.g. 
⍝   - if a file in the domain of ⎕FIX contains multiple objects, all may be loaded. 
⍝   - We simply add ANY valid name to the cache, once we see it. 
⍝ ∘ Invalid names are quietly ignored.
  LibNoAuto← {userLibNmP} 
  LibAuto←{      
    ~⍺.auto:                 userLibNmP       ⍝ Not auto: return.
        w← NoLB ⍵                             ⍝     Skip blanks
    '.'≠ ⊃w:                 userLibNmP       ⍝ No initial '.':   return.
        w← NoLB⊢ w← 1↓w                       ⍝     Skip some more blanks,
        nm← w↑⍨ p← NmSpan w                   ⍝     Get the (apparent) name nm and length p.  
    ⍺.acache∊⍨ ⊂nm:          userLibNmP       ⍝ Saw it before:    return.
        ⍺.acache,← ⊂nm                        ⍝     Mark as seen in autocache global (even if invalid)
    0≠ userLib.⎕NC nm:       userLibNmP       ⍝ In libuser (>1) or invalid name (-1):  return. 
    '←'= ⊃'∘ '~⍨ p↓w:        userLibNmP       ⍝ Name to be set:   return.
        _← userLib ⍺ parms LoadObj nm         ⍝ Try to load obj definition
                             userLibNmP       ⍝ Return.                                       
  }
  ⍝ Support Fns: NoLB, NmSpan
    NoLB← {(∨\' '≠⍵)/⍵}                         ⍝ Fast Idiom. 
    nmSym← { ⍺← ⎕D ⋄ 0=≢⍵: ⍺~'⍺⍵∇' ⋄ ¯1=⎕NC f←⊃⍵: ⍺ ∇ 1↓⍵ ⋄ (⍺,f) ∇ 1↓⍵ } ⎕AV   ⍝ Valid syms in APL user names.
    NmSpan← 0⍳⍨∊∘nmSym
 

  ⍝ ======================================================================================
  ⍝ LoadObj: Find êNm in £.êNm or `L.êNm and try to load its definition into userLib from path.
  ⍝     (1|0)@B← userLib@ns verbose@B parms@ns ∇ êNm@CVS 
  ⍝ Semi-globals: <êNm> and <verbose> set at the LoadObj executive and used in children.
  ⍝ Find <êNm> in search directories (parms.path) and dfns workspace, according to parameters <parms>.
  ⍝ Called by ⍙Auto (above).
  ⍝    (1|0)← userLib verbose parms ∇ êNm 
  ⍝ Returns SHY 1 (succ) or SHY 0 (fail), having established <êNm> in userLib (ns) on success.
  ⍝   - On input, <êNm> is always exactly one name, which must be both an object name AND
  ⍝     the name of a file (with case respected) or a workspace object.
  ⍝   - When complete successfully, êNm may contain just the original <êNm> or, if
  ⍝     additional names were created by, e.g., ⎕FIX, those names as well.
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
      SubScanFiles← {   
        0= ≢⍵: rcNF ⍬ ⋄ 11 22:: rcER ⍬⊣ êDMX⊢←⎕DMX      ⍝ 22: FILE NAME ERROR
        fi← ⊃⍵       
        ~⎕NEXISTS fi: ∇ 1↓⍵ 
        FixByType← { 
          sfx← ⊂⊃⌽⎕NPARTS fi← ⍵  
          ⍝ When ⎕FIX is applied to ¨fi¨, ¨êNm¨ must be among the names listed as ⎕FIXed.  
          Tf sfx:   rcEN rcOK⊃⍨ (⊂êNm)∊ êNms⊢← 2 userLib.⎕FIX _FOpts êErrFi⊢←fi   ⍝ aplf/o/n, dyalog
          Ta sfx:   rcOK⊣ userLib ##.∆VSET ⊂êNm (##.AN2Apl ⊃⎕NGET fi 1)           ⍝ apla
          Tj sfx:   rcOK⊣ userLib ##.∆VSET ⊂êNm (⎕JSON _JOpts ⊃⎕NGET fi 0)        ⍝ json
          Tt sfx:   rcOK⊣ userLib ##.∆VSET ⊂êNm ⊃⎕NGET fi (Ot sfx)                ⍝ aplv, txt, aplvv, aplm
                    rcEN rcOK⊃⍨ (⊂êNm)∊ êNms⊢← êNm FixOrAssign fi                 ⍝ Any other suffix                    
        }
        (FixByType fi) ('file:"',fi,'"')         
      } 
    ⍝ T: Types for FixByType (above); Ot: Option for ⎕NGET for type <t>
      Tf← ∊∘'.aplf' '.aplo' '.apln' '.dyalog'    ⋄ Ta← ≡∘(⊂'.apla')   ⋄   Tj← ≡∘(⊂'.json')                         
      Tt← ∊∘(s4←'.aplv' '.txt' '.aplvv' '.aplm') ⋄ Ot← ⌷∘0 1 1 2(s4∘⍳)    
      _FOpts← ⍠('FixWithErrors' 0)('Quiet' 1)    
      _JOpts← ⍠('Dialect' 'JSON5')('Compact' 0)('Null' ⎕NULL)  
    ⍝ FixOrAssign:    nms← nm ∇ fi  
    ⍝ Try to ⎕FIX file <fi> inside userLib. 
    ⍝ If it fails due to 19/11, try reading <fi> as an array notation object, assigning its value to <nm>.
      FixOrAssign← { 
      ⍝ 19: FILE ACCESS ERROR (⎕FIX/⎕NGET). 11: ERROR ⎕FIXING object contents.
        19 11:: (⊂⍺)⊣ userLib ##.∆VSET ⊂⍺ (##.AN2Apl ⊃⎕NGET ⍵ 1)    ⍝ Array Notation? Assign value to ⍺.
          2 userLib.⎕FIX _FOpts êErrFi⊢← ⍵                         ⍝ Fixable object? Return what ⎕FIX returns.
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
      SubScanWS← { path subp← ⍺ ⍵
        0=≢subp: ScanPath 1↓path 
        ⍝ FixFromWS: If êNm is in workspace ⊃subP, copy it. Otherwise, keep looking.
          FixFromWS← { 11:: rcNF ⍬ ⋄ rcOK ('ws:"',⍵,'"')⊣ ⍺ userLib.⎕CY ⍵ }
          ret← êNm FixFromWS ⊃subp
        rcNF≠⊃ret: ret ⋄ path ∇ 1↓subp 
      }

    ⍝ ScanPath:
    ⍝ rcOK@B where@S← ∇ path@NsV 
    ⍝ extern: êNm  
    ⍝ Recursively scan the path for name ⍵ in each file OR wsid 
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
        ff← ,(⊂cur)∘.,(⊂êNm),¨parms.suffix              ⍝ cur is a CV. Generate ff, list of files.  
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
      EndScan←  { rc libE← ⍺ 
        (~êVerbose)∧ rc= rcOK: rc ⋄ (srcFi dest)← ⍵  
          qNms← '"',⍨ 3↓∊((⊂êNm), êNms~ ⊂êNm),⍨¨⊂'", "' 
        rc=rcOK: rc⊣ ⎕← '∆F: Copied ', qNms, ' into £ibrary',(0≠ ≢srcFi)/ ' from ',srcFi
          Ê← rc∘{  ⍝ Error msgs, either signaled or simply reported.
            en message← ⍵ 
            libE: ⎕SIGNAL ⊂('EN' en) ('Message' message) 
            ~êVerbose: ⍺ ⋄ ⍺⊣ ⎕← ('∆F ',⎕EM en),': ',message   
          }
        rc=rcNF: Ê 11 ('Object "',êNm,'" not found on search path')   
        rc=rcEN: Ê 11 ('Obj "',êNm,'" not present in ',srcFi) 
      ⍝ rc=rcER: ⍝ a trapped APL Error i) loading or ii) converting on load ONLY,  
      ⍝ êDMX: A "global" Diagnostic message. Will be from ⎕DMX only if rc=rcER.
                 Ê êDMX.EN,⍥⊂ 'Error loading ',êNms,' into user library (',êDMX.Message,')'
      }
    ⍝   ===========================================================================
    ⍝   Executive for LoadObj 
    ⍝   ===========================================================================
    ⍝ ê... "External" objects that are used within various subfunctions that are initialised here.
      userLib ê parms← ⍺     ⍝ ê - From the ∆F runtime code. => ns.  

      êDMX←   ⍬              ⍝ Set in SubScanFiles; ref'd in EndScan only. => ⍬|ns
      êErrFi← ''             ⍝ Referenced in EndScan only...   => CV.
    ⍝ êNms may be modifled in ScanPath, if multiple objects are ⎕FIXed.
      êNms← ,⊂êNm← ⍵         ⍝ êNm - always => CV. êNms - always => VCV, initialliy ,⊂êNm. 
      êVerbose←   ê.verbose ∨ parms.verbose         
      ⍝ Return codes: 
      ⍝   rcOK (<êNm> found and loaded), 
      ⍝   rcNF (<êNm> file or w/s not found), 
      ⍝   rcER (specific APL errors, typically a failure to load), 
      ⍝   rcEN (file loaded fine, but <êNm> wasn't one of the top-level objects, which we reject) 
      rcOK rcNF rcER rcEN← 1 0 ¯1 ¯2   
    ⍝ êVerbose: READ in SubScanFiles and EndScan 
      rc where← ScanPath parms._fullPath 
    1: _← rc ##.SHOW_LIB_ERRS EndScan where userLib  
  } ⍝ End LoadObj 

⍝ ==========================================================================================================================
⍝ ==========================================================================================================================

⍝ ===================================================================================
⍝ LOAD TIME ROUTINES
⍝ ===================================================================================

⍝   SetLibIDFull: Point to (empty, but named) user library at load-time.
⍝      actual ref: ##.userLibrary, local ref (alias): userLib, local name: userLibNm.
⍝ external: 
⍝      userLib, userLibNm, Auto, parms, ShowPath, LoadParms   ⍝ loaded here...
  ∇ {libNs}← SetLibIDFull libNs
    ⍝ external: userLib, userLibNm, userLibNmP
    libNs.⎕DF ⎕NULL                      ⍝ Clear, if set...
    userLibNmP← '(',')',⍨ userLibNm← ⍕userLib← libNs 
    userLib.⎕DF '£=[',userLibNm,']'
  ∇

⍝ LoadParms: Load default and user parms for Library processing. (A .∆F LOAD TIME utility)
⍝   rc← ∇ opts
⍝   opts: '[-v] [-c] [-r]'
⍝ ∘ If called more than once, we reload everything so that any user parms loaded
⍝   reflect changes to the initial, built-in state.
⍝     Load default parms? If LIB_ACTIVE≥1
⍝     Load user parms?    If LIB_ACTIVE=2
⍝     Show parms?         If '-v' in opts or parms.verbose
⍝     Show compactly?     If '-c' in opts 
⍝     Is this runtime?    If '-r' in opts
⍝ Used at EXECUTIVE below and via 'parms' call in ##.Special.
⍝ *** All LoadParms routines reference the external (global) namespace 'parms', set in SetBaseParms 
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
        :AndIf rc← parms._readParms[0]     ⍝ Did we read the defaults? If so, continue...
          isR LoadUserParms  ##.LIB_USER_FI        
        :EndIf
      ⍝ If parms._fullPath is empty, then turn auto off, since there's nothing to search..
        :If ~0∊ ≢¨parms.(prefix path)
            parms._fullPath← GenFullPath parms  
        :Else 
            parms._fullPath← ⍬
            isV LoadErr 'The user parameter file generates an empty search path.'
        :EndIf 
        rc← isV (isC _CShow) parms 

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
      2 6 11:: _← parms ⊣ 0 LoadErr 'Default parameter file "',fi,'" has errors'
      ~⎕NEXISTS fi: fi Err 'does not exist'
          _← 'parms' ⎕NS ##.AN2Apl ⊃⎕NGET fi 1  
          parms.verbose← (⍬ ⎕NULL∊⍨ ⊂parms.verbose)⊃ parms.verbose ##.VERBOSE 
      1: _← parms⊣ parms._readParms← 1 0 
    }  
    ⍝ Set baseline parms in case we are directed NOT to read the default parms or if it's corrupted...
      SetBaseParms←{
          _readParms auto path prefix suffix verbose← (0 0) 0 ⍬ ⍬ ⍬ (##.VERBOSE) 
          'parms' ⎕NS '_readParms' 'auto' 'path' 'prefix' 'suffix' 'verbose' 
      }
    ⍝ What to do if loading defaults or user parms fails.
    ⍝    ⍺ LoadErr warning
    ⍝ Issues warning ⍵ if non-null  
    ⍝ Sets LibAuto to a nop and sets auto and _readParms to ¯1.
      LoadErr← { isUsrP← ⍺         ⍝ Do we have an error in user parmloading (or in default parm load)?
          warn← '>>> ∆F LIB. WARNING: ' 
          amsg← (⊂'Library Autoload is '),¨ 'not available' 'available',¨'' ' with default parameters.'
          _← { 0=≢⍵: ⍬ ⋄ ⊢⎕← warn, ⍵ }¨ ⍵ ⎕DMX.Message (isUsrP⊃ amsg)    
          ⎕THIS.(LibAuto← LibNoAuto)                                     ⍝ No Auto function!
          parms.(auto _readParms← 0 (0 0))  
        1: _← 0 
      }

  ⍝ LoadUserParms: Loadtime routine
  ⍝ Loads parameter file ⍵ (if it exists) into namespace ⍺
  ⍝ Note default parameters for special cases (sc) below.
  ⍝ If load is 0, the user parameters are NOT loaded, but any default parameters already loaded are honored.
    LoadUserParms← {  runtime parmFi← ⍺ ⍵  
      ~parms._readParms[0]:  _← 0 
        _← runtime ReadUserParms parmFi  
        _← parms ParmsSpecial ('verbose' ##.VERBOSE) ('prefix'(,⊂'')) ('auto' 0) ('path' ⍬) ('suffix' ⍬)

    }  
    ⍝ ReadUserParms: Update parameters from user parm file.
      ReadUserParms← { 
        ~⎕NEXISTS ⍵: ⍬ 
        0:: '∆F ReadUser Parms Failed, but error was not trapped' ⎕SIGNAL 911
        2 6 11/⍨ ~⍺:: _← 1 LoadErr 'User parameter file "', ⍵,'" has errors'
          _← 'parms' ⎕NS ##.AN2Apl ⊃⎕NGET ⍵ 1      ⍝ Merge parm file into internal defaults
          0⊣ parms._readParms[1]← 1 
      } 
    ⍝ Handle special-case values for  verbose, prefix, auto, path, suffix
    ⍝ ∘ If any parm in (⊃¨sc) has value ⎕NULL or ⍬, 
    ⍝   it is replaced by its default shown here in (⊃∘⌽¨sc)
      ParmsSpecial←{  
        ⍺ ##.∆VSET ⍵/⍨ (⍬∘≡∨⎕NULL∘≡)∘⍺.⎕OR∘⊃¨ ⍵
      }
    ⍝ GenFullPath:   _parms._fullPath← ∇ parms 
      GenFullPath←{
        pfx pth← ⍵.(prefix path)
        ⍬{
          0=≢⍵: ⍺ ⋄ p← ⊂⊃⍵ 
        2<|≡p: (⍺, p) ∇ 1↓⍵                           ⍝ workspace
          (⍺, ,p∘., '/'∘., pfx) ∇ 1↓⍵                  ⍝ file 
        } pth  
      } 
   
    ⍝ _CShow: 
    ⍝ ∘ Cond'lly show all APLAN parameters in 'parms' in alph order 
    ⍝   (⍺⍺=1) compactly, else (⍺⍺=0) multiline.
    ⍝   EXCEPT internal ones starting with '_'
    ⍝ ∘ If ⍺=1, force a display, even if parms.verbose=0.
    ⍝ ∘ Returns: a matrix of parms or (1 0⍴'') 
      _CShow← { ⍺←0 
        0:: 1 0⍴⎕←'∆F Load: Error displaying runtime parameters'
        (~⍺)∧ ~⍵.verbose: _← 1 0⍴''  
        0= ≢nl← ⍵.⎕NL ¯2: _←1 0⍴'' 
        1: _← ↑⍺⍺ ##.Apl2AN ⍵.{⎕NS {⍵/⍨ '_'≠⊃¨⍵}⍵} nl
      } 
    ⍝ ShowPath:  Called via 'path' call in ##.Special. 
      ShowPath← { ⊃1 ##.Apl2AN parms._fullPath } 

⍝ =========================================================================
⍝ EXECUTIVE
  SetLibIDFull ##.userLibrary
  LoadParms  ''
:EndNamespace   ⍝ libUtils
