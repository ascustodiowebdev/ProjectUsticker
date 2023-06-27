class StickersController < ApplicationController
  require_dependency 'order'

  def new
    @sticker = Sticker.new
  end

  def create
    @sticker = Sticker.new(sticker_params)
    if params[:sticker][:image].present?
      uploaded_image = params[:sticker][:image].tempfile
      Cloudinary::Uploader.upload(uploaded_image)
      # Commented out code for attaching the image to the sticker
      # Uncomment and modify according to your needs
      # ...
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
    sticker_id = params[:id].to_i

    session[:cart] ||= []
    @cart = session[:cart]

    @cart << sticker_id

    session[:cart] = @cart

    redirect_to cart_path, notice: 'Sticker added to cart.'
  end

  def view_cart
    @cart = session[:cart] || []

    if @cart.empty?
      @cart_stickers = []
      @cart_total = 0
    else
      sticker_ids = @cart.uniq
      @cart_stickers = Sticker.where(id: sticker_ids)
      @cart_total = calculate_cart_total(@cart_stickers, @cart)
    end
  end

  def remove_from_cart
    sticker_id = params[:id].to_i

    session[:cart] ||= []
    @cart = session[:cart]

    if @cart.include?(sticker_id)
      @cart.delete_at(@cart.index(sticker_id))
    end

    session[:cart] = @cart

    redirect_to cart_path, notice: 'Sticker removed from cart.'
  end


  def checkout
    sticker_ids = session[:cart] || []
    @cart_stickers = Sticker.where(id: sticker_ids)
    @cart_total = calculate_cart_total(@cart_stickers, sticker_ids)
    @order = Order.new # Create a new instance of the Order model (assuming you have an Order model)
  end


  def process_order
    # Retrieve the necessary information from the checkout form
    name = params[:order][:full_name]
    email = params[:order][:email]
    phone_number = params[:order][:phone_number]
    address = params[:order][:address]

    # Create a new Order object and assign the information
    @order = Order.new(
      name: name,
      email: email,
      address: address,
      phone_number: phone_number
    )

    # Add the stickers from the cart to the order
    sticker_ids = session[:cart] || []
    @cart_stickers = Sticker.where(id: sticker_ids)
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


  def order_confirmation
    @order = Order.find(params[:id])
  end

  private

  def sticker_params
    params.require(:sticker).permit(:name, :description, :price, :image)
  end

  def cart_quantity(sticker_id)
    @cart ||= {} # Initialize @cart as an empty hash if it's nil
    @cart[sticker_id] || 0
  end

  def calculate_cart_total(cart_stickers, cart)
    cart_total = 0
    cart.each do |sticker_id|
      cart_sticker = cart_stickers.find { |sticker| sticker.id == sticker_id }
      next unless cart_sticker

      cart_total += cart_sticker.price
    end
    cart_total
  end

  def order_params
    params.require(:order).permit(:full_name, :email, :phone_number, :address)
  end
end
