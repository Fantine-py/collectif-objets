class ObjetDecorator < Draper::Decorator
  include ActionView::Helpers
  delegate_all

  def display_name
    "#{ref_pop} · #{truncate(nom, length: 30)}"
  end

  def commune
    super&.decorate
  end

  def image_urls
    return nil if super&.empty?

    "<img src=\"#{super.first}\" style=\"max-width: 150px; max-height: 150px;\" />".html_safe
  end
end
