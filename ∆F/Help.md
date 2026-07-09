---
title: "∆F Formatted String Literals (v.0.4.2)"
toc: true
---



## 0 Introduction {.unnumbered}

<div class="right-margin-bar"> 
<span class="margin-note">Short for "**format&shy;ted string lit&shy;er&shy;als**, _f‑strings_ were introduced in Python in 2016. **∆F** _f‑strings_ and Python's are **not** compatible.</span>

<a id="intro" class="scroll-target"></a>

<div class="marquee"><center>
**_∆F_** is a function for _Dyalog_ *APL* that interprets _f‑strings_,
a concise, yet powerful way to display multiline *APL* text, arbitrary
*APL* expressions, and multi&shy;dimensional objects using extensions to
_dfns_ and other familiar tools.
</center></div>



### Major Headings {.unnumbered}

<details id="TOC" open>     <!-- option: open  Set id="TOC" here only. -->
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Major Headings</em></summary>

<span class="margin-note"><br><br><br>
**Quick Start:** If you want the minimum before diving in.
</span>
<div class="multi-column-text" style="font-size:80%;">

<big >1.  <a href="#inside-preparing"         >Preparing to Run **∆F**</a> 
<br  >2.  <a href="#inside-overview"          >Overview</a> 
<br  >3.  <a href="#inside-quick-start"       ><span class="blink">**Quick Start**</span></a> 
<br  >4.  <a href="#inside-examples"          >**∆F** Examples: A Primer</a>  
<br  >5.  <a href="#inside-reference"         >**∆F** Reference</a> 
<br  >6.  <a href="#inside-appendices"        >Appendices</a>
<br  >7.  <a href="#inside-index"             >Index of Topics</a>
</big>

</div> 

---

</details>
<!-- <div class="page-break"></div>  -->
# Preparing to Run **∆F**  

<details>            <!-- option: open -->
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Preparing to Run <bold>∆F</bold></em>
</summary>
<a id="inside-preparing" class="scroll-target"></a> 


## **∆F** Installation

1. Via your browser, go to Github URL <mark><a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https://github.com/thecatsam/f-string-apl.git</span></a></mark>.
2. Make a note of <span class="margin-note">Dyalog user command `]cd` will show you your current working directory.</span>your current (or desired) working directory.
3. <span class="margin-note">**Download:** E.g. via the Github **Code** button, use download ZIP to place in the desired directory .</span>Download and copy the file **∆F.dyalog** and directory **∆F** (which contains several files) into the current working directory,
   ensuring they are peers, _i.e._ at the same directory level.

<big>👉</big>&nbsp;Now, **∆F** is available to load and use. Continue in the [next section](#loading-and-running-f).

## Loading and Running **∆F**

1. Confirm that your current directory remains as before.
2. From your Dyalog session<span class="margin-note">*Or,*&emsp;`⎕SE.⎕FIX'∆F.Dyalog'`<br>**_⎕SE:_** Or any _target_ namespace you desire.</span>, enter: <br>&emsp;`]load ∆F -target=⎕SE`<br>
   Now, the target directory (`⎕SE`) will contain the namespace `FString`, containing `∆F` and supporting services and objects. 
3. By default, the target namespace (<code>_⎕SE.FString_</code>) will be prepended to the ***beginning*** of `⎕PATH`.
4. **∆F** may be called as is, i.e. as `∆F`, or fully specified as `⎕SE.FString.∆F`. 
5. You may always choose to create an alias to **∆F** in your chosen namespace (say, `mydir`), e.g. via `mydir.∆F← ⎕SE.FString.∆F`.
4. By default, the ***help*** file, **∆F/∆FHelp.html** is available at `]load` time. If so, it will be copied into **FString**. If not available, a message will note the absence of _help_ information.

<big>👉</big>&nbsp;<small>You may now call `∆F` with the desired [arguments](#f-call-syntax-overview) and [options](#f-option-details).</small><br>
<big>👉</big>&nbsp;<small>**∆F** is `⎕IO`- and `⎕ML`-independent.<br></small>
<big>👉</big>&nbsp;<small>**∆F**'s "help" system uses Dyalog's **_HtmlRenderer_** service to display its documentation or, if unavailable, the ***Ride*** 
development environment.  A less robust version of this 
help information is also available in the file _readme.md_ on Github.</small>

## Displaying ∆F **Help** in _APL_

<span class="margin-note">If `∆F⍨'help'` seems exotic, try: `'help' ∆F ⍬`.</span>

<big>👉</big>&nbsp;To display this **HELP** information, type: `∆F⍨ 'help'`.

---

</details>
<div class="page-break"></div> 
# Overview

<details open><summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Overview</em> 
</summary><a id="inside-overview" class="scroll-target"></a>

<span class="margin-note">The current version of **∆F** requires Dyalog version 20.</span>
Inspired by [Python f‑strings](#appendix-ii-python-fstrings), **∆F** includes a variety of capabilities to make it easy to evaluate, format, annotate, and display related multi&shy;dimensional information.
A **∆F** _f-string_
is (typically) a character vector, which may reference objects in the environment, additional
function arguments, or both.

 <span class="margin-note">For *f-string* formats, see [**∆F** Call Syn&shy;tax Over&shy;view](#f-call-syntax-overview).</span>
**∆F** _f‑strings_ include:

- The abstraction of 2-dimensional character **_fields_**, generated one-by-one from the user's specifications and data, then aligned and catenated into a single overall character matrix result;

<span class="margin-note">`` `◇ ``: back&shy;tick + state&shy;ment sep&shy;ar&shy;ator (`⎕UCS 96 8900`).
</span>

- **Text** fields,
  each allowing [multiline Unicode text](#text-fields-and-space-fields), with the sequence `` `◇ `` generating a **new line**;

- **Code** fields, allowing users to evaluate and display _APL_ arrays of any dimensionality, depth, and type in the user environment, arrays passed as **∆F** arguments, as well as arbitrary _APL_ expressions based on full multi-statement dfn
  logic. Each **Code** field must return a value, simple or otherwise, which will be catenated with other fields and returned from **∆F**;

  **Code** fields also provide a number of concise, convenient extensions, such as:

  - **Quoted strings** <span class="margin-note">Quoted strings, like **Text** fields, allow easy entry of newlines via the sequence `` `◇ ``.</span>
    in **Code** fields, with several quote styles:

    - **double-quotes**<br>
      `∆F '{"like this"}'` or `` ∆F '{"on`◇""three""`◇lines"}' ``
    - **double angle quotation marks**,<span class="margin-note"><big>**«**</big> and <big>**»**</big>: Also known as _guillemets_.</span><br>
      `∆F '{«with internal quotes like "this" or ''this''»}'`,<br> _not to mention:_
    - _APL_'s tried-and-true embedded **single-quotes**,<br>
      `∆F '{''shown ''''right'''' here''}'`

  - Simple shortcuts<span class="margin-note">Details on all the [shortcuts](#code-field-shortcuts) are provided later in this document.</span> for

    - **format**ting numeric arrays, **\$** (short for **⎕FMT**):<br>`∆F '{"F7.5" $ ?0 0}'`
    - putting a **box** around a specific expression, **\`B**:<br>`` ∆F '{`B ⍳2 2}' ``
    - placing the output of one expression **above** another, **%**:<br>`∆F '{"Pi"% ○1}'`
    - formatting **date** and **time** expressions from _APL_ timestamps (**⎕TS**) using **\`T**<span class="margin-note">`` `T `` combines&nbsp;**1200⌶** and **⎕DT**</span>:<br>`` ∆F '{"hh:mm:ss" `T ⎕TS}' ``
    - calling <span class="margin-note">**£** stands for _library_.</span>arbitrary functions on the fly from the **dfns** workspace or a user file:<br>`∆F '{41=£.pco 12}' ⍝ Is 41 the 12th prime?`
    - _and more_;

  - Simple mechanisms for concisely formatting and displaying data from
    - user arrays of any shape and dimensionality:<br>`tempC← 10 110 40 ◇ ∆F '{tempC}'`
      <br>
    - arbitrary <span class="margin-note"><br>£ quietly finds `dec` and `hex` in the **dfns** workspace.</span>_dfn_-style code:<br>`∆F '{ 223423 ≡⊃£.dec £.hex 223423: "Checks out" ◇ "Bad"}'`
      <br>
    - arguments to **∆F** that follow the format string:<br>`` ∆F '{32+`⍵1×9÷5}' (10 110 40) ``<span class="margin-note">`` `⍵1 ``: shortcut for `(⍵⊃⍨1+⎕IO)`</span>
    - _and more_;

- **Space** fields, providing a simple mechanism both for separating adjacent **Text** fields and inserting (rectangular) blocks of any number of spaces between any two fields, where needed;

  - one space: `{ }`; five spaces: `{     }`; or even, zero spaces: `{}`;
  - 1000 spaces? Use a **Code** field instead: `{1000⍴""}`.

- Use of <span class="margin-note">These options are equi&shy;valent:<br>∘ `0 1 1` <br>∘ `(verbose: 1 ◇ box: 1)`</span>
  _either_ [**positional**](#f-option-details) or [**keyword**](#f-option-details) (namespace-based) options, based on _APL_ Array Notation (in&shy;tro&shy;duced in Dyalog 20);

- Multiline (matrix) output built up field-by-field, left-to-right, from values and expressions in the calling environment or arguments to **∆F**;

  - After all fields are generated, they are aligned vertically, then concatenated to form a single character matrix: **_the return value from_** **∆F**. <span class="margin-note"><br>As a prototype, **∆F** is relatively slow, using an _APL_ recursive scan to analyze the **f‑string**. For a way to speed up frequently used _f‑strings_, see the [**_dfn_** option](#f-option-details).</span>

**∆F** is designed for ease of use, _ad hoc_ debugging, fine-grained formatting and informal user interaction, built using Dyalog functions and operators.

<details>     <!-- option: open -->
<summary class="summary">&ensp;Recap: <em>The Three Field Types</em></summary>

<a id="table-field-types" class="scroll-target"></a>

--------------------------------------------------------------------------------------------------------------------------------
 Field            
 Type                     Syntax                         Examples                               Displaying
------------------     -----------------------  -------------------------------------------- ------------------------------------------------
 *Text* F.               _Unicode text_            `` Cats`◇and`◇dogs! ``                      2-D Text

 *Code* F.              `{`_dfn code plus_`}`      `` {"1`◇one"} {"2`◇two"}` ``                Arbitrary _APL_ Express&shy;ions  
                        `{`_shortcuts_`}`          `{"F5.1" $ (32+9×÷∘5)degC}`                 via dfns, including **Quoted Strings**

 *Space* F.             `{`<big>␠ ␠ ␠</big>`}`      `{  }` <br>                                Spacing 
 <br>(*Null                    <br> `{}`              `{}`                                       <br>
 Space* F.)                                                                                     (Field Separation)
----------------------------------------------------------------------------------------------------------------------
Table: 2a. <strong>The Three Field Types</strong>

<br>
</details> 
</details>
<div class="page-break"></div>

# Quick Start

<details>            <!-- option: open -->
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Quick Start</em>
</summary><a id="inside-quick-start" class="scroll-target"></a>

### <span class="blue"><strong>Here's a quick start for the <small>**TL;DR**</small> <span class="margin-note">too long didn't read</span>crowd. </strong></span> {.unnumbered} 

**3.1: Embed variables**
```
   n← ⍪1+⍳3 ◇ nPi← ⍪○n  
   ∆F 'For n={ n }, n×Pi={ nPi }'  
For n=1, n×Pi=3.141592653589793
      2       6.283185307179586
      3       9.42477796076938 
```

**3.2: Embed expressions**
```
   ∆F 'For n={ ⍪1+⍳3 }, n×Pi={ ⍪○1+⍳3 }'  
For n=1, n×Pi=3.141592653589793
      2       6.283185307179586
      3       9.42477796076938 
```

**3.3: Build multiline text fields and code fields**  

```
⍝      <----  text field  ---->   <- text field ->    <- code field str ->
   ∆F 'Cats`◇Elephants`◇Monkeys{ }like`◇enjoy`◇eat{ }{"toys.`◇tv.`◇fruit."}'
Cats      like  toys. 
Elephants enjoy tv.   
Monkeys   eat   fruit.
``` 

**3.4: Apply the Format shortcut $** 

```
   ∆F 'For n={ ⍪1 2 3 }, n×Pi={ "F7.5"$ ○1 2 3 }'  
For n=1, n×Pi=3.14159
      2       6.28319
      3       9.42478
```

**3.5: Add Omega shortcut expressions**

```
⍝  `⍵1 ==> (⍵⊃⍨ 1+⎕IO), i.e. ⎕IO-independently
   ∆F 'For n={ ⍪`⍵2 }, n×Pi={ `⍵1 $ ○`⍵2 }' 'F7.5' (1 2 3)
For n=1, n×Pi=3.14159
      2       6.28319
      3       9.42478
```    

**3.6: Add the Box shortcut**

```
   ∆F 'For n={ `B ⍪`⍵1 }, n×Pi={ `B "F7.5"$ ○`⍵1 }' (1 2 3)
For n=┌─┐, n×Pi=┌───────┐
      │1│       │3.14159│
      │2│       │6.28319│
      │3│       │9.42478│
      └─┘       └───────┘
```

**3.7: Use Self-Documenting Code Fields and the Box option** 

```dyalog20 
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

<div class="page-break"></div> 

**3.8: Serialise an object in Array Notation**

``` 
   anim←(cat: 1 ◇ dog: 2 ◇ mouse: 3)
   ∆F '{`⍵1 `S anim ↓} { `⍵2 `S anim↓}' 1 0    
  `⍵1 `S anim ↓        `⍵2 `S anim↓ 
(cat:1◇dog:2◇mouse:3◇)  (        
                         cat:1   
                         dog:2   
                         mouse:3 
                       )          
```  

**3.9: Grab utility automagically from** ___dfns___ **workspace (or from a file)**

```
   ∆F'{ £.hex 57005 48879 51966}'   ⍝ Get hex fn to convert dec to hexadecimal!
 dead  beef  cafe                   ⍝ Yes, those are ordinary hexadecimal numbers!
```

### <span class="blue"><strong>That's 80% of what you need. Read on for more...</strong></span> {.unnumbered}
</details>

<div class="page-break"></div> 


# ∆F Examples: A Primer

<details>            <!-- option: open -->
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Examples: A Primer</em>
</summary><a id="inside-examples" class="scroll-target"></a>

Before providing information on **∆F** syntax and other details, _let's start with some examples_…

First, let's set some context for the examples. (You can set these however you want.)

<span class="margin-note">All examples in this document assume `⎕IO←0 ◇ ⎕ML←1`.</span>

```
   ⎕IO ⎕ML← 0 1
```

## Code Fields

Here are **Code** fields with simple variables.

<span class="margin-note">So far, this is like everybody else's _f‑strings_.
</span>

```
   name← 'Fred' ◇ age← 43
   ∆F 'The patient''s name is {name}. {name} is {age} years old.'
The patient's name is Fred. Fred is 43 years old.
```

**Code** fields can contain arbitrary expressions. With default options, **∆F** always
returns a single character matrix.
Here **∆F** returns a matrix with 2 rows and 32 columns.

<span class="margin-note"> Now we're taking advantage of _APL_'s array-oriented style.
</span>

```
   tempC← ⍪35 85
   ⍴⎕← ∆F 'The temperature is {tempC}{2 2⍴"°C"} or {32+tempC×9÷5}{2 2⍴"°F"}'
The temperature is 35°C or  95°F.
                   85°C    185°F
2 32
```

Here, we assign the _f‑string_ to an _APL_ variable, then call **∆F** twice!

<span class="margin-note">Setting `⎕RL` ensures our random numbers aren't random!
</span>

```
   ⎕RL← 2342342
   n← ≢names← 'Mary' 'Jack' 'Tony'
   prize← 1000
   f← 'Customer {names⊃⍨ ?n} wins £{?prize}!'
   ∆F f
Customer Jack wins £80!
   ∆F f
Customer Jack wins £230!
```

Isn't Jack lucky, winning twice in a row!

<details id="pPeek"><summary class="summary">&ensp;View a fancier example...</summary>

<span class="margin-note"><br>[See a different method using the **Wrap** shortcut](#winner2).
</span>

<div id="winner1">

```
 ⍝ Be sure everyone wins something.
   n← ≢names← 'Mary' 'Jack' 'Tony'
   prize← 1000
   ∆F '{ ↑names }{ ⍪n⍴ ⊂"wins" }{ "£", ⍕⍪?n⍴ prize}'
Mary wins £711
Jack wins £298
Tony wins £242
```

</div>
</details>

## Text Fields and Space Fields

Below, we have some multi&shy;line **Text** fields separated by non-null **Space** fields.

- The backtick is our "escape" character.
- The sequence `◇ generates a new line in the current **Text** field.
- Each **Space** field `{ }` in this example contains one space within its braces. It produces a matrix a _single_ space wide with as many rows as required to catenate it with adjacent fields.

A **Space** field is useful here because each multi&shy;line field is built
in its own rectangular space.

```
   ∆F 'This`◇is`◇an`◇example{ }Of`◇multiline{ }Text`◇Fields'
This    Of         Text
is      multiline  Fields
an
example
```

<div class="page-break"></div> 
## Null Space Fields

Two adjacent **Text** fields can be separated by a null **Space** field `{}`,
for example when at least one field contains multiline input that you
want formatted separately from others, keeping each field in its own rectangular space:

```
⍝  Extra space here ↓
   ∆F 'Cat`◇Elephant `◇Mouse{}Felix`◇Dumbo`◇Mickey'
Cat      Felix
Elephant Dumbo
Mouse    Mickey
```

In the above example, we added an extra space after the longest
animal name, _Elephant_, so it wouldn't run into the next word, _Dumbo_.

**But wait! There's an easier way!**

Here, you surely want the lefthand field to be guaranteed to have a space
after _each_ word without fiddling; a **Space** field with at least
one space will solve the problem:

```
⍝                          ↓↓↓
   ∆F 'Cat`◇Elephant`◇Mouse{ }Felix`◇Dumbo`◇Mickey'
Cat      Felix
Elephant Dumbo
Mouse    Mickey
```

## Code Fields (Continued)

<span class="margin-note">We could have used a **Space** field <code>{&nbsp;}</code> here as well.</span>
And this is the same example with _identical_ output, but built using two **Code** fields
separated by a **Text** field with a single space.


```
   ∆F '{↑"Cat" "Elephant" "Mouse"} {↑"Felix" "Dumbo" "Mickey"}'
Cat      Felix
Elephant Dumbo
Mouse    Mickey
```

Here's a similar example with double quote-delimited strings in **Code** fields with
the newline sequence, `` `◇ ``:

```
   ∆F '{"This`◇is`◇an`◇example"} {"Of`◇Multiline"} {"Strings`◇in`◇Code`◇Fields"}'
This    Of         Strings
is      Multiline  in
an                 Code
example            Fields
```

Here is some multiline data we'll add to our **Code** fields.

<span class="margin-note"><br><br><br><br><br>Again, we use _APL_ _mix_ `↑` to generate multiline objects (matrices).</span>

```
   fNm←  'John' 'Mary' 'Ted'
   lNm←  'Smith' 'Jones' 'Templeton'
   addr← '24 Mulberry Ln' '22 Smith St' '12 High St'

   ∆F '{↑fNm} {↑lNm} {↑addr}'
John Smith     24 Mulberry Ln
Mary Jones     22 Smith St
Ted  Templeton 12 High St
```

<span class="margin-note">We formally discuss the `⎕FMT` short&shy;cut `$` [below](#the-format-shortcut).</span>
<span class="margin-note"><br><br>In this example, we could have used `0⍕⍪` and `1⍕⍪` here, of course. But we wanted to remind you what Dyalog's `⎕FMT` can do!
</span>

Here's a slightly more interesting code expression, using `$` (a shortcut for `⎕FMT`)
to round Centigrade numbers to the nearest whole degree and Fahrenheit numbers to the nearest tenth of a degree.

```
   cv← 11.3 29.55 59.99
   ∆F 'The temperature is {"I2" $ cv}°C or {"F5.1"$ 32+9×cv÷5}°F'
The temperature is 11°C or  52.3°F
                   30       85.2
                   60      140.0
```

## The Box Shortcut

**∆F** shortcuts are concise *names* for useful *f-string* utilities used inside
**Code** fields. 
Let's introduce shortcuts through `` `B ``, the **Box** shortcut. Here we use `` `B `` to place boxes around key objects in **Code** fields, building on the previous example.

```
   cv← 11.3 29.55 59.99
   ∆F '`◇The temperature is {`B "I2" $ cv}`◇°C or {`B "F5.1" $ 32+9×cv÷5}`◇°F'
                   ┌──┐      ┌─────┐
The temperature is │11│°C or │ 52.3│°F
                   │30│      │ 85.2│
                   │60│      │140.0│
                   └──┘      └─────┘
``` 

For full information on all of the current
shortcuts, see [**Section 5.5**](#code-field-shortcuts) in the [**∆F** *Reference*](#f-reference) below.
For an abridged preview, look no further.
 
<details>     <!-- option: open -->
<summary class="summary">&ensp;A Preview of <em>Code Field Shortcuts</em></summary>

**Code** field ***Shortcuts*** include:

<a id="inside-brief-shortcuts" class="scroll-target"></a>

| Shortcut<div style="width:75px"></div> |               Name                | Syntax<div style="width:150px"></div>  | Default Meaning               |
| :------- | :----------------------------: | :-----------------------------:  |:----------------------------------------------------------------------------------|
| **\`B**                                |                               Box                                | `` `B ⍵ `` |Place `⍵` in a box.   |
| **\`C**                                |                              Commas                              | `` [⍺]`C ⍵  ``|  Add commas to large numbers `⍵`.  |
| **\`D**                                |                            Date-Time                             | `` [⍺]`D ⍵ `` |Synonym for **\`T**.       |
| **\`F**, **$**                         |                               ⎕FMT                               | `[⍺] $ ⍵`| `⍺ ⎕FMT ⍵`.      |
| **\`J**                                |                             Justify                              | `` [⍺]`J ⍵ ``| Justify *rows of* `⍵` according to `⍺`.   |
| **\`L**, **£**                         | Session Library                                             | `£, £.arr, £.dfn`| Use arrays, dfns, and dops in a private, session library, automatically loading from files or workspaces. |
| **\`Q**                                |                              Quote                               | `` [⍺]`Q ⍵ ``| Place character objects in `⍵` in APL quotes, row by row. |
| **\`S**                                |                            Serialise                             | `` [⍺]`S ⍵ ``| Serialise an _APL_ array `⍵`, i.e. display it in _APL_ Array Notation. |
| **\`T**                                |                            Date-Time                             | `` [⍺]`T ⍵  ``|Displays ⎕TS-style timestamps `⍵` according to Dyalog date-time template `⍺`. |
| **\`W**                                |        Wrap                                                      | `` [⍺]`W ⍵ ``| Wraps the *rows of* simple arrays in `⍵` in left and right decorators `⍺`. |
| **\`⍵𝑑𝑑**, **⍹𝑑𝑑**                     |           Omega Shortcut<br>(<small>EXPLICIT</small>)            | `` `⍵𝑑𝑑 ``| Select **∆F** argument `𝑑𝑑`, i.e. `(⍵⊃⍨ 𝑑𝑑+⎕IO)`, given 𝑑𝑑 an `⎕IO`-independent integer *offset*.  |
| **\`⍵**, **⍹**                         |           Omega Shortcut<br>(<small>IMPLICIT</small>)            | `` `⍵ ``| Selects the ***next*** argument to **∆F**, scanning left to right. |
| **→**<br>**↓** _or_ **%**              |     Self-documenting **Code** Fields <small>(SDCFs)</small>      | ``{…→}``<br>``{…↓}``|Displays code field source to left of/above its value. |
Table: 3a. <strong>Brief Summary of Code Field Shortcuts</strong>
</details> 

## Box Mode

But what if you want to place a box around every **Code**, **Text**, **_and_** **Space** field?
We just use the **box** mode option!

While we can't place boxes inside text (or space) fields using `` `B ``,
we can place a box around **_each_** field (_regardless_ of type) by setting **∆F**'s [**box** mode](#f-option-details) option, <span class="margin-note">**box mode:** `0 0 1` _or_ `(box: 1)`</span>to `1`:

```
   cv← 11.3 29.55 59.99
⍝   ↓¯¯¯ box mode,  or:  0 0 1
   (box: 1) ∆F '`◇The temperature is {"I2" $ cv}`◇°C or {"F5.1" $ 32+9×cv÷5}`◇°F'
┌───────────────────┬──┬──────┬─────┬──┐
│                   │11│      │ 52.3│  │
│The temperature is │30│°C or │ 85.2│°F│
│                   │60│      │140.0│  │
└───────────────────┴──┴──────┴─────┴──┘
```

We said you could place a box around every field, but there's an exception.
Null **Space** fields `{}`, _i.e._ 0-width **Space** fields, are discarded once they've done their work of ensuring adjacent fields (typically, **Text** fields) are displayed in their own rectangular space.

Try evaluating this expression on your own:

```
    (box: 1) ∆F 'abc{}def{}{}ghi{""}jkl{ }mno'   
```

<details id="pPeek"><summary class="summary">&ensp;Peek at answer</summary>

```
   (box: 1) ∆F 'abc{}def{}{}ghi{""}jkl{ }mno'
┌───┬───┬───┬┬───┬─┬───┐
│abc│def│ghi││jkl│ │mno│
└───┴───┴───┴┴───┴─┴───┘
```

</details>

In contrast, **Code** fields that return null values&mdash;like `{""}` above&mdash; _will_ be displayed!

## Omega Shortcuts (Explicit)

<span class="margin-note">`` `⍵1 ``: Or its equivalent, `⍹1`.<br><strong>⍹</strong> is ⍵-underscore.</span>
&emsp;&emsp;<strong>Referencing **∆F** arguments after the _f‑string_: **Omega**
shortcut expressions (like `` `⍵1 ``).</strong>

<span class="margin-note">And `(⍵⊃⍨ 1+⎕IO)` is, of course, equivalent to `((1+⎕IO)⊃⍵)`.</span>
The 
expression `` `⍵1 `` is equivalent to `(⍵⊃⍨ 1+⎕IO)`, selecting the first argument after the _f‑string_. Similarly, `` `⍵99 `` would select `(⍵⊃⍨99+⎕IO)`.

We will use `` `⍵1 `` here, both with shortcuts and an externally defined
function `C2F`, that converts Centigrade to Fahrenheit.
A bit further [below](#omega-shortcuts-implicit), we discuss bare `` `⍵ ``
(_i.e._ without an appended non-negative integer).

```
   C2F← 32+9×÷∘5
   ∆F 'The temperature is {"I2" $ `⍵1}°C or {"F5.1" $ C2F `⍵1}°F' (11 15 20)
The temperature is 11°C or 51.8°F
                   15      59.0
                   20      68.0
```

## Referencing the f‑string Itself

<span class="margin-note"> `` `⍵0 `` refers to the _f‑string_, independent of the the number of elements in the right argument to **∆F** (_effectively_, `⊆⍵`).
</span>
The expression `` `⍵0 `` always refers to the _f‑string_ itself. Try this:

```
   bL bR← '«»'                     ⍝ ⎕UCS 171 187
   ∆F 'Our string {bL, `⍵0, bR} has {≢`⍵0} characters.'
```

<details id="pPeek"><summary class="summary">&ensp;Peek at answer</summary>

```
   bL bR← '«»'                     ⍝ ⎕UCS 171 187
   ∆F 'Our string {bL, `⍵0, bR} has {≢`⍵0} characters.'
Our string «Our string {bL, `⍵0, bR} has {≢`⍵0} characters» has 47 characters.
```

<details id="pPeek"><summary class="summary">&ensp;Let's check our work...</summary>

```
   ≢'Our string {bL, `⍵0, bR} has {≢`⍵0} characters.'
47
```

</details>
</details>

## The Format Shortcut

<span class="margin-note">The **Format** shortcut `$`, or `` `F `` (short for `⎕FMT`), can also be used monadically, but let **∆F** handle that for you in most cases.
</span>

> Let's add commas to some very large numbers using the **⎕FMT** shortcut `$`.

We can use Dyalog's built-in formatting specifier "C" with shortcut `$`
to add appropriate commas to the temperatures!

<span class="margin-note"><br><br>`C2F← 32+9×÷∘5`</span>

```
⍝  The temperature of the sun at its core in degrees C.
   sun_core← 15E6                   ⍝ 15000000 is a bit hard to parse!
   ∆F 'The sun''s core is at {"CI10" $ sun_core}°C or {"CI10" $ C2F sun_core}°F'
The sun's core is at 15,000,000°C or 27,000,032°F
```

## The Shortcut for Numeric Commas

<span class="margin-note">Typically, each number or numeric string presented to `` `C `` will represent an integer, but if a real number is presented, only the integer part will have commas added.
</span>
The shortcut for _Numeric_ **Commas** `` `C `` adds commas every 3 digits (from the right) to one or more numbers or numeric strings. It has an advantage over the `$` (Dyalog's `⎕FMT`) specifier: it doesn't require you to guesstimate field widths.

Let's use the `` `C `` shortcut to add the commas to the temperatures!

<span class="margin-note"><br>Cool! OK, not literally.
</span>

```
   sun_core← 15E6               ⍝ 15000000 is a bit hard to parse!
   ∆F 'The sun''s core is at {`C sun_core}°C or {`C C2F sun_core}°F.'
The sun's core is at 15,000,000°C or 27,000,032°F.
```

And for a bit of a twist, let's display either degrees Centigrade
or Fahrenheit under user control (`1` => F, `0` => C). Here, we establish
the _f‑string_ `sunFC` first, then pass it to **∆F** with an additional right argument.

```
   sunFC← 'The sun''s core is at {`C C2F⍣`⍵1⊢ sun_core}°{ `⍵1⊃ "CF"}.'
   ∆F sunFC 1
The sun's core is at 27,000,032°F.
   ∆F sunFC 0
The sun's core is at 15,000,000°C.
```

Now, let's move on to Self-documenting **Code** fields.

## Self-documenting **Code** fields (SDCFs)

<span class="margin-note">Our SDCFs are based on Python's single type of self-documenting expressions in _f‑strings_, but work somewhat differently.
SDCFs are used **_only_** in **Code** fields _(duh)._
</span>

> Self-documenting Code fields (SDCFs) are a useful debugging tool.

What's an SDCF? An SDCF allows whatever source code is in a **Code** field to be automatically displayed literally along with the result of evaluating that code.

The source code for a **Code** field can automatically be shown in **∆F**'s output—

- to the _left_ of the result of evaluating that code; or,
- centered _above_ the result of evaluating that code.

All you need do is enter

- a right arrow <big>`→`</big> for a **horizontal** SDCF, or
- a down arrow <big>`↓`</big> (or <big>`%`</big>)<span class="margin-note">`%` is the same glyph as for the **Above** shortcut, `%` or `` `A ``, discussed
  in [the next section](#the-above-shortcut).</span> for a **vertical** SDCF,

as the **_last non-space_** character in the **Code** field,
before the _final_ right brace.

Here's an example of a horizontal SDCF, _i.e._ using `→`:

```
   name←'John Smith' ◇ age← 34
   ∆F 'Current employee: {name→}, {age→}.'
Current employee: name→John Smith, age→34.
```

As a useful formatting feature, whatever spaces are just **_before_**
or **_after_** the symbol **→** or **↓** are preserved **_verbatim_** in the output.

Here's an example with such spaces: see how the spaces adjacent to
the symbol `→` are mirrored in the output!

```
   name←'John Smith' ◇ age← 34
   ∆F 'Current employee: {name → }, {age→ }.'
Current employee: name → John Smith, age→ 34.
```

Now, let's look at an example of a vertical SDCF, _i.e._ using `↓`:

```
   name←'John Smith' ◇ age← 34
   ∆F 'Current employee: {name↓} {age↓}.'
Current employee:  name↓     age↓.
                  John Smith  34
```

To make it easier to see, here's the same result, but with a box around
each field&mdash;using the **Box** [option](#f-option-details), _namespace_ style.

```dyalog20
⍝  Box all fields
   (box: 1) ∆F 'Current employee: {name↓} {age↓}.'
┌──────────────────┬──────────┬─┬────┬─┐
│Current employee: │ name↓    │ │age↓│.│
│                  │John Smith│ │ 34 │ │
└──────────────────┴──────────┴─┴────┴─┘
```

<div class="page-break"></div> 
## The Above Shortcut

> A cut above the rest…

<span class="margin-note">`%` can be used monadically. In that case, a left argument of `''`
(an empty string) is assumed.
</span>
Here's a useful feature. Let's use the shortcut `%` to display one
expression centered above another;
it's called **Above** and can _also_ be expressed as `` `A ``.

<span class="margin-note">Remember, `` `⍵1 `` designates the **_first_** argument after the _f‑string_ itself, and `` `⍵2 `` the **_second_**.
</span>

```
   ∆F '{"Employee" % ⍪`⍵1} {"Age" % ⍪`⍵2}' ('John Smith' 'Mary Jones')(29 23)
Employee    Age
John Smith  29
Mary Jones  23
```

## Text Justification Shortcut

<span class="margin-note">`` `J `` is a variant of `just`, found in the _dfns_ library.</span>
The Text **Justification** shortcut `` `J `` treats its right argument
as a character array, justifying each line
to the left (`⍺∊"L" ¯1`,
the default), to the right (`⍺∊"R" 1`), or centered (`⍺∊"C" 0`).
<span class="margin-note">**maximum `⎕PP`:** the maximum `⎕PP` is `17` for 64-bit floats, and `34` for 128-bit floats.
</span>
If its right argument contains floating point numbers, they will be displayed with the maximum
print precision `⎕PP` available.

```
   a← ↑'elephants' 'cats' 'rhinoceroses'
   ∆F '{"L" `J a}  {"C" `J a}  {"R" `J a}'
elephants      elephants       elephants
cats              cats              cats
rhinoceroses  rhinoceroses  rhinoceroses
```

And what do you think this _f-string_ displays?

```
   ∆F '{¯1 `J `⍵1} {0 `J `⍵1} { 1`J `⍵1  }' (⍪10*2×⍳4)
```

<details id="pPeek"><summary class="summary">&ensp;Peek at answer</summary>

```
   ∆F '{¯1 `J `⍵1} {0 `J `⍵1} { 1`J `⍵1  }' (⍪10*2×⍳4)
1          1          1
100       100       100
10000    10000    10000
1000000 1000000 1000000
```

</details>

## Omega Shortcuts (Implicit)

> The _next_ best thing: the use of `` `⍵ `` in **Code** field expressions…

We said we'd present the use of **Omega** shortcuts with implicit 
<span class="margin-note">`` `⍵ ``: Or its equivalent, `⍹`.<br><strong>⍹</strong> is ⍵-underscore.</span>
indices `` `⍵ `` in **Code** fields. The expression `` `⍵ `` selects the _next_ element of the right argument `⍵` to **∆F**, defaulting to `` `⍵1 `` when first encountered, _i.e._ if there are **_no_** `` `⍵ `` elements (_explicit_ or _implicit_) to the **_left_** in the entire _f‑string_. If there is any such expression (_e.g._ `` `⍵5 ``), then `` `⍵ `` points to the element after that one (_e.g._ `` `⍵6 ``). If the item to the left is `` `⍵ ``, then we simply increment the index by `1` from that one.

**Let's try an example.** Here, we display arbitrary 2-dimensional expressions,
one above the other.
`` `⍵ `` refers to the **_next_** argument in sequence, left to right,
starting with `` `⍵1 ``, the first, _i.e._ `(⍵⊃⍨ 1+⎕IO)`.
So, from left to right `` `⍵ `` is `` `⍵1 ``, `` `⍵2 ``,
and `` `⍵3 ``.

<span class="margin-note">_Easy peasy._</span>

```
   ∆F '{(⍳2⍴`⍵) % (⍳2⍴`⍵) % (⍳2⍴`⍵)}' 1 2 3
    0 0
  0 0 0 1
  1 0 1 1
0 0 0 1 0 2
1 0 1 1 1 2
2 0 2 1 2 2
```

Here's a useful example, where the formatting option for each text justification `` `J ``
is determined by an argument to **∆F**:

```
   a← ↑'elephants' 'cats' 'rhinoceroses'
   ∆F '{`⍵ `J a}  {`⍵ `J a}  {`⍵ `J a}' ¯1 0 1
elephants      elephants       elephants
cats              cats              cats
rhinoceroses  rhinoceroses  rhinoceroses
```

## Shortcuts With _APL_ Expressions

Shortcuts often make sense with _APL_ expressions, not just entire **Code** fields. They can be manipulated like ordinary _APL_ functions; since they are just that&mdash; ordinary _APL_ functions&mdash; under the covers.
Here, we display one boxed value above the other.

```
   ∆F '{(`B ⍳`⍵1) % `B ⍳`⍵2}' (2 2)(3 3)
  ┌───┬───┐
  │0 0│0 1│
  ├───┼───┤
  │1 0│1 1│
  └───┴───┘
┌───┬───┬───┐
│0 0│0 1│0 2│
├───┼───┼───┤
│1 0│1 1│1 2│
├───┼───┼───┤
│2 0│2 1│2 2│
└───┴───┴───┘
```

<details id="pPeek"><summary class="summary">&ensp;Peek: Shortcuts are just Functions</summary>

While not for the faint of heart, the expression above can be recast as this
concise <span class="margin-note">**concise:** somewhat hard to read.
</span>alternative:

```
   ∆F '{%/ `B∘⍳¨ `⍵1 `⍵2}' (2 2)(3 3)
```

</details

> There are loads of other examples to discover.

## A Shortcut for Dates and Times (Part I)

<span class="margin-note">The syntax for the Date-Time specifications in the left argument to `` `T `` can be found in the Dyalog doc&shy;ument&shy;ation under **1200⌶**. See [below](#code-field-shortcuts), for more info.
</span>
**∆F** supports a simple **Date-Time** shortcut `` `T `` built from **1200⌶** and **⎕DT**. It takes one or more Dyalog `⎕TS`-format timestamps as the right argument and a date-time specification as the <span class="margin-note">The default left arg&shy;ument is `⍺← '%ISO%'`, _i.e._ an ISO date-time.</span> (optional) left argument. Trailing elements of a timestamp may be omitted (they will each be treated as `0` in the specification string).

Let's look at the use of the `` `T `` shortcut to show the current time (now).

<span class="margin-note">The time displayed in practice will be the _true_ current time.</span>

```
   ∆F 'It is now {"t:mm pp" `T ⎕TS}.'
It is now 8:08 am.
```

Here's a fancier example<span class="margin-note">The power is in the capabilities of `1200⌶` and `⎕DT`.</span>.
(We've added the _truncated_ timestamp `2025 01 01` right into the _f‑string_.)

```
   ∆F '{ "D MMM YYYY ''was a'' Dddd."`T 2025 01 01}'
1 JAN 2025 was a Wednesday.
```

## A Shortcut for Dates and Times (Part II)

If it bothers you to use `` `T `` for a date-only expression,
you can use `` `D ``, which means exactly the same thing.

```
   ∆F '{ "D MMM YYYY ''was a'' Dddd." `D 2025 01 02}'
2 JAN 2025 was a Thursday.
```

Here, we'll pass the time stamp via a single **Omega**
expression `` `⍵1 ``, whose argument <span class="margin-note">`(2025 1 21)`</span> is passed in parentheses.

```
   ∆F '{ "D Mmm YYYY ''was a'' Dddd." `T `⍵1}' (2025 1 21)
21 Jan 2025 was a Tuesday.
```

We could also pass the time stamp via a sequence of **Omega**
expressions: `` `⍵ `⍵ `⍵ ``.
This is equivalent to the _slightly_ verbose
expression: `` `⍵1 `⍵2 `⍵3 ``.

```
   ∆F '{ "D Mmm YYYY ''was a'' Dddd." `T `⍵ `⍵ `⍵}' 2025 1 21
21 Jan 2025 was a Tuesday.
```

And what do you think this does?

```
   ∆F '{ "D Mmm YYYY ''was a'' Dddd." `T `⍵1}' (⍪(2025 1 21)(2024 1 21))
```

<details id="pPeek"><summary class="summary">&ensp;Peek: It's `` `T `` time for multiple timestamps!</summary>
```
   ∆F '{ `B "D Mmm YYYY ''was a'' Dddd." `T `⍵1}' (⍪(2025 1 21)(2024 1 21))
┌──────────────────────────┐
│21 Jan 2025 was a Tuesday.│
├──────────────────────────┤
│21 Jan 2024 was a Sunday. │
└──────────────────────────┘ 
```

</details>

## The Quote Shortcut

> Placing quotes around string elements of an array.

<span class="margin-note">If a multi&shy;dimensional character array is found, its <em>rows</em> are quoted; if a character vector, it is quoted <em>in toto</em>; else, each character <em>scalar</em> is quoted in isolation.
</span>
The **Quote** shortcut `` `Q `` recursively scans its right argument, matching rows of character arrays, character vectors, and character scalars, doubling internal single quotes and placing single quotes around the items found.

Non-character data is returned as is. This is useful, for example, when you wish to clearly distinguish character from numeric data.

Let's look at a couple of simple examples:

First, let's use the `` `Q `` shortcut to place quotes around the simple character
arrays in its right argument, `⍵`. This is useful when you want to distinguish between character output that might include numbers and _actual_ numeric output.

```
   ∆F '{`Q 1 2 "three" 4 5 (⍪1 "2") (⍪"cats" "dogs")}'
1 2  'three'  4 5     1    'cats'
                    '2'    'dogs'
```

And here's an example with a simple, mixed vector (_i.e._ a mix of character and numeric scalars only). We'll call the object `iv`, but we won't disclose its definition yet.

Let's display `iv` without using the **Quote** shortcut.

```skip
   iv← ...
   ∆F '{iv}'
1 2 3 4 5
```

Are you **_sure_** which elements of `iv` are numeric and which character scalars?

<details id="pPeek"><summary class="summary">&ensp;Peek to see the example with `iv` defined.</summary>

```
   iv← 1 2 '3' 4 '5'
   ∆F '{iv}'
1 2 3 4 5
```

</details>

Now, we'll show the variable `iv` using the **Quote** `` `Q `` shortcut.

```
   iv← 1 2 '3' 4 '5'
   ∆F '{`Q iv}'
```

<details id="pPeek"><summary class="summary">&ensp;Take a peek at the <bold>∆F</bold> output.</summary>

```
1 2 '3' 4 '5'
```

</details>

Voilà, quotes appear around the character digits, but not the actual APL numbers!

## The Serialise Shortcut

The Serialise
shortcut, `` `S ``, displays objects formatted in _APL_ Array Notation. These include
arrays <span class="margin-note">NB. See Dyalog documentation for what is in the domain of Array Notation.</span>of any depth and shape that
contain only data arrays (nameclass: `2`) and namespaces (nameclass: `9`). The shortcut
allows both a **_tabular_** (multiline) form (default or `` 0 `S ``) and a **_compact_** format (`` 1 `S ``).
If an object cannot be displayed in Array Notation, it is typically displayed unformatted, _i.e._ as is.

Here's a brief example showing a scalar, vector, matrix, and vector of (character) vectors:

```dyalog20
   ∆F '{ `S (scal: 3 ◇ vec: ⍳3 ◇ mx: 3 3⍴⎕A ◇ vv: "cats" "dogs" )}'
(
  mx:[
   'ABC'
   'DEF'
   'GHI'
  ]
  scal:3
  vec:0 1 2
  vv:(
   'cats'
   'dogs'
  )
)
   ∆F '{ 1 `S (scal: 3 ◇ vec: ⍳3 ◇ mx: 3 3⍴⎕A ◇ vv: "cats" "dogs" )}'
(mx:[◇'ABC'◇'DEF'◇'GHI'◇]◇scal:3◇vec:0 1 2◇vv:('cats'◇'dogs'◇)◇)
```

Here's another example, highlighting the similarity between _JSON5_ format and _APL_ Array Notation.
In each case, the object displayed is an _APL_ namespace:

```
   j←'{fred:[1,2,3],jack:9,name:{a:1,b:2}}'
   JSON← ⎕JSON⍠('Dialect' 'JSON5')

   ∆F 'JSON:`◇APL:  {j % 1`S JSON j} '
JSON:  {fred:[1,2,3],jack:9,name:{a:1,b:2}}
APL:   (fred:1 2 3◇jack:9◇name:(a:1◇b:2◇)◇)
```

## The Wrap Shortcut  

<div> 

> Wrapping results in left and right decorators...

<span class="margin-note">For more, see [Wrap Shortcut: Details](#wrap-shortcut-details) _below_.
</span>
The shortcut **Wrap** `` `W `` is used
when you want to place a **_decorator_** string immediately to the left or right of **_each_** row of simple objects in the right argument, `⍵`. It differs from the **Quote** shortcut `` `Q ``, which puts quotes **_only_** around the character arrays in `⍵`.

- The decorators are in `⍺`, the left argument to **Wrap**: the left decorator, `0⊃2⍴⍺`, and the right decorator, `1⊃2⍴⍺`, with `⍺` defaulting to a single quote.
- If you need to omit one or the other decorator, simply make it a null string `""` or a _zilde_&nbsp;`⍬`.

**Here are two simple examples.**

In the first, we place `"°C"` after **[a]** each row of a table `` ⍪`⍵2 ``, or **[b]** after each simple vector in `` ,¨`⍵2 ``. We indicate that is no _left_ decorator here
using `""` or `⍬`, as here.

```
⍝         ... [a] ...       .... [b] ....
    ∆F '{ `⍵1 `W ⍪`⍵2 } ...{ `⍵1 `W ,¨`⍵2 }' (⍬ '°C')(18 22 33)
18°C ... 18°C 22°C 33°C
22°C
33°C
```

In this next example, we place brackets around the lines of each simple array in a complex array.

```
   ∆F '{"[]" `W ("cats")(⍳2 2 1)(2 2⍴⍳4)(3 3⍴⎕A) }'
 [cats]   [0 0 0]   [0 1]  [ABC]
          [0 1 0]   [2 3]  [DEF]
                           [GHI]
          [1 0 0]
          [1 1 0]
```

<div id="winner2">

Now, let's try recasting an _earlier_ example&mdash;reshown here&mdash; to use **Wrap** `` `W ``:

#### [The earlier example](#winner1)...

```
   n← ≢names← 'Mary' 'Jack' 'Tony'
   prize← 1000
   ∆F '{ ↑names }{ ⍪n⍴ ⊂"wins" }{ "£", ⍕⍪?n⍴ prize }'
```

</div>
<details id="pPeek"><summary class="summary">&ensp;Peek to see the solution with **Wrap**...</summary>

<span class="margin-note"><br><br>The string `"wins "` is the left prefix to **Wrap**, and `""` the right.</span>

```
   n← ≢names← 'Mary' 'Jack' 'Tony'
   prize← 1000
   ∆F '{ ↑names } { "wins " "" `W "£", ⍕⍪?n⍴ prize }'
Mary wins £201
Jack wins £ 73
Tony wins £349
```

</details>
</div>

## The Session Library Shortcut  

<div>  
 
The shortcut (Session) **Library** 
`£` denotes 
<span class="margin-note">**£ alias:** `` `L ``. £ is from the first letter of the Latin *lībra*, "pound", very apt for a *libra*-ry.<br><br>**FString**: *See [**∆F** Installation](#f-installation), above.*
</span>
a "private" *user* namespace in **FString**,
where the user may place and manipulate useful objects for the duration
of the ***current*** *APL* session. For example, the user may wish to: <span class="margin-note">*For details, see  [Code Field Short&shy;cuts](#code-field-shortcuts) below.*</span>

- have regularly used functions or operators automatically available when needed, _or_
- create objects that might be referred to, monitored, or modified during the session.

### Explicitly Copied Library Objects

In this example, the user wants to generate all primes between 1 and 100 using
two routines, `sieve` and `to`, that reside in the **_dfns_** workspace. To accommodate this,
we could anticipate all the items we might need and copy them well in advance.

> But there's a better way!

Here we copy both routines from **_dfns_** in real time, only when they are needed.

<span class="margin-note">`⎕CY` returns `0⍴⊂''` on success, _i.e._
an _invisible_, 0-width **Code** field!
</span>

```
    ∆F '{"sieve" "to" £.⎕CY "dfns"}{£.sieve 2 £.to 100}'
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

On subsequent calls, `sieve` and `to` are already available, as we can see here:

```
    ∆F '{ £.⎕NL ¯3 }'
 sieve  to
```

### Automatically Copied Library Objects

> But, **∆F** can handle this all for you!

If <span class="margin-note">Here, we only show examples of objects from the **_dfns_** workspace. _See [Code Field Shortcuts](#code-field-shortcuts) below._
</span>
the user references a simple name of the form
`£.name` that
has not (yet) been defined in the library,
an attempt is made to copy that name into the library either from a text file in a user directory or from the **_dfns_** workspace; if the name appears on the left-side of a **simple** assigment `←`, it is **not** copied in (since the user is defining it).

<big>👉</big>&nbsp;
If **∆F** is unable to find the item during its search,
a standard _APL_ error will be signaled when the **Code** field is evaluated.

In this next example, we use the function `pco` from the
`dfns` workspace. If this is the *first* use, it is quietly copied in (unless the **verbose** option is specified).

```
    ∆F '{ ⍸ 1 £.pco ⍳100 }'
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

<details id="pPeek">
<summary class="summary">&ensp;Peek: Using the <em><strong>verbose</strong></em> option</summary>

<big>👉</big>&nbsp;To understand _when_ an object is automatically copied into a £ibrary,
and to see _where_ it's copied from, use **∆F**'s **_verbose_** option:

<span class="margin-note"><br>First use of `£.pco` this _session._ Since subsequent uses will use the `£.pco` already copied into the library, they are ***quiet***.</span>

```
   (verbose: 1) ∆F '{ ⍸ 1 £.pco ⍳100 }'    ⍝ (verbose: 1) <==> 0 1 
```
```skip
∆F: Copied "pco" into £=[⎕SE.FString.library] from "ws:dfns"
{ ⎕SE.FString.M ⌽⍬({⍸ 1 (⎕SE.FString.library).pco ⍳100}⍵)}⍵
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

<big>👉</big>&nbsp;With the default _verbose_ setting, `(verbose: 0)`, the autoload process works the same way, but quietly!

</details>


### Session Library Variables

> But we can use the Session Library shortcut for arrays as well.

<span class="margin-note"><big>👉</big>&nbsp;If `£.ctr` already exists, it must be in the same class
as its new value, consistent with _APL_ rules.</span>

Here is an example where we define a local session variable `ctr`,
a counter of the number of times a particular
statement is executed. Since we define the counter, `£.ctr←0`,
**∆F** makes **_no_** attempt to copy it from the `dfns` workspace or a file.

```
   ∆F '{ ⍬⊣£.ctr←0 }'         ⍝ Initialise £.ctr.
   t← 'We''ve been called {£.ctr← £.ctr+1} times.'
⍝  ...
   ∆F t
We've been called 1 times.
   ∆F t
We've been called 2 times.
```

This may be sensible when ∆F is called from a variety of namespaces and/or
if the user doesn't wish to clutter the active namespace.

In this example, we simply use `£` as a private namespace for the
the <span class="margin-note">Remember: **∆F** evaluates fields left-to-right.</span>
template variable `£.dt` used during the **∆F** <span class="margin-note"><br><br><br>NB. `£.dt` hangs around after execution!</span>
call:

```
   d1← ⍪(2025 1 21)(2024 1 21)   ◇   d2← (2100 1 1)
   ∆F '{(£.dt← "D Mmm YYYY ''was a'' Dddd.") `T `⍵1 }{£.dt`T `⍵2}' d1 d2
 21 Jan 2025 was a Tuesday. 1 Jan 2100 was a Friday.
 21 Jan 2024 was a Sunday.
```

</div>

## Precomputed f‑strings with the **_dfn_** Option

In this section, we talk about generating standalone _dfns_ via the **∆F** _dfn_ option;
these present some advantages over repeated **∆F** calls. 

<div class="marquee"><center>
By default, **∆F** caches
the output *code* for specific input *f-strings* and options; this leads to about 3-fold
performance improvements for *f-strings* that are used more than once. 
</center></div>

As shown in Table 3a (below), with _(i)_ the default _dfn_ option set to `0`,
the value returned from a successful call to **∆F** is always a character matrix.
However, _(ii)_ <span class="margin-note">Under identical conditions, of course.</span>
if [_dfn_](#f-option-details) is set to `1`, then **∆F** returns a **dfn** that&mdash;
when called later&mdash; will return the identical character expression.

+--------+-------------------+--------------------+
|        | Positional        |  Keyword           |
|  Mode  | Parameter         |  Parameter         |
+:=======+:=================:+:==================:+
| *(i)*  |`0 ∆F 'mycode'`    | `(dfn: 0)          |
| ***    |                   |  ∆F 'mycode'`      |
| default|                   |                    |
| ***    |                   |                    |
+--------+-------------------+--------------------+
| *(ii)* |`1 ∆F 'mycode'`    | `(dfn: 1)          |
| ***    |                   |  ∆F 'mycode'`      |
| dfn    |                   |                    |
| ***    |                   |                    |
+--------+-------------------+--------------------+
Table: 3a. <strong>Using the <em>dfn Option</em></strong>
<br>


<span class="margin-note"><br>**standalone:** _i.e._ via the _inline_ option. See [option details](#f-option-details) (be&shy;low) re&shy;gard&shy;ing the _inline_ option and ex&shy;ceptions.</span>
The _dfn_ option is most useful when you are making repeated use of an _f‑string_, since the overhead for analyzing the _f‑string_ contents **_once_** will be amortized over **_all_** the subsequent calls. An **∆F**-derived _dfn_ can also be made standalone, _i.e._ independent of the runtime library, **FString**.

Let's explore an example where getting the best performance for a heavily
used **∆F** string is important.

First, let's grab `cmpx` and set the variable `cv`, so we can compare the performance…

```
   'cmpx' ⎕CY 'dfns'
   cv← 11 30 60
```

Now, let's proceed. Here's our **∆F** String `t`:

```
   t←'The temperature is {"I2" $ cv}°C or {"F5.1" $ 32+9×cv÷5}°F'
```

<details id="pPeek"><summary class="summary">&ensp;Evaluate <code>∆F t</code></summary>

```
   ∆F t
The temperature is 11°C or  51.8°F
                   30       86.0
                   60      140.0
```

</details>

Let's precompute a dfn `T`, given the string `t`.&ensp;`T` has everything needed to generate the output (given the same definition of the vector `cv`, when `T` is evaluated).

```
   T← 1 ∆F t       ⍝ Or (dfn: 1) ∆F ...
```

<details id="pPeek"><summary class="summary">&ensp;Evaluate <code>T ⍬</code></summary>

```
   T ⍬
The temperature is 11°C or  51.8°F
                   30       86.0
                   60      140.0
```

</details>

Now, let's compare the performance of the two formats, when caching of input fstrings 
is ***not*** enabled; this simulates the relative performance the *first* time an fstring
is encountered. <span class="margin-note"><br><br><br>Both `t` and `T` will
reference `cv`. </span>

```
   cmpx '∆F t' 'T ⍬'
  ∆F t → 1.5E¯4 |   0% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
  T ⍬  → 1.1E¯5 | -93% ⎕⎕⎕
```

The precomputed version is <mark>much</mark> faster than the first use of `∆F t`. At the same
time it is only about *3 times faster* on average than a repeated use of `∆F t`.

Before we get to syntax and other information, we want to show you
that <span class="margin-note">The _dfn_ returned includes the original _f‑string_ text used to generate it,
available as `` `⍵0 ``.</span>
the _dfn_ returned when the _dfn_ option is set to `1` can retrieve one or more arguments passed on the right side of **∆F**, using the very same omega shortcut expressions (like `` `⍵1 ``) we've
discussed above.

Let's share the Centigrade values `cv` from our current example,
not as a _variable_, but as the _first argument_ to **∆F**.
We'll access the value as `` `⍵1 ``.

```
   cv←11 30 60
   t←'The temperature is {"I2" $ `⍵1}°C or {"F5.1" $ 32+9×`⍵1÷5}°F'
   T← 1 ∆F t       ⍝ Or  (dfn: 1)

   ∆F t cv
The temperature is 11°C or  51.8°F
                   30       86.0
                   60      140.0

   T ⊂cv
The temperature is 11°C or  51.8°F
                   30       86.0
                   60      140.0

   cmpx '∆F t cv' 'T ⊂cv'
  ∆F t cv → 1.8E¯4 |   0% ⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕⎕
  T ⊂cv   → 1.1E¯5 | -95% ⎕⎕⎕
```

The precomputed version again shows a <mark>substantial</mark> speedup over the default *uncached* version.

## Multiline _F-strings_ in Dyalog 20

Sometimes it's <span class="margin-note">Excuse the ob&shy;fusc&shy;atory sesqui&shy;pedal&shy;ianism!</span>programmatically pro&shy;pitious or pedagog&shy;ically per&shy;spicacious to construct, or display, an _f-string_ across
multiple lines in the **∆F** call. You can do this using _APL_ Array Notation, for example, dividing
the _f-string_ across multiple (parenthesized) character vectors, each on a separate line.<span class="margin-note"><br><br><br><br><br><br>Note that APL handles the comments in multi-line strings!</span>

```
   lastNm firstNm MI← 'Smith' 'Mary' 'J'
   street city state← '5108 Grover St.' 'Omaha' 'Nebraska'

   ∆F (                              ⍝ Copious explanatory comments!
     'Name: '
     '{lastNm}, '                    ⍝ The last name
     '{firstNm} {MI}. '              ⍝ The first name and middle initial
     'Address is: '
     '{street} in {city}, {state}.'  ⍝ US address.
  ) ⍬                                ⍝ ⍬ is a dummy argument
Name: Smith, Mary J. Address is: 5108 Grover St. in Omaha, Nebraska.
```

In any case, **∆F** treats a multiline _f-string_ as its single-line (`∊`) equivalent.
The above **∆F** call produces the very same output as this one:

```
   ∆F 'Name: {lastNm}, {firstNm} {MI}. Address is: {street} in {city}, {state}.'
```

<big>👉</big>&nbsp;To ensure multiple adjacent character vectors are interpreted as part of the
_f-string_ when there are no following arguments, consider:

- enclosing the vectors, as in `∆F ⊂(...)`, or
- placing any dummy argument (_e.g._ `⍬`) after the multiline _f-string_,
  as in the example above.

---

Below, we summarize key information you've already gleaned from the examples.

</details>
<div class="page-break"></div> 


# ∆F Reference 

<details>        <!-- option: open -->       
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Syntax Info</em> 
</summary> 
<a id="inside-reference" class="scroll-target"></a>

## ∆F Call Syntax Overview


<span class="margin-note"><br><br><br><br><br><br><br><br>See the example of [multiline _f-strings_ in Dy&shy;a&shy;log 20](#multiline-f-strings-in-dyalog-20).</span>
<span class="margin-note"><br><br><br><br><br>**_Options_** may be either _positional_
or&mdash; starting in Dyalog v. 20&mdash; _keyword_-based. We show the posi&shy;tion&shy;al forms through&shy;out the ex&shy;amples, but doc&shy;ument the key&shy;words as well below.</span>


<a id="table-call-syntax" class="scroll-target"></a>

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Call Syntax                                                                Description
-------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**∆F**&ensp;**_f‑string_**                                                 Display an _f‑string_; use the _default_ options. The string may reference objects in the environment or in the string itself. Returns a character matrix.
                                                                             <br><strong><span class="red"><strong>Single or </strong></span>[<span class="red"><strong>multi&shy;line f-string:</strong></span>](#multiline-f-strings-in-dyalog-20)</strong> An **_f-string_** must be a character vector of any length or a [vector of character vectors](#multiline-f-strings-in-dyalog-20). If the latter, it will be converted (via _enlist,_ `∊`) to one, longer character vector, without any added spaces, newlines, etc.

**∆F**&ensp;**_f‑string_**&ensp;**_args_**                                 Display an _f‑string_ (see above); use the _default_ options. Arguments presented _may_ be referred to in the f‑string. Returns a character matrix.

**_options_**&ensp;**∆F**&ensp;**_f‑string_**&ensp;[***args***]            Display an _f‑string_ (see above); control the result with _options_ specified (see below).<br><span class="red"><strong>If **_dfn_** (see below) is ***0*** or omitted,</strong></span> returns a character matrix.<br><span class="red"><strong>If **_dfn_** is ***1***,</strong></span> returns a dfn that will display such a matrix (given an identical system state).

'help'&ensp;**∆F**&ensp;' '&ensp;_or_&ensp;**∆F**⍨'help'                    Display help info and examples for **∆F**. The _f‑string_ is not examined. <big>👉</big>&nbsp;See below for details and related examples.

***Return value***                                                         See below.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Table: 5a. <strong>∆F Call Syntax Overview</strong>

## ∆F Option Details

<a id="inside-option-details" class="scroll-target"></a>

|   <br>Mode   | Positional<br>Option<br><small>[*index*]</small> | Keyword<br>Option<br><small>(_kw: def_)<div style="width:90px"></small>          | <br>Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| :----------: | :----------------------------------------------: | :------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   **dfn**    |                       **_[0]_**                  |                                **_dfn:&nbsp;0_**                                 | <span class="red"><strong>If **_dfn:&nbsp;1_**,</strong></span> **∆F** returns a dfn, which (upon execution) produces the same output as the default mode.<br><span class="red"><strong>If **_dfn:&nbsp;0_** (default),</strong></span> **∆F** returns a char. matrix.                                                                                                                                                                                                                                                                                                                                                                                                   |
| **verbose**  |                       **_[1]_**                  |                              **_verbose:&nbsp;0_**                               | <span class="red"><strong>If **_verbose:&nbsp;1_**,</strong></span> Renders newline characters from `` `◇ `` as the visible `␤` character. Displays the source code that the _f‑string_ **_actually_** generates; <span class="red"><strong>if&nbsp;**_dfn_** is also ***1***,</strong></span> this will include the embedded _f‑string_ source (accessed as `` `⍵0 ``). After the source code is displayed, it will be executed or converted to a _dfn_ and returned (see the **_dfn_** option above).<br><span class="red"><strong>If **_verbose:&nbsp;0_** (default),</strong></span> newline characters from `` `◇ `` are rendered normally as carriage returns, `⎕UCS 13`; the **_dfn_** source code is not displayed. |
|   **box**    |                       **_[2]_**                  |                                **_box:&nbsp;0_**                                 | <span class="red"><strong>If **_box:&nbsp;1_**,</strong></span> each field (except a null **Text** field) is boxed separately.<br><span class="red"><strong>If **_box:&nbsp;0_** (default),</strong></span> nothing is boxed automatically. Any **Code** field expression may be explicitly boxed using the **Box** shortcut, `` `B ``.<br><big>👉</big>&nbsp;**_Box_** mode can be used with settings <strong>`dfn: 1`</strong> _and_ <strong>`dfn: 0`.</strong>                                                                                                                                                                                                                    |
|   **auto**   |                       **_[3]_**                  |                                **_auto:&nbsp;1_**                                | <span class="red"><strong>If **_auto:&nbsp;0_**,</strong></span> user must manually load/create any Session Library objects for use with the £ or `` `L `` shortcuts.<br><span class="red"><strong>If **_auto:&nbsp;1_** (default),</strong></span> honors the default and user-defined settings for `auto`.<br><big>👉</big>&nbsp;Depends on (i) user parameter file **./.∆F** and (ii) the namespace **FString** created during the `]load` process.                                                                                                                                                                                                                                 |
|  **inline**  |                       **_[4]_**                  |                               **_inline:&nbsp;0_**                               | <span class="red"><strong>If **_inline:&nbsp;1_**,</strong></span> the code for each internal support function used is included in the result. <span class="red"><strong>If ***dfn*** is also 1,</strong></span> **_no_** reference to namespace **FString** will be made during the execution of the generated _dfn_. (**_Exception:_** see _Session Library Shortcuts_ below.)<br><span class="red"><strong>If **_inline:&nbsp;0_** (default),</strong></span> whenever **∆F** or a _dfn_ generated by it is executed, it makes calls to library routines in the namespace **FString**, created during the `]load` process for **∆F**.<br><big>👉</big>&nbsp;This option is experimental and may simply disappear one day.            |
|  **cache**   |                     **_[5]_**                    |                               **_cache:&nbsp;1_**                                | <span class="red"><strong>If ***cache:&nbsp;1***, </strong>(the default)</span> will look for a prior call to **∆F** with this ***fstring*** and these ***options*** and use the ***code*** generated previously. *Very fast!* <br><span class="red">If <strong>***cache: 0***, </strong></span> generates the required code on each call. <br> <big>👉</big>&nbsp;Useful for benchmarking, etc.|
| **special**  |                   **_'help'_**                   |                                     &mdash;                                      | <span class="red"><strong>If ***'help'*** is specified,</strong></span> this amazing doc&shy;ument&shy;ation is displayed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **special**  |                  **_'parms'_**                   |                                     &mdash;                                      | <span class="red"><strong>If ***'parms'*** is specified,</strong></span> updates and displays Session Library (`£` or `` `L ``) pa&shy;ram&shy;eters.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
Table: 5b. <strong>∆F Option Details</strong>

- **Default options:** If the left argument `⍺` is omitted, the options default as shown here.

<a id="table-default-options" class="scroll-target"></a>

  ------------------------------------------------------------------------------------------ 
      Option Style              Defaults
  ------------------ ----------------------------------------------------------------------- 
    **Positional**     ` 0         0         0         1         0         1`

    **Keyword**       `(dfn: 0 ◇ verbose: 0 ◇ box: 0 ◇ auto: 1 ◇ inline: 0 ◇ cache: 1)`
  ------------------------------------------------------------------------------------------ 
  Table: 5c. <strong>∆F Default Options</strong>
 

- **Positional-style options:** If **∆F**'s left argument `⍺` is a simple integer vector (or a scalar), omitted (trailing) elements are replaced by the corresponding elements of the default, `0 0 0 1 0 1`.<br><big>👉</big>&nbsp;Extra elements will trigger a ***DOMAIN ERROR.***
- **Keyword-style options:** If the left argument is a <span class="margin-note">Dyalog 20 and later. See docu&shy;ment&shy;ation on _APL_ Ar&shy;ray Not&shy;ation.</span>namespace,
  it is assumed to contain option names (in any order) with their non-default values,<br>&emsp;&emsp;e.g. `(verbose: 1 ◇ auto: 0)`;  
   Keyword options are new for Dyalog 20. They are sometimes clearer and more convenient than positional keywords.
- **Help option:** If the left argument `⍺` starts with `'help'` (case ignored), this help information is displayed. In this case, the right argument to **∆F** is ignored.
- **Parms option:** If the left argument `⍺` matches `'parms'` (case ignored), the Session Library parameters are (re-)loaded and displayed. In this case, the right argument to **∆F** is ignored.
- Otherwise, an error is signaled.

## ∆F Return Value

- Unless the **_dfn_** option is selected, **∆F** always returns a character matrix of at least one row and zero columns, `1 0⍴0`, on success. If the 'help' option is specified, **∆F** displays this information, returning `1 0⍴0`. If the 'parms' option is specified, **∆F** shows the Session Library parameters as a character matrix.
- If the **_dfn_** option is selected, **∆F** always returns a standard Dyalog dfn on success.
- On failure of any sort, an informative _APL_ error is signaled.

## ∆F F‑string Building Blocks

The first element in the right arg to ∆F is a character vector, an _f‑string_,
which contains one or more **Text** fields, **Code** fields, and **Space** fields in any combination.

- **Text** fields consist of simple text, which may include any Unicode characters desired, including newlines.
  - Newlines (actually, carriage returns, `⎕UCS 13`) are normally entered via the sequence `` `◇ ``.
  - Additionally, literal curly braces can be added via `` `{ `` and `` `} ``, so they are distinct from the simple curly braces used to begin and end **Code** fields and **Space** fields.
  - Finally, to enter a single backtick `` ` `` just before the special
    symbols `{`, `}`, `◇`, or `` ` ``, enter **_two_** backticks ` `` `; if preceding any ordinary
    symbol, a **_single_** backtick will suffice.
  - If **∆F** is called with an empty string, `∆F ''`, it is interpreted as containing a single 0-length **Text** field, returning a matrix of shape `1 0`.
- **Code** fields are run-time evaluated expressions enclosed within
  simple, unescaped curly braces <code>{&nbsp;}</code>, _i.e._ those not preceded by a backtick (see the previous paragraph).
  - **Code** fields are, under the covers, Dyalog _dfns_ with some extras.
  - For escape sequences, see **Escape Sequences** below.
- **Space** fields appear to be a special, _degenerate_, form of **Code** fields, consisting of a single pair of simple (unescaped) curly braces `{}` with zero or more spaces in between.
  - A **Space** field with zero spaces is a **_null_** **Space** field; while it may separate any other fields, its typical use is to separate two adjacent **Text** fields.
  - Between fields, **∆F** adds no automatic spaces; that spacing is under user control.

## Code Field Shortcuts

**∆F** **Code** fields may contain various shortcuts, intended to be concise and expressive tools for common tasks. **Shortcuts** are valid in **Code** fields only _outside_ **Quoted strings**.

**Shortcuts** include:

<a id="table-shortcuts" class="scroll-target"></a>

| Shortcut |               Name       | Syntax | Meaning   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| :-------------------- | :------------------------------: | :------------------:| :------------------------------------------------------------------------------------------------- |
| **\`A**, **%**                         |                              Above                               | `[⍺] % ⍵`| Centers array `⍺` above array `⍵`.<br>If omitted, `⍺←''`, _i.e._ a blank line.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **\`B**                                |                               Box                                | `` `B ⍵ ``| Places `⍵` in a box. `⍵` is any array.  <big>👉</big>In contrast with Dyalog `]box` mode, even simple scalars and vectors are boxed here.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **\`C**                                |                              Commas                              | `` [⍺]`C ⍵  ``| By default, adds commas after every 3rd digit (from the right) of the _integer_ part of each number in `⍵` (leaving the fractional part as is). `⍵` is zero or more num strings and/or numbers. The options ``⍺`` consists of up to two scalars, one number ``n`` (if not 3) for every n digits from right to left, and one character (even "\`◇") to insert (if not a comma). <br><small>Examples: "5\_" or "\_5" adds an underscore every 5 digits from the right. "3\`◇" puts each set of 3 digits on its own line. "_" places underscores between every 3 digits from the right.<br>Note: Tolerates chars mixed in with digits, but only formats numbers to the left of an optional decimal point.</small>                                                                                                                                                                                                                                                                                   |
| **\`D**                                |                            Date-Time                             | `` [⍺]`D ⍵ ``|Synonym for **\`T**.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| **\`F**, **$**                         |                               ⎕FMT                               | `[⍺] $ ⍵`| Short for `[⍺] ⎕FMT ⍵`. (See _APL_ doc&shy;ument&shy;ation).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **\`J**                                |                             Justify                              | `` [⍺]`J ⍵ ``| Justify each row of object `⍵` as text:<br>&emsp;&emsp;_left_: ⍺="L"; _center_: ⍺="C"; _right_ ⍺="R".<br>You may use `¯1`\|`0`\|`1` in place of `"L"`\|`"C"`\|`"R"`. If omitted, `⍺←'L'`. <small>_Displays numbers with the maximum precision available._</small>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **\`L**, **£**                         | Session Library                                                  | `£.nm`<br><code>£.nm<span class="grey"><strong>.nm2</strong></span></code>| `£` denotes a private library (namespace) local to the **∆F** runtime environ&shy;ment into which functions or objects (including name&shy;spaces) may be placed (e.g. via `⎕CY`) for the duration of the _APL_ session.<br>**Autoload:** Outside of simple assignments, **∆F** will attempt to copy an undefined object named `nm` in the expression `£.nm`, <code>£.nm<span class="grey"><strong>.nm2</strong></span></code>, *etc.*, from, _in order:_<br>&emsp;<small><small><span class="blue"><strong>DIRECTORY:</strong></span></small></small>&thinsp;**./MyDyalogLib/** &nbsp;\>&nbsp; <small><small><span class="blue"><strong>_APL_ WS:</strong></span></small></small>&thinsp;**dfns** &nbsp;\>&nbsp;<small><small><span class="blue"><strong>DIRECTORY:</strong></span></small></small>&thinsp;**./**<br><small>Other `£` expressions like `£.(hex dec)` are valid, but no autoload takes place.<br>_For filetypes and customisation, see [Session Library Shortcut: Details](#session-library-shortcut-details) below._</small> |
| **\`Q**                                |                              Quote                               | `` [⍺]`Q ⍵ ``| Recursively scans `⍵`, putting char. vectors, scalars, and rows of higher-dimensional strings in APL quotes, leaving other elements as is. If omitted, `⍺←''''`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **\`S**                                |                            Serialise                             | `` [⍺]`S ⍵ ``| Serialise an _APL_ array (via ⎕SE.Dyalog.Array.Serialise), i.e. show in _APL_ Array Notation (APLAN), either (`⍺=0`, the default) in _tabular_ (multiline) form or (`⍺=1`) compactly with statement separators `◇` in place of newlines. If omitted, `⍺←0`. <small>_See details below._</small>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **\`T**                                |                            Date-Time                             | `` [⍺]`T ⍵ ``| Displays timestamp(s) `⍵` according to date-time template `⍺`. `⍵` is one or more APL timestamps `⎕TS`. `⍺` is a date-time template in `1200⌶` format. If omitted, `⍺← '%ISO%'`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **\`W**                                |        Wrap                                                      | `` [⍺]`W ⍵ ``| Wraps the rows of simple arrays in ⍵ in decorators `0⊃2⍴⍺` (on the left) and `1⊃2⍴⍺` (on the right). If omitted, `⍺←''''`. <small>_See details below._</small>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| **\`⍵𝑑𝑑**, **⍹𝑑𝑑**                     |           Omega Shortcut<br>(<small>EXPLICIT</small>)            | &mdash;|A shortcut of the form `` `⍵𝑑𝑑 `` (or `⍹𝑑𝑑`), to access the `𝑑𝑑`**th** element of `⍵`, _i.e._ `(⍵⊃⍨ 𝑑𝑑+⎕IO)`. <small>_See details below._</small>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| **\`⍵**, **⍹**                         |           Omega Shortcut<br>(<small>IMPLICIT</small>)            |  &mdash;|A shortcut of the form `` `⍵ `` (or `⍹`), to access the **_next_** element of `⍵`. <small>_See details below._ <small>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| **→**<br>**↓** _or_ **%**              |     Self-documenting **Code** Fields <small>(SDCFs)</small>      | &mdash; |`→` at end of **Code** field signals that the source code for the field appears _to the left of_ its value. Surrounding blanks are significant.<br>`↓` (_or,_ `%`) at end of **Code** field signals that the source code for the field appears _above_ its value. Surrounding blanks are significant.<br><small>_See [SDCFs](#self-documenting-code-fields-sdcfs) in **Examples** for details._</small>                                                                                                                                                                                                                                                                                                                                                                                                             |
Table: 5d. <strong>Code Field Shortcuts</strong>

<br>

## Escape Sequences: Text Fields & Quoted Strings

<span class="margin-note">See [Quoted Strings in Code Fields](#quoted-strings-in-code-fields)
below on displaying quote characters like `"` in a string.
</span>
**∆F** **Text** fields and **Quoted strings** in **Code** fields may include
a small number of escape sequences, beginning with the backtick `` ` ``.
Some sequences are valid in **Text** fields _only_, but not in Quoted strings:

<span class="margin-note"><br><br><br><br><br>**Quoted Strings** appear ***only*** in **Code** fields.
</span>

<a id="table-escapes" class="scroll-target"></a>

--------------------------------------------------------------------
  Escape      What It         <br>          <br>           
Sequence    <br>Inserts   Description       Where
---------- ------------ -------------- -------------------------------- 
 **\`◇**     _new            ⎕UCS 13    Text fields and Quoted Strings
            line_ 

 **\`\`**     \`           backtick     Text fields and Quoted Strings

 **\`{**      {           left brace    Text fields only

 **\`}**      }           right brace   Text fields only
----------------------------------------------------------
Table: 5e. <strong>Escape Sequences</strong>

Other instances of the backtick character in **Text** fields or **Quoted strings** in **Code** fields will be <span class="margin-note">Sometimes a backtick is just a back&shy;tick.</span>
treated literally.


## Quoted Strings in Code Fields

As mentioned in the introduction, **Quoted strings** in **Code** fields allow several delimiting quote styles:

- **double-quotes**<br>
  `∆F '{"like «this» one"}'` or `∆F '{"like ''this'' one."}'`,
- **double angle quotation marks**,<br>
  `∆F '{«like "this" or ''this''.»}'`,  
  as well as
- _APL_'s tried-and-true embedded **single-quotes**,<br>
  `∆F '{''shown like ''''this'''', "this" or «this».''}'`.

<span class="margin-note">Compare these examples:<br>&emsp;**Invalid:**&ensp;<span class="red"><strong>∆F&ensp;'{"abc\`"def"}'</strong></span><br>&emsp;**Valid:**&ensp;`∆F '{"abc""def"}'`
</span>
If you wish to include a traditional delimiting quote (`'` or `"`) or the closing quote of a quote pair (`«`&ensp;`»`) within the **Quoted string**, you must double it.
You may _not_ use an escape sequence (e.g. `` `" ``) for this purpose.

<a id="table-quote-characters" class="scroll-target"></a>


------------------------------------------------------------------------
 Quote(s)      Example                              Result
---------- -------------------------------------- -------------------------
   `"`        `∆F                                    `like "this" example`
            '{"like ""this"" example"}'`  

   `'`        `∆F                                    `like 'this' example`
            '{''like ''''this'''' example''}'`

   `« »`      `∆F                                    `or «this» one`
            '{«or «this»» one»}'`   
-------------------------------------------------------------------------
Table: 5f. <strong>Doubling Quote Character in Quoted String</strong>

Note that the opening quote `«` is treated as an ordinary character within the string. The clumsiness of the standard single quote `'` examples is due to the fact that the single quote is the required delimiter for the outermost (_APL_-level) string.

## Omega Shortcut Expressions: Details

3.  All **Omega** shortcut expressions in the _f‑string_ are evaluated left to right and are ⎕IO-independent.
1.  **⍹** is a synonym for **\`⍵**. It is Unicode character `⎕UCS 9081`. Either glyph has a special meaning *only* within **Code** fields and outside **Quoted strings**.
4.  **\`⍵𝑑𝑑** or **⍹𝑑𝑑** is equivalent to the expression `(⍵⊃⍨dd+⎕IO)`. Here **𝑑𝑑** must be a _non-negative integer_ with at least 1 digit.
5.  **\`⍵** or **⍹** (with ***no*** digits appended) is equivalent to `(⍵⊃⍨1+ii+⎕IO)`, where *ii* is the index of the most recent
**Omega** expression (of either type) to its left in the *f-string*;if there is no such expression, *ii* is `1`.
6.  The _f‑string_ itself (the 0-th element of **⍵**) is always accessed as `` `⍵0 `` or `⍹0`. It may only be accessed *explicitly.*
7.  If an element of the dfn's right argument **⍵** is accessed at runtime via any means, shortcut or traditional, that element **_must_** exist.

## **Serialise** Shortcut Expressions: Details

Serialise ( `` `S ``) uses Dyalog _APL_'s Array Notation (APLAN)<span class="margin-note">**APLAN**: _⎕SE.Dyalog.Array.Serialise_.</span> to display the object to its right. It is intended to have roughly the same behaviour as displaying an object
with `]APLAN.output on`. (See Dyalog documentation for details).

1.  Serialise displays objects of classes 2 and 9&mdash; data arrays and namespaces&mdash; in Array Notation, as long as they contain **_no_** functions or operators. 
1.  If `⍵` _includes_ a function or operator,`` `S `` will display `⍵` _unformatted_, rather than in APLAN format.

<div>

## Wrap Shortcut: Details

1. Syntax: `` [⍺←''''] `W ⍵ ``.
2. Let `L←0⊃2⍴⍺` and `R←1⊃2⍴⍺`.
3. Wrap each row `X′` of the simple arrays `X` in `⍵` (or the entire array `X` if a simple vector or scalar) in decorators `L` and `R`: `L,(⍕X′),R`.
4. `⍵` is an array of any shape and depth.`L`and `R`are char. vectors or scalars or `⍬` (treated as `''`).
5. If there is one scalar or enclosed vector `⍺`, it is replicated _per (2) above_.
6. By default,`⍺← ''''`,_i.e._ _APL_ quotes will wrap the array ⍵, row by row, whether character, numeric or otherwise.

## Session Library Shortcut: Details

1. If <span class="margin-note">The search **path** depends on settings. Here, we assume the default `auto` option and `]load`-time par&shy;a&shy;meters. See [Lib&shy;rary Parameters](#session-library-shortcut-parameters) and [File&shy;types of Lib&shy;rary Source Files](#session-library-shortcut-filetypes-of-source-files) below.</span>
   an object `£.name` is referenced, but not yet defined in `£`, an attempt is made&mdash; during **∆F**'s left-to-right _scanning_ phase&mdash; to copy it to `£` from (in order) directory **./MyDyalogLib**, workspace **dfns**, and the current directory **./**,
   _unless_ it is being assigned (via a simple `←`) or has <span class="margin-note">Once a name is seen, no attempt will be made to load it.</span>already been seen in this **∆F** call. It will be available for the duration of the *APL* session.

1. If a name is a *qualified* name, i.e. if it is of the form `£.nm1.nm2`, `£.nm1.nm2.nm3`, etc., 
then **∆F** attempts to load the name ***nm1***, presumed to be a namespace (or a 
function returning a namespace). If a namespace, the *entire* namespace is loaded, not just the object
specified.

1. While objects of the form `£.name` will be automatically retrieved (if not defined), names in other `£` expressions, like 
   `£.(name1 name2)` or `£.⎕NC "name3"`, will be ignored during the scanning phase;

1. In the case of a simple assignment (`£.name←val`), the object assigned must be new or
   of an _APL_ class compatible with its existing value, else a domain error will be signaled.
   Even if seen later in the scan, the object will be assumed to have been set by the user.

1. Simple modified assignments of the form `£.name+←val` are allowed: the object `name` will be retrieved (if not present)
   before modification.

### Session Library Shortcut: Filetypes of Source Files

<span class="margin-note"><br><br><br><br><br><br><br><br><br><br><br>**apla:** Encoded using _APL_ Array Notation (Dyalog 20).<br><br><br>**txt:** Each line of file is converted to a Unicode char. vector.</span>

<a id="table-library-filetypes" class="scroll-target"></a>

|  <br>Filetype               |               <br>Action                | _APL_ Class ⎕NC | Key APL<br>Service | Available<br>by Default? |         Type <br>Enforced?          |
| :-------------------------: | :-------------------------------------: | :-------------------------: | :----------------: | :----------------------: | :------------------------------: |
|     .aplf                   |             Fixes function              |        3        |        ⎕FIX        |            ✔             |       ✔<small> FUTURE</small>       |
|     .aplo                   |             Fixes operator              |        4        |        ⎕FIX        |            ✔             |       ✔<small> FUTURE</small>       |
|     .apln                   |             Fixes ns script             |        9        |        ⎕FIX        |            ✔             |       ✔<small> FUTURE</small>       |
|     .apla                   | Assigns array or ns<br>(array notation) |      2, 9       |    _assignment_    |            ✔             |                  ✔                  |
|     .json                   |           Fixes ns from JSON5           |        9        |       ⎕JSON        |            ✔             |                  ✔                  |
|      .txt                   |          Assigns a char. vector         |        2        |    _assignment_    |            ✔             |                  ✔                  |
|      .aplv                  |          Assigns a char. vector         |        2        |    _assignment_    |            ✔             |                  ✔                  |
|      .aplvv                 |    Assigns char. vector of vectors      |        2        |    _assignment_    |            ✔             |                  ✔                  |
|      .aplm                  |          Assigns char. matrix           |        2        |    _assignment_    |            ✔             |                  ✔                  |
|   .dyalog                   |              Fixes object               |     3, 4, 9     |        ⎕FIX        |            ✔             | <span class="red"><strong>✘<small> NEVER</small></strong></span> |
| user-specified              |              Fixes object               |     3, 4, 9     |        ⎕FIX        |      <span class="red"><strong>✘</strong></span>      | <span class="red"><strong>✘<small> NEVER</small></strong></span> |

Table: 5g. <strong>Library Filetypes: Meaning</strong>

### Session Library Shortcut: Parameters

The <span class="margin-note">If the automatic search feature is enabled&mdash; the default&mdash;, the _first_ time each name is used there is the potential for substantial overhead in searching for, loading, and fixing it
in the session library.</span>
Session Library shortcut (`£` or `` `L ``) is deceptively simple, but
the code to support it is a tad complex.
The complex components run only when **∆F** is loaded. If the **auto** parameter is `1`, there is a modest
performance impact at runtime.
If `0`, the runtime impact of the feature is more modest still.

To support the Session Library auto-load process, there are parameters that may _optionally_ be tailored:

- **LIB_ACTIVE**: A global variable set in FString.dyalog.
  - 2: Load default and user parameters (default);
  - 1: Load default parameters ONLY;
  - 0: No autoload features should be available.

In addition, there are user parameters settable in the file **.∆F** in the user's home directory:

- **auto:** allowing **∆F** to automatically load undefined objects of the form `£.obj` or `` `L.obj `` into the Session Library from
  workspaces or files on the search path;
- **verbose:** providing limited information on parameters, object loading, _etc._;
- **path:** listing what directories to search for the object definitions;
- **prefix:** literal character vectors to prefix to each file name during the object search;
- **suffix:** <span class="margin-note">More details appear below.<br>Don't forget the '.' prefix!</span>filetypes that indicate the types of objects in our "library," along with any expected conversions.

The built-in _(default)_ parameter file <span class="margin-note">Additional doc&shy;ument&shy;ation
is need&shy;ed, should this go forward.</span>
is documented _below_.

<details><summary class="summary">&ensp;<em><span style="opacity:0.6;">Show/Hide</span> Default £ibrary Parameter File</em> <big><strong>. ∆F</strong></big></summary>

<a id="table-library-parameters" class="scroll-target"></a>

```skip
(
  ⍝ Default (Internal) Library Parameter File  (in APL Array Notation) 
  ⍝ Default file:           ∆F/∆FParmDefs.apla
  ⍝ User parameter file:   ./.∆F (no filetype)  
  ⍝ Global settings that impact the two parameter files:
  ⍝    LIB_ACTIVE, VERBOSE 
  ⍝ LIB_ACTIVE: 
  ⍝           Setting  Do we want to use the SESSION LIBRARY autoload feature?
  ⍝ LIB_ACTIVE:  2     Yes. Load default and user parameters
  ⍝              1     Yes. Load default parameters ONLY.
  ⍝              0     No.  No autoload features should be available.
  ⍝ VERBOSE: Compile-time and run-time verbosity flag
  ⍝                
  ⍝ Items not to be (re)set by user may be omitted in user .∆F file.           
  ⍝ If (verbose: ⎕NULL), then VERBOSE [note 1] is used for verbose.
  ⍝ If (prefix: ⎕NULL) or (prefix: ⍬), then (prefix: '' ◇)     
  ⍝ [note 1] 
   
  ⍝ Parameter auto:
  ⍝   0: user must load own objects; nothing is automatic.                
  ⍝   1: dfns and files (if any) searched in sequence set by dfnsOrder.
  ⍝      See path for directory search sequence. 
  ⍝ If the user sets (auto: 0) as a ∆F option, then objects already loaded will
  ⍝ be found and used normally, but no new objects will be autoloaded. New objects
  ⍝ may be created explicitly (e.g. via 'obj' ⎕CY 'ws' or £.obj←val), as expected.
  ⍝ Note: If (load: 0) or if there are no files or workspaces in the search path,
  ⍝       auto is set to 0, since no objects will ever be found.                    
    auto: 1
      
  ⍝ verbose: 
  ⍝    If 0 (quiet), 
  ⍝    If 1 (verbose).  
  ⍝    If ⎕NULL, value is set from VERBOSE (see above).
    verbose: ⎕NULL  
                                                          
  ⍝ path: The file dirs and/or workspaces to search IN ORDER left to right:
  ⍝    e.g. path: [ 'fd1', 'fd2', ['ws1', 'wsdir/ws2'], 'fd3', ['ws3']]
  ⍝    For a file directory, the item must be a simple char vector
  ⍝        'MyDyalogLib'
  ⍝    For workspaces, the item must be a vector of one or more char vectors
  ⍝        (⊂'dfns') or (⊂'MyDyalogLib/mathfns') or ('dfns', 'myDfns')
  ⍝  To indicate we don't want to search ANY files, 
  ⍝     best: (load: 0)
  ⍝     ok:   (path: ⎕NULL)
  ⍝           directory      workspace    directory
    path:  ( 'MyDyalogLib' ◇ ('dfns'◇)  ◇  '.'     ◇ )  
                  
  ⍝ prefix: literal string to prefix to each name, when searching directories.
  ⍝     Ignored for workspaces.
  ⍝     Default is ⍬ or (equivalently) ''
  ⍝     Example given name 'mydfn' and (prefix: '∆F_' 'MyLib/' ◇ suffix: ⊂'.aplf')  
  ⍝     ==> ('∆F_mydfn.aplf'  'MyLib/mydfn.aplf')   
    prefix: ⍬ 
                              
  ⍝ suffix: at least one suffix is required for files to be checked.
  ⍝ ∘  Note: Don't forget the '.'.
  ⍝ ∘  Suffixes don't apply to workspaces. See documentation for definitions.
  ⍝ ∘  By default, unknown filetypes are not enabled. 
  ⍝    If they are enabled, they work the same as 'dyalog'.
  ⍝ ∘  If possible, place most used suffixes first.
    suffix: ('.aplf' ◇ '.apla' ◇ '.aplo' ◇ '.apln' ◇ '.json'◇ '.txt' ◇'.dyalog')    
                  
  ⍝  Internal Runtime (hidden) Parameters (not shown). Do not modify or delete. 
  ⍝     ⍙readParms,⍙fullPath                                          
)    
```

</details>

---

</div> 
</details> 
<div class="page-break"></div> 

# Appendices

<details><summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Appendices</em></summary>
<a id="inside-appendices" class="scroll-target"></a>

## Appendix I: Un(der)documented Features

### ∆F Option for Dfn Source Code

If the [**_dfn_** option](#f-option-details) is `¯1`, _equivalently_ `(dfn: ¯1)`<span class="margin-note">In simple terms, this option returns the character representation of the
_dfn_ returned via the **_dfn_** option.
</span>, then **∆F** returns a character vector that contains the source code for the _dfn_ returned via `(dfn: 1)`.
If **_verbose_** is also set, newlines from `` `◇ `` are shown as visible `␤`. However, since this option _returns_ the code string, the **_verbose_** option won't also _display_ the code string.

### Future Behaviours

There are three future behaviours of APL primitives optionally supported by **∆F**: an extension to
circle diaeresis (⍥), the right shoe underscore (⊇), and the ellipsis (…). Each is available
if included in the value of <span class="margin-note">See below</span>load-time parameter, `FUTURES`. By default,
`FUTURES← '⍥⊇…'`.

#### Future Behaviour of ⍥ (Circle Diaeresis) Here Today

As a load-time option, **∆F** adds <span class="margin-note">See **abrudz
dyalog-apl-extended /CircleDiaeresis.dyalog** on Github [retrieved 2026-02-13].</span>
Adám Brudzewsky's **Depth operator** 
extension to circle diaeresis (⍥), which works similarly to rank (⍤), but selects
array components based on depth rather than rank.  If the value of the load-time 
parameter <span class="margin-note">See `FUTURES` global variable in ∆F/FString.dyalog.</span> `FUTURES` includes `'⍥'`,
then this fun *future* feature will be 
recognized within code fields, without impacting other capabilities of `⍥`. 
For more information, see <a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https:\/\/aplwiki.com\/wiki\/Depth_(operator)</span></a>.

#### Future Behaviour of ⊇ (Select / Sane Indexing) Here Today

As a load-time option, **∆F** adds the "future" **Select** function (also known as **Sane indexing**)
if the value of the load-time 
parameter <span class="margin-note">See `FUTURES` global variable in ∆F/FString.dyalog.</span> `FUTURES` includes `'⍥'`.
For more information, see <a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https:\/\/aplwiki.com\/wiki\/From</span></a>.

#### Future Behaviour of … (Ellipsis ["range" function]) Here Today

As a load-time option, **∆F** adds the "future" **Ellipsis** function, which is a "range" function 
similar <span class="margin-note">See **abrudz**
dyalog-apl-extended  on Github [retrieved 2026-02-13].</span>
to function **to** in the *dfns* workspace, extended to handle characters
as well as integers (see discussion
at https://dfns.dyalog.com/n_to.htm).  E.g. `'a' … 'j'` is the same as 'abcdefghij', just 
as `1 … 10` is the same as `1 2 3 4 5 6 7 8 9 10'.  This is similar to Python's range() function.

### ∆F Help's Secret Variant

`∆F⍨'help'` has a secret variant: <span class="margin-note">_synonym:_ `∆F⍨'help-n'`.</span>`∆F⍨'help-narrow'`.
With this variant, the help
session will start up in a narrower window _without_ side notes. If the user widens the
window, the side notes will appear, as in the default
case: <span class="margin-note">_synonym:_ `∆F⍨'help-wide'`.</span>`∆F⍨'help'`.

### ∆F's Library Parameter Option: 'parms'

Normally, ∆F £ibrary parameters are established when **∆F** and associated libraries
are loaded (_e.g._ via `]load ∆F -t=⎕SE`). After editing the parameter file **./.∆F,** you may wish to update the active parameters, while maintaining existing user £ibrary session objects, which would otherwise be lost during a `]load` operation. For such an update, use **∆F**'s `'parms'` option.

`∆F⍨ 'parms'` reads the user parameter file **./.∆F,**
updates the _£ibrary_ parameters, returning them in alphabetical order along with their values as a single character matrix. No current session objects are affected.

### ∆F's Library Parameter Option: 'globals'

**∆F** has a number of load-time parameters (global variables) that set its runtime behaviour for 
all users. You can view these parameters using the call: `∆F⍨ 'globals'`.  The parameters
include:
```skip

  TRAP_ERRORS      VERBOSE_RUNTIME      VERBOSE_LOADTIME  SIGNAL_LIB_ERRS
  ESCAPE_CHAR      QUOTES_SUPPLEMENTAL  INLINE_DEF        HELP_HTML_FI   
  LIB_ACTIVE       LIB_PARM_FI          LIB_USER_FI       LIB_SRC_FI
  OPTS_KW          OPTS_DEFval          OPTS_N
  VERBOSE_RUNTIME  VERSION              FUTURES
```

The meaning of each parameter and appropriate values are currently documented solely within the **∆F** code itself.

## Appendix II: Python f‑strings

For more information on Python f-strings, _see_:

&emsp;<a id="displayText" href="javascript:linkAlert();"><span class="linkNote">https:\//docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals</span></a>.

</details>



# Index of Topics 

<details id="TOC">     <!-- option: open  Set id="TOC" here only. -->
<summary class="summary">&ensp;<span style="opacity:0.6;">Show/Hide</span> <em>Index</em></summary>

<a id="inside-index" class="scroll-target"></a>


<span class="margin-note"><big><big>&emsp;<strong>KEY</strong></big><br><strong><big><span class="red"><strong><big>■</big> Major topic</strong></span></big><br><span class="green"><strong><big>■</big> Topic in table or figure</strong></span><br><big>■</big> Regular entry</strong></big></span>

<div class="multi-column-text" style="font-size:85%;">
<!-- INDEX_BEGIN --><!-- Generated by ∆F_toc: 2025-12-31T14:15:45 -->
<a href="#the-above-shortcut"                            > <strong>\`A (above)</strong>&emsp;<big><span class="blue">4.12</span></big></a><br>
<a href="#the-above-shortcut"                            > <strong>Above shortcut</strong>&emsp;<big><span class="blue">4.12</span></big></a><br>
<a href="#inside-appendices"                             > <span class="red"><big><strong>Appendices</strong></big></span>&emsp;<big><span class="blue">6.</span></big></a><br>
<a href="#the-serialise-shortcut"                        > <strong>Array notation, serialise</strong>&emsp;<big><span class="blue">4.19</span></big></a><br>
<a href="#the-box-shortcut"                              > <strong>\`B (box)</strong>&emsp;<big><span class="blue">4.5</span></big></a><br>
<a href="#box-mode"                                      > <strong>Box option</strong>&emsp;<big><span class="blue">4.6</span></big></a><br>
<a href="#the-box-shortcut"                              > <strong>Box shortcut</strong>&emsp;<big><span class="blue">4.5</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               > <strong>\`C (numeric commas)</strong>&emsp;<big><span class="blue">4.10</span></big></a><br>
<a href="#table-call-syntax"                             > <span class="green"><strong>Call syntax</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5a.</span></big></a><br>
<a href="#table-escapes"                                 > <span class="green"><strong>Code field escape sequences</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5e.</span></big></a><br>
<a href="#code-field-shortcuts"                          > <span class="red"><big><strong>Code field shortcuts</strong></big></span>&emsp;<big><span class="blue">5.5</span></big></a><br>
<a href="#table-brief-shortcuts"                         > <span class="green"><strong>Code field shortcuts, brief</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 3d.</span></big></a><br>
<a href="#table-shortcuts"                               > <span class="green"><strong>Code field shortcuts, details</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5d.</span></big></a><br>
<a href="#code-fields"                                   > <strong>Code fields</strong>&emsp;<big><span class="blue">4.1</span></big></a><br>
<a href="#code-fields-continued"                         > <strong>Code fields (continued)</strong>&emsp;<big><span class="blue">4.4</span></big></a><br>
<a href="#quoted-strings-in-code-fields"                 > <strong>Code fields, quoted strings in</strong>&emsp;<big><span class="blue">5.7</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               > <strong>Commas shortcut, numeric</strong>&emsp;<big><span class="blue">4.10</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-ii"        > <strong>\`D (date)</strong>&emsp;<big><span class="blue">4.17</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-ii"        > <strong>Date shortcut (alias)</strong>&emsp;<big><span class="blue">4.17</span></big></a><br>
<a href="#table-default-options"                         > <span class="green"><strong>Default options</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5c.</span></big></a><br>
<a href="#precomputed-fstrings-with-the-dfn-option"      > <strong>Dfn option, precomputed F-strings</strong>&emsp;<big><span class="blue">4.22</span></big></a><br>
<a href="#table-quote-characters"                        > <span class="green"><strong>Doubling quote characters</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5f.</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>Escape omega, details</strong>&emsp;<big><span class="blue">5.8</span></big></a><br>
<a href="#table-escapes"                                 > <span class="green"><strong>Escape sequences</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5e.</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   > <strong>Escape sequences in quoted strings</strong>&emsp;<big><span class="blue">5.6</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   > <strong>Escape sequences in text fields</strong>&emsp;<big><span class="blue">5.6</span></big></a><br>
<a href="#inside-examples"                               > <span class="red"><big><strong>Examples</strong></big></span>&emsp;<big><span class="blue">4.</span></big></a><br>
<a href="#the-format-shortcut"                           > <strong>\`F (format)</strong>&emsp;<big><span class="blue">4.9</span></big></a><br>
<a href="#table-field-types"                             > <span class="green"><strong>Field types</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 2a.</span></big></a><br>
<a href="#table-library-parameters"                      > <span class="green"><strong>File, of library parameters (.∆F)</strong></span>&emsp;<big><span class="blue"><small><em>Fig.</em></small> 4.21</span></big></a><br>
<a href="#table-library-filetypes"                       > <span class="green"><strong>Filetypes, library: see \`L and £</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5g.</span></big></a><br>
<a href="#the-format-shortcut"                           > <strong>Format shortcut</strong>&emsp;<big><span class="blue">4.9</span></big></a><br>
<a href="#referencing-the-fstring-itself"                > <strong>F-string, referencing</strong>&emsp;<big><span class="blue">4.8</span></big></a><br>
<a href="#intro"                                         > <strong>F-strings, definition</strong>&emsp;<big><span class="blue">0.</span></big></a><br>
<a href="#appendix-ii-python-fstrings"                   > <strong>F-strings, Python</strong>&emsp;<big><span class="blue">6.2</span></big></a><br>
<a href="#table-call-syntax"                             > <span class="green"><strong>∆F Call Syntax</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5a.</span></big></a><br>
<a href="#f-call-syntax-overview"                        > <strong>∆F call syntax overview</strong>&emsp;<big><span class="blue">5.1</span></big></a><br>
<a href="#f-fstring-building-blocks"                     > <strong>∆F f-string building blocks</strong>&emsp;<big><span class="blue">5.4</span></big></a><br>
<a href="#f-installation"                                > <strong>∆F installation</strong>&emsp;<big><span class="blue">1.1</span></big></a><br>
<a href="#loading-and-running-f"                         > <strong>∆F loading and running</strong>&emsp;<big><span class="blue">1.2</span></big></a><br>
<a href="#f-option-details"                              > <strong>∆F option details</strong>&emsp;<big><span class="blue">5.2</span></big></a><br>
<a href="#inside-preparing"                              > <span class="red"><big><strong>∆F preparing to run</strong></big></span>&emsp;<big><span class="blue">1.</span></big></a><br>
<a href="#inside-reference"                              > <span class="red"><big><strong>∆F reference section</strong></big></span>&emsp;<big><span class="blue">5.</span></big></a><br>
<a href="#f-return-value"                                > <strong>∆F return values</strong>&emsp;<big><span class="blue">5.3</span></big></a><br>
<a href="#displaying-f-help-in-apl"                      > <strong>Help, displaying in Apl</strong>&emsp;<big><span class="blue">1.3</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>Horizontal SDCF (→)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#f-installation"                                > <strong>Installing ∆F</strong>&emsp;<big><span class="blue">1.1</span></big></a><br>
<a href="#text-justification-shortcut"                   > <strong>\`J (Justification)</strong>&emsp;<big><span class="blue">4.13</span></big></a><br>
<a href="#text-justification-shortcut"                   > <strong>Justification shortcut</strong>&emsp;<big><span class="blue">4.13</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>\`L (library)</strong>&emsp;<big><span class="blue">4.21</span></big></a><br>
<a href="#table-library-filetypes"                       > <span class="green"><strong>Library Filetypes: see \`L and £</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5g.</span></big></a><br>
<a href="#table-library-parameters"                      > <span class="green"><strong>Library parameters, file of (.∆F)</strong></span>&emsp;<big><span class="blue"><small><em>Fig.</em></small> 4.21</span></big></a><br>
<a href="#session-library-shortcut-details"              > <strong>Library shortcut, details</strong>&emsp;<big><span class="blue">5.11</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>Library shortcut, session</strong>&emsp;<big><span class="blue">4.21</span></big></a><br>
<a href="#loading-and-running-f"                         > <strong>Loading ∆F</strong>&emsp;<big><span class="blue">1.2</span></big></a><br>
<a href="#multiline-f-strings-in-dyalog-20"              > <strong>Multiline f-strings, Dyalog 20</strong>&emsp;<big><span class="blue">4.23</span></big></a><br>
<a href="#null-space-fields"                             > <strong>Null space fields</strong>&emsp;<big><span class="blue">4.3</span></big></a><br>
<a href="#the-shortcut-for-numeric-commas"               > <strong>Numeric commas shortcut</strong>&emsp;<big><span class="blue">4.10</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>Omega shortcut expressions, details</strong>&emsp;<big><span class="blue">5.8</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      > <strong>Omega shortcuts, explicit</strong>&emsp;<big><span class="blue">4.7</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>Omega shortcuts, implicit</strong>&emsp;<big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>Omega underscore (⍹), details</strong>&emsp;<big><span class="blue">5.8</span></big></a><br>
<a href="#table-option-details"                          > <span class="green"><strong>Option details</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5b.</span></big></a><br>
<a href="#table-default-options"                         > <span class="green"><strong>Options, default</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5c.</span></big></a><br>
<a href="#inside-overview"                               > <span class="red"><big><strong>Overview</strong></big></span>&emsp;<big><span class="blue">2.</span></big></a><br>
<a href="#precomputed-fstrings-with-the-dfn-option"      > <strong>Precomputed F‑strings</strong>&emsp;<big><span class="blue">4.22</span></big></a><br>
<a href="#inside-preparing"                              > <span class="red"><big><strong>Preparing to run ∆F</strong></big></span>&emsp;<big><span class="blue">1.</span></big></a><br>
<a href="#appendix-ii-python-fstrings"                   > <strong>Python f‑strings</strong>&emsp;<big><span class="blue">6.2</span></big></a><br>
<a href="#the-quote-shortcut"                            > <strong>\`Q (quote)</strong>&emsp;<big><span class="blue">4.18</span></big></a><br>
<a href="#inside-quick-start"                            > <span class="red"><big><strong>Quick start</strong></big></span>&emsp;<big><span class="blue">3.</span></big></a><br>
<a href="#table-quote-characters"                        > <span class="green"><strong>Quote characters, doubling</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5f.</span></big></a><br>
<a href="#the-quote-shortcut"                            > <strong>Quote shortcut</strong>&emsp;<big><span class="blue">4.18</span></big></a><br>
<a href="#table-quote-characters"                        > <span class="green"><strong>Quoted strings, doubling quote chars.</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5f.</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   > <strong>Quoted strings, escape sequences in</strong>&emsp;<big><span class="blue">5.6</span></big></a><br>
<a href="#quoted-strings-in-code-fields"                 > <strong>Quoted strings in code fields</strong>&emsp;<big><span class="blue">5.7</span></big></a><br>
<a href="#loading-and-running-f"                         > <strong>Running  ∆F</strong>&emsp;<big><span class="blue">1.2</span></big></a><br>
<a href="#the-serialise-shortcut"                        > <strong>\`S (serialise)</strong>&emsp;<big><span class="blue">4.19</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>SDCFs: self-documenting code fields</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>Self-documenting code fields (SDCFs)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#the-serialise-shortcut"                        > <strong>Serialise shortcut, array notation</strong>&emsp;<big><span class="blue">4.19</span></big></a><br>
<a href="#serialise-shortcut-expressions-details"        > <strong>Serialise shortcut, details</strong>&emsp;<big><span class="blue">5.9</span></big></a><br>
<a href="#table-library-parameters"                      > <span class="green"><strong>Session library parameters, file (.∆F)</strong></span>&emsp;<big><span class="blue"><small><em>Fig.</em></small> 4.21</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>Session library shortcut</strong>&emsp;<big><span class="blue">4.21</span></big></a><br>
<a href="#session-library-shortcut-details"              > <strong>Session library shortcut, details</strong>&emsp;<big><span class="blue">5.11</span></big></a><br>
<a href="#code-field-shortcuts"                          > <span class="red"><big><strong>Shortcuts, all</strong></big></span>&emsp;<big><span class="blue">5.5</span></big></a><br>
<a href="#table-brief-shortcuts"                         > <span class="green"><strong>Shortcuts, brief</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 3a.</span></big></a><br>
<a href="#table-shortcuts"                               > <span class="green"><strong>Shortcuts, details</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5d.</span></big></a><br>
<a href="#shortcuts-with-apl-expressions"                > <strong>Shortcuts, with Apl expressions</strong>&emsp;<big><span class="blue">4.15</span></big></a><br>
<a href="#text-fields-and-space-fields"                  > <strong>Space fields</strong>&emsp;<big><span class="blue">4.2</span></big></a><br>
<a href="#null-space-fields"                             > <strong>Space fields, null</strong>&emsp;<big><span class="blue">4.3</span></big></a><br>
<a href="#inside-reference"                              > <span class="red"><big><strong>Syntax (∆F reference)</strong></big></span>&emsp;<big><span class="blue">5.</span></big></a><br>
<a href="#table-call-syntax"                             > <span class="green"><strong>Syntax, ∆F Call</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5a.</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-i"         > <strong>\`T (time)</strong>&emsp;<big><span class="blue">4.16</span></big></a><br>
<a href="#table-escapes"                                 > <span class="green"><strong>Text field escape sequences</strong></span>&emsp;<big><span class="blue"><small><em>Table</em></small> 5e.</span></big></a><br>
<a href="#text-fields-and-space-fields"                  > <strong>Text fields</strong>&emsp;<big><span class="blue">4.2</span></big></a><br>
<a href="#escape-sequences-text-fields-quoted-strings"   > <strong>Text fields, escape sequences in</strong>&emsp;<big><span class="blue">5.6</span></big></a><br>
<a href="#a-shortcut-for-dates-and-times-part-i"         > <strong>Time shortcut</strong>&emsp;<big><span class="blue">4.16</span></big></a><br>
<a href="#appendix-i-underdocumented-features"           > <strong>Underdocumented features</strong>&emsp;<big><span class="blue">6.1</span></big></a><br>
<a href="#appendix-i-underdocumented-features"           > <strong>Undocumented features</strong>&emsp;<big><span class="blue">6.1</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>Vertical SDCF (↓ or %)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#the-wrap-shortcut"                             > <strong>\`W (wrap)</strong>&emsp;<big><span class="blue">4.20</span></big></a><br>
<a href="#the-wrap-shortcut"                             > <strong>Wrap shortcut</strong>&emsp;<big><span class="blue">4.20</span></big></a><br>
<a href="#wrap-shortcut-details"                         > <strong>Wrap shortcut, details</strong>&emsp;<big><span class="blue">5.10</span></big></a><br>
<a href="#the-format-shortcut"                           > <strong>$ (format)</strong>&emsp;<big><span class="blue">4.9</span></big></a><br>
<a href="#the-above-shortcut"                            > <strong>% (above)</strong>&emsp;<big><span class="blue">4.12</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>% (vertical SDCF)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#the-session-library-shortcut"                  > <strong>£ (library)</strong>&emsp;<big><span class="blue">4.21</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>→ (horizontal SDCF)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#self-documenting-code-fields-sdcfs"            > <strong>↓ (vertical SDCF)</strong>&emsp;<big><span class="blue">4.11</span></big></a><br>
<a href="#omega-shortcut-expressions-details"            > <strong>\`⍵ and ⍹, details</strong>&emsp;<big><span class="blue">5.8</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>\`⍵, ⍹ (omega, implicit)</strong>&emsp;<big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      > <strong>\`⍵𝑑𝑑, ⍹𝑑𝑑 (omega, explicit)</strong>&emsp;<big><span class="blue">4.7</span></big></a><br>
<a href="#omega-shortcuts-implicit"                      > <strong>⍹ [<strong>⍵</strong>-underscore]: see <em>\`⍵</em></strong>&emsp;<big><span class="blue">4.14</span></big></a><br>
<a href="#omega-shortcuts-explicit"                      > <strong>⍹𝑑𝑑 [<strong>⍵</strong>-underscore]: see \`⍵𝑑𝑑</strong>&emsp;<big><span class="blue">4.7</span></big></a><br>
<!-- INDEX_END -->

</div>
</details>

<!-- Put a set of navigation tools at a fixed position at the bottom of the Help screen
-->
<div class="doc-footer" style="text-align: left;padding-left:60px;">
<div class="button-container">
<input type="button" value="Back" class="button happy-button" onclick="history.back()"/>
<button id="toggleDetails" class="button happy-button" style="width: 130px;">Expand All</button>&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" class="button normal-button" value="Top" onclick="window.location='#top'"/>
<input type="button" class="button normal-button" value="Quick Start" onclick="window.location='#inside-quick-start'"/>
<input type="button" class="button normal-button" value="Examples" onclick="window.location='#inside-examples'"/>
<input type="button" class="button normal-button" value="Reference" onclick="window.location='#inside-reference'"/>
<!-- 
 <input type="button" class="button normal-button" value="Appendices" onclick="window.location='#appendices'"/> 
-->
<input type="button" class="button normal-button" value="Index" onclick="window.location='#inside-index'"/>
<input type="button" class="button normal-button" value="Bottom" onclick="window.location='#index-of-topics'"/>&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" class="button happy-button" value="Print" onclick="myPrint()">
<button onclick="closeWindowNow()" class="button warn-button">Close Window</button>
</div>
</div>

---



<br>
<span id="copyright" style="font-family:cursive;">
Copyright <big>©</big> 2026 Sam the Cat Foundation.    [Version 0.1.3: 2026-01-20]
</span>
<br> 
</div> <!-- End div for right-margin-bar -->

<!-- a hidden modal expression -->
<div id="pAlertMsg" class="pAlertMsg">
  <span id="pAlertPfx"  style="font-size: 40px;">
  </span> 
  <span id="pAlertText" 
        style="font-weight: bold; font-size: 20px;font-family: Tahoma,  sans-serif;">
  </span>
</div>

<!-- (C) 2026 Sam the Cat Foundation -->
