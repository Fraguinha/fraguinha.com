---
title: "Lambda - Lambda Calculus System"
description: "Tiny introduction to Lambda Calculus with an interactive interpreter."
date: 2022-10-17T20:35:28+01:00
draft: false
---

The code used in this post can be found here: [http://github.com/Fraguinha/Lambda](http://github.com/Fraguinha/Lambda).

# Lambda Calculus

At it's core, Lambda Calculus is composed of three elements: `variables`, `abstractions`, and `applications`.

- Variables are `placeholders that represent an unknown value or lambda term`.
They are typically `represented by a single lowercase letter`.

- Abstractions are `expressions that define a function`.
They consist of a `lambda, followed by a variable, followed by a dot, followed by a lambda term`.
e.g.: `λx.x` is an `abstraction` that `defines a function` that `takes x` and `returns x`.

- Applications are `expressions that apply a function to an argument`.
They consist of `two lambda terms separated by a space`.
The `left term` is the `function to be applied`, and the `right term` is the `argument to which the function will be applied`.
e.g.: `(λx.x) y` is an `application` that `applies the function λx.x` to the `argument y`.

# Playground

<label for="expression">Expression:</label>
<textarea id="expression" type="text" style="width: 100%; height: 10vh">(\x.x) y</textarea>
<br />
<label for="output">Result:</label>
<input id="output" type="textbox" style="width: 100%" disabled></input>

# Syntax

`x` or `x'`

`λx.M` or `\x.M`

`M N`

where `M` and `N` are lambda terms

This interpreter supports sintatic sugar like:

`λxyz.M` instead of `λx.(λy.(λz.M))`

and

`M N O` instead of `((M N) O)`

Terms can be defined in this way:

`Y=λf.(λx.f(xx))(λx.f(xx))`

or

`S=λxyz.xz(yz); K=λxy.x; I=λx.x`

or even

`TRUE=λxy.x`

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
