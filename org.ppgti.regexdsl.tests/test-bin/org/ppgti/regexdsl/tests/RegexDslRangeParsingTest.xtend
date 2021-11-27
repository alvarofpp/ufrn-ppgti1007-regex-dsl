/*
 * generated by Xtext 2.25.0
 */
package org.ppgti.regexdsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.ppgti.regexdsl.regexDsl.RegularExpressions
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.ppgti.regexdsl.regexDsl.RegexDslPackage
import org.ppgti.regexdsl.validation.RegexDslValidator

@ExtendWith(InjectionExtension)
@InjectWith(RegexDslInjectorProvider)
class RegexDslRangeParsingTest {
    @Inject
    ParseHelper<RegularExpressions> parseHelper
    
    @Inject ValidationTestHelper validationTestHelper
    
    @Inject extension CompilationTestHelper
    
    @Test
    def void digits() {
        val result = '----- Regular Expressions -----'
            + '\ndigits: 0-9';
        
        '''
        regex digits {
            range 0 9
        }
        '''.assertCompilesTo(result)
    }
    
    @Test
    def void lettersLower() {
        val result = '----- Regular Expressions -----'
            + '\nletters_lower: a-z';
        
        '''
        regex letters_lower {
            range a z
        }
        '''.assertCompilesTo(result)
    }
    
    @Test
    def void lettersUpper() {
        val result = '----- Regular Expressions -----'
            + '\nletters_upper: A-Z';
        
        '''
        regex letters_upper {
            range A Z
        }
        '''.assertCompilesTo(result)
    }
    
    @Test
    def void errorSameType() {
        val entity = parseHelper.parse(
            "regex same_type {
                range 0 a
            }"
        )
        validationTestHelper.assertError(entity,
            RegexDslPackage.Literals.RANGE,
            RegexDslValidator.SAME_TYPE,
            "Values must be of the same type"
        )
    }
    
    @Test
    def void warningFirstValueGraterThanSecond() {
        val entity = parseHelper.parse(
            "regex first_value_greater_than_second {
                range 9 0
            }"
        )
        validationTestHelper.assertWarning(entity,
            RegexDslPackage.Literals.RANGE,
            RegexDslValidator.FIRST_VALUE_GREATER_THAN_SECOND,
            "Recommend that the first value be less than the second"
        )
    }
    
    @Test
    def void warningFirstValueQualsToSecond() {
        val entity = parseHelper.parse(
            "regex first_value_equals_to_second {
                range 9 9
            }"
        )
        validationTestHelper.assertWarning(entity,
            RegexDslPackage.Literals.RANGE,
            RegexDslValidator.FIRST_VALUE_EQUALS_TO_SECOND,
            "Recommend that the first value be less than the second"
        )
    }
}
