# PPGTI1007 - RegEx Assembly Language

This work has as purpose to create a DSL (Domain-Specific Languages) that helps you assemble and document regular expressions with ease. You can also use it to validate inputs.

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
- GroupBackreference: `backreference('1')` | `backreference('name')`
- Anchor: `anchor (negate)? { expressions }`
- Raw expressions: `'\\.'` | `'\\d'` | `'\\w'` | `...`
<!-- - Comment: `comment 'text here'` -->

The file is read from top to bottom, so you can write smaller expressions at the top and reuse them in a larger expression at the bottom. For example:

```
regex all_digits {
    set {
        range 0 9
    }
}

regex one_or_more {
    quantifier(min=0, without_maximum=true)
}

regex one_or_more_digits {
    all_digits
    one_or_more
}
```

Files:
- Grammar: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/RegexDsl.xtext)
- Generator: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/generator/RegexDslGenerator.xtend`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/generator/RegexDslGenerator.xtend)
- Validator: [`org.ppgti.regexdsl/src/org/ppgti/regexdsl/validation/RegexDslValidator.java`](org.ppgti.regexdsl/src/org/ppgti/regexdsl/validation/RegexDslValidator.java)
- Tests: [`org.ppgti.regexdsl.tests/src/org/ppgti/regexdsl/tests`](org.ppgti.regexdsl.tests/src/org/ppgti/regexdsl/tests)

## Use

Expressions:
```
regex {name} {
    "{expressions_one}"
    "{expressions_two}"
    "{expressions_three}"
    ...
}
```

Input validation:
```
validate {name} {
    regex = {regex_name},
    inputs = [
        "input_one",
        "input_two",
        "input_three"
        ...
    ]
}
```

## Validations

### UNIQUE_NAME
Regular Expression names must be unique.

- **Message**: "RegEx names have to be unique".
- **Type**: error.

Correct:
```
regex unique_name {
    "abc"
}
```

Incorrect:
```
regex unique_name {
    "abc"
}
regex unique_name {
    "abc"
}
```

### NOT_FOUND
Regular Expression name not found.

- **Message**: "RegEx not found".
- **Type**: error.

Correct:
```
regex all_digits {
    set {
        range 0 9
    }
    quantifier(min=0, without_maximum=true)
}

validate zipcode_inputs {
    regex = all_digits,
    inputs = [
        "abc",
        "11111"
    ]
}
```

Incorrect:
```
regex all_digits {
    set {
        range 0 9
    }
    quantifier(min=0, without_maximum=true)
}

validate zipcode_inputs {
    regex = all_digits_wrong,
    inputs = [
        "abc",
        "11111"
    ]
}
```

### STRUCT_EMPTY
Regular Expression is empty. This validation works for `regex`, `set`, `group` and `anchor`.

- **Message**: "Must have other expressions inside the expression".
- **Type**: error.

Correct:
```
regex struct_empty {
    "something"
}
```

Incorrect:
```
regex struct_empty {}
```

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
}

validate zipcode_inputs {
    regex = zipcode,
    inputs = [
        "abc",
        "11111-111",
        "22222222"
    ]
}
```

Output:
```
----- Regular Expressions -----
all_digits: [0-9]
zipcode: [0-9]{5}-?[0-9]{3}

----- Validate Inputs -----
zipcode_inputs:
- RegEx: [0-9]{5}-?[0-9]{3}
- Inputs:
  - abc: false
  - 11111-111: true
  - 22222222: true
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

validate cpf_inputs {
    regex = cpf,
    inputs = [
        "abc",
        "111.111.111-11",
        "222.222.222-22"
    ]
}
```

Output:
```
----- Regular Expressions -----
all_digits: [0-9]
cpf_first_digits_set: [0-9]{3}
cpf: [0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}

----- Validate Inputs -----
cpf_inputs:
- RegEx: [0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}
- Inputs:
  - abc: false
  - 111.111.111-11: true
  - 222.222.222-22: true
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
----- Regular Expressions -----
zero_or_one: ?
zero_or_multiple: *
one_or_multiple: +
exactly_three: {3}
two_to_four: {2,4}
three_or_more: {3,}
```
