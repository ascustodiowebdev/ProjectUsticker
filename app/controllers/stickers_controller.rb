class StickersController < ApplicationController

  def new
    @sticker = Sticker.new
  end

  def create
    @sticker = Sticker.new(sticker_params)
    if params[:sticker][:image].present?
      uploaded_image = params[:sticker][:image].tempfile
      Cloudinary::Uploader.upload(uploaded_image)
      # @sticker.image.attach(io: File.open(uploaded_image), filename: cloudinary_result['original_filename'])
    end

    if @sticker.save
      redirect_to @sticker
    else
      render 'new'
    end
  end


  def show
    @sticker = Sticker.find(params[:id])
  end

  def edit
    @sticker = Sticker.find(params[:id])
  end

  def update
    @sticker = Sticker.find(params[:id])
    # Check if a new image is present and different from the old one
    if params[:sticker][:image].present? && params[:sticker][:image] != @sticker.image
      # Remove old image if it exists
      @sticker.image.purge

      # Upload new image to Cloudinary
      @sticker.image.attach(params[:sticker][:image])
    end

    if @sticker.update(sticker_params)
      redirect_to @sticker, notice: 'Sticker was successfully updated.'
    else
      render :edit
    end
  end

  def index
    @stickers = Sticker.all
  end

  def destroy
    @sticker = Sticker.find(params[:id])
    @sticker.destroy
    redirect_to stickers_path
  end

  def add_to_cart
    @sticker = Sticker.find(params[:id])
    cart << @sticker.id
    redirect_to stickers_path, notice: 'Sticker added to cart.'
  end

  def cart
    @cart = session[:cart] || []
    @cart_total = calculate_cart_total
  end

  def view_cart
    @cart_stickers = Sticker.find(cart)
  end

  def remove_from_cart
    @sticker = Sticker.find(params[:id])
    cart.delete(@sticker.id)
    redirect_to cart_path, notice: 'Sticker removed from cart.'
  end

  private

  def sticker_params
    params.require(:sticker).permit(:name, :description, :price, :image)
  end

end
