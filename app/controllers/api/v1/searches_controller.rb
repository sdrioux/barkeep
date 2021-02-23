class Api::V1::SearchesController < ApplicationController
  api :GET, '/v1/searches'
  def index
    searches = Search.all.order(updated_at: :desc)
    results = SearchSerializer.new(searches).serializable_hash

    render json: results, status: 200
  end

  api :GET, '/v1/searches/:id'
  param :id, :number, required: true, desc: 'id of the requested search object'
  def show
    search = Search.find(params[:id])
    result = SearchSerializer.new(search).serializable_hash

    render json: result, status: 200
  end

  api :DELETE, '/v1/searches/:id'
  param :id, :number, required: true, desc: 'id of the search object to be deleted'
  def destroy
    search = Search.find(params[:id])
    search.destroy

    render json: "Search has been deleted", status: 200
  end

  api :POST, '/v1/searches'
  param :cocktail, Hash, required: true do
    param :query, String, required: true
  end
  def create
    query = cocktail_params[:query]
    existing_search = Search.find_by(query: query)
    # if search is already in the database we'll just return that
    render json: existing_search, status: 200 if existing_search

    cocktail_search = cocktail_service(query)
    results = JSON.parse(cocktail_search.response.body)
    search = create_search(query, cocktail_search.url, results)

    render json: search, status: 200
  end

  private

  def cocktail_params
    params.require(:cocktail).permit(:query)
  end

  def create_search(query, url, results)
    Search.create!(query: query, url: url, results: results)
  end

  def cocktail_service(query)
    CocktailService.new(query)
  end
end
