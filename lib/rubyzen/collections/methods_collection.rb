module Rubyzen
  module Collections
    # Collection of method declarations with access to parameters,
    # call sites, if statements, rescues, and raises within each method.
    #
    # @example Ensuring no method has more than 5 parameters
    #   controllers.all_methods.each { |m| expect(m.parameters.size).to be <= 5 }
    class MethodsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Returns all parameters across every method.
      #
      # @return [ParametersCollection]
      def parameters
        ParametersCollection.new(
          flat_map do |method|
            method.parameters
          end
        )
      end

      # Returns all if-statement declarations across every method.
      #
      # @return [DeclarationCollection]
      def if_statements
        DeclarationCollection.new(
          flat_map do |method|
            method.if_statements
          end
        )
      end

      # Returns all call sites across every method.
      #
      # @return [CallSiteCollection]
      def call_sites
        CallSiteCollection.new(
          flat_map do |method|
            method.call_sites
          end
        )
      end

      # Returns all rescue declarations across every method.
      #
      # @return [RescuesCollection]
      def rescues
        RescuesCollection.new(
          flat_map do |method|
            method.rescues
          end
        )
      end

      # Returns all raise declarations across every method.
      #
      # @return [RaisesCollection]
      def raises
        RaisesCollection.new(
          flat_map do |method|
            method.raises
          end
        )
      end

      # Returns all return points across every method.
      #
      # @return [ReturnsCollection]
      def returns
        ReturnsCollection.new(
          flat_map do |method|
            method.returns
          end
        )
      end

      # Returns all return expressions across every method.
      #
      # @return [ExpressionsCollection]
      def return_expressions
        returns.expressions
      end

      # Returns all local-variable assignments across every method.
      #
      # @return [AssignmentsCollection]
      def assignments
        AssignmentsCollection.new(
          flat_map do |method|
            method.assignments
          end
        )
      end
    end
  end
end
