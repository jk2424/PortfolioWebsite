class PagesController < ApplicationController
  before_action :authorize, only: [:secret]

  FROM  = "1 washington avenue, Miami Beach, FL"

  def new
    @amount = current_order.subtotal * 100 #+ @quote.fee



    # from_lat = "37.778307"
    # from_lon = "-122.413524"
    # to_lat = "37.778307"
    # to_lon = "-122.413524"
    # @quote = $client.quote(pickup_latitude: from_lat, pickup_longitude: from_lon, dropoff_latitude: to_lat, dropoff_longitude: to_lon)

    package = {
                :manifest => "a box of kittens",
                :pickup_name => "The Warehouse",
                :pickup_address => "1 Ocean Drive, Miami Beach, FL",
                :pickup_phone_number => "415-555-1234",
                # :pickup_business_name => "Optional Pickup Business Name, Inc.",
                :pickup_notes => "Optional note that this is Invoice #123",
                :dropoff_name => "Alice",
                :dropoff_address => "1 washington avenue, Miami Beach, FL, FL",
                :dropoff_phone_number => "415-555-1234", # params[:drop_phone]
                # :dropoff_business_name => "Optional Dropoff Business Name, Inc.",
                :dropoff_notes => "Optional note to ring the bell",
                # :quote_id => @quote.id #"dqt_K9LFfpSZCdAJsk"
              }

      @delivery = $client.create(package)

  end

  def create
    # Amount in cents
    # @amount =

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'usd'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end


  def show
    @order_items = current_order.order_items
  end

  def buildbox
    def create
      @order = current_order
      @order.status = OrderStatus.in_progress.id
      @order_item = @order.order_items.new(order_item_params)
      @order.save
      session[:order_id] = @order.id
    end

    def update
      @order = current_order
      @order_item = @order.order_items.find(params[:id])
      @order_item.update_attribute(:orderitems_quantity, order_item_params[:orderitems_quantity])
    end




  end
  def index
    @products = Product.all
    @order_item = current_order.order_items.new
  end
  private

  def get_quote
    to  = "1 Ocean Drive, Miami Beach, FL" #params[:delivery_address]
    @quote = $client.quote(pickup_address: FROM, dropoff_address: to)
  end

  def order_item_params
    params.require(:order_item).permit(:orderitems_quantity, :product_id)
  end

end
