class API::FilesController < APIController
  PUBLIC_FILES = Rails.public_path.join('files').children

  def show
    if file
      send_file file, disposition: :inline
    else
      render json: { error: 'Fichier non trouvé' }, status: :not_found
    end
  end

  def download
    if file
      send_file file, disposition: :attachment
    else
      render json: { error: 'Fichier non trouvé' }, status: :not_found
    end
  end

  private

  def file
    PUBLIC_FILES.find do |public_file|
      filename_from_path_without_extension(public_file) == file_params[:file_name]
    end
  end

  def filename_from_path_without_extension(filename)
    filename.basename.to_s.split('.').first
  end

  def file_params
    {
      file_name: params.require(:file_name)
    }
  end
end
