# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'
require 'aasm'
require 'pp'
require 'colored2'

require 'cloud/kitchens/dispatch/types'
require 'cloud/kitchens/dispatch/order_struct'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class Order
        class << self
          def stateful_queues
            if @stateful_queues.nil?
              @stateful_queues = {}
              Order::STATES.each do |state|
                @stateful_queues[state] = Queue.new
              end
            end
            @stateful_queues
          end
        end

        extend Forwardable

        STATES = [:received,
                  :cooking,
                  :ready,
                  :picked_up,
                  :delivered,
                  :expired].freeze

        # @description Class that captures timings for all order states
        StateChangeTimeLog = Struct.new(*STATES)

        include ::AASM

        attr_reader :id,
                    :name,
                    :temperature,
                    :shelf_life,
                    :state_time_log,
                    :decay_rate

        attr_accessor :shelf

        def_delegators :@state_time_log, *STATES

        # @param [OrderStruct] order_struct
        def initialize(order_struct)
          @id          = order_struct.id
          @name        = order_struct.name
          @temperature = order_struct.temp
          # noinspection RubyResolve
          @shelf_life = order_struct.shelfLife.to_f
          # noinspection RubyResolve
          @decay_rate = order_struct.decayRate.to_f
          @state_time_log = StateChangeTimeLog.new(Time.now.to_f)
        end

        def update_state_change
          state_time_log.send("#{aasm.to_state}=", Time.now.to_f)
        end

        def order_value(shelf_decay_modifier = 1)
          (0.0 + shelf_life - age * decay_rate * shelf_decay_modifier).to_f / shelf_life
        end

        # @return [Float] number of seconds since the order has been received
        def age
          now - state_time_log.received
        end

        # @return [Float] EPOCH time as a floating point number
        def now
          Time.now.to_f
        end

        def to_s
          "Order<[#{id}] #{to_h.except('id')}>"
        end

        def color_inspect
          indent = "\n  "
          "\nOrder<[#{id}] "\
            "#{indent}id          ➔  #{id.green} " \
            "#{indent}name        ➔  #{(sprintf '%-20.20s', name).green} " \
            "#{indent}temp        ➔  #{(sprintf '%-5s', temperature).green} " \
            "#{indent}decay_rate  ➔  #{(sprintf '%05.2f', decay_rate).green} " \
            "#{indent}shelf_life  ➔  #{(sprintf '%03d', shelf_life).green} " \
            "#{indent}age(secs)   ➔  #{(sprintf '%04.2f', age).cyan}" \
            "#{indent}value       ➔  #{(sprintf '%04.2f', order_value).send(order_value > 0 ? :cyan : :red)}" \
            "#{indent}state       ➔  #{(sprintf '%-10s', aasm.current_state).yellow}" \
            "\n>"
        end

        def to_h
          {
            'id' => id,
            'name' => name,
            'shelfType' => temperature,
            'decay_rate' => decay_rate,
            'shelf_life' => shelf_life,
            'order_value' => order_value,
            'state' => aasm.current_state,
            'currentShelf' => shelf ? shelf.name : 'N/A',
          }
        end

        aasm do
          after_all_transitions :update_state_change

          state :received, initial: true
          state(*(STATES - [:received]))

          event :cook do
            transitions from: :received, to: :cooking
          end

          event :prepared do
            transitions from: :cooking, to: :ready
          end

          event :pick_up do
            transitions from: :ready, to: :picked_up
          end

          event :deliver do
            transitions from: :picked_up, to: :delivered
          end

          event :expire do
            transitions from: :ready, to: :expired
          end
        end
      end
    end
  end
end
