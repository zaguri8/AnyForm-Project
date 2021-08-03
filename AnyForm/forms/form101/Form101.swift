//
//  Form101.swift
//  AnyForm
//
//  Created by נדב אבנון on 22/07/2021.
//

import Foundation

class Form101 : Form {
    
    init() {
        super.init(type: .form101,design:FormLightDesign())
    }
    override func getHolder() -> FormFieldsHolder {
        return super.getHolder()
    }
    
    func getValue(for key:String) -> String {
        do {
            guard let field  = getHolder().getTextFields().first(where:  {f in
                                                                    return key == f.key})else {
                guard let field  = getHolder().getCheckBoxes().first(where:  {f in
                                                                        return key == f.key}) else {
                    throw FormError.unDefinedFieldKey("[Form101] Could not find key \(key)")
                }
                return field.key
            }
            return field.key
        }catch {
            print(error)
            return ""
        }
    }
    
    /// `Form 101 Fields Section`
    /// here we set the values for our from 101 fields.
    /// to add a field just add a new setter with the desired key(String) and value(String or Bool or Date).
    /// make sure the form's template json data file contains the key before adding a setter.
    /// if the template doesn't contain the key, we may add it in two ways:
    /// 1.use the template generator to edit a pdf form.
    /// 2.find the x,y coordinate of the field on the pdf file
    /// and manualy add them to the template.
    func setFirstName(_ value:String) {
        getHolder().setFieldValue(for: "first_name", value: value)
    }
    func setLastName(_ value:String) {
        getHolder().setFieldValue(for: "last_name", value: value)
    }
    func setIdNumber(_ value:String) {
        getHolder().setFieldValue(for: "id_number", value: value)
    }
    func setBirthDate(_ value:Date) {
        getHolder().setFieldValue(for: "birth_date", value: value.string())
    }
    func setPilgrimageDate(_ value:Date) {
        getHolder().setFieldValue(for: "pilgrimage_date", value: value.string())
    }
    func setPassportId(_ value:String) {
        getHolder().setFieldValue(for: "passport_id", value: value)
    }
    func setCity(_ value:String) {
        getHolder().setFieldValue(for: "city", value: value)
    }
    func setStreet(_ value:String) {
        getHolder().setFieldValue(for: "street", value: value)
    }
    func setHouseNumber(_ value:String) {
        getHolder().setFieldValue(for: "house_number", value: value)
    }
    func setPostalCode(_ value:String) {
        getHolder().setFieldValue(for: "postal_code", value: value)
    }
    func setIsKibutzMember(_ value:String) {
        getHolder().setFieldValue(for: "is_kibutz_memeber", value: value)
    }
    func setIsNotKibutzMember(_ value:String) {
        getHolder().setFieldValue(for: "is_not_kibutz_memeber", value: value)
    }
    func setIsMale(_ value:Bool) {
        getHolder().setFieldValue(for: "is_male", value: value ? "true" : "false")
    }
    func setIsFemale(_ value:Bool) {
        getHolder().setFieldValue(for: "is_female", value: value ? "true" : "false")
    }
    func setIsCitizen(_ value:Bool) {
        getHolder().setFieldValue(for: "is_citizen", value:  value ? "true" : "false")
    }
    func setIsNotCitizen(_ value:Bool) {
        getHolder().setFieldValue(for: "is_not_citizen", value:  value ? "true" : "false")
    }
    func setIsMarried(_ value:Bool) {
        getHolder().setFieldValue(for: "is_married", value:  value ? "true" : "false")
    }
    func setIsSingle(_ value:Bool) {
        getHolder().setFieldValue(for: "is_single", value:  value ? "true" : "false")
    }
    func setIsAlman(_ value:Bool) {
        getHolder().setFieldValue(for: "is_alman", value:  value ? "true" : "false")
    }
    func setIsDivorced(_ value:Bool) {
        getHolder().setFieldValue(for: "is_divorced", value:  value ? "true" : "false")
    }
    func setIsSeperated(_ value:Bool) {
        getHolder().setFieldValue(for: "is_seperated", value:  value ? "true" : "false")
    }
    func setHasHealthInsurance(_ value:String) {
        getHolder().setFieldValue(for: "has_health_insurance", value: value)
    }
    func setHasNoHealthInsurance(_ value:String) {
        getHolder().setFieldValue(for: "has_no_health_insurance", value: value)
    }
    func setHealthInsurance(_ value:String) {
        getHolder().setFieldValue(for: "health_insurance", value: value)
    }
    func setEmail(_ value:String) {
        getHolder().setFieldValue(for: "email", value: value)
    }
    func setPhonePrefix(_ value:String) {
        getHolder().setFieldValue(for: "phone_prefix", value: value)
    }
    func setPhone(_ value:String) {
        getHolder().setFieldValue(for: "phone", value: value)
    }
    func setHomePhone(_ value:String) {
        getHolder().setFieldValue(for: "home_phone", value: value)
    }
    
    func setIsMonthlySalary(_ value:Bool) {
        getHolder().setFieldValue(for: "is_monthly_salary", value: value ? "true" : "false")
    }
    func setIsPayCheckTwoJobs(_ value:Bool) {
        getHolder().setFieldValue(for: "is_twojob_paycheck", value:  value ? "true" : "false")
    }
    func setIsDailySalary(_ value:Bool) {
        getHolder().setFieldValue(for: "is_daily_salary", value:  value ? "true" : "false")
    }
    func setIsPartialSalary(_ value:Bool) {
        getHolder().setFieldValue(for: "is_partial_salary", value:  value ? "true" : "false")
    }
    func setIsAllowance(_ value:Bool) {
        getHolder().setFieldValue(for: "is_allowance", value:  value ? "true" : "false")
    }
    func setIsScholarship(_ value:Bool) {
        getHolder().setFieldValue(for: "is_scholarship", value:  value ? "true" : "false")
    }
    
    
    /**
     Secondary Job Form Section:
     */
    
    func setHasNoOtherIncomes(_ value:Bool) {
        getHolder().setFieldValue(for: "has_no_other_incomes", value:  value ? "true" : "false")
    }
    func setHasOtherIncomes(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_incomes", value:  value ? "true" : "false")
    }
    func setHasOtherMonthlySalary(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_monthly_salary", value:  value ? "true" : "false")
    }
    func setIsOtherParitalSalary(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_parital_salary", value:  value ? "true" : "false")
    }
    func setMaskuretBeadNosefet(_ value:Bool) {
        getHolder().setFieldValue(for: "has_maskuret_bead_nosefet", value:  value ? "true" : "false")
    }
    func setHasOtherAllowance(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_allowance", value:  value ? "true" : "false")
    }
    func setHasOtherScholarship(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_scholarship", value:  value ? "true" : "false")
    }
    func setHasOtherSelfDefinedJob(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_self_defined_job", value:  value ? "true" : "false")
    }
    func setSelfDefinedJob(_ value:Bool) {
        getHolder().setFieldValue(for: "self_defined_job", value:  value ? "true" : "false")
    }
    func setIsOtherJobDayWorker(_ value:Bool) {
        getHolder().setFieldValue(for: "is_other_job_day_worker", value:  value ? "true" : "false")
    }
    func setIsAskingForPromotional(_ value:Bool) {
        getHolder().setFieldValue(for: "is_asking_promotional", value:  value ? "true" : "false")
    }
    func setHasOtherPromotional(_ value:Bool) {
        getHolder().setFieldValue(for: "has_other_promotional", value:  value ? "true" : "false")
    }
    func setHasNoKerenPensia(_ value:Bool) {
        getHolder().setFieldValue(for: "has_no_keren_pensia", value:  value ? "true" : "false")
    }
    func setHasNoPitzoim(_ value:Bool) {
        getHolder().setFieldValue(for: "has_no_pitzoim", value:  value ? "true" : "false")
    }
    
    
    
    
}
