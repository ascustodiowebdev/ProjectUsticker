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

  ######## CART STARTS HERE ############

  def add_to_cart
    @sticker = Sticker.find(params[:id])
    session[:cart] ||= []
    session[:cart] << @sticker.id
    redirect_to stickers_path, notice: 'Sticker added to cart.'
  end

  def cart
    @cart_stickers = Sticker.find(session[:cart] || [])
  end

  def view_cart
    @cart_stickers = Sticker.find(session[:cart] || [])
    @cart_total = calculate_cart_total(@cart_stickers)
    @cart = @cart_stickers.map { |sticker| { id: sticker.id, name: sticker.name, price: sticker.price } }
  end


  def remove_from_cart
    @sticker = Sticker.find(params[:id])

    # Initialize the cart if it is nil
    session[:cart] ||= {}

    # Retrieve the cart from the session
    @cart = session[:cart]

    # Remove the sticker from the cart
    @cart.delete(@sticker.id)

    # Save the updated cart in the session
    session[:cart] = @cart

    redirect_to cart_path, notice: 'Sticker removed from cart.'
  end



  def checkout
    @cart_stickers = Sticker.find(cart)
    @cart_total = calculate_cart_total
    @order = Order.new # Create a new instance of the Order model (assuming you have an Order model)
  end

  def process_order
    # Retrieve the necessary information from the checkout form
    full_name = params[:order][:full_name]
    email = params[:order][:email]
    address = params[:order][:address]
    phone_number = params[:order][:phone_number]

    # Create a new Order object and assign the information
    @order = Order.new(
      full_name: full_name,
      email: email,
      address: address,
      phone_number: phone_number
    )

    # Add the stickers from the cart to the order (assuming you have a cart method)
    @cart_stickers = Sticker.find(cart)
    @order.stickers << @cart_stickers
    if @order.save
      # Clear the cart after the order is successfully processed
      session[:cart] = []

      # Optionally, redirect to a confirmation page or display an order summary
      redirect_to order_confirmation_path(@order)
    else
      # Handle the case where order creation fails, such as displaying an error message or redirecting back to the checkout page
      redirect_to checkout_path, alert: 'Failed to process the order.'
    end
  end

  private

  def sticker_params
    params.require(:sticker).permit(:name, :description, :price, :image)
  end

  def calculate_cart_total(cart_stickers)
    cart_stickers.sum(&:price)
  end
end
