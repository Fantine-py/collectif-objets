# frozen_string_literal: true

class RecensementsController < ApplicationController
  before_action :set_objet, :restrict_commune
  before_action :restrict_recensable, only: %i[new create]
  before_action :set_recensement, :restrict_editable, only: %i[edit update]
  before_action :restrict_already_recensed, only: [:create]

  def new
    @recensement = Recensement.new(objet: @objet, recensable: "true")
  end

  def edit
    @recensement.confirmation = true
    @recensement.skip_photos = true if @recensement.photos.empty?
  end

  def create
    result = Communes::CreateRecensementService
      .new(params: recensement_params, objet: @objet, user: current_user)
      .perform
    if result.success?
      redirect_to commune_objets_path(@objet.commune, recensement_saved: true, objet_id: @objet.id)
    else
      @recensement = result.recensement
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @recensement.confirmation = true
    if @recensement.update(recensement_params)
      redirect_to commune_objets_path(@objet.commune, recensement_saved: true, objet_id: @objet.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def set_objet
    @objet = Objet.find(params[:objet_id])
  end

  def set_recensement
    @recensement = Recensement.find(params[:id])
  end

  def recensement_params
    @recensement_params ||= Co::Recensements::ParamsParser.new(params).parse
  end

  def restrict_commune
    return true if current_user&.commune == @objet.commune

    redirect_to objet_path(@objet), alert: "Vous n'êtes pas autorisé à recenser cet objet"
  end

  def restrict_recensable
    return true if @objet.recensable?

    redirect_to objet_path(@objet), alert: "Le recensement de votre commune est déjà terminé."
  end

  def restrict_editable
    return true if @recensement.editable?

    redirect_to objet_path(@objet), alert: "Ce recensement ne peut plus être édité."
  end

  def restrict_already_recensed
    raise "Objet déjà recensé" if @objet.recensements.any?
  end
end
