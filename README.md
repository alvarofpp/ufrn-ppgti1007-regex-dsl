# PPGTI1007 - RegEx Assembly Language

This work has as purpose to create a DSL (Domain-Specific Languages) that helps you assemble and document regular expressions with ease.

Work of Domain-Specific Languages (PPGTI1007) course of Master's degree in Information Technology from the Federal University of Rio Grande do Norte (UFRN), with [Sergio Queiroz de Medeiros](https://docente.ufrn.br/201900341664/perfil) as professor.

# Domain-Specific Language

On this DSL you have:
- Group: `group (non_capturing)? (name)? { expressions }`;
- Set: `set { expressions }`;
- Range: `range 0 9` | `range a z` | `range A Z`;
- Quantifier: `quantifier(size=int, min=int, max=int, without_maximum=bool)`;
- Comment: `comment 'text here'`;
- GroupBackreference: `backreference('1')` | `backreference('name')`;
- Anchor: `anchor (negate)? { expressions }`;
- Raw expressions: `'\\.'` | `'\\d'` | `'\\w'` | `...` .

You can reuse a expression in other expression. You can find the grammar in [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext).

## Use

```
regex {id} {
    "{expressions_one}"
    "{expressions_two}"
    "{expressions_three}"
    ...
}
```

## Examples

### Zipcode (Brazil)

Input:
```
regex all_digits {
    set {
        range 0 9
    }
}

regex zipcode {
    all_digits
    quantifier(size=5)
    '-'
    quantifier(min=0, max=1)
    all_digits
    quantifier(size=3)
    comment 'Get zipcode Brazil on input'
}
```

Output:
```
all_digits: [0-9]
zipcode: [0-9]{5}-?[0-9]{3}(?#Get zipcode Brazil on input)
```

### CPF

Input:
```
regex all_digits {
    set {
        range 0 9
    }
}

regex cpf_first_digits_set {
    all_digits
    quantifier(size=3)
}

regex cpf {
    cpf_first_digits_set
    '\\.'
    cpf_first_digits_set
    '\\.'
    cpf_first_digits_set
    '-'
    all_digits
    quantifier(size=2)
}
```

Output:
```
all_digits: [0-9]
cpf_first_digits_set: [0-9]{3}
cpf: [0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}
```

### Quantifiers

Input:
```
regex zero_or_one {
    quantifier(min=0, max=1)
}

regex zero_or_multiple {
    quantifier(min=0, without_maximum=true)
}

regex one_or_multiple {
    quantifier(min=1, without_maximum=true)
}

regex exactly_three {
    quantifier(size=3)
}

regex two_to_four {
    quantifier(min=2, max=4)
}

regex three_or_more {
    quantifier(min=3, without_maximum=true)
}
```

Output:
```
zero_or_one: ?
zero_or_multiple: *
one_or_multiple: +
exactly_three: {3}
two_to_four: {2,4}
three_or_more: {3,}
```
