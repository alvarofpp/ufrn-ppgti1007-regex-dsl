# PPGTI1007 - RegEx Assembly Language

This work has as purpose to create a DSL (Domain-Specific Languages) that helps you assemble and document regular expressions with ease.

Work of Domain-Specific Languages (PPGTI1007) course of Master's degree in Information Technology from the Federal University of Rio Grande do Norte (UFRN), with [Sergio Queiroz de Medeiros](https://docente.ufrn.br/201900341664/perfil) as professor.

# Domain-Specific Language

```
regex hello_world {
    "Hello World!"
}
```

On this DSL you have:
- Group: `group (non_capturing)? (name)? { expressions }`
- Set: `set { expressions }`
- Range: `range 0 9` | `range a z` | `range A Z`
- Quantifier: `quantifier(size=int, min=int, max=int, without_maximum=bool)`
- Comment: `comment 'text here'`
- GroupBackreference: `backreference('1')` | `backreference('name')`
- Anchor: `anchor (negate)? { expressions }`
- Raw expressions: `'\\.'` | `'\\d'` | `'\\w'` | `...`

You can reuse a expression in other expression. Files:

- Grammar: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext).
- Generator: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/generator/RegexDslGenerator.xtend`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/generator/RegexDslGenerator.xtend).
- Tests: [`org.ppgti.regexdsl.tests/src/org/ppgti/regexdsl/tests`](org.ppgti.regexdsl.tests/src/org/ppgti/regexdsl/tests).
- Validator: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/validation/RegexDslValidator.java`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/validation/RegexDslValidator.java).

## Use

```
regex {id} {
    "{expressions_one}"
    "{expressions_two}"
    "{expressions_three}"
    ...
}
```

## Validations

### SAME_TYPE
Range values must by of the same type.

- **Message**: "Values must be of the same type".
- **Type**: error.

Correct:
```
regex same_type {
    range 0 9
}
```

Incorrect:
```
regex same_type {
    range 0 a
}
```

### FIRST_VALUE_GREATER_THAN_SECOND
The first value is greater than the second.

- **Message**: "Recommend that the first value be less than the second".
- **Type**: warning.

Correct:
```
regex first_value_greater_than_second {
    range 0 9
}
```

Incorrect:
```
regex first_value_greater_than_second {
    range 9 0
}
```

### FIRST_VALUE_EQUALS_TO_SECOND
The first value equals to the second.

- **Message**: "Recommend that the first value be less than the second".
- **Type**: warning.

Correct:
```
regex first_value_equals_to_second {
    range 0 9
}
```

Incorrect:
```
regex first_value_equals_to_second {
    range 9 9
}
```

### ATTRIBUTES_TYPE_INTEGER
The attributes `size`, `min`, `max` must be a integer.

- **Message**: "The value of '{key}' must be a integer, was given {value}".
- **Type**: error.

Correct:
```
regex attributes_type_integer {
    quantifier(size=3)
}
```

Incorrect:
```
regex attributes_type_integer {
    quantifier(size="abc")
}
```

### ATTRIBUTES_TYPE_BOOLEAN
The attribute `without_maximum` must be a boolean.

- **Message**: "The value of 'without_maximum' must be a boolean, was given {value}".
- **Type**: error.

Correct:
```
regex attributes_type_boolean {
    quantifier(without_maximum=true)
}
```

Incorrect:
```
regex attributes_type_boolean {
    quantifier(without_maximum="abc")
}
```

### SIZE_WITH_MIN_AND_MAX
The quantifier have `size` and `[min or max]` attributes.

- **Message**: "You can use 'size' or 'min' and 'max', but not these attributes together".
- **Type**: error.

Correct:
```
regex size_and_min_and_max {
    quantifier(size=1)
}
// Or
regex size_and_min_and_max {
    quantifier(min=2, max=3)
}
```

Incorrect:
```
regex size_and_min_and_max {
    quantifier(size=1, min=2, max=3)
}
```

### MIN_GREATER_THAN_MAX
The minimum value is greater than maximum value.

- **Message**: "Minimum value must be less than the maximum value".
- **Type**: error.

Correct:
```
regex min_greater_than_max {
    quantifier(min=1, max=3)
}
```

Incorrect:
```
regex min_greater_than_max {
    quantifier(min=3, max=1)
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
