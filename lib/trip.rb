require "csv"

require "time"

require_relative "csv_record"

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, :end_time, :cost, :rating, :driver_id, :driver

    def initialize(id:,
                   passenger: nil, passenger_id: nil,
                   start_time:, end_time:, cost: nil, rating:, driver_id: nil, driver: nil)
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id
      elsif passenger_id
        @passenger_id = passenger_id
      else
        raise ArgumentError, "Passenger or passenger_id is required"
      end

      @start_time = Time.parse(start_time)
      if end_time.nil?
        @end_time = nil
      else
        @end_time = Time.parse(end_time)
      end
      @cost = cost
      @rating = rating

      @driver_id = (driver && driver.id) || driver_id
      @driver = driver

      if (@driver_id.nil? && @driver.nil?)
        raise ArgumentError, "Driver or driver_id is required"
      end

      if !@end_time.nil? && @end_time < @start_time
        raise ArgumentError.new("End time before start time.")
      end
      if !@rating.nil? && (@rating > 5 || @rating < 1)
        raise ArgumentError.new("Invalid rating #{@rating}")
      end
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
      "ID=#{id.inspect} " +
      "PassengerID=#{passenger&.id.inspect}>"
    end

    def connect(passenger, driver)
      @passenger = passenger
      @driver = driver
      passenger.add_trip(self)
      driver.add_trip(self)
    end

    def duration
      duration = (@end_time - @start_time).to_i
      return duration
    end

    private

    def self.from_csv(record)
      return self.new(
               id: record[:id],
               passenger_id: record[:passenger_id],
               start_time: record[:start_time],
               end_time: record[:end_time],
               driver_id: record[:driver_id],
               cost: record[:cost],
               rating: record[:rating],
             )
    end
  end
end
