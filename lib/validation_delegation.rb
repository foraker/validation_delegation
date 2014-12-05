require "validation_delegation/version"
require "active_support"
require "active_support/core_ext"

module ValidationDelegation
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def receive_errors(attribute, object_attribute, errors)
    Array.wrap(errors).each{ |error| receive_error attribute, object_attribute, error }
  end

  def receive_error(attribute, object_attribute, error)
    attribute ? receive_error_on_attribute(attribute, object_attribute, error) : receive_error_on_self(object_attribute, error)
  end

  def receive_error_on_attribute(attribute, prefix, error)
    errors[attribute] << [format_attribute(prefix), error].join(" ")
  end

  def receive_error_on_self(attribute, error)
    errors[attribute] << error
  end

  def format_attribute(attribute_name)
    self.class.human_attribute_name(attribute_name).downcase
  end

  module ClassMethods
    def delegate_validation(*args)
      if args.first.is_a?(Hash)
        transplant_errors(args.first)
      else
        transplant_errors(args.last.merge(attribute: args.first))
      end
    end

    def transplant_errors(options)
      validate lambda {
        return unless send(options[:if]) if options[:if]
        return if send(options[:unless]) if options[:unless]

        object = send(options[:to])
        ErrorTransplanter.new(self, object, options).transplant unless object.valid?
      }
    end
  end

  class ErrorTransplanter
    delegate :errors, to: :donor
    delegate :receive_errors, to: :recipient

    attr_accessor :recipient, :donor, :options

    def initialize(recipient, donor, options)
      self.recipient = recipient
      self.donor     = donor
      self.options   = options
    end

    def transplant
      errors.each do |object_attribute, object_errors|
        next if ignore_attribute? object_attribute
        receive_errors options[:attribute], object_attribute, object_errors
      end
    end

    def ignore_attribute?(attribute)
      excepted_attribute?(attribute) || !specified_attribute?(attribute)
    end

    def excepted_attribute?(attribute)
      Array.wrap(options[:except]).include?(attribute.to_sym)
    end

    def specified_attribute?(attribute)
      return true unless options[:only]
      Array.wrap(options[:only]).include?(attribute.to_sym)
    end
  end
end
