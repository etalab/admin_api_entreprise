RSpec.shared_context 'when using rake mute tasks' do
  let(:original_stderr) { $stderr }
  let(:original_stdout) { $stdout }
  let(:dev_null_stderr) { File.open(File::NULL, 'w') }
  let(:dev_null_stdout) { File.open(File::NULL, 'w') }

  before do
    Rails.application.load_tasks

    $stderr = dev_null_stderr
    $stdout = dev_null_stdout

    Rake::Task[task_name].clear if Rake::Task.task_defined?(task_name)
    namespace = task_name.split(':').first
    Rake.application.rake_require("tasks/#{namespace}")
  end

  after do
    dev_null_stderr.close
    dev_null_stdout.close
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
