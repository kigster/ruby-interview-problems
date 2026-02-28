# frozen_string_literal: true

require 'json'
require_relative 'order'
require_relative 'shelf_manager'
require_relative 'courier'

class Kitchen
  attr_reader :shelf_manager, :couriers, :stats, :running

  def initialize(courier_count: 5)
    @shelf_manager = ShelfManager.new
    @couriers = Array.new(courier_count) { |i| Courier.new("courier-#{i + 1}") }
    @running = false
    @stats = {
      orders_received: 0,
      orders_cooked: 0,
      orders_ready: 0,
      orders_picked_up: 0,
      orders_delivered: 0,
      orders_expired: 0,
      orders_discarded: 0
    }
    @mutex = Mutex.new
  end

  def start(orders_file:, orders_per_second: 2.0)
    @running = true

    orders_data = load_orders(orders_file)
    puts "🍳 Kitchen starting with #{orders_data.length} orders at #{orders_per_second} orders/second"

    # Start background shelf update thread
    start_shelf_updater

    # Process orders at specified rate
    interval = 1.0 / orders_per_second

    orders_data.each_with_index do |order_data, index|
      break unless @running

      process_order(order_data)

      # Sleep between orders (except for the last one)
      if index < orders_data.length - 1
        sleep(interval)
      end
    end

    # Wait for all orders to be delivered or expired
    wait_for_completion

    @running = false
    display_final_stats
    puts "🏁 Kitchen simulation completed"
  end

  def stop
    @running = false
  end

  private

  def load_orders(file_path)
    JSON.parse(File.read(file_path))
  rescue StandardError => e
    puts "❌ Error loading orders from #{file_path}: #{e.message}"
    exit 1
  end

  def process_order(order_data)
    order = Order.new(order_data)

    log_event("📥 Order received", order)
    increment_stat(:orders_received)

    # Instantly cook the order
    order.cook!
    increment_stat(:orders_cooked)

    # Instantly ready the order
    order.ready!
    increment_stat(:orders_ready)

    # Place on shelf
    placement_result = @shelf_manager.place_order(order)
    handle_shelf_placement(order, placement_result)

    # Dispatch courier
    dispatch_courier(order) if order.state == :ready

    display_shelf_contents
  end

  def handle_shelf_placement(order, result)
    case result[:action]
    when :placed_on_temp_shelf
      log_event("🥶 Order placed on #{result[:shelf].temperature} shelf", order)
    when :placed_on_overflow
      log_event("📦 Order placed on overflow shelf", order)
    when :placed_on_overflow_after_move
      log_event("🔄 Moved order to temp shelf, placed new order on overflow", order)
      log_event("   ↳ Moved", result[:moved_order])
    when :placed_on_overflow_after_discard
      log_event("🗑️  Discarded random order, placed new order on overflow", order)
      log_event("   ↳ Discarded", result[:discarded_order])
      increment_stat(:orders_discarded)
    when :order_wasted
      log_event("💀 Order wasted - no shelf space", order)
      increment_stat(:orders_expired)
    end
  end

  def dispatch_courier(order)
    available_courier = @couriers.find { |c| c.state == :ready }

    if available_courier
      available_courier.assign_order(order)
      log_event("🚗 Courier #{available_courier.id} dispatched", order)

      # Start monitoring this order for pickup/delivery
      Thread.new do
        monitor_order_lifecycle(order)
      end
    else
      log_event("⏳ No available couriers", order)
    end
  end

  def monitor_order_lifecycle(order)
    # Wait for pickup
    while order.state == :ready && @running
      sleep(0.1)
    end

    return unless order.state == :picked_up

    log_event("📋 Order picked up", order)
    @shelf_manager.remove_order(order)
    increment_stat(:orders_picked_up)

    # Wait for delivery
    while order.state == :picked_up && @running
      sleep(0.1)
    end

    return unless order.state == :delivered

    log_event("✅ Order delivered", order)
    increment_stat(:orders_delivered)
  end

  def start_shelf_updater
    Thread.new do
      while @running
        sleep(1) # Update every second
        expired_count = @shelf_manager.update_all_shelves!
        next unless expired_count > 0

        increment_stat(:orders_expired, expired_count)
        puts "⚠️  #{expired_count} orders expired and removed from shelves"
        display_shelf_contents
      end
    end
  end

  def wait_for_completion
    puts "\n⏳ Waiting for all orders to complete..."

    loop do
      active_orders = @shelf_manager.all_orders.count { |o| [:ready, :picked_up].include?(o.state) }
      busy_couriers = @couriers.count { |c| c.state != :ready }

      break if active_orders == 0 && busy_couriers == 0

      sleep(0.5)
    end
  end

  def log_event(message, order = nil)
    timestamp = Time.now.strftime("%H:%M:%S.%L")
    if order
      puts "#{timestamp} #{message}: #{order}"
    else
      puts "#{timestamp} #{message}"
    end
  end

  def display_shelf_contents
    contents = @shelf_manager.shelf_contents
    puts "\n📊 Current shelf contents:"
    contents.each do |shelf_name, orders|
      capacity = shelf_name == 'overflow' ? 15 : 10
      puts "  #{shelf_name.capitalize}: #{orders.length}/#{capacity} - #{orders.map(&:name).join(', ')}"
    end
    puts ""
  end

  def display_final_stats
    puts "\n#{'=' * 50}"
    puts "📈 FINAL STATISTICS"
    puts "=" * 50
    @stats.each do |key, value|
      formatted_key = key.to_s.split('_').map(&:capitalize).join(' ')
      puts "  #{formatted_key}: #{value}"
    end
    puts "\n🏪 Final shelf state:"
    display_shelf_contents
  end

  def increment_stat(key, amount = 1)
    @mutex.synchronize do
      @stats[key] += amount
    end
  end
end
