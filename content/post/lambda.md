---
title: "Lambda - Lambda Calculus System"
description: "Tiny introduction to Lambda Calculus with an interactive interpreter."
date: 2022-10-17T20:35:28+01:00
draft: false
---

The code used in this post can be found here: [http://github.com/Fraguinha/Lambda](http://github.com/Fraguinha/Lambda).

# Lambda Calculus

At it's core, Lambda Calculus is composed of three elements: __variables__, __abstractions__, and __applications__.

- Variables are __placeholders that represent an unknown value or lambda term__.
They are typically __represented by a single lowercase letter__.

- Abstractions are __expressions that define a function__.
They consist of a __lambda, followed by a variable, followed by a dot, followed by a lambda term__.
e.g.: __λx.x__ is an __abstraction__ that __defines a function__ that __takes x__ and __returns x__.

- Applications are __expressions that apply a function to an argument__.
They consist of __two lambda terms separated by a space__.
The __left term__ is the __function to be applied__, and the __right term__ is the __argument to which the function will be applied__.
e.g.: __(λx.x) y__ is an __application__ that __applies the function λx.x__ to the __argument y__.

# Playground

<label for="expression">Expression:</label>
<textarea id="expression" type="text" style="width: 100%; height: 10vh">(\x.x) y</textarea>
<br />
<label for="output">Result:</label>
<input id="output" type="textbox" style="width: 100%" disabled></input>

# Syntax

__x__ or __x'__

__λx.M__ or __\x.M__

__M N__

where __M__ and __N__ are lambda terms

This interpreter supports sintatic sugar like:

__λxyz.M__ instead of __λx.(λy.(λz.M))__

and

__M N O__ instead of __((M N) O)__

Terms can be defined in this way:

__Y=λf.(λx.f(xx))(λx.f(xx))__

or

__S=λxyz.xz(yz); K=λxy.x; I=λx.x__

or even

__TRUE=λxy.x__

Statements are separated by semicolons

<script type="module" src="/files/lambda/main.bc.js"></script>
<script>
const init = () => {
  let expression = document.getElementById("expression");
  let output = document.getElementById("output");

  expression.focus();
  expression.selectionStart = expression.value.length;

  output.value = Interpreter.parse(expression.value);
  expression.addEventListener("input", (event) => {
    output.value = Interpreter.parse(event.target.value);
  });
};

window.onload = init
</script>
