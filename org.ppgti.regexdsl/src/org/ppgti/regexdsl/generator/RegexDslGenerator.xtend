/*
 * generated by Xtext 2.25.0
 */
package org.ppgti.regexdsl.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.ppgti.regexdsl.regexDsl.RegularExpression
import org.ppgti.regexdsl.regexDsl.Set
import org.ppgti.regexdsl.regexDsl.Quantifier
import org.ppgti.regexdsl.regexDsl.Expression
import org.ppgti.regexdsl.regexDsl.Range
import org.ppgti.regexdsl.regexDsl.RawExpression
import org.ppgti.regexdsl.regexDsl.AttributesQuantifier
import org.ppgti.regexdsl.regexDsl.Group
import java.util.Map
import java.util.HashMap
import org.ppgti.regexdsl.regexDsl.Comment
import org.ppgti.regexdsl.regexDsl.GroupBackreference
import org.ppgti.regexdsl.regexDsl.Anchor
import org.ppgti.regexdsl.regexDsl.ValidateInput

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class RegexDslGenerator extends AbstractGenerator {
    String ZERO_OR_ONE = '?';
    String ZERO_OR_MULTIPLE = '*';
    String ONE_OR_MULTIPLE = '+';
    HashMap<String, String> regexs;

    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        this.seedRegexsMap(resource);
        var expressions = resource.allContents
                .filter(RegularExpression)
                .map[compile]
                .join('\n');
        var validates = resource.allContents
                .filter(ValidateInput)
                .map[compileValidateInput]
                .join('\n');
        
        var result = '----- Regular Expressions -----\n'
            + expressions;
        
        if (validates.length > 0) {
            result += '\n\n----- Validate Inputs -----\n'
                + validates;
        }
        
        fsa.generateFile('regex.txt', result)
    }
    
    private def compileValidateInput(ValidateInput validateInput) {
        if (validateInput.inputs.length == 0) {
            return '';
        }
        
        var regex = this.regexs.get(validateInput.regex);
        var result = '';
        
        for (input : validateInput.inputs) {
            result += '\n  - '
                + input + ': ';
            
            try {
            	result += (input.toString().matches(regex) ? 'true' : 'false');
            } catch (Exception exception) {
            	result += '(ERROR) ' + exception.getMessage();
            }
        }
        
        return validateInput.name + ':'
            + '\n- RegEx: ' + regex
            + '\n- Inputs:'
            + result;
    }
    
    private def seedRegexsMap(Resource resource) {
        this.regexs = new HashMap<String, String>();
        var allNames = resource.allContents
                .filter(RegularExpression)
                .map[getNameFromRegularExpression];
        while (allNames.hasNext()) {
            regexs.put(allNames.next(), null);
        }
    }
    
    private def getNameFromRegularExpression(RegularExpression regularExpression) {
        return regularExpression.name;
    }
    
    private def compile(RegularExpression regularExpression) {
//    	if () {
//    		
//    	}
    	
        var String regex = '';
        for (expression : regularExpression.struct.expressions) {
            regex += this.compileExpression(expression);
        }
        this.regexs.put(regularExpression.name, regex);
        
        return regularExpression.name + ': ' + regex;
    }
    
    private def compileExpression(Expression expression) {
        if (expression instanceof Set) {
            return this.compileSet(expression);
        } else if (expression instanceof Group) {
            return this.compileGroup(expression);
        } else if (expression instanceof GroupBackreference) {
            return this.compileBackreference(expression);
        } else if (expression instanceof Anchor) {
            return this.compileAnchor(expression);
        } else if (expression instanceof Quantifier) {
            return this.compileQuantifier(expression);
        } else if (expression instanceof Range) {
            return this.compileRange(expression);
//        } else if (expression instanceof Comment) {
//            return this.compileComment(expression);
        } else if (expression instanceof RawExpression) {
            var value = this.regexs.get(expression.value);
            if (value != null) {
                return value
            }
            
            return expression.value;
        }
    }
    
    private def compileAnchor(Anchor anchor) {
        var String pre = '^';
        var String pos = '$';
        
        if (anchor.negate) {
            pre = '\\b';
            pos = '\\B';
        }
        
        var String result = '';
        
        for (expression : anchor.struct.expressions) {
            result += this.compileExpression(expression);
        }
        
        return pre + result + pos;
    }
    
    private def compileSet(Set set) {
        var String result = '[';
        
        for (expression : set.struct.expressions) {
            result += this.compileExpression(expression);
        }
        
        return result + ']';
    }
    
    private def compileGroup(Group group) {
        var String result = '(';
        
        if (group.non_capturing) {
            result += '?:';
        } else if (group.name != null) {
            result += '?P<' + group.name + '>';
        }
        
        for (expression : group.struct.expressions) {
            result += this.compileExpression(expression);
        }
        
        return result + ')';
    }
    
    private def compileBackreference(GroupBackreference backreference) {
        if (this.isNumericInt(backreference.value)) {
            return '\\' + backreference.value;
        }
        return '(?P=' + backreference.value + ')';
    }
    
    private def compileQuantifier(Quantifier quantifier) {
        var String result = '';
        var attributes = newHashMap();
        
        for (attribute : quantifier.attributes) {
            attributes.put(attribute.key, attribute.value);
        }
        var boolean withoutMaximum = this.convertStringToBoolean(attributes.getOrDefault('without_maximum', '0'));
        
        if (attributes.containsKey('size')) {
            result += attributes.get('size');
        } else if (attributes.containsKey('min') || attributes.containsKey('max')) {
            var String min = attributes.getOrDefault('min', '0');
            var String max = attributes.getOrDefault('max', '0');
            
            if (min == '0' && max == '1') {
                return this.ZERO_OR_ONE;
            } else if (min == '0' && withoutMaximum) {
                return this.ZERO_OR_MULTIPLE;
            } else if (min == '1' && withoutMaximum) {
                return this.ONE_OR_MULTIPLE;
            }
            
            result = min;
            
            if (withoutMaximum == true) {
                result += ',';
            } else if (Integer::parseInt(max) > Integer::parseInt(min)) {
                result += ',' + max;
            }
        } else {
            if (withoutMaximum) {
                return this.ZERO_OR_MULTIPLE;
            }
        }
        
        return '{' + result + '}'
    }
    
    private def compileRange(Range range) {
        return range.value.replaceAll(' ', '-');
    }
    
    private def compileComment(Comment comment) {
        return '(?#' + comment.value + ')';
    }
    
    private def boolean convertStringToBoolean(String value) {
        if (value.toLowerCase() == 'true') {
            return true;
        }
        
        if (this.isNumericInt(value) && Integer::parseInt(value) > 0) {
            return true;
        }
        
        return false;
    }
    
    private def boolean isNumericInt(String value) {
        if (value == null) {
            return false;
        }
        try {
            var int valueInt = Integer::parseInt(value);
        } catch (NumberFormatException nfe) {
            return false;
        }
        return true;
    }
}