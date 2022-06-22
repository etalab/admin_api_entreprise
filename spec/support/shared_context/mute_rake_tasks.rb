RSpec.shared_context 'when using rake mute tasks' do
  let(:original_stderr) { $stderr }
  let(:original_stdout) { $stdout }

  before do
    Rails.application.load_tasks

    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')

    # Clear rake task from memory if it was already loaded
    # This ensures rake task is loaded only once
    Rake::Task[task_name].clear if Rake::Task.task_defined?(task_name)
    # load rake task only once here
    namespace = task_name.split(':').first
    Rake.application.rake_require("tasks/#{namespace}")
  end

  after do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
