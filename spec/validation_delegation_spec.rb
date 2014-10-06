require "active_model"
require "validation_delegation"

class TestClass ; end

class Validator
  include ActiveModel::Validations
end

RSpec::Matchers.define :have_error do |message|
  match do |actual|
    actual.errors[@attribute].include?(message)
  end

  chain :on do |attribute|
    @attribute = attribute
  end
end

describe ValidationDelegation do
  let(:validator) { Validator.new }
  let(:test) { TestClass.new }

  before do
    Object.send(:remove_const, "TestClass")

    class TestClass
      include ActiveModel::Validations
      include ValidationDelegation
    end

    allow(validator).to receive(:valid?).and_return(false)
    validator.errors[:attr] << "is invalid"
    allow(test).to receive(:validator).and_return(validator)
  end

  subject { test.tap(&:valid?) }

  it "copies errors from the validator to itself" do
    TestClass.delegate_validation to: :validator
    expect(subject).to have_error("is invalid").on(:attr)
  end

  it "copies all errors" do
    validator.errors[:attr] << "is bananas"
    TestClass.delegate_validation to: :validator

    expect(subject).to have_error("is invalid").on(:attr)
    expect(subject).to have_error("is bananas").on(:attr)
  end

  it "copies errors if the :if option is true" do
    allow(test).to receive(:validate?).and_return(true)
    TestClass.delegate_validation to: :validator, if: :validate?
    expect(subject).to have_error("is invalid").on(:attr)
  end

  it "does not copy errors if the :if option is false" do
    allow(test).to receive(:validate?).and_return(false)
    TestClass.delegate_validation to: :validator, if: :validate?
    expect(subject).to_not have_error("is invalid").on(:attr)
  end

  it "copies errors if the :unless option is false" do
    allow(test).to receive(:validate?).and_return(false)
    TestClass.delegate_validation to: :validator, unless: :validate?
    expect(subject).to have_error("is invalid").on(:attr)
  end

  it "does not copy errors if the :unless option is true" do
    allow(test).to receive(:validate?).and_return(true)
    TestClass.delegate_validation to: :validator, unless: :validate?
    expect(subject).to_not have_error("is invalid").on(:attr)
  end

  it "does not copy errors for excluded attributes" do
    allow(test).to receive(:validate?).and_return(true)
    TestClass.delegate_validation to: :validator, except: :attr
    expect(subject).to_not have_error("is invalid").on(:attr)
  end

  it "only copies errors for specified attributes" do
    allow(test).to receive(:validate?).and_return(true)
    TestClass.delegate_validation to: :validator, only: :attr
    expect(subject).to have_error("is invalid").on(:attr)
  end

  context "an method is supplied" do
    it "copies errors to the specified method and prefixes the attribute name" do
      TestClass.delegate_validation :my_method, to: :validator
      expect(subject).to have_error("attr is invalid").on(:my_method)
    end

    it "copies all errors" do
      allow(validator).to receive(:errors).and_return({attr: ["is invalid", "is bananas"]})
      TestClass.delegate_validation :my_method, to: :validator

      expect(subject).to have_error("attr is invalid").on(:my_method)
      expect(subject).to have_error("attr is bananas").on(:my_method)
    end

    it "reformats nested attribute errors" do
      TestClass.delegate_validation :my_method, to: :validator
      validator.errors[:"associated_class.attribute"] << "is bananas"

      expect(subject).to have_error("associated class attribute is bananas").on(:my_method)
    end

    it "copies errors if the :if option is true" do
      allow(test).to receive(:validate?).and_return(true)
      TestClass.delegate_validation :my_method, to: :validator, if: :validate?

      expect(subject).to have_error("attr is invalid").on(:my_method)
    end

    it "does not copy errors if the :if option is false" do
      allow(test).to receive(:validate?).and_return(false)
      TestClass.delegate_validation :my_method, to: :validator, if: :validate?
      expect(subject).to_not have_error("attr is invalid").on(:my_method)
    end

    it "copies errors if the :unless option is false" do
      allow(test).to receive(:validate?).and_return(false)
      TestClass.delegate_validation :my_method, to: :validator, unless: :validate?
      expect(subject).to have_error("attr is invalid").on(:my_method)
    end

    it "does not copy errors if the :unless option is true" do
      allow(test).to receive(:validate?).and_return(true)
      TestClass.delegate_validation :my_method, to: :validator, unless: :validate?
      expect(subject).to_not have_error("attr is invalid").on(:my_method)
    end

    it "does not copy errors for excluded attributes" do
      allow(test).to receive(:validate?).and_return(true)
      TestClass.delegate_validation :my_method, to: :validator, except: :attr
      expect(subject).to_not have_error("attr is invalid").on(:my_method)
    end

    it "only copies errors for specified attributes" do
      allow(test).to receive(:validate?).and_return(true)
      TestClass.delegate_validation :my_method, to: :validator, only: :attr
      expect(subject).to have_error("attr is invalid").on(:my_method)
    end
  end

end