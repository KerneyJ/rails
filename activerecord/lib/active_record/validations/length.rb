# frozen_string_literal: true
require 'pp'

module ActiveRecord
  module Validations
    class LengthValidator < ActiveModel::Validations::LengthValidator # :nodoc:
      def initialize(options)
        #pp options
        max = nil
        min = nil
        if options[:within]
          max = options[:within].end
          min = options[:within].begin
        else
          max = options[:maximum]
          min = options[:minimum]
        end

        file = File.open("/home/ubuntu/dse/policy-extraction-scripts/constraints_extactor/constraints", "a")
        c = LengthConstraint.new(options[:class].to_s, options[:attributes][0].to_s, min, max)
        file.puts c

        super
      end

      def validate_each(record, attribute, association_or_value)
        if association_or_value.respond_to?(:loaded?) && association_or_value.loaded?
          association_or_value = association_or_value.target.reject(&:marked_for_destruction?)
        end
        super
      end
    end

    module ClassMethods
      # Validates that the specified attributes match the length restrictions supplied.
      # If the attribute is an association, records that are marked for destruction are not counted.
      #
      # See ActiveModel::Validations::HelperMethods.validates_length_of for more information.
      def validates_length_of(*attr_names)
        validates_with LengthValidator, _merge_attributes(attr_names)
      end

      alias_method :validates_size_of, :validates_length_of
    end
  end
end
