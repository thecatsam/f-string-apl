## 0 Introduction

<div class="right-margin-bar">

<a id="intro" class="scroll-target"></a>

<div class="marquee">

<center>

***∆F*** is a function for *Dyalog* *APL* that interprets *f‑strings*, a
concise, yet powerful way to display multiline *APL* text, arbitrary
*APL* expressions, and multi­dimensional objects using extensions to
*dfns* and other familiar tools.
</center>

</div>

------------------------------------------------------------------------

</details>

<!-- <div class="page-break"></div>  -->

# Preparing to Run **∆F**

<details open>

<!-- option: open -->

<summary class="summary">

 <span style="opacity:0.6;">Show/Hide</span> <em>Preparing to Run
<bold>∆F</bold></em>
</summary>

<a id="inside-preparing" class="scroll-target"></a>

## **∆F** Installation

1.  Via your browser, go to Github URL
    <mark><a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https://github.com/thecatsam/f-string-apl.git</span></a></mark>.
2.  Make a note of your current (or desired) working directory.
3.  Download and copy the file **∆F.dyalog** and directory **∆F** (which
    contains several files) into the current working directory, ensuring
    they are peers, *i.e.* at the same directory level.

<big>👉</big> Now, **∆F** is available to load and use. Continue in the
[next section](#loading-and-running-f).

## Loading and Running **∆F**

1.  Confirm that your current directory remains as before.
2.  From your Dyalog session, enter: <br> `]load ∆F -target=⎕SE`<br>
    Now, the target directory (`⎕SE`) will contain the function `∆F` and
    namespace `⍙FUtils`.
3.  By default, the ***help*** file, **∆F/∆FHelp.html** is available at
    `]load` time. If so, it will be copied into **⍙FUtils**. If not
    available, a message will note the absence of *help* information.
4.  Namespace <code>*⎕SE*.**⍙FUtils**</code> contains utilities used by
    **∆F** and, once `]load`ed, ***should not*** be moved, as **∆F**
    always refers to **⍙FUtils** in its *original* location.
5.  By default, the target namespace (<code>*⎕SE*</code>) will be added
    to the end of `⎕PATH`, if not already defined there. You may always
    choose to relocate or assign **∆F** anywhere you want so that it is
    available.

<big>👉</big> <small>You may now call `∆F` with the desired
[arguments](#f-call-syntax-overview) and
[options](#f-option-details).</small><br> <big>👉</big> <small>**∆F** is
`⎕IO`- and `⎕ML`-independent.<br></small> <big>👉</big> <small>**∆F**’s
“help” system uses Dyalog’s ***HtmlRenderer*** service to display its
documentation or, if unavailable, the ***Ride*** development
environment. A less robust version of this help information is also
available in the file *readme.md* on Github.</small>

## Displaying ∆F **Help** in *APL*

<big>👉</big> To display this **HELP** information, type: `∆F⍨ 'help'`.

------------------------------------------------------------------------

</details>

<div class="page-break">

</div>

# Overview

<details open>

<summary class="summary">

 <span style="opacity:0.6;">Show/Hide</span> <em>Overview</em>
</summary>

<a id="inside-overview" class="scroll-target"></a>

Inspired by [Python f‑strings](#appendix-ii-python-fstrings), **∆F**
includes a variety of capabilities to make it easy to evaluate, format,
annotate, and display related multi­dimensional information. A **∆F**
*f-string* is (typically) a character vector, which may reference
objects in the environment, additional function arguments, or both.

**∆F** *f‑strings* include:

- The abstraction of 2-dimensional character ***fields***, generated
  one-by-one from the user’s specifications and data, then aligned and
  catenated into a single overall character matrix result;

- **Text** fields, each allowing [multiline Unicode
  text](#text-fields-and-space-fields), with the sequence `` `◇ ``
  generating a **new line**;

- **Code** fields, allowing users to evaluate and display *APL* arrays
  of any dimensionality, depth, and type in the user environment, arrays
  passed as **∆F** arguments, as well as arbitrary *APL* expressions
  based on full multi-statement dfn logic. Each **Code** field must
  return a value, simple or otherwise, which will be catenated with
  other fields and returned from **∆F**;

  **Code** fields also provide a number of concise, convenient
  extensions, such as:

  - **Quoted strings** in **Code** fields, with several quote styles:

    - **double-quotes**<br> `∆F '{"like this"}'` or
      `` ∆F '{"on`◇""three""`◇lines"}' ``
    - **double angle quotation marks**,<br>
      `∆F '{«with internal quotes like "this" or ''this''»}'`,<br> *not
      to mention:*
    - *APL*’s tried-and-true embedded **single-quotes**,<br>
      `∆F '{''shown ''''right'''' here''}'`

  - Simple shortcuts for

    - **format**ting numeric arrays, **\$** (short for
      **⎕FMT**):<br>`∆F '{"F7.5" $ ?0 0}'`
    - putting a **box** around a specific expression,
      **\`B**:<br>`` ∆F '{`B ⍳2 2}' ``
    - placing the output of one expression **above** another,
      **%**:<br>`∆F '{"Pi"% ○1}'`
    - formatting **date** and **time** expressions from *APL* timestamps
      (**⎕TS**) using **\`T**:<br>`` ∆F '{"hh:mm:ss" `T ⎕TS}' ``
    - calling arbitrary functions on the fly from the **dfns** workspace
      or a user file:<br>`∆F '{41=£.pco 12}' ⍝ Is 41 the 12th prime?`
    - *and more*;

  - Simple mechanisms for concisely formatting and displaying data from

    - user arrays of any shape and
      dimensionality:<br>`tempC← 10 110 40 ◇ ∆F '{tempC}'` <br>
    - arbitrary *dfn*-style
      code:<br>`∆F '{ 223423 ≡⊃£.dec £.hex 223423: "Checks out" ◇ "Bad"}'`
      <br>
    - arguments to **∆F** that follow the format
      string:<br>`` ∆F '{32+`⍵1×9÷5}' (10 110 40) `` *either*
      [**positional**](#f-option-details) or
      [**keyword**](#f-option-details) (namespace-based) options, based
      on *APL* Array Notation (in­tro­duced in Dyalog 20);

- Multiline (matrix) output built up field-by-field, left-to-right, from
  values and expressions in the calling environment or arguments to
  **∆F**;

  - After all fields are generated, they are aligned vertically, then
    concatenated to form a single character matrix: ***the return value
    from*** **∆F**.

**∆F** is designed for ease of use, *ad hoc* debugging, fine-grained
formatting and informal user interaction, built using Dyalog functions
and operators.

<details open>

<!-- option: open -->

<summary class="summary">

 Recap: <em>The Three Field Types</em>
</summary>

<a id="table-field-types" class="scroll-target"></a>

| Field Type | Syntax | Examples | Displaying |
|:--:|:--:|:--:|:--:|
| *Text* F. | *Unicode text* | `` Cats`◇and`◇dogs! `` | 2-D Text |
| *Code* F. | `{`*dfn code plus*`}` `{`*shortcuts*`}` | `` {"1`◇one"} {"2`◇two"}` `` `{"F5.1" $ (32+9×÷∘5)degC}` | Arbitrary *APL* Express­ions via dfns, including **Quoted Strings** |
| *Space* F. <br>(*Null Space* F.) | `{`<big>␠ ␠ ␠</big>`}` <br> `{}` | `{  }` <br> `{}` | Spacing <br> (Field Separation) |

2a. <strong>The Three Field Types</strong>

<br>
</details>

</details>

<div class="page-break">

</div>

# Quick Start

<details open>

<!-- option: open -->

<summary class="summary">

 <span style="opacity:0.6;">Show/Hide</span> <em>Quick Start</em>
</summary>

<a id="inside-quick-start" class="scroll-target"></a>

### <span class="blue"><strong>Here’s a quick start for the <small>**TL;DR**</small> crowd. </strong></span>

**3.1: Embed variables**

       n← ⍪1+⍳3 ◇ nPi← ⍪○n  
       ∆F 'For n={ n }, n×Pi={ nPi }'  
    For n=1, n×Pi=3.141592653589793
          2       6.283185307179586
          3       9.42477796076938 

**3.2: Embed expressions**

       ∆F 'For n={ ⍪1+⍳3 }, n×Pi={ ⍪○1+⍳3 }'  
    For n=1, n×Pi=3.141592653589793
          2       6.283185307179586
          3       9.42477796076938 

**3.3: Build multiline text fields and code fields**

    ⍝      <----  text field  ---->   <- text field ->    <- code field str ->
       ∆F 'Cats`◇Elephants`◇Monkeys{ }like`◇enjoy`◇eat{ }{"toys.`◇tv.`◇fruit."}'
    Cats      like  toys. 
    Elephants enjoy tv.   
    Monkeys   eat   fruit.

**3.4: Apply the Format shortcut \$**

       ∆F 'For n={ ⍪1 2 3 }, n×Pi={ "F7.5"$ ○1 2 3 }'  
    For n=1, n×Pi=3.14159
          2       6.28319
          3       9.42478

**3.5: Add Omega shortcut expressions**

    ⍝  `⍵1 ==> (⍵⊃⍨ 1+⎕IO), i.e. ⎕IO-independently
       ∆F 'For n={ ⍪`⍵2 }, n×Pi={ `⍵1 $ ○`⍵2 }' 'F7.5' (1 2 3)
    For n=1, n×Pi=3.14159
          2       6.28319
          3       9.42478

**3.6: Add the Box shortcut**

       ∆F 'For n={ `B ⍪`⍵1 }, n×Pi={ `B "F7.5"$ ○`⍵1 }' (1 2 3)
    For n=┌─┐, n×Pi=┌───────┐
          │1│       │3.14159│
          │2│       │6.28319│
          │3│       │9.42478│
          └─┘       └───────┘

**3.7: Use Self-Documenting Code Fields and the Box option**

``` dyalog20
   names←  ⍪'Ted' 'Mary' 'Sam'
   scores← ⍪(70 66 44) (82 88 92) (90 77 83)
   Ave← +/÷≢
   (box: 1) ∆F '{names↓}{scores↓}{1⍕Ave¨scores↓}'
┌──────┬──────────┬─────────────┐
│names↓│ scores↓  │1⍕Ave¨scores↓│
│ Ted  │ 70 66 44 │     60.0    │
│ Mary │ 82 88 92 │     87.3    │
│ Sam  │ 90 77 83 │     83.3    │
└──────┴──────────┴─────────────┘
```

<div class="page-break">

</div>

**3.8: Serialise an object in Array Notation**

       anim←(cat: 1 ◇ dog: 2 ◇ mouse: 3)
       ∆F '{`⍵1 `S anim ↓} { `⍵2 `S anim↓}' 1 0    
      `⍵1 `S anim ↓        `⍵1 `S anim↓ 
    (cat:1◇dog:2◇mouse:3◇)  (        
                             cat:1   
                             dog:2   
                             mouse:3 
                           )          

**3.9: Grab utility automagically from** ***dfns*** **workspace (or from
a file)**

       ∆F'{ £.hex 57005 48879 51966}'   ⍝ Get hex fn to convert dec to hexadecimal!
     dead  beef  cafe 

### <span class="blue"><strong>That’s 80% of what you need. Read on for more…</strong></span>

</details>

<div class="page-break">

</div>

# ∆F Reference

<details open>

<!-- option: open -->

<summary class="summary">

 <span style="opacity:0.6;">Show/Hide</span> <em>Syntax Info</em>
</summary>

<a id="inside-reference" class="scroll-target"></a>

## ∆F Call Syntax Overview

<a id="table-call-syntax" class="scroll-target"></a>

| Call Syntax | Description |
|:---|:---|
| **∆F** ***f‑string*** | Display an *f‑string*; use the *default* options. The string may reference objects in the environment or in the string itself. Returns a character matrix. <br><strong><span class="red"><strong>Single or </strong></span>[<span class="red"><strong>multi­line f-string:</strong></span>](#multiline-f-strings-in-dyalog-20)</strong> An ***f-string*** must be a character vector of any length or a [vector of character vectors](#multiline-f-strings-in-dyalog-20). If the latter, it will be converted (via *enlist,* `∊`) to one, longer character vector, without any added spaces, newlines, etc. |
| **∆F** ***f‑string*** ***args*** | Display an *f‑string* (see above); use the *default* options. Arguments presented *may* be referred to in the f‑string. Returns a character matrix. |
| ***options*** **∆F** ***f‑string*** \[***args***\] | Display an *f‑string* (see above); control the result with *options* specified (see below).<br><span class="red"><strong>If ***dfn*** (see below) is ***0*** or omitted,</strong></span> returns a character matrix.<br><span class="red"><strong>If ***dfn*** is ***1***,</strong></span> returns a dfn that will display such a matrix (given an identical system state). |
| ‘help’ **∆F** ‘ ’ *or* **∆F**⍨‘help’ | Display help info and examples for **∆F**. The *f‑string* is not examined. <big>👉</big> See below for details and related examples. |
| ***Return value*** | See below. |

5a. <strong>∆F Call Syntax Overview</strong>

## ∆F Option Details

<a id="inside-option-details" class="scroll-target"></a>

| <br>Mode | Positional<br>Option<br><small>\[*index*\]</small> | Keyword<br>Option<br><small>(*kw: def*) | <br>Description |
|:--:|:--:|:--:|:---|
| **Dfn** | ***\[0\]*** | ***dfn: 0*** | <span class="red"><strong>If ***dfn: 1***,</strong></span> **∆F** returns a dfn, which (upon execution) produces the same output as the default mode.<br><span class="red"><strong>If ***dfn: 0*** (default),</strong></span> **∆F** returns a char. matrix. |
| **Verbose** | ***\[1\]*** | ***verbose: 0*** | <span class="red"><strong>If ***verbose: 1***,</strong></span> Renders newline characters from `` `◇ `` as the visible `␤` character. Displays the source code that the *f‑string* ***actually*** generates; <span class="red"><strong>if ***dfn*** is also ***1***,</strong></span> this will include the embedded *f‑string* source (accessed as `` `⍵0 ``). After the source code is displayed, it will be executed or converted to a *dfn* and returned (see the ***dfn*** option above).<br><span class="red"><strong>If ***verbose: 0*** (default),</strong></span> newline characters from `` `◇ `` are rendered normally as carriage returns, `⎕UCS 13`; the ***dfn*** source code is not displayed. |
| **Box** | ***\[2\]*** | ***box: 0*** | <span class="red"><strong>If ***box: 1***,</strong></span> each field (except a null **Text** field) is boxed separately.<br><span class="red"><strong>If ***box: 0*** (default),</strong></span> nothing is boxed automatically. Any **Code** field expression may be explicitly boxed using the **Box** shortcut, `` `B ``.<br><big>👉</big> ***Box*** mode can be used with settings <strong>`dfn: 1`</strong> *and* <strong>`dfn: 0`.</strong> |
| **Auto** | ***\[3\]*** | ***auto: 1*** | <span class="red"><strong>If ***auto: 0***,</strong></span> user must manually load/create any Session Library objects for use with the £ or `` `L `` shortcuts.<br><span class="red"><strong>If ***auto: 1*** (default),</strong></span> honors the default and user-defined settings for `auto`.<br><big>👉</big> Depends on (i) user parameter file **./.∆F** and (ii) the namespace **⍙FUtils** created during the `]load` process. |
| **Inline** | ***\[4\]*** | ***inline: 0*** | <span class="red"><strong>If ***inline: 1***,</strong></span> the code for each internal support function used is included in the result. <span class="red"><strong>If ***dfn*** is also 1,</strong></span> ***no*** reference to namespace **⍙FUtils** will be made during the execution of the generated *dfn*. (***Exception:*** see *Session Library Shortcuts* below.)<br><span class="red"><strong>If ***inline: 0*** (default),</strong></span> whenever **∆F** or a *dfn* generated by it is executed, it makes calls to library routines in the namespace **⍙FUtils**, created during the `]load` process for **∆F**.<br><big>👉</big> This option is experimental and may simply disappear one day. |
| **Special** | ***‘help’*** | — | <span class="red"><strong>If ***‘help’*** is specified,</strong></span> this amazing doc­ument­ation is displayed. |
| **Special** | ***‘parms’*** | — | <span class="red"><strong>If ***‘parms’*** is specified,</strong></span> updates and displays Session Library (`£` or `` `L ``) pa­ram­eters. |

5b. <strong>∆F Option Details</strong>

- **Default options:** If the left argument `⍺` is omitted, the options
  default as shown here.

<a id="table-default-options" class="scroll-target"></a>

|  Option Style  |                        Defaults                        |
|:--------------:|:------------------------------------------------------:|
| **Positional** |                      `0 0 0 1 0`                       |
|  **Keyword**   | `(dfn: 0 ◇ verbose: 0 ◇ box: 0 ◇ auto: 1 ◇ inline: 0)` |

5c. <strong>∆F Default Options</strong>

- **Positional-style options:** If **∆F**’s left argument `⍺` is a
  simple integer vector (or a scalar), omitted (trailing) elements are
  replaced by the corresponding elements of the default,
  `0 0 0 1 0`.<br><big>👉</big> Extra elements will be ***ignored!***
- **Keyword-style options:** If the left argument is a namespace, it is
  assumed to contain option names (in any order) with their non-default
  values,<br>  e.g. `(verbose: 1 ◇ auto: 0)`;  
  Keyword options are new for Dyalog 20. They are sometimes clearer and
  more convenient than positional keywords.
- **Help option:** If the left argument `⍺` starts with `'help'` (case
  ignored), this help information is displayed. In this case, the right
  argument to **∆F** is ignored.
- **Parms option:** If the left argument `⍺` matches `'parms'` (case
  ignored), the Session Library parameters are (re-)loaded and
  displayed. In this case, the right argument to **∆F** is ignored.
- Otherwise, an error is signaled.

## ∆F Return Value

- Unless the ***dfn*** option is selected, **∆F** always returns a
  character matrix of at least one row and zero columns, `1 0⍴0`, on
  success. If the ‘help’ option is specified, **∆F** displays this
  information, returning `1 0⍴0`. If the ‘parms’ option is specified,
  **∆F** shows the Session Library parameters as a character matrix.
- If the ***dfn*** option is selected, **∆F** always returns a standard
  Dyalog dfn on success.
- On failure of any sort, an informative *APL* error is signaled.

## ∆F F‑string Building Blocks

The first element in the right arg to ∆F is a character vector, an
*f‑string*, which contains one or more **Text** fields, **Code** fields,
and **Space** fields in any combination.

- **Text** fields consist of simple text, which may include any Unicode
  characters desired, including newlines.
  - Newlines (actually, carriage returns, `⎕UCS 13`) are normally
    entered via the sequence `` `◇ ``.
  - Additionally, literal curly braces can be added via `` `{ `` and
    `` `} ``, so they are distinct from the simple curly braces used to
    begin and end **Code** fields and **Space** fields.
  - Finally, to enter a single backtick `` ` `` just before the special
    symbols `{`, `}`, `◇`, or `` ` ``, enter ***two*** backticks
    ``` `` ```; if preceding any ordinary symbol, a ***single***
    backtick will suffice.
  - If **∆F** is called with an empty string, `∆F ''`, it is interpreted
    as containing a single 0-length **Text** field, returning a matrix
    of shape `1 0`.
- **Code** fields are run-time evaluated expressions enclosed within
  simple, unescaped curly braces <code>{ }</code>, *i.e.* those not
  preceded by a backtick (see the previous paragraph).
  - **Code** fields are, under the covers, Dyalog *dfns* with some
    extras.
  - For escape sequences, see **Escape Sequences** below.
- **Space** fields appear to be a special, *degenerate*, form of
  **Code** fields, consisting of a single pair of simple (unescaped)
  curly braces `{}` with zero or more spaces in between.
  - A **Space** field with zero spaces is a ***null*** **Space** field;
    while it may separate any other fields, its typical use is to
    separate two adjacent **Text** fields.
  - Between fields, **∆F** adds no automatic spaces; that spacing is
    under user control.

## Code Field Shortcuts

**∆F** **Code** fields may contain various shortcuts, intended to be
concise and expressive tools for common tasks. **Shortcuts** are valid
in **Code** fields only *outside* **Quoted strings**.

**Shortcuts** include:

<a id="table-shortcuts" class="scroll-target"></a>

| Shortcut | Name | Syntax | Meaning |
|:---|:--:|:--:|:---|
| **\`A**, **%** | Above | `[⍺] % ⍵` | Centers array `⍺` above array `⍵`.<br>If omitted, `⍺←''`, *i.e.* a blank line. |
| **\`B** | Box | `` `B ⍵ `` | Places `⍵` in a box. `⍵` is any array. <big>👉</big>In contrast with Dyalog `]box` mode, even simple scalars and vectors are boxed here. |
| **\`C** | Commas | `` [⍺]`C ⍵ `` | By default, adds commas after every 3rd digit (from the right) of the *integer* part of each number in `⍵` (leaving the fractional part as is). `⍵` is zero or more num strings and/or numbers. If specified, ⍺\[0\] is the stride, *if not 3,* as an integer or as a single quoted digit; if specified, ⍺\[1\] is the character (even “\`◇”) to insert *in place of* a comma. <br><small>Examples: “5\_” adds an underscore every 5 digits from the right. “3\`◇” puts each set of 3 digits on its own line.</small> |
| **\`D** | Date-Time | `` [⍺]`D ⍵ `` | Synonym for **\`T**. |
| **\`F**, **\$** | ⎕FMT | `[⍺] $ ⍵` | Short for `[⍺] ⎕FMT ⍵`. (See *APL* doc­ument­ation). |
| **\`J** | Justify | `` [⍺]`J ⍵ `` | Justify each row of object `⍵` as text:<br>  *left*: ⍺=“L”; *center*: ⍺=“C”; *right* ⍺=“R”.<br>You may use `¯1`\|`0`\|`1` in place of `"L"`\|`"C"`\|`"R"`. If omitted, `⍺←'L'`. <small>*Displays numbers with the maximum precision available.*</small> |
| **\`L**, **£** | Session Library | `£.nm`<br><code>£.nm<span class="grey"><strong>.nm2</strong></span></code> | `£` denotes a private library (namespace) local to the **∆F** runtime environ­ment into which functions or objects (including name­spaces) may be placed (e.g. via `⎕CY`) for the duration of the *APL* session.<br>**Autoload:** Outside of simple assignments, **∆F** will attempt to copy an undefined object named `nm` in the expression `£.nm`, <code>£.nm<span class="grey"><strong>.nm2</strong></span></code>, *etc.*, from, *in order:*<br> <small><small><span class="blue"><strong>DIRECTORY:</strong></span></small></small> **./MyDyalogLib/**  \>  <small><small><span class="blue"><strong>*APL* WS:</strong></span></small></small> **dfns**  \> <small><small><span class="blue"><strong>DIRECTORY:</strong></span></small></small> **./**<br><small>Other `£` expressions like `£.(hex dec)` are valid, but no autoload takes place.<br>*For filetypes and customisation, see [Session Library Shortcut: Details](#session-library-shortcut-details) below.*</small> |
| **\`Q** | Quote | `` [⍺]`Q ⍵ `` | Recursively scans `⍵`, putting char. vectors, scalars, and rows of higher-dimensional strings in APL quotes, leaving other elements as is. If omitted, `⍺←''''`. |
| **\`S** | Serialise | `` [⍺]`S ⍵ `` | Serialise an *APL* array (via ⎕SE.Dyalog.Array.Serialise), i.e. show in *APL* Array Notation (APLAN), either (`⍺=0`, the default) in *tabular* (multiline) form or (`⍺=1`) compactly with statement separators `◇` in place of newlines. If omitted, `⍺←0`. <small>*See details below.*</small> |
| **\`T** | Date-Time | `` [⍺]`T ⍵ `` | Displays timestamp(s) `⍵` according to date-time template `⍺`. `⍵` is one or more APL timestamps `⎕TS`. `⍺` is a date-time template in `1200⌶` format. If omitted, `⍺← '%ISO%'`. |
| **\`W** | Wrap | `` [⍺]`W ⍵ `` | Wraps the rows of simple arrays in ⍵ in decorators `0⊃2⍴⍺` (on the left) and `1⊃2⍴⍺` (on the right). If omitted, `⍺←''''`. <small>*See details below.*</small> |
| **\`⍵𝑑𝑑**, **⍹𝑑𝑑** | Omega Shortcut<br>(<small>EXPLICIT</small>) | — | A shortcut of the form `` `⍵𝑑𝑑 `` (or `⍹𝑑𝑑`), to access the `𝑑𝑑`**th** element of `⍵`, *i.e.* `(⍵⊃⍨ 𝑑𝑑+⎕IO)`. <small>*See details below.*</small> |
| **\`⍵**, **⍹** | Omega Shortcut<br>(<small>IMPLICIT</small>) | — | A shortcut of the form `` `⍵ `` (or `⍹`), to access the ***next*** element of `⍵`. <small>*See details below.* <small> |
| **→**<br>**↓** *or* **%** | Self-documenting **Code** Fields <small>(SDCFs)</small> | — | `→` at end of **Code** field signals that the source code for the field appears *to the left of* its value. Surrounding blanks are significant.<br>`↓` (*or,* `%`) at end of **Code** field signals that the source code for the field appears *above* its value. Surrounding blanks are significant.<br><small>*See [SDCFs](#self-documenting-code-fields-sdcfs) in **Examples** for details.*</small> |

5d. <strong>Code Field Shortcuts</strong>

<br>

## Escape Sequences: Text Fields & Quoted Strings

**∆F** **Text** fields and **Quoted strings** in **Code** fields may
include a small number of escape sequences, beginning with the backtick
`` ` ``. Some sequences are valid in **Text** fields *only*, but not in
Quoted strings:

<a id="table-escapes" class="scroll-target"></a>

| Escape Sequence | What It <br>Inserts | <br> Description | <br> Where |
|:--:|:--:|:--:|:--:|
| **\`◇** | *new line* | ⎕UCS 13 | Text fields and Quoted Strings |
| **\`\`** | \` | backtick | Text fields and Quoted Strings |
| **\`{** | { | left brace | Text fields only |
| **\`}** | } | right brace | Text fields only |

5e. <strong>Escape Sequences</strong>

Other instances of the backtick character in **Text** fields or **Quoted
strings** in **Code** fields will be treated literally.

## Quoted Strings in Code Fields

As mentioned in the introduction, **Quoted strings** in **Code** fields
allow several delimiting quote styles:

- **double-quotes**<br> `∆F '{"like «this» one"}'` or
  `∆F '{"like ''this'' one."}'`,
- **double angle quotation marks**,<br>
  `∆F '{«like "this" or ''this''.»}'`,  
  as well as
- *APL*’s tried-and-true embedded **single-quotes**,<br>
  `∆F '{''shown like ''''this'''', "this" or «this».''}'`.

<br> **Valid:** `∆F '{"abc""def"}'` </span> If you wish to include a
traditional delimiting quote (`'` or `"`) or the closing quote of a
quote pair (`«` `»`) within the **Quoted string**, you must double it.
You may *not* use an escape sequence (e.g. `` `" ``) for this purpose.

<a id="table-quote-characters" class="scroll-target"></a>

| Quote(s) |                Example                 |        Result         |
|:--------:|:--------------------------------------:|:---------------------:|
|   `"`    |    `∆F '{"like ""this"" example"}'`    | `like "this" example` |
|   `'`    | `∆F '{''like ''''this'''' example''}'` | `like 'this' example` |
|  `« »`   |       `∆F '{«or «this»» one»}'`        |    `or «this» one`    |

5f. <strong>Doubling Quote Character in Quoted String</strong>

Note that the opening quote `«` is treated as an ordinary character
within the string. The clumsiness of the standard single quote `'`
examples is due to the fact that the single quote is the required
delimiter for the outermost (*APL*-level) string.

## Omega Shortcut Expressions: Details

3.  All **Omega** shortcut expressions in the *f‑string* are evaluated
    left to right and are ⎕IO-independent.
4.  **⍹** is a synonym for **\`⍵**. It is Unicode character `⎕UCS 9081`.
    Either glyph is valid only in **Code** fields and outside **Quoted
    strings**.
5.  **\`⍵𝑑𝑑** or **⍹𝑑𝑑** is equivalent to the expression `(⍵⊃⍨dd+⎕IO)`.
    Here **𝑑𝑑** must be a *non-negative integer* with at least 1 digit.
6.  **\`⍵** or **⍹** (with ***no*** digits appended) is equivalent to
    `(⍵⊃⍨1+ii+⎕IO)`, where *ii* is the index of the most recent
    **Omega** expression (of either type) to its left in the
    *f-string*;if there is no such expression, *ii* is `1`.
7.  The *f‑string* itself (the 0-th element of **⍵**) is always accessed
    as `` `⍵0 `` or `⍹0`. It may only be accessed *explicitly.*
8.  If an element of the dfn’s right argument **⍵** is accessed at
    runtime via any means, shortcut or traditional, that element
    ***must*** exist.

## **Serialise** Shortcut Expressions: Details

Serialise ( `` `S ``) uses Dyalog *APL*’s Array Notation (APLAN) to
display the object to its right. It is intended to have roughly the same
behaviour as displaying an object with `]APLAN.output on`. (See Dyalog
documentation for details).

1.  Serialise displays objects of classes 2 and 9— data arrays and
    namespaces— in Array Notation, as long as they contain ***no***
    functions or operators.
2.  If `⍵` *includes* a function or operator,`` `S `` will display `⍵`
    *unformatted*, rather than in APLAN format.

<div>

## Wrap Shortcut: Details

1.  Syntax: `` [⍺←''''] `W ⍵ ``.
2.  Let `L←0⊃2⍴⍺` and `R←1⊃2⍴⍺`.
3.  Wrap each row `X′` of the simple arrays `X` in `⍵` (or the entire
    array `X` if a simple vector or scalar) in decorators `L` and `R`:
    `L,(⍕X′),R`.
4.  `⍵` is an array of any shape and depth.`L`and `R`are char. vectors
    or scalars or `⍬` (treated as `''`).
5.  If there is one scalar or enclosed vector `⍺`, it is replicated
    *per (2) above*.
6.  By default,`⍺← ''''`,*i.e.* *APL* quotes will wrap the array ⍵, row
    by row, whether character, numeric or otherwise.

## Session Library Shortcut: Details

1.  If an object `£.name` is referenced, but not yet defined in `£`, an
    attempt is made— during **∆F**’s left-to-right *scanning* phase— to
    copy it to `£` from (in order) directory **./MyDyalogLib**,
    workspace **dfns**, and the current directory **./**, *unless* it is
    being assigned (via a simple `←`) or has already been seen in this
    **∆F** call. It will be available for the duration of the *APL*
    session.

2.  If a name is a *qualified* name, i.e. if it is of the form
    `£.nm1.nm2`, `£.nm1.nm2.nm3`, etc., then **∆F** attempts to load the
    name ***nm1***, presumed to be a namespace (or a function returning
    a namespace). If a namespace, the *entire* namespace is loaded, not
    just the object specified.

3.  While objects of the form `£.name` will be automatically retrieved
    (if not defined), names in other `£` expressions, like
    `£.(name1 name2)` or `£.⎕NC "name3"`, will be ignored during the
    scanning phase;

4.  In the case of a simple assignment (`£.name←val`), the object
    assigned must be new or of an *APL* class compatible with its
    existing value, else a domain error will be signaled. Even if seen
    later in the scan, the object will be assumed to have been set by
    the user.

5.  Simple modified assignments of the form `£.name+←val` are allowed:
    the object `name` will be retrieved (if not present) before
    modification.

### Session Library Shortcut: Filetypes of Source Files

<a id="table-library-filetypes" class="scroll-target"></a>

| <br>Filetype | <br>Action | *APL* Class ⎕NC | Key APL<br>Service | Available<br>by Default? | Type <br>Enforced? |
|:--:|:--:|:--:|:--:|:--:|:--:|
| .aplf | Fixes function | 3 | ⎕FIX | ✔ | ✔<small> FUTURE</small> |
| .aplo | Fixes operator | 4 | ⎕FIX | ✔ | ✔<small> FUTURE</small> |
| .apln | Fixes ns script | 9 | ⎕FIX | ✔ | ✔<small> FUTURE</small> |
| .apla | Assigns array or ns<br>(array notation) | 2, 9 | *assignment* | ✔ | ✔ |
| .json | Fixes ns from JSON5 | 9 | ⎕JSON | ✔ | ✔ |
| .txt | Assigns char. vectors | 2 | *assignment* | ✔ | ✔ |
| .dyalog | Fixes object | 3, 4, 9 | ⎕FIX | ✔ | <span class="red"><strong>✘<small> NEVER</small></strong></span> |
| user-specified | Fixes object | 3, 4, 9 | ⎕FIX | <span class="red"><strong>✘</strong></span> | <span class="red"><strong>✘<small> NEVER</small></strong></span> |

5g. <strong>Library Filetypes: Meaning</strong>

### Session Library Shortcut: Parameters

The Session Library shortcut (`£` or `` `L ``) is deceptively simple,
but the code to support it is a tad complex. The complex components run
only when **∆F** is loaded. If the **auto** parameter is `1`, there is a
modest performance impact at runtime. If `0`, the runtime impact of the
feature is more modest still.

To support the Session Library auto-load process, there are parameters
that may *optionally* be tailored:

- **LIB_ACTIVE**: A global variable set in ∆FUtils.dyalog.
  - 2: Load default and user parameters (default);
  - 1: Load default parameters ONLY;
  - 0: No autoload features should be available.

In addition, there are user parameters settable in the file **.∆F** in
the user’s home directory:

- **auto:** allowing **∆F** to automatically load undefined objects of
  the form `£.obj` or `` `L.obj `` into the Session Library from
  workspaces or files on the search path;
- **verbose:** providing limited information on parameters, object
  loading, *etc.*;
- **path:** listing what directories to search for the object
  definitions;
- **prefix:** literal character vectors to prefix to each file name
  during the object search;
- **suffix:** filetypes that indicate the types of objects in our
  “library,” along with any expected conversions.

The built-in *(default)* parameter file , then **∆F** returns a
character vector that contains the source code for the *dfn* returned
via `(dfn: 1)`. If ***verbose*** is also set, newlines from `` `◇ `` are
shown as visible `␤`. However, since this option *returns* the code
string, the ***verbose*** option won’t also *display* the code string.

### Future Behaviours

There are two future behaviours of APL primitives optionally supported
by **∆F**, an extension to circle diaeresis (⍥) and the availability of
right shoe underscore (⊇). Each is available if included in the value of
load-time parameter, `FUTURES`. By default, `FUTURES← '⍥⊇'`.

#### Future Behaviour of ⍥ (Circle Diaeresis) Here Today

As a load-time option, **∆F** adds Adám Brudzewsky’s **Depth operator**
extension to circle diaeresis (⍥), which works similarly to rank (⍤),
but selects array components based on depth rather than rank. If the
value of the load-time parameter `FUTURES` includes `'⍥'`, then this fun
*future* feature will be recognized within code fields, without
impacting other capabilities of `⍥`. For more information, see
<a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https://aplwiki.com/wiki/Depth\_(operator)</span></a>.

#### Future Behaviour of ⊇ (Select / Sane Indexing) Here Today

As a load-time option, **∆F** adds the “future” **Select** function
(also known as **Sane indexing**) if the value of the load-time
parameter `FUTURES` includes `'⍥'`. For more information, see
<a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https://aplwiki.com/wiki/From</span></a>.

### ∆F Help’s Secret Variant

`∆F⍨'help'` has a secret variant: `∆F⍨'help-narrow'`. With this variant,
the help session will start up in a narrower window *without* side
notes. If the user widens the window, the side notes will appear, as in
the default case: `∆F⍨'help'`.

### ∆F’s Library Parameter Option: ‘parms’

Normally, ∆F £ibrary parameters are established when **∆F** and
associated libraries are loaded (*e.g.* via `]load ∆F -t=⎕SE`). After
editing the parameter file **./.∆F,** you may wish to update the active
parameters, while maintaining existing user £ibrary session objects,
which would otherwise be lost during a `]load` operation. For such an
update, use **∆F**’s `'parms'` option.

`∆F⍨ 'parms'` reads the user parameter file **./.∆F,** updates the
*£ibrary* parameters, returning them in alphabetical order along with
their values as a single character matrix. No current session objects
are affected.

### ∆F’s Library Parameter Option: ‘globals’

**∆F** has a number of load-time parameters (global variables) that set
its runtime behaviour for all users. You can view these parameters using
the call: `∆F⍨ 'globals'`. The parameters include:

``` skip

  TRAP_ERRORS      VERBOSE_RUNTIME      VERBOSE_LOADTIME  SIGNAL_LIB_ERRS
  ESCAPE_CHAR      QUOTES_SUPPLEMENTAL  INLINE_UTILS      HELP_HTML_FI   
  LIB_ACTIVE       LIB_PARM_FI          LIB_USER_FI       LIB_SRC_FI
  OPTS_KW          OPTS_DEFval          OPTS_N
  VERBOSE_RUNTIME  VERSION              FUTURES
```

The meaning of each parameter and appropriate values are currently
documented solely within the **∆F** code itself.

## Appendix II: Python f‑strings

For more information on Python f-strings, *see*:

 <a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https://docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals</span></a>.

</details>

# Index of Topics

<details id="TOC">

<!-- option: open  Set id="TOC" here only. -->

<summary class="summary">

 <span style="opacity:0.6;">Show/Hide</span> <em>Index</em>
</summary>

<a id="inside-index" class="scroll-target"></a>

</big><br><span class="green"><strong><big>■</big> Topic in table or
figure</strong></span><br><big>■</big> Regular
entry</strong></big></span>

<div class="multi-column-text" style="font-size:85%;">

<!-- INDEX_BEGIN -->

<!-- Generated by ∆F_toc: 2025-12-31T14:15:45 -->

<a href="#the-above-shortcut"                            > <strong>\`A
(above)</strong> <big><span class="blue">4.12</span></big></a><br>
<a href="#the-above-shortcut"                            > <strong>Above
shortcut</strong> <big><span class="blue">4.12</span></big></a><br>
<a href="#inside-appendices"                             >
<span class="red"><big><strong>Appendices</strong></big></span> <big><span class="blue">6.</span></big></a><br>
<a href="#the-serialise-shortcut"                        > <strong>Array
notation,
serialise</strong> <big><span class="blue">4.19</span></big></a><br>
<a href="#the-box-shortcut"                              > <strong>\`B
(box)</strong> <big><span class="blue">4.5</span></big></a><br>
<a href="#box-mode"                                      > <strong>Box
option</strong> <big><span class="blue">4.6</span></big></a><br>
<a href="#the-box-shortcut"                              > <strong>Box
shortcut</strong> <big><span class="blue">4.5</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               > <strong>\`C
(numeric
commas)</strong> <big><span class="blue">4.10</span></big></a><br>
<a href="#table-call-syntax"                             >
<span class="green"><strong>Call
syntax</strong></span> <big><span class="blue"><small><em>Table</em></small>
5a.</span></big></a><br>
<a href="#table-escapes"                                 >
<span class="green"><strong>Code field escape
sequences</strong></span> <big><span class="blue"><small><em>Table</em></small>
5e.</span></big></a><br>
<a href="#code-field-shortcuts"                          >
<span class="red"><big><strong>Code field
shortcuts</strong></big></span> <big><span class="blue">5.5</span></big></a><br>
<a href="#table-brief-shortcuts"                         >
<span class="green"><strong>Code field shortcuts,
brief</strong></span> <big><span class="blue"><small><em>Table</em></small>
3d.</span></big></a><br>
<a href="#table-shortcuts"                               >
<span class="green"><strong>Code field shortcuts,
details</strong></span> <big><span class="blue"><small><em>Table</em></small>
5d.</span></big></a><br>
<a href="#code-fields"                                   > <strong>Code
fields</strong> <big><span class="blue">4.1</span></big></a><br>
<a href="#code-fields-continued"                         > <strong>Code
fields
(continued)</strong> <big><span class="blue">4.4</span></big></a><br>
<a href="#quoted-strings-in-code-fields"                 > <strong>Code
fields, quoted strings
in</strong> <big><span class="blue">5.7</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               >
<strong>Commas shortcut,
numeric</strong> <big><span class="blue">4.10</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-ii"        > <strong>\`D
(date)</strong> <big><span class="blue">4.17</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-ii"        > <strong>Date
shortcut
(alias)</strong> <big><span class="blue">4.17</span></big></a><br>
<a href="#table-default-options"                         >
<span class="green"><strong>Default
options</strong></span> <big><span class="blue"><small><em>Table</em></small>
5c.</span></big></a><br>
<a href="#precomputed-fstrings-with-the-dfn-option"      > <strong>Dfn
option, precomputed
F-strings</strong> <big><span class="blue">4.22</span></big></a><br>
<a href="#table-quote-characters"                        >
<span class="green"><strong>Doubling quote
characters</strong></span> <big><span class="blue"><small><em>Table</em></small>
5f.</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            >
<strong>Escape omega,
details</strong> <big><span class="blue">5.8</span></big></a><br>
<a href="#table-escapes"                                 >
<span class="green"><strong>Escape
sequences</strong></span> <big><span class="blue"><small><em>Table</em></small>
5e.</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   >
<strong>Escape sequences in quoted
strings</strong> <big><span class="blue">5.6</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   >
<strong>Escape sequences in text
fields</strong> <big><span class="blue">5.6</span></big></a><br>
<a href="#inside-examples"                               >
<span class="red"><big><strong>Examples</strong></big></span> <big><span class="blue">4.</span></big></a><br>
<a href="#the-format-shortcut"                           > <strong>\`F
(format)</strong> <big><span class="blue">4.9</span></big></a><br>
<a href="#table-field-types"                             >
<span class="green"><strong>Field
types</strong></span> <big><span class="blue"><small><em>Table</em></small>
2a.</span></big></a><br>
<a href="#table-library-parameters"                      >
<span class="green"><strong>File, of library parameters
(.∆F)</strong></span> <big><span class="blue"><small><em>Fig.</em></small>
4.21</span></big></a><br>
<a href="#table-library-filetypes"                       >
<span class="green"><strong>Filetypes, library: see \`L and
£</strong></span> <big><span class="blue"><small><em>Table</em></small>
5g.</span></big></a><br>
<a href="#the-format-shortcut"                           >
<strong>Format
shortcut</strong> <big><span class="blue">4.9</span></big></a><br>
<a href="#referencing-the-fstring-itself"                >
<strong>F-string,
referencing</strong> <big><span class="blue">4.8</span></big></a><br>
<a href="#intro"                                         >
<strong>F-strings,
definition</strong> <big><span class="blue">0.</span></big></a><br>
<a href="#appendix-ii-python-fstrings"                   >
<strong>F-strings,
Python</strong> <big><span class="blue">6.2</span></big></a><br>
<a href="#table-call-syntax"                             >
<span class="green"><strong>∆F Call
Syntax</strong></span> <big><span class="blue"><small><em>Table</em></small>
5a.</span></big></a><br>
<a href="#f-call-syntax-overview"                        > <strong>∆F
call syntax
overview</strong> <big><span class="blue">5.1</span></big></a><br>
<a href="#f-fstring-building-blocks"                     > <strong>∆F
f-string building
blocks</strong> <big><span class="blue">5.4</span></big></a><br>
<a href="#f-installation"                                > <strong>∆F
installation</strong> <big><span class="blue">1.1</span></big></a><br>
<a href="#loading-and-running-f"                         > <strong>∆F
loading and
running</strong> <big><span class="blue">1.2</span></big></a><br>
<a href="#f-option-details"                              > <strong>∆F
option details</strong> <big><span class="blue">5.2</span></big></a><br>
<a href="#inside-preparing"                              >
<span class="red"><big><strong>∆F preparing to
run</strong></big></span> <big><span class="blue">1.</span></big></a><br>
<a href="#inside-reference"                              >
<span class="red"><big><strong>∆F reference
section</strong></big></span> <big><span class="blue">5.</span></big></a><br>
<a href="#f-return-value"                                > <strong>∆F
return values</strong> <big><span class="blue">5.3</span></big></a><br>
<a href="#displaying-f-help-in-apl"                      > <strong>Help,
displaying in
Apl</strong> <big><span class="blue">1.3</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            >
<strong>Horizontal SDCF
(→)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#f-installation"                                >
<strong>Installing
∆F</strong> <big><span class="blue">1.1</span></big></a><br>
<a href="#text-justification-shortcut"                   > <strong>\`J
(Justification)</strong> <big><span class="blue">4.13</span></big></a><br>
<a href="#text-justification-shortcut"                   >
<strong>Justification
shortcut</strong> <big><span class="blue">4.13</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>\`L
(library)</strong> <big><span class="blue">4.21</span></big></a><br>
<a href="#table-library-filetypes"                       >
<span class="green"><strong>Library Filetypes: see \`L and
£</strong></span> <big><span class="blue"><small><em>Table</em></small>
5g.</span></big></a><br>
<a href="#table-library-parameters"                      >
<span class="green"><strong>Library parameters, file of
(.∆F)</strong></span> <big><span class="blue"><small><em>Fig.</em></small>
4.21</span></big></a><br>
<a href="#session-library-shortcut-details"              >
<strong>Library shortcut,
details</strong> <big><span class="blue">5.11</span></big></a><br>
<a href="#the-session-library-shortcut"                  >
<strong>Library shortcut,
session</strong> <big><span class="blue">4.21</span></big></a><br>
<a href="#loading-and-running-f"                         >
<strong>Loading
∆F</strong> <big><span class="blue">1.2</span></big></a><br>
<a href="#multiline-F-strings-in-dyalog-20"              >
<strong>Multiline f-strings, Dyalog
20</strong> <big><span class="blue">4.23</span></big></a><br>
<a href="#null-space-fields"                             > <strong>Null
space fields</strong> <big><span class="blue">4.3</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               >
<strong>Numeric commas
shortcut</strong> <big><span class="blue">4.10</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>Omega
shortcut expressions,
details</strong> <big><span class="blue">5.8</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      > <strong>Omega
shortcuts,
explicit</strong> <big><span class="blue">4.7</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>Omega
shortcuts,
implicit</strong> <big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>Omega
underscore (⍹),
details</strong> <big><span class="blue">5.8</span></big></a><br>
<a href="#table-option-details"                          >
<span class="green"><strong>Option
details</strong></span> <big><span class="blue"><small><em>Table</em></small>
5b.</span></big></a><br>
<a href="#table-default-options"                         >
<span class="green"><strong>Options,
default</strong></span> <big><span class="blue"><small><em>Table</em></small>
5c.</span></big></a><br>
<a href="#inside-overview"                               >
<span class="red"><big><strong>Overview</strong></big></span> <big><span class="blue">2.</span></big></a><br>
<a href="#precomputed-fstrings-with-the-dfn-option"      >
<strong>Precomputed
F‑strings</strong> <big><span class="blue">4.22</span></big></a><br>
<a href="#inside-preparing"                              >
<span class="red"><big><strong>Preparing to run
∆F</strong></big></span> <big><span class="blue">1.</span></big></a><br>
<a href="#appendix-ii-python-fstrings"                   >
<strong>Python
f‑strings</strong> <big><span class="blue">6.2</span></big></a><br>
<a href="#the-quote-shortcut"                            > <strong>\`Q
(quote)</strong> <big><span class="blue">4.18</span></big></a><br>
<a href="#inside-quick-start"                            >
<span class="red"><big><strong>Quick
start</strong></big></span> <big><span class="blue">3.</span></big></a><br>
<a href="#table-quote-characters"                        >
<span class="green"><strong>Quote characters,
doubling</strong></span> <big><span class="blue"><small><em>Table</em></small>
5f.</span></big></a><br>
<a href="#the-quote-shortcut"                            > <strong>Quote
shortcut</strong> <big><span class="blue">4.18</span></big></a><br>
<a href="#table-quote-characters"                        >
<span class="green"><strong>Quoted strings, doubling quote
chars.</strong></span> <big><span class="blue"><small><em>Table</em></small>
5f.</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   >
<strong>Quoted strings, escape sequences
in</strong> <big><span class="blue">5.6</span></big></a><br>
<a href="#quoted-strings-in-code-fields"                 >
<strong>Quoted strings in code
fields</strong> <big><span class="blue">5.7</span></big></a><br>
<a href="#loading-and-running-f"                         >
<strong>Running
∆F</strong> <big><span class="blue">1.2</span></big></a><br>
<a href="#the-serialise-shortcut"                        > <strong>\`S
(serialise)</strong> <big><span class="blue">4.19</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            >
<strong>SDCFs: self-documenting code
fields</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            >
<strong>Self-documenting code fields
(SDCFs)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#the-serialise-shortcut"                        >
<strong>Serialise shortcut, array
notation</strong> <big><span class="blue">4.19</span></big></a><br>
<a href="#serialise-shortcut-expressions-details"        >
<strong>Serialise shortcut,
details</strong> <big><span class="blue">5.9</span></big></a><br>
<a href="#table-library-parameters"                      >
<span class="green"><strong>Session library parameters, file
(.∆F)</strong></span> <big><span class="blue"><small><em>Fig.</em></small>
4.21</span></big></a><br>
<a href="#the-session-library-shortcut"                  >
<strong>Session library
shortcut</strong> <big><span class="blue">4.21</span></big></a><br>
<a href="#session-library-shortcut-details"              >
<strong>Session library shortcut,
details</strong> <big><span class="blue">5.11</span></big></a><br>
<a href="#code-field-shortcuts"                          >
<span class="red"><big><strong>Shortcuts,
all</strong></big></span> <big><span class="blue">5.5</span></big></a><br>
<a href="#table-brief-shortcuts"                         >
<span class="green"><strong>Shortcuts,
brief</strong></span> <big><span class="blue"><small><em>Table</em></small>
3a.</span></big></a><br>
<a href="#table-shortcuts"                               >
<span class="green"><strong>Shortcuts,
details</strong></span> <big><span class="blue"><small><em>Table</em></small>
5d.</span></big></a><br>
<a href="#shortcuts-with-apl-expressions"                >
<strong>Shortcuts, with Apl
expressions</strong> <big><span class="blue">4.15</span></big></a><br>
<a href="#text-fields-and-space-fields"                  > <strong>Space
fields</strong> <big><span class="blue">4.2</span></big></a><br>
<a href="#null-space-fields"                             > <strong>Space
fields, null</strong> <big><span class="blue">4.3</span></big></a><br>
<a href="#inside-reference"                              >
<span class="red"><big><strong>Syntax (∆F
reference)</strong></big></span> <big><span class="blue">5.</span></big></a><br>
<a href="#table-call-syntax"                             >
<span class="green"><strong>Syntax, ∆F
Call</strong></span> <big><span class="blue"><small><em>Table</em></small>
5a.</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-i"         > <strong>\`T
(time)</strong> <big><span class="blue">4.16</span></big></a><br>
<a href="#table-escapes"                                 >
<span class="green"><strong>Text field escape
sequences</strong></span> <big><span class="blue"><small><em>Table</em></small>
5e.</span></big></a><br>
<a href="#text-fields-and-space-fields"                  > <strong>Text
fields</strong> <big><span class="blue">4.2</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   > <strong>Text
fields, escape sequences
in</strong> <big><span class="blue">5.6</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-i"         > <strong>Time
shortcut</strong> <big><span class="blue">4.16</span></big></a><br>
<a href="#appendix-i-underdocumented-features"           >
<strong>Underdocumented
features</strong> <big><span class="blue">6.1</span></big></a><br>
<a href="#appendix-i-underdocumented-features"           >
<strong>Undocumented
features</strong> <big><span class="blue">6.1</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            >
<strong>Vertical SDCF (↓ or
%)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#the-wrap-shortcut"                             > <strong>\`W
(wrap)</strong> <big><span class="blue">4.20</span></big></a><br>
<a href="#the-wrap-shortcut"                             > <strong>Wrap
shortcut</strong> <big><span class="blue">4.20</span></big></a><br>
<a href="#wrap-shortcut-details"                         > <strong>Wrap
shortcut,
details</strong> <big><span class="blue">5.10</span></big></a><br>
<a href="#the-format-shortcut"                           > <strong>\$
(format)</strong> <big><span class="blue">4.9</span></big></a><br>
<a href="#the-above-shortcut"                            > <strong>%
(above)</strong> <big><span class="blue">4.12</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>%
(vertical
SDCF)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>£
(library)</strong> <big><span class="blue">4.21</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>→
(horizontal
SDCF)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>↓
(vertical
SDCF)</strong> <big><span class="blue">4.11</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>\`⍵
and ⍹, details</strong> <big><span class="blue">5.8</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>\`⍵,
⍹ (omega,
implicit)</strong> <big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      >
<strong>\`⍵𝑑𝑑, ⍹𝑑𝑑 (omega,
explicit)</strong> <big><span class="blue">4.7</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>⍹
\[<strong>⍵</strong>-underscore\]: see
<em>\`⍵</em></strong> <big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      > <strong>⍹𝑑𝑑
\[<strong>⍵</strong>-underscore\]: see
\`⍵𝑑𝑑</strong> <big><span class="blue">4.7</span></big></a><br>
<!-- INDEX_END -->

</div>

</details>

<!-- Put a set of navigation tools at a fixed position at the bottom of the Help screen
-->

<div class="doc-footer" style="text-align: left;padding-left:60px;">

<div class="button-container">

<input type="button" value="Back" class="button happy-button" onclick="history.back()"/>
⍠⍠⍠    
<input type="button" class="button normal-button" value="Top" onclick="window.location='#top'"/>
<input type="button" class="button normal-button" value="Quick Start" onclick="window.location='#inside-quick-start'"/>
<input type="button" class="button normal-button" value="Examples" onclick="window.location='#inside-examples'"/>
<input type="button" class="button normal-button" value="Reference" onclick="window.location='#inside-reference'"/>
<!-- 
 <input type="button" class="button normal-button" value="Appendices" onclick="window.location='#appendices'"/> 
-->
<input type="button" class="button normal-button" value="Index" onclick="window.location='#inside-index'"/>
<input type="button" class="button normal-button" value="Bottom" onclick="window.location='#index-of-topics'"/>    
<input type="button" class="button happy-button" value="Print" onclick="myPrint()">
⍠⍠⍠

</div>

</div>

------------------------------------------------------------------------

<br> <span id="copyright" style="font-family:cursive;"> Copyright
<big>©</big> 2026 Sam the Cat Foundation. \[Version 0.1.3: 2026-01-20\]
</span> <br>

</div>

<!-- End div for right-margin-bar -->

<!-- a hidden modal expression -->

<div id="pAlertMsg" class="pAlertMsg">

<span id="pAlertPfx" style="font-size: 40px;"> </span>
<span id="pAlertText"
style="font-weight: bold; font-size: 20px;font-family: Tahoma,  sans-serif;">
</span>

</div>

<!-- (C) 2026 Sam the Cat Foundation -->

</div>
