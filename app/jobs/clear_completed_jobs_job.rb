# frozen_string_literal: true

class ClearCompletedJobsJob < ApplicationJob
  queue_as :default

  def perform
    SolidQueue::Job.clear_finished_in_batches
  end
end
