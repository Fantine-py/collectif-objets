# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    def initialize(objet:, recensement: nil)
      @objet = objet
      @recensement = recensement
      super
    end

    def call
      render ::ObjetCardComponent.new(objet:, badges:, main_photo_url: recensement_photo_url, path:, tags:)
    end

    attr_reader :objet, :recensement

    def path
      if recensement
        edit_conservateurs_objet_recensement_analyse_path(objet, recensement)
      else
        objet_path(objet)
      end
    end

    def badges
      @badges ||= [analysed_badge, prioritaire_badge].compact
    end

    def tags
      @tags ||= [not_recensed_badge, missing_photos_badge].compact
    end

    def recensement_photo_url
      recensement&.photos&.first&.variant(:medium)
    end

    def badge_struct
      Struct.new(:color, :text)
    end

    def not_recensed_badge
      badge_struct.new("warning", "Pas encore recensé") if recensement.nil?
    end

    def missing_photos_badge
      return nil unless recensement&.missing_photos?

      badge_struct.new(
        "warning", I18n.t("recensement.photos.missing")
      )
    end

    def analysed_badge
      return nil unless recensement&.analysed?

      badge_struct.new(
        "success",
        I18n.t("conservateurs.objet_card_component.analysed_badge")
      )
    end

    def prioritaire_badge
      return nil unless recensement&.prioritaire?

      badge_struct.new(
        "warning",
        I18n.t("conservateurs.objet_card_component.prioritaire_badge")
      )
    end
  end
end
