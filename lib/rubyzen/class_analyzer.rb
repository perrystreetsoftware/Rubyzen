module Rubyzen
  class ClassAnalyzer
    def initialize(processed_source)
      @processed_source = processed_source
    end

    def analyze
      @processed_source.ast.each_node(:class).map do |class_node|
        Rubyzen::Project::ClassInfo.new(
          name: class_node.identifier&.const_name,
          superclass_name: extract_superclass_name(class_node),
          constants_referenced: constants_referenced_in(class_node),
          file_path: @processed_source.path,
          method_names: extract_method_names(class_node),
          top_level_module: find_top_level_module(@processed_source.ast),
          called_method_names: extract_called_method_names(class_node),
          call_sites: extract_call_sites(class_node)
        )
      end
    end

    private

    def extract_superclass_name(class_node)
      super_node = class_node.children[1]
      return nil unless super_node && super_node.type == :const
      super_node.const_name
    end

    def constants_referenced_in(class_node)
      class_node.each_descendant(:const).map(&:const_name).uniq
    end

    def extract_method_names(class_node)
      class_node.each_node(:def).map { |def_node| def_node.method_name.to_s }
    end

    def find_top_level_module(ast)
      module_node = ast.children.find { |child| child.is_a?(RuboCop::AST::Node) && child.module_name? }
      return unless module_node
      module_node.const_name
    end

    def extract_called_method_names(class_node)
      class_node.each_descendant(:send).map { |send_node| send_node.method_name.to_s }.uniq
    end

    def extract_call_sites(class_node)
      class_node.each_descendant(:send).map do |send_node|
        {
          receiver: extract_receiver_name(send_node),
          method_name: send_node.method_name.to_s,
          keyword_args: extract_keyword_args(send_node),
          line: send_node.loc.expression.line
        }
      end
    end

    def extract_receiver_name(send_node)
      recv_node = send_node.receiver
      recv_node&.type == :const ? recv_node.const_name : nil
    end

    def extract_keyword_args(send_node)
      send_node.arguments.flat_map do |arg|
        if arg.hash_type?
          arg.each_pair.map do |pair|
            key_node = pair.key
            key_node.type == :sym ? key_node.value : nil
          end.compact
        else
          []
        end
      end.uniq
    end
  end
end
