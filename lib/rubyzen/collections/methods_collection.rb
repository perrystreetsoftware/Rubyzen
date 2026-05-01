require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

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
    end
  end
end
