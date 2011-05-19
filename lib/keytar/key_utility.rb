# Monkey patches for Object#blank?, Object.present? and String#pluralize
# If active support is required, this won't be used, but
# we shouldn't require a ruby project to use ActiveSupport
# just for these three simple things

module KeyUtility
  unless Object.respond_to?(:blank?)
    Object.class_eval do
      def blank?
        respond_to?(:empty?) ? empty? : !self
      end

      def present?
        !blank?
      end
    end
  end

  unless String.respond_to? :pluralize
    String.class_eval do
      def pluralize
        self[(self.length - 1), 1] =~ /s/i ? self : "#{self}s"
      end
    end
  end
end