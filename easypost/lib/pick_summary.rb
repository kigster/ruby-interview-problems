# frozen_string_literal: true

# andykram@easypost.com

module EasyPost
  class PickSummary
    Pick = Struct.new(:warehouse_id,
                      :worker_id,
                      :pick_id,
                      :type,
                      :timestamp,
                      :inventory_id,
                      :date) do
      def initialize(hash)
        super(
          hash[:warehouse_id],
            hash[:worker_id],
            hash[:pick_id],
            hash[:type],
            hash[:timestamp],
            hash[:inventory_id],
            Time.at(hash[:timestamp]).to_date
        )
      end

      def <=>(other)
        return nil unless other.is_a?(Pick)

        if warehouse_id == other.warehouse_id
          if date == other.date
            if worker_id == other.worker_id
              if pick_id == other.pick_id
                if type == other.type
                  inventory_id.nil? ? 0 : inventory_id <=> other.inventory_id
                elsif type == 'pick-start'
                  -1
                elsif type == 'pick-item'
                  0
                end
              else
                pick_id <=> other.pick_id
              end
            else
              worker_id <=> other.worker_id
            end
          else
            date <=> other.date
          end
        else
          warehouse_id <=> other.warehouse_id
        end
      end
    end

    attr_accessor :warehouse_id, :date, :data

    def initialize(warehouse_id, date, data = [])
      self.warehouse_id = warehouse_id
      self.date         = date
      self.data         = data.map { |item| Pick.new(item) }
                              .select { |item| item.warehouse_id == warehouse_id && item.date == date }
                              .sort
    end

    def result
      current_worker_id     = nil
      current_pick_start_at = 0
      current_pick_items_at = nil
      (data << nil).each_with_object({}) do |pick, hash|
        if pick.nil?
          if current_worker_id && current_pick_start_at && current_pick_items_at
            hash[current_worker_id] += current_pick_items_at - current_pick_start_at
          end

        else
          current_worker_id = pick.worker_id

          hash[pick.worker_id] ||= 0

          if pick.type == 'pick-start'
            if current_pick_items_at && current_pick_start_at
              hash[current_worker_id] += current_pick_items_at - current_pick_start_at
            end
            current_pick_start_at = pick.timestamp
            current_pick_items_at = nil
          else
            current_pick_items_at = pick.timestamp
          end
        end
      end
    end
  end
end
