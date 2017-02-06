# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module Database

  Sequel::Model.plugin(:schema)
  Sequel::Model.plugin(:boolean_readers)
  Sequel::Model.plugin(:validation_helpers)
  Sequel::Model.plugin(:timestamps, :update_on_create => true, :create => :created_on, :update => :updated_on)
  Sequel::Model.raise_on_save_failure = false 

  class Sequel::Model

    def self.db_polls
      @db_polls
    end
    
    def self.db_polls=(db)
      @db_polls = db
    end
    
    def validate_date(date)
      unless values[date].blank?
        begin
          DateTime.parse(values[date]) if values[date].is_a?(String)
        rescue
          errors.add(date, I18n.t(:invalid_date))
        end
      end
    end
    
  end

  def self.connect_db_polls    
    name = "codingmonamour.polls.db"
    Sequel::Model.db_polls = Sequel.connect("sqlite://" + File.join(DB_FOLDER, name),  :loggers => [Logger.new(File.join(LOG_FOLDER, "${name}.log"))]) unless Sequel::Model.db_polls
  end
  connect_db_polls 

  def self.disconnect_db_polls
    Sequel::Model.db_polls.disconnect
    Sequel::Model.db_polls = nil
  end

  require 'schemas/coding_activity_poll'
  include CodingActivityPollSchema


  require 'models/coding_activity_poll'

end



