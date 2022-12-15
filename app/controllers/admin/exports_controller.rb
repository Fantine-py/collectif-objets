# frozen_string_literal: true

module Admin
  class ExportsController < BaseController
    Export = Struct.new(:departement_code, keyword_init: true)

    def new
      @export = Export.new(departement_code: params[:departement_code])
      return unless @export.departement_code

      set_instance_vars
    end

    def create
      redirect_to new_admin_export_path(departement_code: params[:export][:departement_code])
    end

    private

    def set_instance_vars
      @dossiers = Dossier
        .in_departement(@export.departement_code)
        .accepted
        .order("communes.nom ASC")
        .includes(recensements: %i[photos_attachments photos_blobs objet])
      @recensements = @dossiers.to_a.map(&:recensements).flatten
        .select { _1.recensable? || _1.absent? }
      @photos = @recensements.map(&:photos).flatten
    end
  end
end
