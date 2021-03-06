# API controller in charge of the questionnaire:
#
# Responds with json
module API
class QuestionnaireController < ApplicationController

  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, KeyError, with: :verses_not_found

  # It responds with all Relationships whose names match the search string parameter
  #
  # Used in conjonction with angular-ui bootstrap typeahead
  def relationship
    if typeahead_params[:search].blank?
      respond_with [], status: :bad_request and return
    else
      #relationships = Relationship.where("LOWER(name) like ?", "%#{typeahead_params[:search].downcase}%").pluck(:name)
      relationships = Relationship.name_like("%#{typeahead_params[:search]}%")
    end
    if relationships.present?
      respond_with relationships
    else
      respond_with relationships, status: :no_content
    end
  end

  # It responds with all Traits whose name match the search string parameter
  #
  # Used in conjonction with angular-ui bootstrap typeahead
  def trait
    if typeahead_params[:search].blank?
      respond_with [], status: :bad_request and return
    else
      traits = TraitCategory.name_like("%#{typeahead_params[:search]}%")
    end
    if traits.present?
      respond_with traits
    else
      respond_with traits, status: :no_content
    end
  end

  # It responds with all Messages whose name match the search string parameter
  #
  # Used in conjonction with angular-ui bootstrap typeahead
  def message
    if typeahead_params[:search].blank?
      respond_with [], status: :bad_request and return
    else
      #messages = MessageCategory.where("LOWER(name) like ?", "%#{typeahead_params[:search].downcase}%").pluck(:name)
      messages = MessageCategory.name_like("%#{typeahead_params[:search]}%")
    end
    if messages.present?
      respond_with messages
    else
      respond_with messages, status: :no_content
    end
  end

# Validates the questionnaire, builds and returns the poem as JSON
#
# ==== Attributes
#
# * +receiver_name+ - String containing the receiver's name
# * +receiver_sex+ - Integer representing the receiver's sex (1: male, 2: female)
# * +location+ - String containing the receiver's location
# * +relationship+ - String containing the relation to the receiver
# * +trait+ - String containing the Trait's name
# * +message+ - String containing the Message's name
  def poem
    questionnaire = Questionnaire.new(questionnaire_form_params)
    response_params = {}
    if questionnaire.valid?
      rawVerses = VerseSelector.select_verses(questionnaire.trait_category, questionnaire.message_category)
      poem = PoemCustomizer.customize_poem(rawVerses, questionnaire)
      response_params[:success] = true
      response_params[:poem] = poem
      render json: response_params
    else
      response_params[:success] = false
      response_params[:errors] = questionnaire.errors
      render json: response_params
    end
  end

  protected

  # Override the verified_request? method to also read the token from header X-XSRF-TOKEN
  # See: # See: https://docs.angularjs.org/api/ng/service/$http#cross-site-request-forgery-xsrf-protection
  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  private

  # Is called when a ActiveRecord::RecordNotFound exception is raised in this controller
  # Logs error and renders an error message page
  def verses_not_found(ex)
    logger.error "Exception raised in questionnaire_controller.rb: Exception #{ex.class}: #{ex.message}"
    response_params = {
      success: false,
      errors: { error_text: "Sorry, a problem occured and the poem couldn't be built. Please try again." }
    }
    render json: response_params
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def typeahead_params
    params.permit(:search)
  end

  def questionnaire_form_params
    params.require(:questionnaire).permit(:receiver_name, :receiver_sex, :location, :relationship, :trait_category, :message_category)
  end
end
end
