require 'rails_helper'

RSpec.describe API::FilesController, type: :request do
  let(:file_name) { 'whatever' }
  let(:file_content) { 'whatever-anything' }
  let(:file_path) { Rails.public_path.join('files', file_name) }

  before do
    described_class.instance_eval { remove_const(:PUBLIC_FILES) }
    described_class::PUBLIC_FILES = [file_path].freeze
    File.write(file_path, file_content)
  end

  after do
    File.delete(file_path)
  end

  describe 'show' do
    context 'when file exists' do
      it 'shows a file inline' do
        get "/fichiers/#{file_name}"

        expect(response.headers['Content-Disposition']).to eq("inline; filename=\"#{file_name}\"; filename*=UTF-8''#{file_name}")
        expect(response.body).to eq(file_content)
      end
    end

    context 'when file doesnt exist' do
      it '404' do
        get '/fichiers/telechargement/not_existing_file'

        expect(response.code).to eq('404')
      end
    end
  end

  describe 'download' do
    it 'downloads a file' do
      get "/fichiers/telechargement/#{file_name}"

      expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{file_name}\"; filename*=UTF-8''#{file_name}")
      expect(response.body).to eq(file_content)
    end
  end
end
