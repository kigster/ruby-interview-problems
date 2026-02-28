# frozen_string_literal: true

module Tasks
  class Base
    attr_accessor :created_at, :due_at

    class << self
      attr_accessor :task_classes, :completion_time

      def inherited(task)
        self.task_classes ||= Set.new
        self.task_classes << task
      end
    end

    def initialize(created_at: Time.now)
      self.created_at = created_at
      self.due_at     = created_at + self.class.completion_time
    end

    def <=>(other)
      return nil unless other.is_a?(Tasks::Base)

      due_at <=> other.due_at
    end
  end

  class MessageResponse < Base
    self.completion_time = 30
  end

  class UpdatePrescription < Base
    self.completion_time = 20
  end
end

class TaskQueue
  attr_accessor :tasks, :mutex

  def initialize
    self.mutex = Mutex.new
    self.tasks = {}
    Tasks::Base.task_classes.each do |task|
      tasks[task] = []
    end
  end

  def push(task)
    mutex.synchronize do
      tasks[task.class] << task
    end
  end

  def next_task_for(employee)
    mutex.synchronize do
      task_types = employee.role.task_types

      filtered_tasks = task_types.map do |task_type|
        tasks[task_type]
      end

      filtered_tasks.flatten!.sort!
      filtered_tasks.first.tap do |task|
        tasks[task.class].delete(task)
      end
    end
  end
end

module Roles
  class BaseRole
    class << self
      attr_accessor :task_types
    end
  end
  # common methods

  class CustomerService < BaseRole
    self.task_types = [Tasks::MessageResponse]
  end

  class Pharmacist < BaseRole
    self.task_types = [Tasks::MessageResponse, Tasks::UpdatePrescription]
  end
end

class User
end

class Employee < User
  # belongs_to :role
  attr_accessor :role

  def initialize(role)
    self.role = role
  end
end

tq = TaskQueue.new

tq.push(Tasks::UpdatePrescription.new)
sleep 1
tq.push(Tasks::MessageResponse.new)
sleep 1
tq.push(Tasks::MessageResponse.new)
sleep 1

ph = Employee.new(Roles::Pharmacist)
cs = Employee.new(Roles::CustomerService)

# pp tq
puts "Next task for Customer Service"
pp tq.next_task_for(cs)

puts "Next task for Pharmacist"
pp tq.next_task_for(ph)
