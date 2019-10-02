require "hc/permalink/version"
require "active_support/inflector/transliterate"
require "russian"

module Hc
  module Permalink

    @@shared_resource_classes = []

    def self.shared_resource_classes=(class_list)
      raise "Class list must be an array of classes" unless class_list.is_a?(Array)
      @@shared_resource_classes = class_list.dup
    end

    def self.shared_resource_classes
      @@shared_resource_classes.collect(&:constantize)
    end

    def self.generate_unique(value:, target_class:, target_field: 'permalink', ignore_id: nil, constraint: nil)

      # Create a base name which we will later increment
      #
      base_value    = self.from_string(value, remove_spaces: true).to_s[0..63]
      current_value = base_value
      counter       = 0

      # Loop on finding objects with these parameters until no object found
      #
      while self.locate_object(target_class: target_class, target_field: target_field, target_value: current_value, ignore_id: ignore_id, constraint: constraint)
        counter += 1
        current_value = "#{base_value[0..(63 - counter.to_s.length)]}#{counter}"
      end

      # Return the current generated value
      #
      return current_value

    end

    def self.from_string(value, remove_spaces: false)

      # Replace spaces and underscores with hyphens, then replace all
      # other common punctuation and symbols, then downcase the result
      #
      value = value.to_s.gsub(/[\s_]+/,'-').gsub(/[!"#$%&'\(\)*+,\.\/:;<=>?@\[\\\]\^_`{}¦|£¬~]+/, '').gsub(/[-]{2,}/, '-')
      value = value.gsub('-','') if remove_spaces

      # Attempt to Transliterate Russian and latin-based characters
      # with accents into their latin(ish) equivalents
      #
      value = I18n.transliterate(Russian::transliterate(value).gsub('ș', 's').gsub('ț', 't').gsub('ồ', 'o').gsub('ế', 'e').gsub('ộ', 'o').gsub('ạ', 'a')).downcase.gsub("?", "")

      # Return the resulting slug, but remove any trailing hyphens
      #
      return value[/[\w-]*\w/]

    end

    def self.simple(value)
      value.to_s.gsub(/[\s-]+/,'_').gsub(/[^\w]+/, '').downcase
    end

    private

    def self.locate_object(target_class:, target_field:, target_value:, ignore_id:, constraint:)
      self.find_object(
        target_class: target_class,
        target_field: target_field,
        target_value: target_value,
        ignore_id:    ignore_id,
        constraint:   constraint
      ) || self.taken_by_shared_resource?(
        target_class: target_class,
        value:        target_value,
        ignore_own:   true
      )
    end

    def self.taken_by_shared_resource?(target_class:, value:, ignore_own: false)

      # No need to check presence of values for irelevent classes
      #
      return false unless @@shared_resource_classes.include?(target_class)

      # Identify and class search space
      #
      classes_to_search = @@shared_resource_classes.dup
      classes_to_search = classes_to_search.reject{|k|k==target_class} if ignore_own

      # Loop on search space and try to find something
      #
      classes_to_search.each do |shared_target_class|
        found_object = shared_target_class.find_by_shared_resource_identifier(value)
        return true if !found_object.nil?
      end

      # Fall back to false if nothing was found
      #
      return false

    end

    def self.find_object(target_class:, target_field:, target_value:, ignore_id: nil, constraint: nil)

      # Ensure that the constraint matches the following format:
      # constraint: {key: value}
      #
      if !constraint.nil?
        raise "constraint must be a hash containing only one key" if !constraint.is_a?(Hash) || constraint.keys.count > 1
      end

      # Attempt to find objects matching these constraints
      #
      if !constraint.nil?
        located_objects = target_class.where(target_field.to_sym => target_value).where.not(id: ignore_id).where(constraint)
      else
        located_objects = target_class.where(target_field.to_sym => target_value).where.not(id: ignore_id)
      end

      # Return any results of our lookup
      #
      return located_objects.count > 0 ? located_objects.first : nil

    end

  end
end
