# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################
require 'sequel'

module CodingActivityPollSchema

    Sequel::Model.db_polls.create_table?(:coding_activity_contexts_polls) {
      primary_key :id
      String   :province
      String   :city
      String   :school
      String   :class
      Float    :average_age
      Integer  :males
      Integer  :females
      Datetime :date_begin
      Datetime :date_end
      Datetime :created_on
      Datetime :updated_on
    }

    Sequel::Model.db_polls.create_table?(:coding_activity_teacher_skills_polls) {
      primary_key :id
      foreign_key :context_id, :coding_activity_contexts_polls
      Integer  :age
      String   :sex, :fixed => true, :size => 1
      String   :role
      Text     :knowledge
      Text     :training
      Text     :groups
      Datetime :created_on
      Datetime :updated_on
    }

    Sequel::Model.db_polls.create_table?(:coding_activity_projects_polls) {
      primary_key :id
      foreign_key :context_id, :coding_activity_contexts_poll
      Text     :goal
      Integer  :estimated_time_in_days
      Datetime :date_begin
      Datetime :date_end
      Text     :activity
      Text     :environments
      Text     :monitorings
      Text     :best_practices
      Datetime :created_on
      Datetime :updated_on
    }

    Sequel::Model.db_polls.create_table?(:coding_activity_ratings_polls) {
      primary_key :id
      foreign_key :context_id, :coding_activity_contexts_polls
      Text     :goals
      Text     :difficulties
      Text     :unexpected
      Text     :comments
      Text     :comments_teacher
      Datetime :created_on
      Datetime :updated_on
    }

    Sequel::Model.db_polls.create_table?(:coding_activity_futures_polls) {
      primary_key :id
      foreign_key :context_id, :coding_activity_contexts_polls
      TrueClass   :activities
      TrueClass   :products_reuse
      TrueClass   :sharing
      Datetime :created_on
      Datetime :updated_on
    }  

end
