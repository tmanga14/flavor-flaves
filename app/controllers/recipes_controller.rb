class RecipesController < ApplicationController
  before_action :authenticate_user!, :except => [:index]

  def index
    if params[:user_id]
      @recipes = User.find_by(params[:id]).recipes
    elsif params[:ingredient] && params[:ingredient][:name] != ""
      @recipes = Ingredient.find_by(name: params[:ingredient][:name]).recipes.all
    else
      @recipes = Recipe.all
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      recipe_params[:ingredients_attributes].each do |ingredient_index|
        if recipe_params[:ingredients_attributes][ingredient_index][:name] != ""
          ingredient = Ingredient.find_by(name: recipe_params[:ingredients_attributes][ingredient_index][:name])
          recipe_ingredient = RecipeIngredient.find_by(recipe_id: @recipe.id, ingredient_id: ingredient.id)
          recipe_ingredient.quantity = recipe_params[:ingredients_attributes][ingredient_index][:recipe_ingredients_attributes][ingredient_index][:quantity]
          recipe_ingredient.save
        end
      end
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    if params[:user_id] && params[:id]
      ur = UserRecipe.find_by(user_id: params[:user_id], recipe_id: params[:id])
      if ur
        ur.destroy
        redirect_to root_path
      else
        UserRecipe.create(user_id: params[:user_id], recipe_id: params[:id])
        redirect_to root_path
      end
    else
      @recipe = Recipe.find(params[:id])
    end
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to recipe_path(@recipe)
    else
      render :edit
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title,
                                  :directions,
                                  ingredient_ids:[],
                                  ingredients_attributes: [:name, recipe_ingredients_attributes: [:quantity]])
  end
end
