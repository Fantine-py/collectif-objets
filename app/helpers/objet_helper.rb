# frozen_string_literal: true

module ObjetHelper
  def objet_first_image_or_recensement_photo_url(objet)
    return objet.palissy_photos.first["url"] if objet.palissy_photos.any?

    if objet.current_recensement&.photos&.attached? && can_see_recensement_for(objet)
      return objet.current_recensement.photos.first.variant(:medium)
    end

    "images/illustrations/photo-manquante.png"
  end

  def edifice_nom(nom)
    return nom.capitalize if nom.present?

    content_tag(:i, "Édifice non renseigné")
  end

  def link_to_palissy(objet)
    link_to(
      objet.palissy_REF,
      "https://www.pop.culture.gouv.fr/notice/palissy/#{objet.palissy_REF}",
      target: "_blank", rel: "noopener"
    )
  end

  private

  def can_see_recensement_for(objet)
    current_user&.commune == objet.commune
  end
end
