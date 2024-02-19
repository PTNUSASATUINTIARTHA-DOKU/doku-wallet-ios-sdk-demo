//
//  Validator.swift
//  DokuWalletFrameworkDemo
//
//  Created by DOKU on 10/11/23.
//

import Foundation

enum ValidationActionType {
    case removeLast
    case removeAll
    case blank
}

class ValidationError: Error {
    var message: String
    var action: ValidationActionType
    init(_ message: String, _ action: ValidationActionType) {
        self.message = message
        self.action = action
    }
}

protocol Validator {
    func validated(_ value: String?) throws -> String
}

enum ValidatorType {
    case requiredField(field: String)
    case minLength(value: Int, forField: String)
    case name(forField: String)
    case phoneNumber(forField: String)
    case otp(forField: String)
    case email
    case amount(field: String, amountType: AmountType)
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> Validator {
        switch type {
        case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
        case .minLength(let minValue, let field): return MinLengthValidator(minValue, field)
        case .email: return EmailValidator()
        case .name(let forField): return NameValidator(forField)
        case .otp(let forField): return OTPValidator(forField)
        case .phoneNumber(let forField): return PhoneNumberValidator(forField)
        case .amount(let field, let amountType): return AmountTransferValidator(field, amountType)
        }
    }
}

struct AmountTransferValidator: Validator {
    
    private let amountType: AmountType
    private let field: String
    init(_ field: String, _ amountType: AmountType) {
        self.field = field
        self.amountType = amountType
    }
    
    func validated(_ value: String?) throws -> String {
        
        guard let value = value, !value.isEmpty else {
            throw ValidationError("\(field) wajib diisi", .blank)
        }
        
        let originalAmount = AppHelper.shared.getOriginalAmount(data: value)
        guard let amountInput = Double(originalAmount) else { throw ValidationError("\(field) tidak valid", .blank) }
        
        var minimum = 0.0
        var maximum = 0.0
        switch self.amountType {
        case .qrisAmountGenerate:
            minimum = 1.0
            maximum = 10000000.0
        case .qrisAmountPayment:
            minimum = 1000.0
            maximum = 10000000.0
        case .qrisFee:
            minimum = 1.0
            maximum = 10000000.0
        case .transfer:
            minimum = 10000.0
            maximum = 10000000.0
        }
        
        let minimumString = "\(Int(minimum))".currencyFormatterForCurrencyIntegerString()
        if(amountInput <= 0.0) {
            throw ValidationError("\(field) minimum Rp\(minimumString)", .removeAll)
        } else if amountInput < minimum {
            let minimumString = "\(Int(minimum))".currencyFormatterForCurrencyIntegerString()
            throw ValidationError("\(field) minimum Rp\(minimumString)", .blank)
        } else if amountInput > maximum {
            let maximumString = "\(Int(maximum))".currencyFormatterForCurrencyIntegerString()
            throw ValidationError("\(field) maksimum Rp\(maximumString)", .blank)
        }
        return originalAmount
    }
}

struct RequiredFieldValidator: Validator {
    
    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: String?) throws -> String {
        guard let value = value, !value.isEmpty else {
            throw ValidationError(fieldName + " wajib diisi", .blank)
        }
        return value
    }
}

struct MinLengthValidator: Validator {
    
    private var min: Int = 0
    private var field: String = ""
    init(_ minValue: Int,_ field: String) {
        self.min = minValue
        self.field = field
    }
    
    func validated(_ value: String?) throws -> String {
        
        guard let value = value, !value.isEmpty else {
            throw ValidationError("\(field) wajib diisi", .blank)
        }
        
        if value.count < self.min {
            throw ValidationError("\(field) tidak valid", .blank)
        }
        
        return value
    }
}

struct EmailValidator: Validator {
    
    func validated(_ value: String?) throws -> String {
        guard let value = value, !value.isEmpty else {
            throw ValidationError("Email wajib diisi", .blank)
        }
        
        if !value.isValidEmail {
            throw ValidationError("Email tidak valid", .blank)
        }
        
        return value
    }
}

struct PhoneNumberValidator: Validator {
    
    private var field: String = ""
    private var minLength : Int = 11
    
    init(_ field: String) {
        self.field = field
    }
    
    func validated(_ value: String?) throws -> String {
        
        guard let value = value, !value.isEmpty else {
            throw ValidationError("\(field) wajib diisi", .blank)
        }
        
        if (value.count < minLength) {
            throw ValidationError("\(field) tidak valid", .blank)
        } else if (!(value.count >= 3 && value.prefix(3).elementsEqual("628"))) {
            throw ValidationError("Format \(field.lowercased()) salah", .blank)
        }
        
        return value
    }
}

struct NameValidator: Validator {
    
    private var field: String = ""
    private var minLength : Int = 3
    
    init(_ field: String) {
        self.field = field
    }
    
    func validated(_ value: String?) throws -> String {
        guard let value = value, !value.isEmpty else {
            throw ValidationError(field + " wajib diisi", .blank)
        }
        
        if(!value.containsOnlyLettersAndWhitespace()) {
            throw ValidationError("Format " + field.lowercased() + " salah", .blank)
        } else if (value.count < minLength) {
            throw ValidationError(field + " tidak valid", .blank)
        }
        
        return value
    }
}

struct OTPValidator: Validator {
    
    private var field: String = ""
    private var minLength : Int = 6
    
    init(_ field: String) {
        self.field = field
    }
    
    func validated(_ value: String?) throws -> String {
        guard let value = value, !value.isEmpty else {
            throw ValidationError(field + " wajib diisi", .blank)
        }
        
       if (value.count < minLength) {
            throw ValidationError(field + " tidak valid", .blank)
        }
        
        return value
    }
}

class Validation {
    
    static func validated(data: String?, validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(data)
    }
}
