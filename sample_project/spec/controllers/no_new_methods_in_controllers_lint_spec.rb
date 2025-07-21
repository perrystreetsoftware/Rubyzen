require 'rspec'
require 'rubyzen'

RSpec.describe 'Controller method restrictions' do
  let(:project) { Rubyzen::Project.new }
  let(:controller_classes) { project.classes_in_path('src/controllers') }

  let(:allowed_public_methods) do
    %i[enqueue execute execute_and_enqueue should_enqueue?]
  end

  let(:allowed_private_methods) do
    %i[components request service response presenter respond_with
       job_config enqueue_job queue_adapter deferred_component]
  end

  let(:allowed_class_methods) do
    %i[components request service response presenter job]
  end

  context "given controller classes" do
    let(:violations) do
      all_violations = []

      controller_classes.each do |controller_class|
        # Check instance methods (public and private combined)
        instance_method_names = controller_class.methods.map(&:name)
        allowed_instance_methods = (allowed_public_methods + allowed_private_methods).map(&:to_s) + ['initialize']

        # Apply allowlist for instance methods
        file_path_without_prefix = controller_class.file_path.to_s.sub(/^\.\/target_project\//, '')
        allowlisted_instance_methods = CONTROLLER_INSTANCE_METHOD_ALLOWLIST[file_path_without_prefix] || []
        unauthorized_instance_methods = instance_method_names - allowed_instance_methods - allowlisted_instance_methods

        unless unauthorized_instance_methods.empty?
          all_violations << "#{controller_class.file_path}: unauthorized instance methods: #{unauthorized_instance_methods.join(', ')}"
        end

        # Check class methods
        class_method_names = controller_class.class_methods.map(&:name)

        # Apply allowlist for class methods
        allowlisted_class_methods = CONTROLLER_CLASS_METHOD_ALLOWLIST[file_path_without_prefix] || []
        unauthorized_class_methods = class_method_names - allowed_class_methods.map(&:to_s) - allowlisted_class_methods

        unless unauthorized_class_methods.empty?
          all_violations << "#{controller_class.file_path}: unauthorized class methods: #{unauthorized_class_methods.join(', ')}"
        end
      end

      all_violations
    end

    it "only defines allowed methods" do
      expect(violations).to be_empty,
        "Controllers define unauthorized methods:\n#{violations.join("\n")}"
    end
  end
end

CONTROLLER_INSTANCE_METHOD_ALLOWLIST = {
  'src/controllers/accounts/register_factory.rb' => %w[
    new controller lurker_visitor? device device_id register_authenticated_controller
  ],
  'src/controllers/album_images/create.rb' => %w[
    transcode_job_params
  ],
  'src/controllers/feeds/media_upload.rb' => %w[
    dbwriter_params
  ],
  'src/controllers/stores/apple_purchase_factory.rb' => %w[
    new controller device device_id
  ],
  'src/controllers/test/index.rb' => %w[
    some_other_method
  ],
  'src/controllers/tickets/show.rb' => %w[
    ticket_template_from_flavor layout_from_flavor
  ]
}.freeze

CONTROLLER_CLASS_METHOD_ALLOWLIST = {
  'src/controllers/test/index.rb' => %w[
    some_class_method
  ]
}.freeze
