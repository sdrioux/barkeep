class Api::V1::SearchesController < ApplicationController
  def index
    searches = Search.all.order(updated_at: :desc)

    results = SearchSerializer.new(searches).serializable_hash
    render json: results, status: 200
  end
end