⍝  MIT License
⍝ Copyright (c) 2018 Adám Brudzewsky

⍝ Permission is hereby granted, free of charge, to any person obtaining a copy
⍝ of this software and associated documentation files (the "Software"), to deal
⍝ in the Software without restriction, including without limitation the rights
⍝ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
⍝ copies of the Software, and to permit persons to whom the Software is
⍝ furnished to do so, subject to the following conditions:

⍝ The above copyright notice and this permission notice shall be included in all
⍝ copies or substantial portions of the Software.

⍝ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
⍝ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
⍝ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
⍝ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
⍝ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
⍝ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
⍝ SOFTWARE.

⍝ Original Op Name...
⍝   CircleDiaeresis←{    
⍝ Replaced by...
Ö← {  
    0::⎕SIGNAL⊂⎕DMX.(('EN'EN)('EM'EM)('Message'(OSError{⍵,2⌽(×≢⊃⍬⍴2⌽⍺,⊂'')/'") ("',⊃⍬⍴2⌽⍺}Message)))
    ncs←⎕NC⊃⍤0⊢'⍺' '⍵⍵'
    0 3≡ncs:⍺⍺ ⍵⍵ ⍵         ⍝   f⍥g Y
    2 3≡ncs:⍺ ⍺⍺⍥⍵⍵ ⍵       ⍝ X f⍥g Y
    1<≢⍴⍵⍵:⎕SIGNAL 4        ⍝ non-vec/scal: RANK
    ⎕IO≠1 4⍸≢⍵⍵:⎕SIGNAL 5   ⍝ not 1…3 elements: LENGTH
    (c←⎕NS ⍬).⎕CT←1E¯14     ⍝ tolerant space
    c.≢∘⌊⍨⍵⍵:⎕SIGNAL 11     ⍝ not ints: DOMAIN
    0∊⎕NC'⍺':0⊢∘⍺⍺ ∇∇ ⍵⍵⊢⍵  ⍝ monadic: placeholder left arg
    ⍺←{⍵ ⋄ ⍺⍺}              ⍝ monadic: pass-thorugh
    a←⍺                     ⍝ [17941]
    k←⌽3⍴⌽⍵⍵                ⍝ r → r r r    q r → r q r    p q r → p q r
    n←k c.<0
    d←|≡¨3⍴⍵ ⍺ ⍵ ⍵
    (n/k)+←n/d
    k⌊←d
    b←1↓k<d
    b∧←0≠1↓d                ⍝ bottomed out
    r←⍵⍵<0
    ww←r+⍵⍵
    ww+←(⌈/d)×r∧0=ww
    S←⍺⍺ ∇∇ ww
    c.⍱/b:⍺ ⍺⍺ ⍵  
    c.</b:⍺∘S¨⍵   
    c.>/b:S∘⍵¨⍺   
    c.∧/b:⍺ S¨⍵   
}
